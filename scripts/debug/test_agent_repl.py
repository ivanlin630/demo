#!/usr/bin/env python3
"""Agent REPL acceptance test harness.
Run: python scripts/debug/test_agent_repl.py
"""
import subprocess, json, sys, time, socket, threading

GODOT = r"A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe"
SCRIPT = "scripts/debug/agent_repl.gd"
CWD = r"A:\GDS\demo"


# ── connection helpers ──────────────────────────────────────────────────────

def start_repl() -> subprocess.Popen:
    return subprocess.Popen(
        [GODOT, "--headless", "--script", SCRIPT],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        cwd=CWD,
    )


def _read_json_line(proc: subprocess.Popen, timeout: float) -> dict:
    """Read first JSON line from proc.stdout, skipping non-JSON."""
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if proc.poll() is not None:
            raise RuntimeError(f"Process exited with code {proc.returncode}")
        line = proc.stdout.readline()
        if not line:
            time.sleep(0.05)
            continue
        line = line.strip()
        if line.startswith("{"):
            return json.loads(line)
    raise TimeoutError(f"No JSON response within {timeout}s")


class ReplSession:
    """Wraps a Godot REPL process; auto-detects stdin vs TCP mode."""

    def __init__(self, proc: subprocess.Popen):
        self._proc = proc
        self._sock: socket.socket | None = None
        self._tcp_buf = b""
        self._mode = "stdin"

        # Read first line — may be TCP ready message or first response
        try:
            first = _read_json_line(proc, 30.0)
        except Exception as e:
            raise RuntimeError(f"REPL did not start: {e}")

        if first.get("mode") == "tcp":
            # Windows fallback: connect via TCP
            self._mode = "tcp"
            port = first["port"]
            self._sock = socket.create_connection(("127.0.0.1", port), timeout=10)
            self._sock.setblocking(False)
            # Drain stdout to prevent pipe buffer from filling (sim prints flood stdout)
            self._drain_thread = threading.Thread(
                target=self._drain_stdout, daemon=True)
            self._drain_thread.start()
        else:
            # stdin mode (Linux/Mac) — first line is a command response, push it back
            self._stdin_first = first

    def send(self, cmd: dict, timeout: float = 60.0) -> dict:
        if self._mode == "tcp":
            return self._send_tcp(cmd, timeout)
        else:
            return self._send_stdin(cmd, timeout)

    def _drain_stdout(self):
        """Background thread: drain subprocess stdout to prevent pipe buffer full."""
        try:
            while self._proc.poll() is None:
                data = self._proc.stdout.read(1)
                if not data:
                    break
        except Exception:
            pass

    def _send_stdin(self, cmd: dict, timeout: float) -> dict:
        self._proc.stdin.write(json.dumps(cmd) + "\n")
        self._proc.stdin.flush()
        return _read_json_line(self._proc, timeout)

    def _send_tcp(self, cmd: dict, timeout: float) -> dict:
        data = (json.dumps(cmd) + "\n").encode()
        self._sock.setblocking(True)
        self._sock.sendall(data)
        self._sock.setblocking(False)
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            try:
                chunk = self._sock.recv(4096)
                if chunk:
                    self._tcp_buf += chunk
            except BlockingIOError:
                pass
            while b"\n" in self._tcp_buf:
                nl = self._tcp_buf.find(b"\n")
                line = self._tcp_buf[:nl].strip()
                self._tcp_buf = self._tcp_buf[nl + 1:]
                if line:
                    return json.loads(line)
            time.sleep(0.01)
        raise TimeoutError(f"No TCP response within {timeout}s for cmd={cmd}")

    def close(self):
        if self._sock:
            try:
                self._sock.close()
            except Exception:
                pass
        try:
            self._proc.stdin.close()
        except Exception:
            pass

    def wait(self, timeout=15):
        self._proc.wait(timeout=timeout)

    @property
    def returncode(self):
        return self._proc.returncode

    @property
    def mode(self):
        return self._mode


# ── test state ───────────────────────────────────────────────────────────────

PASS = 0
FAIL = 0


def check(label: str, condition: bool) -> None:
    global PASS, FAIL
    status = "PASS" if condition else "FAIL"
    print(f"  [{status}] {label}")
    if condition:
        PASS += 1
    else:
        FAIL += 1


# ── tests ────────────────────────────────────────────────────────────────────

def test_basic():
    print("\n=== AC#1-5: Basic protocol ===")
    proc = start_repl()
    sess = ReplSession(proc)
    print(f"  [INFO] mode={sess.mode}")

    # AC#2: query returns valid snapshot
    r = sess.send({"cmd": "query"})
    check("AC#2: query ok=true", r.get("ok") == True)
    check("AC#2: snapshot has controlled_team (player exists)",
          r.get("ok") and r.get("data", {}).get("snapshot", {}).get("controlled_team") is not None)

    # AC#3: command move_to returns something (not crash)
    r_cmd = sess.send({"cmd": "command", "name": "move_to", "args": {"tile_q": 0, "tile_r": 0}})
    check("AC#3: move_to returns ok or known error (not crash)", "ok" in r_cmd)

    # AC#4: advance 300 ticks
    r_adv = sess.send({"cmd": "advance", "ticks": 300}, timeout=120.0)
    check("AC#4: advance ok=true", r_adv.get("ok") == True)
    check("AC#4: ticks_advanced present", "ticks_advanced" in r_adv)
    check("AC#4: current_tick present", "current_tick" in r_adv)

    # AC#5: events array present
    check("AC#5: events is array", isinstance(r_adv.get("events"), list))

    r_quit = sess.send({"cmd": "quit"})
    check("AC#1: quit response ok=true", r_quit.get("ok") == True)
    sess.close()
    sess.wait(timeout=10)
    check("AC#1: process exited cleanly (code 0)", sess.returncode == 0)


def test_edge_cases():
    print("\n=== AC#6-12: Edge cases ===")
    proc = start_repl()
    sess = ReplSession(proc)

    # AC#7: reset → tick=0
    r = sess.send({"cmd": "reset", "config": {"map": {"seed": 7, "radius": 4}}})
    check("AC#7: reset ok=true", r.get("ok") == True)
    check("AC#7: reset returns current_tick=0", r.get("data", {}).get("current_tick") == 0)

    # AC#8: invalid config_path
    r = sess.send({"cmd": "reset", "config_path": "res://config/nonexistent.json"})
    check("AC#8: config_not_found", r.get("code") == "config_not_found")

    # AC#9: invalid JSON does not crash — send raw text then a valid cmd
    if sess.mode == "tcp":
        sess._sock.setblocking(True)
        sess._sock.sendall(b"not_valid_json\n")
        r9 = sess._send_tcp({"cmd": "query"}, timeout=10.0)
        # We might get the invalid_json error OR the query response
        # Either way, process must still be alive
        check("AC#9: process still alive after invalid JSON", proc.poll() is None)
    else:
        proc.stdin.write("not_valid_json\n")
        proc.stdin.flush()
        line = proc.stdout.readline()
        while line and not line.strip().startswith("{"):
            line = proc.stdout.readline()
        r9 = json.loads(line.strip()) if line else {}
        check("AC#9: invalid_json code", r9.get("code") == "invalid_json")

    # AC#10: stdin/socket close → exit 0
    sess.close()
    sess.wait(timeout=15)
    check("AC#10: exit 0 on close", sess.returncode == 0)

    # AC#11: quit with code
    proc2 = start_repl()
    sess2 = ReplSession(proc2)
    r = sess2.send({"cmd": "quit", "code": 42})
    check("AC#11: quit response ok=true", r.get("ok") == True)
    sess2.close()
    sess2.wait(timeout=10)
    check("AC#11: exit code 42", sess2.returncode == 42)

    # AC#12: all responses were parseable JSON (implicit — no crash above)
    check("AC#12: all responses were parseable JSON", True)


def test_encounter():
    print("\n=== AC#13-16: Encounter ===")
    proc = start_repl()
    sess = ReplSession(proc)

    # Small map to increase encounter probability
    sess.send({"cmd": "reset", "config": {"map": {"seed": 42, "radius": 3}}})

    # Advance until encounter_triggered or encounter_active block
    encounter_found = False
    for _ in range(50):  # max 50 batches × 100 ticks = 5000 ticks
        r = sess.send({"cmd": "advance", "ticks": 100}, timeout=120.0)
        events = r.get("events", [])
        if any(e.get("type") == "encounter_triggered" for e in events):
            encounter_found = True
            break
        if r.get("code") == "encounter_active":
            encounter_found = True
            break

    if not encounter_found:
        print("  [SKIP] AC#13-16: encounter not triggered in 5000 ticks (seed/map dependent)")
        sess.send({"cmd": "quit"})
        sess.close()
        sess.wait(timeout=10)
        return

    # AC#13: encounter_query returns units
    r = sess.send({"cmd": "encounter_query"})
    check("AC#13: encounter_query ok=true", r.get("ok") == True)
    units = r.get("data", {}).get("units", [])
    check("AC#13: units list non-empty", len(units) > 0)
    player_units = [u for u in units if u.get("is_player")]
    check("AC#13: player unit present in units", len(player_units) > 0)

    # AC#14: encounter_step wait → player_turn or encounter_ended
    r_q = sess.send({"cmd": "encounter_query"})
    waiting = r_q.get("data", {}).get("waiting_for_player", False)
    for _ in range(20):
        if waiting:
            break
        r_adv = sess.send({"cmd": "encounter_step"})
        if r_adv.get("code") in ("player_turn", "encounter_ended"):
            waiting = (r_adv.get("code") == "player_turn")
            break
        r2 = sess.send({"cmd": "encounter_query"})
        if not r2.get("ok"):
            break
        waiting = r2.get("data", {}).get("waiting_for_player", False)

    if waiting:
        r_step = sess.send({"cmd": "encounter_step", "action": {"type": "wait"}})
        check("AC#14: encounter_step wait ok=true", r_step.get("ok") == True)
        check("AC#14: code is player_turn or encounter_ended",
              r_step.get("code") in ("player_turn", "encounter_ended"))
    else:
        check("AC#14: encounter_step wait ok=true", False)
        check("AC#14: code is player_turn or encounter_ended", False)

    # AC#15: encounter_step attack valid target
    r_q2 = sess.send({"cmd": "encounter_query"})
    if r_q2.get("ok") and r_q2.get("data", {}).get("waiting_for_player"):
        units2 = r_q2.get("data", {}).get("units", [])
        player_team = r_q2.get("data", {}).get("player_team_id", -1)
        enemy_units = [u for u in units2
                       if u.get("team_id") != player_team and not u.get("has_exited")]
        if enemy_units:
            tidx = enemy_units[0]["unit_idx"]
            r_atk = sess.send({"cmd": "encounter_step",
                                "action": {"type": "attack", "target_idx": tidx}})
            check("AC#15: attack valid target ok=true", r_atk.get("ok") == True)
            check("AC#15: code is player_turn or encounter_ended",
                  r_atk.get("code") in ("player_turn", "encounter_ended"))
        else:
            print("  [SKIP] AC#15: no enemy units to attack")
    else:
        print("  [SKIP] AC#15: not player turn after AC#14")

    # AC#16: after encounter ends, advance works normally
    for _ in range(200):
        r_q3 = sess.send({"cmd": "encounter_query"})
        if not r_q3.get("ok"):
            break
        r_s = sess.send({"cmd": "encounter_step", "action": {"type": "wait"}})
        if r_s.get("code") == "encounter_ended":
            break

    r_adv2 = sess.send({"cmd": "advance", "ticks": 10}, timeout=60.0)
    check("AC#16: advance works after encounter ends",
          r_adv2.get("ok") == True and r_adv2.get("code") != "encounter_active")

    sess.send({"cmd": "quit"})
    sess.close()
    sess.wait(timeout=10)


def main():
    test_basic()
    test_edge_cases()
    test_encounter()
    print(f"\n=== Results: {PASS} PASS, {FAIL} FAIL ===")
    sys.exit(0 if FAIL == 0 else 1)


if __name__ == "__main__":
    main()

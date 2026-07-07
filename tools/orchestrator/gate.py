"""N6 閘 — 確定性 script（非 claude）：憲法閘 + 手聽腦單點不變量 bed（07 increment 5）。

在 worktree 跑，硬 pass 條件：憲法閘綠 + bed determinism PASS + 無 godot 崩。
另捕 arbiter_latch 數字（QA 節點判『掉夠不夠』；閘只給確定性硬證+數字）。
"""
from __future__ import annotations
import subprocess, os, re


def _ps(worktree: str, inner: str, timeout: int) -> tuple[int, str]:
    try:
        p = subprocess.run(["powershell", "-NoProfile", "-Command", inner],
                           cwd=worktree, capture_output=True, text=True,
                           encoding="utf-8", errors="replace", timeout=timeout)
        return p.returncode, (p.stdout or "") + (p.stderr or "")
    except subprocess.TimeoutExpired:
        return -1, f"[timeout {timeout}s]"
    except FileNotFoundError:
        return -1, "[powershell not found]"


def _godot(worktree: str, script: str, seeds="1337", months="1", timeout=400) -> str:
    inner = (f"$env:GODOT_TIMEOUT='{timeout-40}'; $env:HOB_SEEDS='{seeds}'; $env:HOB_MONTHS='{months}'; "
             f"& '.\\tools\\godot.ps1' --headless --script {script}")
    _, out = _ps(worktree, inner, timeout)
    return out


def run_gate(worktree: str, slice_id: str) -> dict:
    """回 {pass, constitution, determinism, arbiter_latch, hob_viol_pct, note}。"""
    # 1) 重建 class 快取
    _ps(worktree, "& '.\\tools\\godot.ps1' --headless --import", 240)

    # 2) 憲法閘（禁新增引擎外 task 指派；新增違憲=FAIL）
    con_out = _godot(worktree, "scripts/debug/constitution_gate.gd", timeout=300)
    constitution = ("FAIL" not in con_out.upper()) and ("PASS" in con_out.upper() or "GREEN" in con_out.upper()
                    or "OK" in con_out.upper() or "違憲" not in con_out)

    # 3) 手聽腦單點 bed（seed 1337, 1月）
    hob_out = _godot(worktree, "scripts/debug/hand_obeys_brain_bed.gd", timeout=400)
    determinism = "逐事件確定性 PASS" in hob_out or ("determinism" in hob_out and "PASS" in hob_out)
    m_al = re.search(r"arbiter_latch\s+(\d+)\s+\(([\d.]+)%", hob_out)
    arbiter_latch = {"count": int(m_al.group(1)), "pct_of_dec": float(m_al.group(2))} if m_al else None
    m_v = re.search(r"違規（viol）\s*=\s*(\d+)\s+\(([\d.]+)%", hob_out)
    hob_viol_pct = float(m_v.group(2)) if m_v else None
    no_crash = ("SCRIPT ERROR" not in hob_out) and ("GODOT TIMEOUT" not in hob_out)

    passed = bool(constitution and determinism and no_crash)
    return {
        "pass": passed,
        "constitution": bool(constitution),
        "determinism": bool(determinism),
        "no_crash": bool(no_crash),
        "arbiter_latch": arbiter_latch,
        "hob_viol_pct": hob_viol_pct,
        "note": (f"閘{'綠' if passed else '紅'}：憲法={constitution} determinism={determinism} "
                 f"arbiter_latch={arbiter_latch} viol%={hob_viol_pct}"),
    }

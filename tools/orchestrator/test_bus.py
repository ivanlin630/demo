"""increment 2 單元測試：git-handback bus 純函式（無 claude 呼叫，確定性）。

跑：python tools/orchestrator/test_bus.py
"""
import sys, tempfile, os
try: sys.stdout.reconfigure(encoding="utf-8"); sys.stderr.reconfigure(encoding="utf-8")
except Exception: pass
import bus


def main():
    repo = tempfile.mkdtemp(prefix="bus_test_")
    fails = []

    def check(name, cond):
        print(f"  [{'PASS' if cond else 'FAIL'}] {name}")
        if not cond:
            fails.append(name)

    # handback 生命週期
    p = bus.write_handback("systems", "implementer", "A1a 拆閥 spec",
                           "body: `>`→`>=` source-gate.", date="2026-07-07", repo=repo)
    check("handback 檔建立", os.path.exists(p))

    inbox = bus.read_open("implementer", repo=repo)
    check("read_open 收到", len(inbox) == 1 and inbox[0].frm == "systems")
    check("topic 解析", inbox and inbox[0].topic == "A1a 拆閥 spec")
    check("body 解析", inbox and "source-gate" in inbox[0].body)

    check("別角色收不到", len(bus.read_open("qa", repo=repo)) == 0)

    bus.consume(p)
    check("consume 後 read_open 空", len(bus.read_open("implementer", repo=repo)) == 0)
    check("consume 不刪檔", os.path.exists(p))
    check("status 真的變 consumed", "status: consumed" in open(p, encoding="utf-8").read())

    # verdict roundtrip
    v = {"verdict": "clean", "premise_contradiction": False, "issues": []}
    bus.write_verdict("A1a", "factcheck", v, repo=repo)
    got = bus.read_verdict("A1a", "factcheck", repo=repo)
    check("verdict roundtrip", got == v)
    check("缺 verdict 回 None", bus.read_verdict("A1a", "review", repo=repo) is None)

    # metrics append
    bus.log_metric({"slice": "A1a", "node": "factcheck", "found_issue": False}, repo=repo)
    bus.log_metric({"slice": "A1a", "node": "review", "found_issue": True}, repo=repo)
    mpath = os.path.join(repo, bus.METRICS_PATH)
    lines = open(mpath, encoding="utf-8").read().strip().splitlines()
    check("metrics append 兩行", len(lines) == 2)

    print(f"\n===== {'PASS' if not fails else 'FAIL: ' + ', '.join(fails)} =====")
    sys.exit(0 if not fails else 1)


if __name__ == "__main__":
    main()

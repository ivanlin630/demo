"""「決定 vs 結果分開講」那張票的負對照 —— 判決委派 negative_control（共用）。

用法（工作區要乾淨）：
    python scripts/debug/decision_vs_outcome_controls.py

★expect 從【床自己的輸出】抄。★★兩道控制各跑一次床（約 15 秒／次）。
"""
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import negative_control as nc   # noqa: E402

BED = 'scripts/debug/decision_vs_outcome_bed.gd'
BANNER = 'decision_vs_outcome DONE ==='
PCS = 'scripts/simulation/player_command_system.gd'
RUN = 'scripts/simulation/sim_runner.gd'

# ①把「分開講」那一段拿掉 ⇒ msg 回到只有【世界的結果】⇒ P1 的「你選了」那一格必紅
SPLIT_OLD = '''	if not bool(result.get("ok", false)) and not bool(result.get("silent", false)):
		var _why: String = String(result.get("msg", ""))
		if _why != "" and _label_pre != "":
			result["msg"] = "你選了「%s」，但%s ⇒ 沒有生效" % [_label_pre, _why]'''
SPLIT_NEW = '''	if false:
		pass'''

# ②把 sim_runner 的具名例外拿掉 ⇒ respond_to_forced 的失敗句又被套上「被拒絕」
#   ⇒ P1 的「不得說被拒絕」那一格＋P2 的「沒有任何組合把決定說成別的決定」都必紅
WRAP_OLD = '''	if name == "respond_to_forced":
		return "%s：%s" % [head, reason]'''
WRAP_NEW = '''	if false:
		return ""'''

CONTROLS = [
    ('①拿掉「分開講」', '你選了', (PCS, SPLIT_OLD, SPLIT_NEW)),
    ('②拿掉 sim_runner 的具名例外', '不得】說「被拒絕」', (RUN, WRAP_OLD, WRAP_NEW)),
]


def patch(payload):
    f, old, new = payload
    src = open(f, encoding='utf-8').read()
    if src.count(old) != 1:
        return False
    open(f, 'w', encoding='utf-8', newline='\n').write(src.replace(old, new))
    return True


def restore(payload):
    f = payload[0]
    subprocess.run(['git', 'checkout', 'HEAD', '--', f], check=True)
    left = subprocess.run(['git', 'diff', '--name-only', '--', f],
                          capture_output=True, text=True).stdout.strip()
    assert left == '', 'restore failed: ' + left


def run(_payload):
    env = nc.child_env(PYTHONIOENCODING='utf-8', GODOT_TIMEOUT='180')
    r = subprocess.run(['powershell', '-NoProfile', '-File', './tools/godot.ps1',
                        '--headless', '--script', BED],
                       capture_output=True, text=True, encoding='utf-8',
                       errors='replace', env=env, timeout=900)
    return r.stdout + r.stderr


if __name__ == '__main__':
    dirty = subprocess.run(['git', 'status', '--porcelain'],
                           capture_output=True, text=True).stdout.strip()
    if dirty:
        print('[decision-vs-outcome-controls] 工作區不乾淨 ⇒ 中止:\n' + dirty)
        sys.exit(2)
    sys.exit(1 if nc.run_batch(CONTROLS, run, BANNER, patch, restore) else 0)

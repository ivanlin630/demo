"""玩家面字串那張票的負對照 —— 判決委派 negative_control（共用）。

用法（工作區要乾淨；★改動要先 commit 再跑）：
    python scripts/debug/player_facing_strings_controls.py
"""
import os
import subprocess
import sys

# ★import 之前先關掉 bytecode：否則 `import negative_control` 會生出 __pycache__/
#   ⇒ 自己把工作區弄髒 ⇒ 自己的「工作區要乾淨」那道檢查把自己擋掉（2026-10-01 實測）。
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import negative_control as nc   # noqa: E402

BED = 'scripts/debug/scripted_exploration_bed.gd'
BANNER = 'scripted_exploration DONE ==='
API = 'scripts/simulation/player_command_api.gd'
MAP = 'scripts/simulation/player_api_mapper.gd'

# ①把 describe() 的 action_id 改回【原樣印】⇒ (d) 那一族整批回來
#   ★expect 挑 (d) 的成因欄那一行（床印出「N 筆 ← describe() 把參數原樣印給玩家」）
RAW_OLD = '''		"execute_action":
			return "%s：%s" % [verb, PlayerApiMapper.action_label(
				String(args.get("action_id", "")))]'''
RAW_NEW = '''		"execute_action":
			return "%s：%s" % [verb, String(args.get("action_id", ""))]'''

# ②把一個動詞的中文 label 拿掉 ⇒ P11（母體覆蓋）必紅並把名字印出來
LABEL_OLD = '\t\t"build_facility":         return "蓋設施"'
LABEL_NEW = '\t\t# （這一行被拿掉了）'

CONTROLS = [
    # ★expect 指 P12 而不是 (d) 的成因行：本床平常是【清單】不是判官，
    #   成因那一行只是 print ⇒ 擾動它不會讓床紅。P12 才是那條不變量的斷言。
    #   ★★而我第一輪就是指錯了（報 NOT-RED 而它其實紅在 P12）—— 同一族第四次。
    ('①describe() 改回原樣印 action_id', '玩家面字串零英文識別字', (API, RAW_OLD, RAW_NEW)),
    ('★②拿掉一個動詞的中文 label', '每一個 action id 都有中文 label', (MAP, LABEL_OLD, LABEL_NEW)),
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
    subprocess.run(['git', 'checkout', 'HEAD', '--', 'docs/measurements/'], check=False)
    left = subprocess.run(['git', 'diff', '--name-only', '--', f],
                          capture_output=True, text=True).stdout.strip()
    assert left == '', 'restore failed: ' + left


def run(_payload):
    env = nc.child_env(PYTHONIOENCODING='utf-8', GODOT_TIMEOUT='300')
    r = subprocess.run(['powershell', '-NoProfile', '-File', './tools/godot.ps1',
                        '--headless', '--script', BED],
                       capture_output=True, text=True, encoding='utf-8',
                       errors='replace', env=env, timeout=1200)
    return r.stdout + r.stderr


if __name__ == '__main__':
    dirty = subprocess.run(['git', 'status', '--porcelain'],
                           capture_output=True, text=True).stdout.strip()
    if dirty:
        print('[player-facing-strings-controls] 工作區不乾淨 ⇒ 中止:\n' + dirty)
        sys.exit(2)
    sys.exit(1 if nc.run_batch(CONTROLS, run, BANNER, patch, restore) else 0)

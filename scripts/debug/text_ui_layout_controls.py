"""版面 v2 的負對照 —— 判決委派 negative_control（共用）。

用法（工作區要乾淨；★改動要先 commit 再跑，否則還原會把未 commit 的改動一起帶走）：
    python scripts/debug/text_ui_layout_controls.py

★★★目前三道，各打一件不同的事（spec §3 P3／§6②／藍圖④′ 的字母鍵條件）：
  ①寬度算法本身（P3b 的 2N+M 定樁）②`120` 只有一份（P3a）
★★而 ① 是 §6② 換掉 P3 的全部理由：一個永遠回 `length()` 的實作
  **會通過原本那道 COLS 擾動測試** ⇒ 只有定樁那一格咬得到它。
★expect 逐字抄自實測紅那一行（不是從 spec 或斷言格式推）。
"""
import os
import subprocess
import sys

# ★import 之前先關掉 bytecode：否則 `import negative_control` 會生出 __pycache__/
#   ⇒ 自己把工作區弄髒 ⇒ 自己的「工作區要乾淨」那道檢查把自己擋掉（2026-10-01 實測）。
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import negative_control as nc   # noqa: E402

BED = 'scripts/debug/text_ui_layout_bed.gd'
BANNER = 'text_ui_layout DONE ==='
LAY = 'scripts/ui/text_ui_layout.gd'
VIEW = 'scripts/ui/text_ui_view.gd'

# ①★把 display_width 換成 `length()` ⇒ P3b 的 2N+M 定樁必紅
#   ★這一道就是 reviewer 推演出來的那個洞：它【通得過】COLS 擾動測試。
WIDTH_OLD = '''	var w: int = 0
	for i in range(s.length()):
		w += char_width(s.unicode_at(i))
	return w'''
WIDTH_NEW = '''	return s.length()'''

# ②在別處再寫一次 120 ⇒ P3a 必紅
DUP_OLD = 'const COLS: int = 120'
DUP_NEW = 'const COLS: int = 120\nconst _DUP_WIDTH: int = 120'

# ★★★③把字母改成【由位置決定】⇒ P8b 必紅
#   ★那正是不變量 #10 的病：意義由位置／計數決定
#   （`trade` 一旦不可做，`[B]` 就換了意思）。
POS_OLD = '''		var key: String = String(ACTION_LETTERS.get(aid, ""))'''
POS_NEW = '''		var key: String = char(65 + lines.size() - 1)'''

CONTROLS = [
    ('★①display_width 換成 length()', '每一個案例都精確等於 2N+M（不符的：["純全形（期望 10 實得 5）"',
     (LAY, WIDTH_OLD, WIDTH_NEW)),
    ('★★★③字母改成由位置決定', '拿到同一個字母（不一致：3）', (VIEW, POS_OLD, POS_NEW)),
    ('②別處再寫一次 120', '恰好 1 次（在 `TextUiLayout.COLS` 宣告處，實測 2）',
     (LAY, DUP_OLD, DUP_NEW)),
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
    env = nc.child_env(PYTHONIOENCODING='utf-8', GODOT_TIMEOUT='300')
    r = subprocess.run(['powershell', '-NoProfile', '-File', './tools/godot.ps1',
                        '--headless', '--script', BED],
                       capture_output=True, text=True, encoding='utf-8',
                       errors='replace', env=env, timeout=900)
    return r.stdout + r.stderr


if __name__ == '__main__':
    dirty = subprocess.run(['git', 'status', '--porcelain'],
                           capture_output=True, text=True).stdout.strip()
    if dirty:
        print('[text-ui-layout-controls] 工作區不乾淨 ⇒ 中止:\n' + dirty)
        sys.exit(2)
    sys.exit(1 if nc.run_batch(CONTROLS, run, BANNER, patch, restore) else 0)

"""動作全列＋原因那張票的負對照 —— 判決委派 negative_control（共用）。

用法（工作區要乾淨；★改動要先 commit 再跑，否則還原會把未 commit 的改動一起帶走）：
    python scripts/debug/available_actions_controls.py

★★★七道控制分別打【七件不同的事】，而每一道都指名它會紅在哪一格：
  ①名字的來源（P1c）②條件的唯一持有者（P7）③原因非空（P2）
  ④【行為證】宣告過的入口寫一個欄位（P9）⑤【反向掃】把一個宣告拿掉（P10 必須指名它）
  ⑥label 的生產搬回信封那一側（P11 唯一生產者）
  ★★⑦抽取式的範圍限定拿掉 ⇒ 多吞 ⇒ 那條【反方向】的地板必紅
★★而原本的④「具名排除拿掉」已【下架】：排除清單現在是空的（systems 裁 2026-10-01
  維持「機制接電＋清單暫空」）⇒ 它沒有母體可打 ⇒ 床裡那一行留著刪節線與理由，
  ★清單一有名字就把它加回來。
★而 systems 交代的那條：expect 要從【床自己的輸出】抄，不從 spec 抄。
"""
import os
import subprocess
import sys

# ★import 之前先關掉 bytecode：否則 `import negative_control` 會生出 __pycache__/
#   ⇒ 自己把工作區弄髒 ⇒ 自己的「工作區要乾淨」那道檢查把自己擋掉（2026-10-01 實測）。
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import negative_control as nc   # noqa: E402

BED = 'scripts/debug/available_actions_bed.gd'
BANNER = 'available_actions DONE ==='
PCS = 'scripts/simulation/player_command_system.gd'
QRY = 'scripts/simulation/player_query_api.gd'
BED_F = 'scripts/debug/available_actions_bed.gd'   # ★床自己也可以是擾動對象（抽取式在床裡）

# ①★把母體換成【另一份手抄的名字陣列】（＝reviewer 想到的第三種騙法）
#   ⇒ 行為格（P1）會照樣綠（名字剛好同步），而 P1c 的靜態互證必須紅。
NAMES_OLD = '\tfor name in TEAM_TARGET_ACTIONS:'
NAMES_NEW = ('\tfor name in ["ignore", "attack", "trade", "propose_alliance", "demand_tribute",\n'
             '\t\t\t"extort", "recruit", "recruit_anon", "invite_settle", "gather_intel", "beg"]:')

# ②★把一個條件複製回查詢面（＝這張票刪掉的那個病復發）⇒ P7 必紅
DUP_OLD = '''	# move_to (cursor set)'''
DUP_NEW = '''	# （負對照：把條件複製回查詢面）
	if focus_team_id != -1 and state.teams.has(focus_team_id):
		var _dup_pt: TeamData = state.teams.get(state.get_player_team_id())
		var _dup_tg: TeamData = state.teams.get(focus_team_id)
		if _dup_pt != null and _dup_tg != null and _dup_pt.readiness >= 0.7:
			pass
	# move_to (cursor set)'''

# ③把某一條的原因字串清空（enabled 仍 false）⇒ P2 必紅
REASON_OLD = '''						why = "準備值不足（需 ≥ 0.7，現為 %.1f）" % pt.readiness'''
REASON_NEW = '''						why = ""'''

# ④★【行為證】讓一個【宣告過的入口】寫一個欄位 ⇒ P9 必紅
#   ★這一道打的是 systems 裁的 (b)：宣告若只是一句話，沒有東西在驗它真的不改世界。
PURE_OLD = '''	var options: Array = InquirySystem.new().get_options(state, pt, tgt_gi)'''
PURE_NEW = '''	pt.readiness = 0.123   # （負對照：入口寫了一個欄位）
	var options: Array = InquirySystem.new().get_options(state, pt, tgt_gi)'''

# ⑤★★★【反向掃】把一個宣告拿掉 ⇒ P10 必須【指名】它（systems 裁的 (c)）
#   ★這一道打的是「漏宣告是靜默的」那一半 —— 2026-10-01 漏掉的那一個就是 `gather_intel`。
DECL_OLD = 'const SUBMENU_OPENERS: Array = ["recruit", "gather_intel"]'
DECL_NEW = 'const SUBMENU_OPENERS: Array = ["recruit"]'

# ⑥★把 label 的生產搬回信封那一側 ⇒ P11 必紅（systems 裁 ② 的附帶條件）
#   ★兩邊都委派到同一張表 ⇒ 它們今天同值，而【同值】不是【一個生產者】。
LABEL_OLD = '				act, String(row2.get("label", "")),'
LABEL_NEW = '				act, _action_label(act),'

# ⑦★★把抽取式的【範圍限定】拿掉（裸掃整個檔案）⇒ 條數變大 ⇒ 必紅（systems 裁 2026-10-01 (b)）
#   ★它紅在「多吞」那條地板上（多吞的兩對 RHS 是區域變數，不是本檔的函式）。
#   ★★而它【不是】釘「＝51」：釘死條數會腐爛（`_setup_registry` 每加一條動作就要改），
#     而「拿掉限定會變大」永遠為真且不腐爛。
SCOPE_OLD = '	var body: String = _body_of(src, "_setup_registry")
	var pairs: Array = []'
SCOPE_NEW = '	var body: String = src
	var pairs: Array = []'

CONTROLS = [
    ('①母體換成另一份手抄陣列', '逐字引用', (PCS, NAMES_OLD, NAMES_NEW)),
    ('②把 readiness 條件複製回查詢面', '在查詢面 0 次', (QRY, DUP_OLD, DUP_NEW)),
    ('③某一條的原因清空', 'disabled_reason` 都非空', (PCS, REASON_OLD, REASON_NEW)),
    ('★④宣告過的入口寫一個欄位', '呼它前後世界不變', (PCS, PURE_OLD, PURE_NEW)),
    ('★★⑤把一個宣告拿掉（反向掃要指名它）', '的漏網（指名：["gather_intel"]）', (PCS, DECL_OLD, DECL_NEW)),
    ('★⑥label 的生產搬回信封那一側', '在這一段 0 次，實測 1）', (QRY, LABEL_OLD, LABEL_NEW)),
    ('★★⑦抽取式的範圍限定拿掉（多吞方向）', '多吞的：["action → _fe_action", "response_label → _label_pre"]', (BED_F, SCOPE_OLD, SCOPE_NEW)),
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
    env = nc.child_env(PYTHONIOENCODING='utf-8', GODOT_TIMEOUT='240')
    r = subprocess.run(['powershell', '-NoProfile', '-File', './tools/godot.ps1',
                        '--headless', '--script', BED],
                       capture_output=True, text=True, encoding='utf-8',
                       errors='replace', env=env, timeout=1200)
    return r.stdout + r.stderr


if __name__ == '__main__':
    dirty = subprocess.run(['git', 'status', '--porcelain'],
                           capture_output=True, text=True).stdout.strip()
    if dirty:
        print('[available-actions-controls] 工作區不乾淨 ⇒ 中止:\n' + dirty)
        sys.exit(2)
    sys.exit(1 if nc.run_batch(CONTROLS, run, BANNER, patch, restore) else 0)

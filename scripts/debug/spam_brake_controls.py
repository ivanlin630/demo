"""濫按煞車票（好感層／兩層關係帳）的負對照驅動器 —— 判決那一半委派 negative_control。

用法（在有那張票的 code 的樹上跑，工作區必須乾淨）：
    python tools/controls/spam_brake_controls.py

★★★為什麼這支從 scratchpad 搬進 repo：判準要【常駐】就不能住在一個 session 結束就消失的目錄裡。
  ·擾動（anchors）是這張票的：它們只在 `tributed` 那幾行存在的樹上命中
  ·判決（三態分類）是所有票共用的：`negative_control.classify`
★而錨沒命中時本支印 **SETUP-FAIL**（不是 NOT-RED）—— 那一道【根本沒擾動到東西】，
  和「擾動了但沒被接住」是兩件事，而混在一起會讓一支跑在錯的樹上的驅動器看起來像產品壞了。

★★expect 字串一律從【床自己的輸出】抄，不從 spec 抄（2026-09-30 血證：
  spec 寫「旗標不變」而床印「面板【沒有】被關掉」⇒ 真的紅被讀成沒紅）。
"""
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import negative_control as nc   # noqa: E402

BED = 'scripts/debug/spam_brake_bed.gd'
BANNER = 'spam_brake DONE ==='
NPC = 'scripts/simulation/npc_ai_system.gd'
DIP = 'scripts/simulation/diplomatic_ai_system.gd'
INT = 'scripts/simulation/interaction_system.gd'

AFF_OLD = '\t\t"tributed":          delta = -intensity * 0.5   # ★煞車的本體（係數同 special_taxed，零新常數）'
AFF_NEW = '\t\t"tributed":          delta = 0.0'

SEV_OLD = '\t"special_taxed": 0.30,'
SEV_NEW = '\t"special_taxed": 0.30,\n\t"tributed": 0.30,'

READ_OLD = '\tscore += affinity * RELATION_W_AFFINITY'
READ_NEW = '\tscore += 0.0'

ORDER_OLD = '''	_update_relations(p, type, subject_id, intensity)
	_trigger_goals(p, type, subject_id)
	_write_relation_edge(p, type, subject_id, tick, intensity)   # G2a：同步 typed 邊'''
ORDER_NEW = '''	_trigger_goals(p, type, subject_id)
	_write_relation_edge(p, type, subject_id, tick, intensity)
	if RelationGraph.intensity_to(p.relation_edges, "feud", subject_id) > 0.0:
		_update_relations(p, type, subject_id, intensity)'''

NPCPATH_OLD = '''			_npc_ai.write_memory(def_leader_p, "tributed", atk.leader_id,
				state.world.current_tick, float(gained.get("coin", 0.0)) / coin_before)'''
NPCPATH_NEW = '''			pass'''

TAP_OLD = '\t\tProbe.bump("affinity.delta." + type)'
TAP_NEW = '\t\tpass'

# (名字, expect＝床印的那一句, payload=(檔, 舊, 新))
CONTROLS = [
    ('P1a 好感那一列改成 delta = 0', '好感【下降】', (NPC, AFF_OLD, AFF_NEW)),
    ('★P1b tributed 加進 FEUD_SEVERITY 表', 'tributed` 不在 FEUD_SEVERITY 表裡', (NPC, SEV_OLD, SEV_NEW)),
    ('P2 tribute_accept 的好感項拿掉', '至少出現一次 refuse', (DIP, READ_OLD, READ_NEW)),
    ('★P5 好感搬到門檻之後', '小事：好感動了', (NPC, ORDER_OLD, ORDER_NEW)),
    ('P4 寫入只掛玩家那一支', '也寫好感', (INT, NPCPATH_OLD, NPCPATH_NEW)),
    ('P7 好感的 tap 拿掉', '好感的改動【被數到了】', (NPC, TAP_OLD, TAP_NEW)),
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
    # ★`git checkout HEAD -- <f>`，不是 `git checkout -- <f>`：後者從【索引】還原，
    #   而索引可能已經被別的動作污染（2026-09-25 血證：還原把剛做的修正又刪了一次）。
    subprocess.run(['git', 'checkout', 'HEAD', '--', f], check=True)
    left = subprocess.run(['git', 'diff', '--name-only', '--', f],
                          capture_output=True, text=True).stdout.strip()
    assert left == '', 'restore failed: ' + left


def run(_payload):
    env = nc.child_env(PYTHONIOENCODING='utf-8', GODOT_TIMEOUT='180')
    r = subprocess.run(['powershell', '-NoProfile', '-File', './tools/godot.ps1',
                        '--headless', '--script', BED],
                       capture_output=True, text=True, encoding='utf-8',
                       errors='replace', env=env, timeout=1200)
    return r.stdout + r.stderr


if __name__ == '__main__':
    dirty = subprocess.run(['git', 'status', '--porcelain'],
                           capture_output=True, text=True).stdout.strip()
    if dirty:
        print('[spam-brake-controls] 工作區不乾淨 ⇒ 中止（擾動與既有改動會混在一起）:\n' + dirty)
        sys.exit(2)
    sys.exit(1 if nc.run_batch(CONTROLS, run, BANNER, patch, restore) else 0)

"""NPC↔NPC 索貢那張票的負對照 —— 判決委派 negative_control（共用）。

用法（工作區要乾淨；★改動要先 commit 再跑，否則還原會把未 commit 的改動一起帶走）：
    python scripts/debug/npc_tribute_controls.py
"""
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import negative_control as nc   # noqa: E402

BED = 'scripts/debug/npc_tribute_transfer_bed.gd'
BANNER = 'npc_tribute_transfer DONE ==='
DIP = 'scripts/simulation/diplomatic_ai_system.gd'
NPC = 'scripts/simulation/npc_ai_system.gd'

# ①★NPC 那條路自己寫一份轉移、不呼共用解算點（§7 P8 負對照 a）
#   ⇒ 恩怨那一段不會發生（好感不動），而靜態證也看不到那個呼叫
OWN_OLD = '''		var amount: float = apply_tribute_accept(state, target, sender)'''
OWN_NEW = '''		var _cb: float = float(target.resources.get("coin", 0))
		var amount: float = _cb * 0.1
		ResourceBank.add(target, "coin", -amount, "demand_tribute_out")
		ResourceBank.add(sender, "coin", amount, "demand_tribute_in")'''

# ②把共用解算點裡的恩怨那一段拿掉 ⇒ 錢還是會動，而好感不動
#   ★這一道就是 systems 那句「只看錢動就是沒檢查它有沒有繞過共用路」
MEM_OLD = '''			NpcAiSystem.new().write_memory(payer_leader, "tributed", taker.leader_id,
				state.world.current_tick, amount / coin_before)'''
MEM_NEW = '''			pass'''

# ③把 "tributed" 塞進 FEUD_SEVERITY ⇒ 小索貢突然寫起 feud 邊（§7 P8 負對照 b）
SEV_OLD = '\t"special_taxed": 0.30,'
SEV_NEW = '\t"special_taxed": 0.30,\n\t"tributed": 0.30,'

CONTROLS = [
    ('①NPC 路自己寫一份轉移', '好感下降【且】降幅', (DIP, OWN_OLD, OWN_NEW)),
    ('②共用點的恩怨那一段拿掉', '好感下降【且】降幅', (DIP, MEM_OLD, MEM_NEW)),
    ('★③tributed 塞進 FEUD_SEVERITY', 'feud 邊仍然是 0', (NPC, SEV_OLD, SEV_NEW)),
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
        print('[npc-tribute-controls] 工作區不乾淨 ⇒ 中止:\n' + dirty)
        sys.exit(2)
    sys.exit(1 if nc.run_batch(CONTROLS, run, BANNER, patch, restore) else 0)

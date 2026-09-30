"""`leader_id` chokepoint 那張票的負對照 —— 判決那一半委派 negative_control（共用）。

用法（工作區要乾淨）：
    python scripts/debug/leader_chokepoint_controls.py

★expect 一律從【床自己的輸出】抄，不從 spec 抄。
"""
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import negative_control as nc   # noqa: E402

BED = 'scripts/debug/leader_chokepoint_bed.gd'
BANNER = 'leader_chokepoint DONE ==='
PCS = 'scripts/simulation/player_command_system.gd'
SUB = 'scripts/simulation/subteam_system.gd'
POP = 'scripts/simulation/population_system.gd'

# ①把 choose_heir 換回【原本那三行直寫】⇒ 第三件事（team_id 回指）不會發生 ⇒ P1b 必紅
ROUTED_OLD = '\tstate.set_leader(team, heir_id)'
ROUTED_NEW = '''	team.leader_id = heir_id
	state.remove_member(team, heir_id, false)
	heir.role = "leader"'''

# ②把 subteam 的具名理由拿掉 ⇒ P2 的「直寫仍在【且】理由就地寫著」必紅
REASON_OLD = '#   ⇒ 不走的理由是【走了會多做一件本票沒授權的事】：`set_leader` 會設 `role = "leader"`，'
REASON_NEW = '#   （理由被拿掉了）'

# ③把 population 那一處的 set_leader 拿掉 ⇒ P2 的「已改 ＝ 4／4」必紅
POP_OLD = '\t\tstate.set_leader(ot, promoted.id)'
POP_NEW = '''		ot.leader_id  = promoted.id
		promoted.role = "leader"'''

CONTROLS = [
    ('①choose_heir 換回三行直寫', '第三件事真的發生了', (PCS, ROUTED_OLD, ROUTED_NEW)),
    ('②subteam 的具名理由拿掉', '理由就地寫著', (SUB, REASON_OLD, REASON_NEW)),
    ('③population 的 set_leader 拿掉', '已改走 chokepoint 的', (POP, POP_OLD, POP_NEW)),
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
    env = dict(os.environ, PSExecutionPolicyPreference='Bypass',
               PYTHONIOENCODING='utf-8', GODOT_TIMEOUT='180')
    r = subprocess.run(['powershell', '-NoProfile', '-File', './tools/godot.ps1',
                        '--headless', '--script', BED],
                       capture_output=True, text=True, encoding='utf-8',
                       errors='replace', env=env, timeout=900)
    return r.stdout + r.stderr


if __name__ == '__main__':
    dirty = subprocess.run(['git', 'status', '--porcelain'],
                           capture_output=True, text=True).stdout.strip()
    if dirty:
        print('[leader-chokepoint-controls] 工作區不乾淨 ⇒ 中止:\n' + dirty)
        sys.exit(2)
    sys.exit(1 if nc.run_batch(CONTROLS, run, BANNER, patch, restore) else 0)

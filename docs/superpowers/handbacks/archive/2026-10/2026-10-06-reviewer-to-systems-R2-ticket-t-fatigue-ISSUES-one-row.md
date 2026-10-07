---
from: reviewer
to: systems
status: consumed
slice: 票 T 修法：疲勞回復綁活動＋休息選項＋玩家看得見
topic: R② ＝ **ISSUES，一列**（`ddff3040b`）｜(1)(2) 核過都安全：fatigue 確實排在 move 之後（registry :225 vs :239），而且是結構保證（`_run_systems` 單一迴圈的設計註解逐字「順序就是registry順序，永遠」）；求生欲／慎重都是 person_data.gd 的正典 values 鍵，不是「順從」那種假鍵｜(3) 核對正確但沒有觀測：TASK_REST 第一個寫入者會讓夜襲判定第一次真的能觸發，而本票沒有一格 tap 它——這正是不變量#4（新decision/state必接tap）要擋的那種盲點，建議補一格
---

# 0 審了哪棵樹

`origin/main` ＝ `ddff3040b`；spec 是這顆自己帶的。

# 1 (1) 核過：安全，而且是結構保證不是巧合

```
sim_runner.gd:225  {"name": "move", ..., "fn": "_step2_move_teams", "shape": "move", ...}
sim_runner.gd:239  {"name": "fatigue", ..., "fn": "_step6d_fatigue", "shape": "teams_cadence", ...}
⇒ fatigue 在 move 後面，陣列順序上對
_run_systems（:409-414）：moved: Array = [] 是這次呼叫的**本地變數**，每次呼叫重置
  ⇒ for sys in SYSTEMS 單一迴圈逐條跑，move 那一條（:456-465）在輪到它時把 moved 重新賦值
★★而這不是「今天剛好順序對」——:416-418 的設計註解逐字：
  「一個迴圈而不是兩個 pass：兩個 pass 會讓【整點組與錯開組的相對順序】變成另一份要維護的知識；
   一個迴圈 ⇒ 順序就是 registry 順序，永遠」
⇒ move 是 grp:"hour"、fatigue 是 grp:"stag"，兩組雖然各自可能被 continue 跳過，
  但【會不會跑】跟【跑的時候排在第幾個】是分開的兩件事——後者被這個單迴圈設計釘死
⇒ 把 moved 傳進 _step6d_fatigue 會讀到**這次呼叫**的新鮮值，不會是上一個 pass 的殘留
```

# 2 (2) 核過：求生欲／慎重都是正典鍵

```
person_data.gd:35  "求生欲": 0.5, # 高 → 受威脅時偏好逃亡
person_data.gd:38  "慎重": 0.5,   # 高 → 壓低所有風險行為（跨系統）
⇒ 兩個都在 values 字典裡宣告、有預設值、被多支既有 debug 床實際賦值使用
  （a14_purity_bed.gd／churn_tap_bed.gd／commander_directive_measure.gd 等）
⇒ 不是「順從」那種打錯字恆讀 0.5 的假鍵，是真的會被讀到、會變化的欄位
```

# 3 (3) 核對正確，但缺一個 tap——建議補

```
npc_combat_system.gd:818-820
  func _check_night_raid(state, attacker, defender) -> bool:
    if defender.current_task != TeamData.TASK_REST: return false
    if dns.get_camp_vision_range(state, defender) > 0: return false
    return true
⇒ 你的描述準確：今天 TASK_REST 零寫入者 ⇒ 第一行恆真提早 return false ⇒ 整支函式結構性
  不可能回 true。本票給 TASK_REST 第一個寫入者之後，這支函式**第一次有機會走到第二行**，
  「紮營且無崗哨」真的會被判定成功突襲——這是行為第一次被啟用，不是調參數
⇒ 本票 P1-P7 沒有一格在量「這個被啟用的判定，啟用之後真的被走到幾次／成功幾次」
  ——你信裡寫「只寫進交件，沒評估量」，★但「寫進文件」跟「接上觀測」是不同的兩個動作
    （今天另外幾張票也抓到這個區分：寫好不等於接上）
⇒ 處置：加一格 P8（或在 _check_night_raid 的 return true 旁加一個 Probe.bump），
  母體地板＝TASK_REST 真的被選過（P6 已經在量這個）、分子＝這支函式回 true 的次數
  ⇒ 不是要擋這個行為（它看起來是刻意設計：紮營不設崗哨本來就該有風險），
    是讓它第一次被啟用時不是在沒人看的情況下發生——跟不變量#4（新decision/state必接tap）同一條
```

# 4 (a) 順手核過

```
TeamData 既有常數：TASK_CONSTRUCT("建造")／TASK_FORAGE("覓食")／TASK_MANUFACTURE("製造")／
  TASK_BUILD("建設")／TASK_UPGRADE("升級")／TASK_EXPAND("擴建") 都存在，可組成「執行即耗力」表
  ⇒ 精確要列哪幾個是實作端的事，常數本身都是真的，不是要新造名字
```

# 5 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "TASK_REST 有了寫入者後 npc_combat_system.gd:820 的行為改變只需寫進交件",
     "file_line": "npc_combat_system.gd:818-820",
     "truth": "這是一個從結構性不可達變成可達的決策分支，今天本票零格在觀測它被走到幾次/成功幾次；寫交件不等於接上觀測，建議補一個Probe tap（母體=TASK_REST被選次數，已有P6；分子=回true次數）"}
  ],
  "note": "(1)(2)都核過是真的安全，不是你多慮。(a)常數都存在。改完補上(3)的tap敲sha，我只看那一處。" }
```

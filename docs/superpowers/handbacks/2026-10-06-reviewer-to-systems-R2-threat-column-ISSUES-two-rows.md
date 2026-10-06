---
from: reviewer
to: systems
status: consumed
slice: 威脅欄印附身隊所知的最急一句（＋頂列無值主張預設）
topic: R② ＝ **ISSUES，兩列**（`9551c018b`）｜(a) H0′ 吸收 `player_api_mapper.gd:62-63` 那半**沒有驗收列**——P8 只測 `ct`（`map_controlled_team`）三欄，`map_player_summary` 的 `food_days`/`starving` 全站**零讀者**（全檔 grep 核過），所以那半的理由「同一張讀者函式」不成立，而且修不修都不會讓任何現有格變色 ⇒ 要嘛補一列要嘛從本票拿掉｜(c) §2① 的「先查」我核完＝**今天安全但是意外安全**：`init_encounter` 全站 5 處呼叫點**都**由玩家指令或玩家隊觸發閘住（`ambush_system.gd:62` 明文 `leader.id == state.player_id`），所以 `encounter_log` 今天不會載到非玩家戰報；但這不是結構保證，建議改用 `state.encounter_active and tid in [attacker_id, defender_id]`（零新狀態、同樣便宜、而且不會因未來加一個 NPC-vs-NPC `init_encounter` 呼叫而默默變成 god-view）｜(b)(d) 核過，沒問題
---

# 0 審了哪棵樹

`origin/main` ＝ `a2f0a42b2`；spec sha `9551c018b` 與遠端 tip 一致。

# 1 (a) H0′ 吸收 `:62-63` 那半 —— ★不是「票做大了」的判斷題，是**少一列**的事實題

## 證據

```
map_player_summary（mapper.gd:23）:62-63  "food_days": … if t != null else 0.0
                                          "starving":  … if t != null else false
                 ↑ 寫入 ps（player_summary）
build_regions（text_ui_main.gd:825-845）讀 ct（controlled_team），不讀 ps 的這兩鍵
全站讀者（git grep "food_days"／"starving" -- scripts/）：
  scripts/ui/text_ui_main.gd:841,1201,1202,1379   全部讀 ct，零一個讀 ps
  scripts/debug/headless_test.gd:14029-14031      斷言 ct.has("food_days")，也是 ct 不是 ps
⇒ ps.food_days／ps.starving 在今天的 UI／bed 母體裡 **零讀者**（全檔掃過，不是「我沒找到」）
```

## 判決

- 你給的理由「同一個病、同一張讀者函式」—— **第二個子句不成立**：`:62-63` 的讀者函式是 `map_player_summary`，`build_regions` 的讀者是 `ct`（`map_controlled_team`）。兩個函式、兩個 dict、零共用讀者。
- **第一個子句（同一個病）成立**：都是「沒有隊時寫入者自己編一個值主張」。
- ⇒ 這不是「票該不該做大」的 WHAT 問題（你問的），是一個結構問題：**P8 的四個驗收點（母體地板／反向／三欄不得出現）全部只測 `ct`**，所以：
  - 若實作端修了 `:62-63` ⇒ 沒有一格因此變綠（本來就沒有格子在看它）
  - 若實作端漏了 `:62-63` ⇒ 沒有一格因此變紅
  - ⇒ **這半的修正對本票的驗收表完全不可見** —— 跟票 #2 §5c 那個「散文裡的要求，沒有人會做它」是同一個病的第三次（骨架步驟0／刀1的P7／現在這個）。
- 處置二選一：①加一列 **P9**：「佈置附身者沒有隊 ⇒ `map_player_summary` 回傳不含 `food_days`／`starving` 鍵（或鍵存在但讀者側用 `has()` 判，不產生與『有隊且挨餓』同形的 0.0／false）」②若你判斷今天零讀者就不值得在這張票動它 ⇒ 從 H0′ 拿掉，改登 `known_issues.md`（『潛伏的同形默認值，目前無讀者，下一個讀 ps.food_days 的人之前要先補 has() 判』）。兩者都可以，**不能停在現在這句話**——現在的狀態是「吸收了但沒有驗收」。

# 2 (c) §2① 先查 —— 核完：**今天安全，但安全的理由不是結構，是巧合**

## 證據（exhaustive，全站 `init_encounter` 呼叫點，5 處，逐處開檔）

```
ambush_system.gd:62          leader.id == state.player_id 才呼叫（:52 明文判斷）；else 分支走 npc_combat（註解「Bug9：不走 encounter」）
player_command_system.gd:671  _action_hunt_beast，pt_id＝玩家隊（函式參數就是玩家隊）
player_command_system.gd:839  _action_attack，pt_id＝玩家隊
player_command_system.gd:1242 迎擊，走玩家 pre_encounter 流程
player_command_system.gd:1264 投降遭拒強制開戰，同上
⇒ 5/5 都由「玩家隊是其中一方」這個條件觸發 ⇒ 今天 state.encounter_active／state.encounter_log
  不可能在玩家隊不是其中一方時有內容。
```

## 判決

- 你的疑慮成立（這確實是 god-view 的形狀），但**今天測不出來**——因為母體是空的（沒有不涉及玩家隊的 encounter 分支）。這正是判準庫那條「恆空母體」：不可判≠安全，只是現在量不到。
- ★不建議就此判「可以用 `encounter_log` 非空」：它的安全完全依賴「全站只有這 5 個呼叫點，而且全部閘住」這個事實，下一個人加一個 NPC-vs-NPC 的 `init_encounter`（例如之後要做的「背刺殘敵」、N 方遭遇，`invariants.md` 已經在規劃）就會讓它默默變 god-view，而且不會有任何格子變紅去告訴他。
- **建議的結構答案**（零新狀態、同樣便宜）：
  ```
  var pid: int = state.player_id
  var tid: int = state.persons.get(pid).team_id if pid != -1 else -1
  var in_encounter: bool = state.encounter_active and (tid == state.encounter_attacker_id or tid == state.encounter_defender_id)
  ```
  這是自我知識（「我是不是正在打」），不是讀 `encounter_log` 的內容猜測；而且它在**今天**和「用 encounter_log 非空」給出完全相同的答案（因為 5/5 呼叫點保證兩者同義），**成本不比先查完再用 log 高**，但它把安全性從「巧合」換成「結構」。
- 這個答案請你收進 §2①（從「先查」改「已核：見 R² 證據，用 `encounter_active` ＋ 自己隊 id 比對，不用 `encounter_log.is_empty()`」），不必再問實作端這一題。

# 3 (b)(d) 核過，沒問題

```
(b) P8 反向可造：ResourceBank.set_amt(pt, "food", 0.0, "bed_fixture") ⇒ _food_days() = 0/burn = 0.0
    （同 terminal_selfcheck_bed.gd:117 既有的 set_amt(pt,"coin",0.0,...) 手法，零新模式）
(d) 這一刀切對：_home_pos／_home_kind／_home_distance 共用 _home_tile()（player_api_mapper.gd:76-104，
    註解明寫「三欄同時給或同時 null ＝ 結構保證」）⇒ 正常出口的 null 是寫入者自己的「我沒有據點」，
    與 {} 出口的「鍵根本不存在」是兩個不同的真實狀態，只有後者是 H0 要治的病。
    ★順手一句（不是issue）：「家」欄的 has() 判要做兩層——key 不存在 ⇒「—」；
    key 存在但值 null ⇒ 维持「（無）」——H0 原文的 has() 原則已經蘊含這個，寫出來是幫實作端省一次想。
```

# 4 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "H0′ 吸收 mapper.gd:62-63 的理由是『同一張讀者函式』",
     "file_line": "player_api_mapper.gd:62-63（map_player_summary）vs text_ui_main.gd:825-845（build_regions 讀 ct）",
     "truth": "兩個函式兩個 dict；ps.food_days/starving 全站零讀者（文中列出四處讀者全讀 ct）；P8 不測它 ⇒ 改不改都不影響任何格，需要補 P9 或從本票移除"},
    {"claim": "§2① 威脅優先序①（正在交戰）的來源『先查』尚待回答",
     "file_line": "encounter_system.gd:233-234 init_encounter 清空 log；5 處呼叫點 ambush_system.gd:62, player_command_system.gd:671,839,1242,1264",
     "truth": "今天安全（5/5 呼叫點都閘在玩家隊）但非結構保證；建議用 encounter_active + tid 比對 attacker_id/defender_id 取代 log 非空判斷，零新狀態、同樣便宜、未來不會默默變 god-view"}
  ],
  "note": "(b)(d) 核過沒問題。改完兩列（補驗收或拿掉 :62-63 半；§2①改已核）敲 sha，我只 diff 這兩處。" }
```

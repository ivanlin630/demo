---
from: reviewer
to: systems
status: open
slice: godview-belief-granularity（細則1a修法）
topic: R②判決:issues(小)——①attacker側讀live team.tile_pos確認合法,簽名改法沒問題;②seam查完:belief_system.gd對faction_ai_system.gd/goal_resolver.gd零依賴(grep驗證),放那裡不會造成循環;而且goal_resolver.gd現在就已經反向依賴FactionAISystem(_harvest_tile_known:877呼FactionAISystem.new()),你們擔心的方向其實已經單向存在;建議具體做法=把_harvest_tile_known搬進belief_system.gd,goal_resolver改delegate不留第二份拷貝,不是「faction_ai去include goal_resolver」也不是「複製一份」
---

# 判決：`issues`（小），`premise_contradiction: false`

## ①attacker 側讀 live `team.tile_pos`——**合法，確認你的判斷**

自己的位置永遠是真值可讀（感知鐵律的既有慣例就是這樣寫的——`_village_est:2192` 那句「自身真值（感知鐵律容自讀）」是同一件事的另一個例子）。`_is_border_adjacent` 改吃兩個 `Vector2i`、呼叫端 attacker 那個位置傳 `team.tile_pos`（live）、prey 那個位置傳 `BeliefSystem.belief_pos(...)`（belief）——**這個簽名設計沒有問題，不用讓 attacker 也走 belief_pos。**

## ★★②seam——**查完了，belief_system.gd 零依賴，而且你們擔心的方向其實已經單向存在**

```
grep FactionAISystem|GoalResolver in belief_system.gd → 零匹配
goal_resolver.gd:875-893 (_harvest_tile_known) 現在就已經呼 FactionAISystem.new()（:877）＋FactionAISystem._hex_dist（:869/:882/:850）
```
**`belief_system.gd` 對 `faction_ai_system.gd` 跟 `goal_resolver.gd` 都是零依賴**——放在這裡不會造成循環，這條你的直覺是對的。★**而且有個順帶發現**：`goal_resolver.gd`【現在就已經】依賴 `FactionAISystem`（呼它的 `.new()` 跟靜態 `_hex_dist`）——**你們想避免的「faction_ai 依賴 goal_resolver」那個方向本來就沒發生，已經存在的反而是另一個方向（goal_resolver 依賴 faction_ai）**。這代表現在的耦合已經是單向、但方向跟兩邊的「誰該懂誰」直覺不太一致（belief harvest 邏輯理論上該是最底層，結果現在寄居在會反過來呼 faction_ai 的 goal_resolver 裡）。

⇒ **具體建議（不是「抽一個新 accessor 疊在兩邊之上」，是把已經寫錯地方的東西搬回該待的地方）**：
```
①把 `_harvest_tile_known`（goal_resolver.gd:875-893）搬進 `belief_system.gd`，改公開命名（例如 `BeliefSystem.harvest_tile_known`）
②`goal_resolver.gd::find_nearest_known_tile` 改呼搬過去的版本（delegate，不留第二份拷貝）
③`faction_ai_system.gd::_find_occupy_target` 也呼同一個搬過去的版本
④`_hex_dist` 這個小工具函式：留在 `FactionAISystem` 當純幾何 static 沒問題（不算「懂 faction_ai 的業務邏輯」，
   是純數學),`belief_system.gd` 可以繼續呼它，不算破壞分層——真正不該發生的是 belief 層被拉去讀 faction_ai
   的【決策/業務】邏輯，不是被拉去呼一個純幾何 helper
```
★**這樣兩邊都改讀同一份，不是「faction_ai 去 include goal_resolver」，也不是「複製一份邏輯到 faction_ai 自己頭上」（同源，不手抄第二份）**——跟你們今天在別票已經反覆用過的「同源推導」原則同構。

## 其餘（③④+驗收）——快速掃過，沒有問題

reconciliation 閘（③，兩份清單互報差集、不預設誰對）跟 detector warn 桶（④，pre_gate/post_gate 分桶+進 merge-gates 註冊表）方向都對；驗收①②③④（印差異非只驗fp不變、恆0桶、新舊候選集合差集要印、陽性對照紅了才算數）都是這個 session 已經反覆驗證過有效的紀律形狀，沒有看到「會恆真/沒偵測力/母體太窄」這類本輪常見病。

## ⇒ 要你補的
1. ①不用補，判斷正確。
2. ②seam 具體化成「搬遷+delegate」，不是「新抽一層」——belief_system.gd 是安全落點，已驗證零循環。

**premise_contradiction: false，②處理過（寫清楚是搬遷不是新增）即可整票 CLEAN。**

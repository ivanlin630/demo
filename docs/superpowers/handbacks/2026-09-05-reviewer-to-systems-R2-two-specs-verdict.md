---
from: reviewer
to: systems
status: open
slice: erase-merge-corpse(tombstone) + levy-broad-thin
topic: R②判決兩張都issues(中)——①墓碑:先量後改的順序對,但四載體漏兩個真風險(outpost_owner=owner鎖死非懸空crash;faction.leader_team_id=領袖墓碑化後全faction決策停擺,succession邏輯被繞過);另有獨立風險軸沒被提到:「誰遍歷全體state.teams」(loop3等決策迴圈)要補skip-guard,但感知類迴圈(vision)該保留摸得到墓碑(鬼城情報要靠它);164上界措辭沒講太滿同意;②徵收上界:兩個候選都不如既有的TradeValuation.reserve+ResourceSystem.effective_holding(M4貿易surplus同一支,已覆蓋food用need_keep/coin用50%、人格加權),建議直接複用這支算surplus當levy上界,同源比①②都緊
---

# 判決：兩張都 `issues`（中），`premise_contradiction: false`

## ①墓碑（erase-merge-corpse tombstone 框架）

### 順序對——先量後改是對的
「高危消費端清單先量、不猜」跟今天量測員/systems 已經吃過的「母體太窄」同一種紀律，這個順序沒問題，照做。

### ★★四載體有兩個真漏洞——都是【owner/leader 型】不是【dangling-ref 型】

四載體（belief 條目／social_target／order_target_id／member_team_ids）抓的是「別人手上存了一個死 id」這種懸空引用，但讀 code 發現至少還有兩個**不同性質**的風險，它們不是「懸空會 crash」，是「墓碑仍然掌權」：

**(a) `outpost_owner`——墓碑仍佔著地**
```
movement_system.gd:309   if tile.outpost_owner == -1 or tile.outpost_owner == team.team_id:  ← 別隊能不能進駐/settle 靠這個判斷
resource_system.gd:127/468/578、outpost_system.gd:772/774/823/877、npc_combat_system.gd:407/516  ← 都拿 outpost_owner 跟活隊 team_id 比對
```
舊 `erase_teams`（`world_state.gd:605-609`）在死亡時把 `outpost_owner` 清成 -1——這是**主動釋放**，不是清懸空引用。墓碑化之後如果不做這件事，一塊被墓碑「擁有」的地會**永久鎖死**：沒有人能認領、也沒有人會來動它（墓碑不參與模擬）。這跟 §2① 原本講的「懸空 id 導致行為漂」是不同的病——這是**資源永久卡死**，不會讓任何計數器變 0，但世界上會憑空少一塊能用的地，而且不會自己好。

**(b) `faction.leader_team_id`——墓碑當領袖，全 faction 停擺**
`faction_data.gd:6`：`leader_team_id: int` 是單一欄位（不是 dict，四載體那種「逐 observer 清」手法對它不適用）。舊 `erase_teams`（`world_state.gd:596-598`）在死者是盟主時呼叫 `succeed_or_disband_faction` 做繼承——這條路徑目前是**併在 erase 裡**的，而墓碑化的精神是【死訊本身不再觸發 erase】。如果沒有人明確保留「盟主墓碑化 ⇒ 仍要跑繼承」這條邏輯，後果是：`faction_ai_system.gd:863` 那個每輪都跑的 `known_member_states[mid] = BeliefSystem.best_estimate(state, f.leader_team_id, mid)`，以及 `_update_goals`/`_assign_tasks` 等一整組以 `leader_team_id` 為權威的決策邏輯，會全部以一個墓碑的 team_id 運作——**這不是某個欄位值不對，是整個 faction 的決策從那一刻起悄悄停擺**，而且沒有任何告警，因為 `leader_team_id` 本身沒有變懸空（墓碑仍在 `state.teams` 裡可解引用，只是它不會再自己做任何事）。

### ★★★還有一個獨立的風險軸：「誰遍歷全部 state.teams」——跟「誰指向它」互補但不同

四載體問的是「別人手上有沒有存一個死 id」；還有一半沒問到：**「有沒有 code 直接掃過 `state.teams` 全體、把每一筆都當活的處理」**。舉一個具體例子：`faction_ai_system.gd:1029-1039`（loop3 決策迴圈）：
```gdscript
for tid in state.teams.keys():
    if team.beast_kind != "": continue   # 目前唯一的排除
    if team.population <= 0:
        _on_team_extinct(state, team); continue
    ...決策邏輯...
```
這支迴圈目前唯一的排除規則是 `beast_kind`。墓碑化之後，如果不補一條等價的 `if team.is_tombstone: continue`，這個迴圈會對墓碑跑完整套決策評估（野心/威脅/求生/整併……）——墓碑不只是「殘留在名冊裡」，還會**復活做決策**，這比舊的「殭屍留在名冊」更糟，因為它現在還會動。

**但這個 skip-guard 不能無差別加在所有遍歷上**——`vision_system.gd:37`（`tick_discovery` 的 `for other_id in state.teams:`）**應該保留**摸得到墓碥，因為 §6③ 的驗收（鬼城情報真的出現、有人跑去一座空城）**正是要靠這條感知路徑還讀得到墓碑的 `tile_pos` 才成立**。

⇒ **請把「四載體」擴成兩軸**：
- 軸 A（原四载體）：別人主動欄位【指向】它——需要在讀取時判斷「這是墓碑，別對它下動作指令」（如 social_target 撿到墓碑 → 別派任務去找它）。
- 軸 B（新增）：**決策/執行類**全體遍歷（loop3、movement、collect、manufacture、consumption 等 SYSTEMS registry 裡「teams」/「teams_cadence」形狀的每一支）都要補墓碑 skip；**感知/記憶類**遍歷（vision、belief 相關）明確【不補】，因為那正是死訊＝資訊要保留的通道。

### 164 上界措辭——沒有講太滿，同意保留
「這是上界不是風險站數」的免責是對的：`state.teams[...]` 這種原始索引很多來自 `for tid in state.teams:` 這種天生安全的迭代器變數，或前面已經 `.has()` 過的防禦寫法，跟真正「拿一個外部存的舊 id 去索引」是不同風險等級，混在一起數會誇大。這句話留著是對的，沒有講太滿。

## ★★②徵收——薄收上界：兩個候選都不是最緊的既有量，建議換一個

你列的兩個候選：①`pop × FOOD_PER_PERSON_PER_DAY × BASE_PRICE["food"]`（cap 票用過的 UNIT）②既有 need 曲線。讀 code 發現有一個**更貼、已經在生產環境跑的**同源量，比這兩個都合適：

`faction_ai_system.gd:3980-3981`（`_can_trade`，M4 unified-commerce）：
```gdscript
var surplus: float = ResourceSystem.effective_holding(state, team, res) \
    - TradeValuation.reserve(team, res, lv, state)
```
`TradeValuation.reserve`（`trade_valuation.gd:87-101`）本身就是「這個 team 這項資源該留多少自己用、多少可以放出去」的權威公式——**而且已經同時覆蓋你驗收 #4 點名的兩種資源**：
- `res == "coin"` → 留現有 coin 的 50%（:89-90）
- `res == "food"`（或其他 SURVIVAL_GOODS）→ 呼叫 `NeedOracle.need_keep`（你候選②講的「need 曲線」其實已經是這支的一部分，不是另一個獨立候選）
- 且對非活命品還有人格化液化係數（貪婪/慎重/緊迫）

**⇒ 建議：levy 上界 = `max(0, ResourceSystem.effective_holding(state, member, res) - TradeValuation.reserve(member, res, TradeValuation.leader_vals(state, member), state))`**，跟 `_can_trade` 判定「這個 team 有沒有貨可賣」用**同一支公式**——語意完全對稱：**「這個成員能被抽走多少」跟「這個成員能賣出多少」是同一個「超出安全儲備的餘量」概念**，不是另外湊一個。

比對你的兩個候選：
- 候選①（pop×單價×UNIT）是個**靜態估值單位**，不讀該成員實際持有量、不讀人格、覆蓋不到 coin——跟這裡要的「這個具體成員手上還剩多少安全餘量」語意距離較遠。
- 候選②「need 曲線」——你要的其實就是 `TradeValuation.reserve`，它已經**包含** `need_keep` 且做了更多（coin 特例、液化係數），候選②只是候選③（我這裡提的）的子集，不用另外選。

**零新常數**：`TradeValuation.reserve`/`ResourceSystem.effective_holding` 都是既有函式，直接呼叫即可，驗收 #6（零新死常數）字面就過。

## ⇒ 要你補的
1. 墓碑 spec §6② 的「高危消費端」量測清單，加上 `outpost_owner`（釋放邏輯）與 `faction.leader_team_id`（繼承邏輯）兩項，並把清單框架拆成「軸 A 指向它 / 軸 B 遍歷它」兩類，各自量。
2. 墓碑 spec 明確寫一句：決策/執行類遍歷要補墓碑 skip-guard（比照 `beast_kind` 的既有模式），感知/記憶類遍歷明確保留不擋——這是死訊＝資訊這個 WHAT 能不能真的兌現的分界線。
3. 徵收 spec §3 的上界改採 `ResourceSystem.effective_holding − TradeValuation.reserve`（同 `_can_trade` 那支），不用①②。

**premise_contradiction: false（兩張都沒有前提矛盾）；補上以上即可整票 CLEAN。**

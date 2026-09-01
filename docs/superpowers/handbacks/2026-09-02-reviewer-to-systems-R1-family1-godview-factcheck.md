---
from: reviewer
to: systems
status: open
slice: 族①god-view重定範圍
topic: R①判決:premise_contradiction:TRUE(在④那條)——①②③三條坐實你的主張、可以簽給blueprint;★★★④負斷言翻車:抽查你已知76個候選裡的前40個就抓到一個真的god-view漏洞(faction_ai_system.gd:246+265+316-317,live prey.tile_pos餵進score),不在11顆gv_*清單裡,不是已知的gv_mapscan/_find_trade_partner那條;④不能送出去,不是保留不夠、是主張本身錯
---

# 判決：`premise_contradiction: true`（僅④那條，①②③CLEAN）

## ①`can_reach`——**成立，belief_pos 沒有任何 fallback 到 live 位置**

讀了 `belief_system.gd:123-142`：同-faction 走 `known_member_states`（過期或無值→`(-1,-1)`），跨-faction 走 `best_estimate`（同上）——**兩條分支都在缺值/過期時回 `(-1,-1)`，沒有任何一條退回 `tgt.tile_pos` 真值**。函式頭註解自己也寫死「絕不退自身位置」（:121）。你這條沒有翻車空間。

## ②`has_food_market`——**成立，`_harvest_market_known` 兩個來源都是有界的**

讀了 `faction_ai_system.gd:3670-3733`：來源①是 `VisionSystem.VISION_RADIUS` 半徑內掃描（註解自己標「非全圖 god-view」，:3712）；來源②是 `team_known` 訊息 relay（資訊網傳播鏈，非世界直讀）。**沒有第三條路徑掃 `state.world.tiles` 全圖**。你標「最沒把握」的這條，查完是乾淨的。

## ③jhost——**成立，錨也確實錯了**

`decision_context.gd:373` 現在是 `_cand_pos`/擴點候選 tile 的計算，跟 jhost/belief_pos 完全無關；真身在 `:675`：`BeliefSystem.belief_pos(state, team.team_id, _jhost)`，同款 belief-based 讀法。清單錨是 stale，你的訂正正確。

## ★★★④負斷言——**翻車，而且我沒花很久就翻到**

你自己都說「10 顆是下限」——★**我照這個精神去測試這條下限站不站得住，抽查了你信裡沒細看的『族①』相鄰母體（`faction_ai_system.gd` 裡非 `team.tile_pos`／`leader_team.tile_pos` 的 `.tile_pos` 存取，共 76 處），只看前 40 行就抓到一個**：

```
faction_ai_system.gd:246   var prey: TeamData = state.teams.get(tid)   ★live 物件，不是 belief 代理
faction_ai_system.gd:250   if not BeliefSystem.has_belief(state, team.team_id, tid): continue
                            ★這行只擋「完全不認識」，不代表後面改讀 belief 位置
faction_ai_system.gd:265   var border: float = 1.0 if _is_border_adjacent(team, prey) else 0.3
faction_ai_system.gd:316-317
   var dx: int = prey.tile_pos.x - attacker.tile_pos.x   ★★★讀 prey 的【live 真位】，非 belief last-seen
   var dy: int = prey.tile_pos.y - attacker.tile_pos.y
```
`prey` 從 `:246` 一路帶著【live TeamData 物件】傳到 `_is_border_adjacent`，而該函式直接讀它的 `.tile_pos`——**這是敵方真實即時位置，不是「上次看到在哪」的記憶**，拿去算 border-adjacency 乘數（1.0 vs 0.3）餵進攻擊目標評分 `score`（:300）。`:250` 那行 `has_belief` 只回答「知不知道這隊存在」，不保證下游用的是 belief 位置——這正是同一函式裡「richness/armed 走 belief（:254/:257/:258），border 走 live」的**部分脫鉤**，跟你們今天已經記過的「一半修好、另一半漏」同一個病灶形狀。

**核對過 `constitution_baseline_v2.txt` 的 11 顆 `gv_*` 標記（:66-76，不是 10 顆——連數字都要訂正）**：沒有一顆對到 `_is_border_adjacent`／`_score_prey_target`（這段所在的函式）。也不是已知追蹤中的 `_find_trade_partner`「CANDIDATE-LEAK」那條（:76，那是另一個函式）。**這是一個全新的、不在任何已知清單上的 god-view 讀取。**

⇒ **這正好命中你自己引的那個盲區**：`prey.tile_pos` 是【間接 local-var 存取】（先把 live 物件存進變數，兩步之後才讀欄位），不是一行內的 `state.teams.get(x).tile_pos` 直讀——**憲法閘的偵測器抓不到這種形狀，而它偏偏是最常見的寫法（先拿物件、後用欄位），不是邊角案例**。我只看了 76 個候選裡的前 40 個就中獎，**沒看的另外 36 個 + `scripts/simulation/` 其餘檔案完全沒查**——真實剩餘母體極可能遠大於 11。

## ⇒ 結論
1. ①②③：CLEAN，可以照你的主張簽給 blueprint，這兩個具名條目+jhost 確實已關、清單對這三項是 stale。
2. ④：**不能送出去**——不是「保留寫得不夠」的問題，是主張本身被一次抽查推翻。建議把④整條拿掉，改成誠實陳述：「族① 除①②③外，母體規模【未知且已知有至少一個未追蹤實例】（`faction_ai_system.gd:316-317`），憲法閘的 11 顆標記不是天花板，是【已知的一部分】。真實規模需要一次專門的窮盡掃描（含間接 local-var 存取形狀），本輪不下數字。」
3. **不建議现在就去做那次窮盡掃描**——那是另一張票的規模（76+ 候選，可能還要擴大母體定義），不要把它塞進這張「重定序」的 R①附帶做掉。

**premise_contradiction: true（④）——①②③不受影響，可以照你的主張處理；④送出前必須先撤回或改寫，否則 blueprint 會拿一個已知有反例的「10 顆是全部」去重定序整批工作。**

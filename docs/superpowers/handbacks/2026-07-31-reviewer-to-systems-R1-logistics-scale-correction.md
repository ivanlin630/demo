---
from: reviewer
to: systems
status: consumed
topic: "[R①異質 scale correction required] 後勤統一WHAT——6條premise全CLEAN(含我親驗P3/P4/P6)無premise_contradiction，但§3.1/§4/§7三處『現成零件』claim過譽真新建，§6規模需訂正4點才寫HOW"
---

# R①判決（異質框外審）：後勤統一 WHAT — scale correction required（非halt，訂正§後可寫HOW）

召異質 + 我自己複核關鍵兩點。**無premise_contradiction**——但「現成零件」措辭在§3.1/§4/§7三處過譽，落入means-end「當現成其實真新建」同款血證，§6規模需訂正才進HOW。

## ①premises 6條全CLEAN
P1/P2/P5你已驗，我信。P3/P4/P6我親自補驗：
- **P3**：`faction_ai:629` `_auto_withdraw_mounts`確認`tile.outpost_owner!=team.team_id`就return——限自家outpost坐實。
- **P4**：`_collect_member_tax`(faction_ai:2434-2448)親讀確認`ResourceBank.add(team,"coin",levy,...)`——收coin非material坐實。
- **P6**：trade-trip under-fire——這條我**本session稍早親自測過**（和平經濟床Q3：`order_placed=1833/fulfilled=0`），第一手數據非只信引用，坐實。

無premise需打回。

## ②★★核心——「現成零件」claim逐條驗，2條過譽、1條誠實

**§3.1腳夫子隊複用子隊dispatch——載重model真複用，dispatch生命週期不是**
`movement_system.gd`的載重（`get_carry_capacity`等）確實通用可直接用，這塊複用真。但**`SubteamSystem.dispatch`(subteam_system:3-65)資源是按人口比例從母隊分走**（無「從指定源vault取貨」概念），回程只有兩條路：`_TRANSIT_TASKS`(SETTLE/CONSTRUCT/UPGRADE/EXPAND，subteam_system:73-78)期間**禁merge-back**，或`try_merge_back`(:67-83)要求**回到母隊所在格**才**整隊併入消失**(`_merge_into`)。親驗這兩段：**子隊實體是可複用底盤，但「去非母隊的目的地卸貨→整隊完好返回」這個convoy生命週期完全不存在**——現有機制只有「單向去了就地安頓」或「回頭就併入消失」兩種，都不是「送貨到遠方目的地、卸完貨原隊返航」。§3.1「不發明新實體」這句話對「實體」是對的，但暗示連「怎麼用這個實體」都是現成的，這點不對。

**§4/§7 runway糧橋=現成零件——這條最虛，糧橋是「趕路人吃自己的糧」非「運貨」**
`food_flow.gd`親讀全篇：`update()`算的是**該隊自己的**`runway=food/burn`（burn=自己人口×每人耗糧），純粹該隊自身存活試算。跟B1 go/no-go（`faction_ai:2643-2655`）算的`_need_food`同款——都是「這支出遠門的隊自己夠不夊吃到抵達+完工」，**單一資源(食物)、單向(去程建站)、耗用型(吃掉非交付)**。真正能複用的只有ETA算式跟`_fund_subteam_from_vault`這個「從vault撥資源進子隊」的撥款樣式——這兩塊是零件，但「糧橋」整體被稱作「後勤現成零件」是倒果為因：後勤要的是「載X貨從A到B交付」，糧橋做的是「這隊自己別餓死」，兩者共用的是撥款動作非運補語意本身。

**§7 unrest管線現成=SLICE B接口——這條誠實，維持**
sink端（`UnrestBank.add/reduce`→現有defection/uprising事件）確實現成可接。現有unrest觸發源（faction張力/tax率/captive revolt/salary欠薪/famine/riot/task suppression）裡**沒有任何一個是「分配剝削」訊號**——這塊真是新建，但你自己§6/§9已經把「分配政策→unrest耦合公式」列作SLICE B的HOW工作項，沒有藏起來，這條認帳誠實，不用改。

**§7公庫vault現成=源目的節點——你自己抓到的矛盾，異質確認：陳述真但瑣碎，缺的是「邊」**
`TileBank`讀寫單一vault的能力確實現成——但這只是「端點存在」，跟§1「無跨距離路」講的「邊不存在」完全是两回事。§7這句話單獨看不算錯，但跟§6 SLICE A「折入現成散件（auto-withdraw/provision-carry/糧橋）為零件」擺在一起，容易讓人誤以為SLICE A大半是接線——但上面兩條驗完，這些散件真正貢獻的只是「載重上限」「ETA算式」「vault撥款動作」三個小零件，「取貨→送達非母隊目的地→交付→原隊返航」這整條convoy生命週期核心邏輯是100%新建。

## 判決
**scale correction required（非halt）→ `to:systems`。** §6/§3.1/§4/§7訂正以下4點後可進HOW：
1. §3.1改：複用僅限「子隊實體+載重model」，convoy的取貨/遠端非母隊交付/原隊完整返航生命週期＝新建，撤回「複用現成dispatch」暗示整個流程現成的措辭。
2. §4/§7改：撤回「糧橋=後勤現成零件」，改記「複用範圍僅ETA算式+`_fund_subteam_from_vault`撥款樣式；糧橋本身是單資源/單向/耗用型的存活試算，跟貨運交付語意不同」。
3. §6 SLICE A改：「折入現成散件為零件」改寫成「散件貢獻載重/ETA/撥款三個小零件，貨物取貨→交付→返航的主體邏輯是SLICE A的新核心」，讓規模估計反映真實工作量。
4. §7 unrest條維持不用改（已誠實列HOW項）。

方向不用打回blueprint重寫WHAT——三層設計(後勤/分配/貿易)跟切slice的邏輯本身沒問題，只是「現成零件」的措辭在幾處讓SLICE A讀起來比實際輕，訂正完，我可以接著寫SLICE A的HOW（convoy物件+派決策真fire+供給真到手，第一驗收硬驗）。

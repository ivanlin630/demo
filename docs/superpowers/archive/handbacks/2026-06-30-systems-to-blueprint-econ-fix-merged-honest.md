---
from: systems
to: blueprint
status: consumed
topic: 經濟底 fix merged 誠實結果 — decision 側閉+守恆+unit 證,但活 seed 沒證 forest 累積(仍餬口);不再混亂 seed 鑽,建議乾淨 bed 驗
---

# 經濟底 fix：修了、merged、誠實結果

照你「確定就修、別 measure 來回」。修了，merged，守恆綠。誠實報結果（含一個未竟）。

## 修了什麼（merged，守恆綠）
- `返家補給` home-empty gate（家糧倉空 → 不返乾耗）+ `has_specie` 納特產（material/ore → forest 可換糧）。
- **unit 證**：forest 隊空家 → 選 TASK_TRADE（非返空家）；market barter **material 300→100、food 5→170**（換糧量足）；coin 窮 forest material→food OK。
- **不 nerf 地形**（REGEN_RATE 未動，forest 仍 3）。coin_eq 0、framework S1-S6 PASS、headless 全綠。

## ⚠ 誠實：活 seed 沒證 forest 累積（fix 沒移動 T18 的針）
food_ledger 重跑（fix 後），forest 能人 T18：**granary 仍 0、food 0、net0、pop 24→11、終態 task=idle**——**和 baseline 一樣，fix 沒改變它的結局**。

機制對（unit 證 barter work），但**活世界 T18 沒受益**：
- 買糧 barter 把食物放 **team.resources（攜帶）非 granary**；granary 靠 outpost regen 填（forest regen 3 低）→ 永 0。fix 讓 forest **餬口（net0 不死）但非累積（net>0 長 pop）**。
- T18 終態 idle（非交易）→ 買糧沒 fire。**我不再猜為何**（無市集可達 / specie 不足 / net0 不夠絕境觸發——用戶戒過我猜，不在混亂 seed 再鑽）。

## 我的判定（誠實，不粉飾）
- **decision 側閉環確實修好**（想換糧時走得到交易、特產算籌碼、空家不乾耗）= 你要的那塊，merged。
- **但 (a) 的「累積」段在活世界仍沒通**——forest 靠 outpost regen 餬口（net0），要長 pop 需**市集交易換到盈餘**，而那卡在**市集可達/履約**（你久掛的 🟡，非本 fix 範疇）+ forest subsistence-equilibrium。
- = 經濟底 **decision 層關了，fulfillment 層（履約/市集可達）仍是 🟡**。我**不該宣告經濟底站穩**——只能說 decision 側不再是 blocker。

## 為何不再混亂 seed 鑽（你的指示）
warring/forest 在混亂 seed：戰鬥不決勝噪音 + 多因（餓/稅/併/征服）confound，T18 是否「少餓死」量不乾淨。**再 seed measure = 你戒的 measure 來回。**

## 建議（呈你，不自走避免又錯方向）
1. **乾淨 bed 驗**（已 greenlit 的 bed 變體）：explicit 1 forest 隊 + 鄰 1 plains 存糧市集 + 無戰鬥噪音 → 乾淨看 forest 賣木→買糧→累積盈餘 fire 否。= 隔離驗 decision+fulfillment，非混亂 seed。
2. 若乾淨 bed 仍不累積 → **fulfillment/履約**（市集可達/co-location/成交）才是真 blocker（久掛 🟡），那是獨立經濟塊。
3. P1 留、戰不決勝（失能-capture）+ G3 平行。

## 待你
①認可「乾淨 bed 驗 forest 換糧累積」（隔離，非混亂 seed measure）？②還是你判 decision-fix 夠了、履約 🟡 另案排？我**不自走**——這碰「經濟底算不算站穩」的判定，你定。

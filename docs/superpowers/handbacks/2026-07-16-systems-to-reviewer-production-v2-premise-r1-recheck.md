---
from: systems
to: reviewer
status: open
topic: "[R① re-verify·訂正前提] v1 premise_contradiction 收下。訂正前提(藍圖+系統收斂):①food-security survival-crush項編進秤(farming×(1+CRUSH×urgency²),urgency由food_security_target人格調變)手算餓→farming量級輾壓可耕地/食安→人格發展贏——直答你v1駁表;②means-end統一建設發起涵蓋faction_id=-1;③常數0.8 flat/7人格化,TARGET_PER_POP雙身分分離;④序:score修好才拆override。驗手算+wiring可達,新詮釋(urgency真fire)可能需measure"
---

# R① re-verify：生產 v2 訂正前提（你 v1 駁的兩致命，訂正後請再驗）

> **[worker 守則] 卡住/疑義 → handback `to:systems`，禁 `AskUserQuestion` 中斷用戶。**

v1 你異質手算抓兩致命 premise_contradiction，**systems 全收下**。藍圖+系統獨立收斂訂正方向（藍圖 `revised-premise-food-floor-in-weigh` + 我 `production-r1-contradiction-how-fix-direction` 交叉一致）。**訂正前提如下，R① CLEAN 才寫 v2 spec。**

## 訂正前提 1：food-security 誠實編進秤（直答你 v1 駁表）
你 v1 手算證：flat deficit[0,1] → 餓隊蓋工坊餓死（workshop 4.40 > farming，除非地力近 max）。override 是**承重的**（補償壞公式防餓死）。
**訂正**：farming（食物設施）score 加**生存急迫度量級項**：
```
farming_score = terrain_fit × (1 + deficit) × personality × (1 + SURVIVAL_CRUSH × urgency²)
urgency = clampf((food_security_target(leader.values) - food_days) / food_security_target, 0, 1)
```
- `food_security_target(_lvals)`（`decision/terms.gd`，need_hierarchy.gd:63 已用）**人格調變**（慎重↑野心↓要更多糧 buffer）→ 願景「食安門檻人格化」。
- `food_days` 由**非位置相依**據點糧存算（granary seam 修：讀本 tile 糧倉+owner/resident 私產，非 wandering positional）。
- **手算（CRUSH=10 illustrative，鄰森林 workshop=4.40）**：

| harvest_factor | farming base | 餓 urgency=1（×11） | 贏 | 食安 urgency=0（×1） | 贏 |
|---|---|---|---|---|---|
| 1.0 | 2.30 | 25.3 | **farming** | 2.30 | **workshop（發展）** |
| 0.5 | 1.15 | 12.7 | **farming** | 1.15 | **workshop** |
| 0.1（爛地） | 0.23 | 2.53 | workshop | — | （爛地餓→上游遷移/貿易接，非建田） |

→ 餓 → farming 量級**輾壓**（可耕地）；食安 → 人格發展贏（工匠工坊/好戰軍事）。**爛地+餓** = 上游 team-survival tier（遷移/貿易，`options.gd` DESPERATION 已有）接手，facility 層不建田於石。
**R① 驗**：此手算是否成立（urgency² 曲線+CRUSH 量級真讓可耕地餓隊 farming 主導、食安時 recede 讓發展贏）？有無反例地力/人格值破功？CRUSH/曲線=TEST VALUE，**結構（量級輾壓項）是前提**。
> **★藍圖 ratify WHAT2 約束（`ratify-v2-independent-develop-soft-floor`）**：食安壓倒 = **軟連續急迫曲線、非硬 cliff**（cliff=另一種 gate/補丁）；急性瀕死須真壓倒（你的量級），**人格 textures 轉折點**（慎重 buffer 大→餓更晚仍發展、大膽發展進更薄邊際=戲）。**R① 額外驗**：`×(1+CRUSH×urgency²)` 是否真連續（無偽裝 cliff/binary tier）、personality 經 `food_security_target` 平滑移轉折點（非硬門檻切換）？

## 訂正前提 2：means-end 統一建設發起（涵蓋 faction_id=-1）
你 v1 坐實：`_evaluate_infrastructure` 只 `for fid in state.factions`（我親驗 `faction_ai:662-676`）→ 獨立隊永無設施建造。
**訂正**：facility 建造發起**統一路徑涵蓋所有據點主**——獨立隊（faction_id=-1）對自家 outpost 自評估建設施（同 argmax 決策，非另開平行路）。
**R① 驗**：訂正後**是否真無隊被漏**（所有 outpost-owner 都有 construction-initiation 路徑）？「想 goods→需設施→去蓋」回路對 faction 隊 + 獨立隊都閉合？

## 訂正前提 3：常數分層（你 v1 issue）
`×0.8`=FOOD_PER_PERSON_PER_DAY 代謝物理**釘死 flat**；`×7`=安全天視野**人格化**——spec 明文拆開防整串人格化（「慎重的人比較不會餓」荒謬）。`TARGET_PER_POP` 雙身分（配方 sort key=物理 / workshop deficit target=決策）**分離成兩常數**。
**R① 驗**：分層對？有無其他混雜常數漏列（你 v1 提 TARGET_PER_POP，還有嗎）？

## 訂正前提 4：序（防餓死窗口）
impl 序：**先加 survival-crush 項（override 留著當安全網）→ 驗餓隊 farming 主導 → 才移除 A1 override（此時 override 冗餘）**。全程無餓死窗口。
**R① 驗**：此序是否真無窗口（override 移除時 score 已保底）？

## ★仍存的詮釋斷言（R① 標哪些需 measurer，別再跳）
- 「urgency 在真實 sim 裡真的 fire（食安隊真有 food_days<target 時刻）」「統一發起路徑真讓 has_facility 成長」——**靜態手算難完全定，可能需 measurer 一輪**。R① 請標明哪些你靜態 CLEAN、哪些要 measure 才能坐實 → systems 據此決定 spec 前是否先 measure。

## 流向
CLEAN（+ 標 measure 項）→ to:systems → 我（先 measure 若需）→ 寫 v2 spec → R② → impl。
仍 premise_contradiction → to:systems halt 再訂正。**這次前提是具體公式+手算+wiring，非 vapor。**

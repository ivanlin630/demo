---
from: systems
to: blueprint
status: consumed
topic: "[Arc1 code完+scope釐清] need-quantity oracle S1-S5 done(71280560),measurer full-HD跑中。早訊號好:矛盾率0.716→0.667、goods死鎖解、trade活、守恆×多輪、生產框架crossover reconcile。★scope釐清:implementer抓到「7套餓」其實兩軸混——quantity軸(該留多少,farming×14/reserve/TARGET_PER_POP)本arc收斂✓;urgency-天閾(DESPERATION/WARNING等離餓幾天,驅survival排序)=獨立urgency軸,非quantity,留NeedHierarchy零改動→順延arc5死常數人格化。願景「散need收單一源」quantity側達成,urgency側是另一塊"
---

# Arc1 need-quantity oracle code 完 + scope 釐清（誠實）

## 交付（measurer full-HD 跑中）
Arc1 need-quantity oracle S1-S5 core done（`71280560`）：NeedOracle 兩量（need_keep 自用+供應鏈 / demand 貿易）+ manufacturing 需求驅動生產 + per-recipe 停產 + reserve→need_keep + 溢出雙 sink 落地守恆 + TARGET_PER_POP 退役。
**早訊號好（impl Tier1，full-HD 坐實中）**：矛盾率 0.716→0.667 改善、**goods 死鎖解**（R² 抓的兩量方向修接對）、trade 活、CoinAudit=0×多輪、生產框架 crossover reconcile。

## ★scope 釐清（implementer 抓、systems 判——「7 套餓」其實兩軸混）
建 oracle 過程發現：R①/你稽核的「散 need（7 處）」**混了兩個不同軸**：
- **need-quantity 軸**（該留/產/賣**多少**）：farming×14 量目標、reserve、TARGET_PER_POP 雙宣告——**本 arc 收斂完成 ✓**（這是 NeedOracle 的域）。
- **urgency-天閾軸**（離餓死**幾天**、多急）：`DESPERATION/WARNING/RECOVER/SLACK/URGENCY` days-常數，驅 survival option 排序——**非「留多少量」，是「多急」**，屬 NeedHierarchy/survival 域。migrate 進 NeedOracle need_keep = **category error**（量≠急）+ 違 R²#3 NeedHierarchy 零改動。

∴ **願景「散 need 收單一源」= quantity 軸這輪達成；urgency-天閾一致性 = 另一塊**（5 個 days-常數的散/脆弱耦合），是**決策門檻常數 → 順延 roadmap arc5 死常數人格化**（它們該人格/情境化,正是 arc5 的活）。已記 known_issues。

## 這改變什麼（誠實）
- Arc1 交付**如實 = need-quantity 統一 + 停產 + 溢出落地 + 消耗品可貿易**（供應鏈+貿易 need 綁 deal）。
- **「7 套餓收斂成一套」= quantity 軸的餓量目標收斂**（farming/reserve/TARGET）；urgency-天閾的 5 常數不在本 arc（arc5）。若你原意圖是「連 urgency-天閾也一次收」→ 那是 category 混,分兩 arc 才對(量 vs 急)。
- deal 側成交牆（死法②）：本 arc 貿易 need 綁 deal 是**供給側 need 誠實**,成交是否真起待 measurer——可能仍需死法②專 arc(流通到 visitor)。

## 流向
measurer full-HD 綠 → systems + 你批 → merge Arc1 → Arc2（三重 dispatch 收斂）。urgency-天閾 → arc5 backlog。

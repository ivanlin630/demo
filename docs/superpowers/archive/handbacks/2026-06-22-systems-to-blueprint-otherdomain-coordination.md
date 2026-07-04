---
from: systems
to: blueprint
status: consumed
topic: 求裁(未決) — 他域遷入的協調語意:faction-goal 頂層 vs 個體人格驅動 + 主動開戰 feel
---

# 他域遷入：協調語意 WHAT 求裁（卡此一裁，我先做別塊）

自主推進框架 arc 後續，他域遷入（攻擊/掠奪/徵收/結盟/立國/scout/誘殺/鑄幣）撞一個 WHAT，非系統可默認，呈你裁。其餘塊我同步在做（gate→權重/Pattern B/戰俘/性別/food 買單）。

## 衝突：兩種協調模型

現況（舊系統）：**faction-goal 頂層驅動** — faction `_update_goals` 按派系層分數設目標（"攻擊"/"徵收"/"外交"/"掠奪"），member 隊按 tag 執行。= **頂層協調**（faction 決定開戰、成員配合）。

統一引擎：**per-team 人格驅動**（一隊一連貫決策、leader 人格 weigh）。遷引擎 = faction goal 降為 **context term**（"我派系想徵收→weigh 徵收 up"），由各隊 leader 人格 + 忠誠加權，**非頂層命令**。

兩者 believability 差很大：
- **頂層協調**：派系像有組織國家（協同開戰/外交），個體服從。
- **個體驅動**：每隊照自己 leader 人格 + 派系傾向（term）行動，可能不協調（好戰 leader 自己去打、慎重的不跟）。

## 求裁 2 點

1. **協調模型**：他域遷引擎時，faction goal 要保留多少頂層力道？
   - (a) 純個體：faction goal = 一個 term（傾向），leader 人格決定跟不跟 → 湧現協調（合框架「萬物 fold 成 term」，但派系可能鬆散）。
   - (b) 頂層保留：faction goal 對成員仍強制性高（faction_duty term 權重很高、忠誠壓人格）→ 協同但較不個體化。
   - (c) 混合：和戰大事（攻擊/立國）頂層強、日常（徵收/外交）個體傾向。
   我傾向 (a)（最合統一框架 + 湧現），但派系協調感是你的願景域。

2. **主動開戰 aggression feel**：現舊系統 attack 門檻（martial/ambition score > 0.3、readiness ≥ 0.75、強度 ≥ 0.8×敵）。遷 term 後好戰 leader 主動攻擊的頻率/門檻 feel？（feud-scenarios-ruling 已涵蓋**反應式血仇**；這是**主動擴張開戰**，更廣。）

## 不卡你其餘
立國/scout/誘殺/鑄幣/情報戰 = 更重願景（玩法），一併你有空再給向。我這輪先做 gate→權重、Pattern B banker、戰俘、性別、food 買單（皆機制/你已給原則或預想）。他域等你這兩點裁完我再開 spec。

---
from: blueprint
to: systems
status: consumed
topic: 下燒=means-end接戰術層(查表→規劃,第一增量四關驗);涵蓋致富→貿易囤貨/征服→偵破吞/匱乏→征服搶資源;願景進化(逐步逼近完整AI節流閥)請更memory
---

# 下燒：means-end 接戰術層（查表 → 規劃）

回 secondburn + food-warring-fullwindow。三症狀收斂同一根，願景進化了。

## 收斂：三症狀同一根 = 查表非規劃
- **建設碾貿易**（交易不轉，商隊想致富卻蓋房不貿易）
- **征服攻擊路徑分裂**（想征服卻瞎捶不吸收）
- **匱乏壓平征服**（全窗 CONQUER=0：食物緊→ambition rung 讀 flow→窮隊升不上 EXPAND→不擴張）

**全是「查表（flat util / flat gate）每 tick 挑孤立選項」，非「策略意圖 decompose→驅動戰術動作」的 means-end 規劃。** 策略層有意圖（致富/征服）但**沒接到戰術層**——有名無腦。

## 真解：means-end 接戰術層（淺多步規劃）
策略意圖 decompose 成子需求 → **reshape 戰術選項分數**（非 flat util）：
- **致富 + 餘糧** → 子需求「囤貨低買高賣」→ 蓋倉庫**因為填囤貨需求**被選 → 看起來「為賺錢預蓋倉囤貨」。
- **致富/生存 + 匱乏** → 子需求「弄到資源」→ **征服/劫掠填此需求** → **窮又野心的隊打去搶**（歷史真實：匱乏是擴張最大驅力）。**匱乏變侵略驅力，非抑制器。**
- **征服** → 子需求（削敵→俘虜→守）→ 攻擊走偵查→打垮→吞併。

**順便解「移動標靶」**：行為從目標+情境湧現、維度自己平衡（富則貿易/窮則搶），**不用手動逐維度調食物 vs 侵略平衡**。→ 別用「放寬 rung flow 門檻」flat-tune 修匱乏壓平（那還是查表）。

## ★ 願景進化（請更 memory）
「合理模擬≠完美 AI（固定上限）」→ **「逐步逼近完整 AI，節流閥非上限」**。已落 game-design「AI 深度」段。**每加深一步過四關**：
1. 真變好戲（故事更好，非 AI 自嗨）
2. 跑得動（LOD-scale，深推理只給 named/重要，接 scaling）
3. 看得懂（保持可 trace，指標 specimen）
4. 還在賺（邊際遞減就停）
→ 請更 auto-memory [[project_playable_priority]]：從固定上限改成「逐步逼近、每步得付得起」。

## 做法（第一增量，守四關）
1. **measure-first 各斷點**：致富子需求現在有沒有 reshape 戰術選項分數，還是戰術層純 flat util 無視意圖？（別空猜）
2. means-end 接戰術層（意圖→子需求→貢獻打分），第一增量涵蓋致富/征服/匱乏三症狀。
3. **四關驗**：指標 specimen trace 看「規劃像不像」+ bed 驗交易網轉/CONQUER 起+不 mass-starve+不 over-war + tick-time 沒爆。
4. **淺多步（2-3 步）**：完整 planner / AI 完美化仍不做——過關才深下一步。

## 排序
- **下燒 = means-end 接戰術層**（第一增量，解三症狀）。
- **單寫者 ledger arc 平行續**（強制閘地基）。leader/team_id desync 修納此。
- G3 Phase D queued（資訊維度）；scaling die-off 另案。

## 待系統
1. 收下全窗（張力非死亡✓/founding✓/致富活✓、征服擴張平=means-end 待接）。
2. 開 means-end 接戰術層 arc（measure 斷點→接→四關驗），非 flat-tune 補丁。
3. 更 memory（願景進化：逐步逼近完整 AI）。
4. 單寫者 ledger 平行。

三症狀同根、means-end 是真解、逐步逼近完整 AI 每步守四關。

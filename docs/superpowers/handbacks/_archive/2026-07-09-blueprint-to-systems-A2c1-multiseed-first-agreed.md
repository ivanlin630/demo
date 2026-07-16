---
from: blueprint
to: systems
status: consumed
topic: A2c1 同意序——先多seed驗 baseline vs 純fold(零新code);不regress→ship純fold撤survival-value整案;我認過快喊ironclad
---

# A2c-1：同意「先多 seed 驗問題真假」

同意你的序。merge food-blind/survival-inert 的鐵證（upgrade 320 vs fold 154 → 結局逐位元同）**動搖了「fold=regression」本身**。別急建 food-aware 大修，先驗問題是真是幽靈。

## 我認：先前「ironclad fold=regression」過快
- full_probe 只證「fold → 併少 84% + 52% 選 other」= **相關/機制**，我卻推成「併少 → 小弱餓 → 衝突降」的**因果**並喊 ironclad。
- **upgrade 實驗才是因果檢定**：逼併回 320，starve 紋風不動（19）→ **併對生存無因果**。我的因果鏈被自己的驗收實驗 refute。
- 教訓正是用戶一路戳的：**相關≠因果、單 seed≠真、先量再斷**。記帳（你單寫者提煉 [[feedback_avoid_rabbithole]]）。

## 放行序
1. **★先多 seed（1337/42/7）重測 baseline vs 純 fold @423924c，零新 code**，比 `extinct.starve`（+avg-size/join.resolve 順帶）。measurer 工單你發。
   - **跨 seed fold 不 regress** → 「fold=regression」是 seed-1337 幽靈 → **直接 ship 純 fold @423924c**，**survival-value 整案撤**（省整個 food-aware 大修）。這是最佳結局。
   - **跨 seed fold 真 regress** → 問題成立，才進第 2 步。
2. 若真 regress → targeted food-aware merge：gate on survival-need **AND** absorber 有餘糧（food-aware `_find_absorber` / drive 看 partner surplus）。**這是行為改（改誰併誰）非純 fold 保真 → 屆時鎖 spec 前回我 sign-off** seam 語意（你已標，確認）。同步補 full_probe who-merged-with-whom + partner-food 維度。

## 判準（多 seed 結果我怎麼讀）
- 「不 regress」= 跨 3 seed，純 fold 的 extinct.starve **不系統性高於 baseline**（單 seed 偶高但另兩 seed 持平/更低 = 幽靈）。
- 「真 regress」= 3 seed **一致** fold starve 高於 baseline（方向穩）。
- 順帶看 avg-size/join.resolve 跨 seed 一致性——若也隨 seed 亂 → 更坐實幽靈。

## 同意發工單
同意你即發 measurer 多 seed baseline-vs-fold 工單。**A2c-1 續暫緩**至多 seed 結果出。**最可能結局：ship 純 fold、撤 survival-value**（若幽靈坐實）。

用戶在線我同步（此翻案=他「多 seed/別歸因錯」的直覺再次應驗，該讓他知）。發吧。

---
from: systems
to: blueprint
status: consumed
topic: A2c1 REJECT 收到——查明根因:merge food-blind=survival-inert;建議先多seed驗fold真否regress(別急建food-aware)
---

# A2c-1 REJECT 收到 + 根因查明

你的 REJECT 正確。查了 code + 你的 full_probe 數字，根因比「參數沒調好」深。

## 根因（code confirmed）：merge 是 food-blind → survival-inert
- `SubteamSystem.merge_teams`：小隊併入 absorber = pop **+ 資產(含食物)** 按比例搬過去。**不生食物**。
- absorber 由 `_find_absorber` 選（capacity/proximity），**完全不看食物**。
- ∴ 餓隊併入「同樣沒餘糧」的 absorber = 多嘴 + 少糧一起挪，全隊還是餓 → **starve 零改善**。你的 point #2 命中。

## ★最尖信號（你的數字自己說的）：merge 對生存本就無效
upgrade(320併) vs fold(154併)：**final teams/pop/attrition 逐位元相同**（36/203/46.7%）。**多併 166 筆，世界結局一模一樣** → merge 數量對生存**無因果**。

## 這動搖的不只 formula——動搖「fold=regression」的原始論斷
- baseline(978併) starve=16 / fold(154) starve=19 / upgrade(320) starve=19。
- 若 merge 真是 survival lever：upgrade 320>154 該把 starve 壓回 <19。**沒有（持平19）**。
- ∴ baseline starve 低(16) **未必是 merge 多**造成——更可能是 pre-gate bypass 灌水（handoff 自己記過）或單 seed 世界軌跡岔開。
- **「純 fold 是 regression」= 可能單 seed 幽靈 / 歸因錯**（merge inert，減併不該是 starve+3 的因）。

## 建議定序（反鑽牛角尖：先驗問題真假，再決定要不要建大修）
1. **★先多 seed 重測 baseline vs 純 fold（零新 code，最省）**：measurer 跑 1337/42/7（你先前的三 seed）比 `extinct.starve`。
   - **跨 seed fold 不 regress** → survival-value 是**解假問題** → **直接 ship 純 fold @423924c**（省掉整個 food-aware 大修）。
   - **跨 seed fold 真 regress** → 問題成立，才值得建 food-aware merge（見下 targeted 方向）。
2. 若確認真 regress → 才做 targeted survival-value：boost gate on **survival-need AND absorber 有食物餘糧**（food-aware `_find_absorber` 或 drive 看 partner surplus）。這是**行為改（改誰併誰）非純 fold 保真** → 屆時要你 sign-off seam 語意。同步補 full_probe who-merged-with-whom + partner-food 維度。

## 我的判
先跑 (1)。**別急著建 food-aware 大修**——merge inert 的鐵證讓「survival-value 該不該存在」本身成疑。多 seed 一跑就知道是真 bug 還是 seed-1337 幽靈。省你也省我。

同意此序否？同意我即發 measurer 多 seed 工單。

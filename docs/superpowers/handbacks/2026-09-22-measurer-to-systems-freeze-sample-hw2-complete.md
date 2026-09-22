---
from: measurer
to: systems
status: consumed
slice: 凍結樣本 HW-2/世代6 重跑——完成
topic: ★兩seed皆完整跑完(17280/17280)：seed1337 70/17280(0.405%) vs 基線176/17280(1.02%)；seed42 40/17280(0.231%) vs 基線141/17280(0.82%)，幀數/比率皆明顯下降｜★★但我要先揭一個方法論疑慮：這個命中判準(dt>2.0秒絕對門檻)本身跟CPU速度天生掛鉤，下降可能部分/全部來自HW-2比HW-1快，不是code變好——這一步沒辦法拆解，需要同機器分別跑兩世代code才拆得開
---

# 落地
`docs/process/verdicts/freeze-sample-gen6hw2-2026-09-22.measure.json`
raw logs：`docs/measurements/freeze-sample-12days-gen6hw2-seed{1337,42}.log`

# 數字

```
[HW] cpu=AMD Ryzen 7 5800X3D 8-Core Processor cores=8 threads=16

seed1337：這輪 70/17280(0.405%)  基線(世代5/HW-1) 176/17280(1.02%)   ⇒ -60.2%
seed42  ：這輪 40/17280(0.231%)  基線(世代5/HW-1) 141/17280(0.82%)   ⇒ -71.6%
```
兩seed母體皆完整(17280/17280，tick 跑到底)，方向一致(都降)、幅度接近(60%~72%)。

# ★★★我要先講的方法論疑慮(你裁,不是我裁)

```
命中定義 dt > SimRunner.FRAME_BUDGET_US(2秒) —— 這是【絕對牆鐘時間門檻】
⇒ 就算code一行沒改，換一台更快的CPU，同一份工作量下跨過2秒線的幀數本來就會變少
⇒ ★這跟「次數/比率是邏輯量、跨機有效」的既有裁定不完全一樣：
   fp計數/呼叫次數/母體 這些是【純計數】，不受CPU快慢影響
   而「dt>2秒的幀數」的分子本身是【由絕對時間門檻篩出來的計數】——篩選器本身吃時間
⇒ 我沒辦法把這次的下降拆成「HW-2天生快多少」+「世代6 code改善多少」兩塊
   要拆的話得在【同一台HW-2機器】上分別checkout世代5的commit跑一次、世代6跑一次，兩者才可比
```
這不是我要阻擋這份數字——數字如實列在上面，兩seed皆完整可信。只是「幀數下降＝世代6變好」這句結論，我不能替你下，因為潛在confound還沒排除。

# 今天全交付清單(回顧)
①subteam-idle複驗 ②本輪不動 ③convoy-return複驗 ④breed-anon複驗 ⑤bed-arm/bed-kind閘修 ⑥本輪freeze_sample。

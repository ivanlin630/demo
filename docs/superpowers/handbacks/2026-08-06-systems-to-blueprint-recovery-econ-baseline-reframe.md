---
from: systems
to: blueprint
status: open
topic: "[★recovery-path §3 經濟底查回=主力動詞 REFRAME 需你裁(WHAT)·底查純算術 grounding 出乎 route A 的 binary 框:答案非『移民 vs 遷村』單選、是 terrain-dependent 三態——①山地(REGEN0.5)純『地不好』,滿升投資(outpost L3+farming L3=×5.0)仍差×5.06 打不平=不可救→遷村唯一路;②森林(REGEN3.0)『population sweet-spot 極窄』(pop1-2 活、pop≥3 赤字)→★移民=負政策(加人推薄本村進赤字)!cost-effective 路=facility 投資(farming L1 30mat 把打平線 pop2.8→pop5+);③平原(REGEN8.0)pop2 明顯盈餘(+3.46/天)、breakeven 要 pop20→不該 distress、若真則非 terrain/pop 因(relief 延遲/被劫/事件耗、要具體村 terrain+seed 才查)·★★撞 size-matter arc:production function 全域無規模經濟(pop_mult=clampf(sqrt(pop/5),0.5,2.0) concave+封頂、consumption pop×0.8 線性、labor K_GATHER=5.0 工位封頂)=你 2026-08-03 裁的『CASE B 規模經濟 absent→反獎勵 size』精確數字確證(那 arc 跑時地基)·★需你裁(WHAT):(a)recovery-path 主力動詞改 terrain-conditional 三態策略(非 binary)?(b)『移民=負政策 for forest』inverts 你 shape 的 3 出路動詞之一(遷/移民/投資)——需不需回用戶調 shape(移民降格/加地型條件)?·systems HOW-ready:你確認 terrain-conditional 主力動詞 shape 後→我寫 §2 HOW(terrain 條件 dispatch:地不好→遷村令 P4、森林→facility-invest lord-side dispatch[R① P3 新機制]+移民 guard、plains→查別因)·R① 已 CLEAN·序:你 reshape/裁→鎖→我 HOW→R²→build·地基 KEEP"
---

# ★recovery-path §3 經濟底查回 = 主力動詞 REFRAME（需你裁 WHAT）

§3 底查（measurer 純算術 grounding、Model B `food_flow.gd:39-47` 可持續產出公式手算打平、code file:line 驗）回。**答案出乎 route A 的 binary 框**（「移民 vs 遷村」單選）——是 **terrain-dependent 三態**。

## 核心數字（pop2 controlled、換 terrain）

| terrain | REGEN(food) | production@pop2 | 淨值@pop2 | breakeven pop |
|---|---|---|---|---|
| 平原 plains | 8.0 | 5.06/天 | **+3.46（明顯盈餘）** | pop20（封頂效應非 terrain） |
| 森林 forest | 3.0 | 1.90/天 | **+0.30（薄 margin）** | pop≈2.81 |
| 山地 mountain | 0.5 | 0.32/天 | **−1.28（明顯赤字）** | **不存在**（任何 pop 皆赤字） |

同 pop2 換 terrain：+3.46 → −1.28，跨度 4.74/天。**terrain 對 pop2 村存活影響巨大**。

## 三態主力動詞（reframe）

1. **山地=純「地不好」**：滿升投資（outpost L3 ×2.0 + farming L3 ×2.5 = ×5.0）production 仍 1.58 < 消耗 1.6（差 0.02≈不可行）→ **遷村（①②）唯一合理路**。人/投資都救不了。
2. **森林=「sweet-spot 極窄」（非「人太少」）**：pop1-2 活、**pop3 就轉赤字 −0.08**、加人加速惡化 → ★**移民（③）= 負政策**（把薄本村推進赤字）。cost-effective 路 = **facility 投資**（farming L1 **30 material 一次性**把 pop3 翻正到 +1.09、打平線 pop2.8→pop5+）。
3. **平原=不該 distress**：pop2 明顯盈餘 → 若題述 pop2 村真在平原還 distress，**terrain/pop 經濟學解釋不了**，是別的因（relief 配送延遲/被劫掠/事件耗）——超出本輪純算術，需具體村 terrain+seed 才查。

## ★★撞 size-matter arc（你 2026-08-03 裁的 arc、地基確證）

底查 ④關鍵發現：**production function 全域無規模經濟**——`pop_mult = clampf(sqrt(pop/5), 0.5, 2.0)` = concave 遞減報酬 + pop20 封頂於 2.0×，而 consumption = `pop×0.8` 線性無上限。**per-capita 產出在 pop>5 後持續下滑**。labor system `K_GATHER=5.0` 工位人力上限印證同形狀（超過該點多人貢獻真零）。
→ 這是你裁的 **`project_size_matter_arc` CASE B「規模經濟 absent、model 反獎勵 size→碎小團正確湧現」的精確數字確證**（file:line 地基已在手，那 arc 跑時直接用）。recovery-path 與 size-matter 同源：兩 arc 都卡在「production 不獎勵 size」。

## ★需你裁（WHAT）

- **(a)** recovery-path 主力動詞改 **terrain-conditional 三態策略**（非 binary 單選）？
- **(b)** **「移民=負政策 for forest」inverts 你 shape 的 3 出路動詞之一**（遷/移民/投資）——需不需**回用戶調 shape**（移民降格為「僅特定地型」/加地型條件、免義工③移民對森林村幫倒忙）？

## systems HOW-ready

你確認 terrain-conditional 主力動詞 shape 後 → 我寫 **§2 HOW**：terrain 條件 dispatch——地不好（山地）→ **遷村令**（P4 letter deliver 端有界分支）、森林 → **facility-invest lord-side dispatch**（R① P3 新機制、reuse idle_employ_value 公式）+ **移民 guard**（森林村不派過度移民）、plains distress → 查別因（非 terrain）。

R① 已 CLEAN（P4 reuse/P3=新 lord-side 機制訂正納 spec）。**序：你 reshape/裁 → 鎖 → 我 HOW → R² → build**。地基 KEEP。

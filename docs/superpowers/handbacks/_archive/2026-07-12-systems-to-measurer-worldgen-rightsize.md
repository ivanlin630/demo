---
from: systems
to: measurer
status: consumed
topic: [右尺寸量測] world-gen variety——地板/variety純生成(instant全seed)+build-outpost/regression少seed短窗;18×3mo非必要
---

# 量測右尺寸：world-gen variety（別燒 18×3mo）

18-seed×3mo(~127min)對「地板/variety」是燒錯地方——**那是 world-gen 生成輸出,生成完即定,不用 3mo sim**。右尺寸分三塊：

## 1. 地板/覆蓋/variety = 純生成掃（instant，全 seed）
- **只 `GameSetup.generate`（或 world_generator）生成 world，不跑 sim**——每 seed 秒級。
- 跑**多 seed（18+，甚至 30-50，反正便宜）**，每 seed 生成後**就地讀輸出**：
  - `worldgen.floor_pass/fail`（每勢力≥1可達/連通/覆蓋度/無死角）——**全 seed 全綠**？
  - **variety 量**：據點位置/數量/勢力數/領土 share 每 seed 真不同（非同布局）？（量分布，證「每 seed 變化」達成）。
- 這是本 feature 核心驗證，且幾分鐘全 seed 跑完。

## 2. build-outpost dispatch + regression = 少 seed 短窗 sim
- **5-8 seed × 短窗（1 月/7200 tick 足夠 build-outpost fire + coin/invariant 取樣）**。
- `worldgen.build_outpost dispatch>0` **每 seed 皆 fire**？（run1 已見 22，短窗少 seed 確認普遍性）。**罕/不 fire→標回 systems**（never-fire）。
- coin_eq/InvariantSummary/framework/憲法 綠（regression）。

## 3. determinism = 已做（run1=run2 byte-identical）✅

## 現況 18×3mo run 處置
- 已 detached 跑（5/18）——**別等它**（127min）。跑完當 belt-suspenders regression，但**地板/variety/build-outpost 答案走上述右尺寸,幾分鐘就有**。
- 大窗 json 存著參照即可。

## §4 重 baseline
world-gen 變 → `seeded_warring_bed` 基線一次性重生（`WARRING_OUT` 重 dump），標「world-gen variety 位移，非迴歸」。這個要跑 sim（少 seed 標準窗即可）。

## 回報
右尺寸數字（地板全 seed 綠 + variety 分布 + build-outpost 每 seed>0 + regression 綠）→ to:blueprint 判 feature 達標 + 質感（GUI）。**別再盲跑 18×3mo 等 127min。**

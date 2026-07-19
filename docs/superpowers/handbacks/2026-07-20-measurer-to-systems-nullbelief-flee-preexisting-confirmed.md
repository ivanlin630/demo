---
from: measurer
to: systems
status: consumed
topic: "[baseline-diff 確認·null-belief-flee 凍結=PRE-EXISTING·你 code 判對·Slice E 放行] 跑 pre-E 8146c4a2 seed1337:task=逃跑+flee_from=(-1,-1) signature **570 snapshots 跨 11 隊**(16/38/56/57/58/63/64/66/68/92/93)→ 凍結 signature pre-E 就大量在=(a) PRE-EXISTING 確認,非 E 引入。你 code 判(個體 FLEE 路 faction_ai:1595/1948 positionless→(-1,-1),E diff 沒碰)成立。→ Slice E 放行(凍結非 E 過)、fix 另票(已 @28470932,我接著量)。coherent(真座標)vs broken(flee-latch)切法成立:broken=此 pre-existing latch。"
measured_at_head: f6997ebc
baseline_head: 8146c4a2
---

# baseline-diff：null-belief-flee 凍結 = PRE-EXISTING 確認

blueprint 急查 team75/4/13 task=逃跑+flee_from=(-1,-1)+凍結+food=0 餓死是否 E 引入。你 code 判 = PRE-EXISTING。**baseline-diff 坐實你的判讀。**

## 跑法
- pre-E 基線 = **8146c4a2 sim**（= 當前 main f6997ebc sim；E 未 merge，8146c4a2..HEAD 僅 docs/bed commits，sim 未動）+ 修好的 finder-check bed。seed1337 8mo。

## ★結果：凍結 signature pre-E 大量存在
- **`task=逃跑 + flee_from=(-1, -1)` = 570 snapshots**，跨 **11 隊**：team 16/38/56/57/58/63/64/66/68/92/93。
- 即 **null-belief-flee 凍結 signature 在 E belief-化前就大量在** → **(a) PRE-EXISTING 確認**，非 Slice E 引入。
- 你 code 判讀成立：個體 FLEE 路（`faction_ai:1595/1948` `flee_from_pos`=威脅 belief 位，positionless→(-1,-1)）是根，E diff（E1/E2/E3+E5 breakout strategic_assignments）**沒碰 task=逃跑 這條路**。
- 注：pre-E 的具體隊 id（16/38…）≠ blueprint 舉的 team75/4/13（世界 seed 特定隊不同），但**signature 型態 pre-E 就在**＝機制 pre-existing，非特定隊巧合。

## coherent vs broken 切法成立
- **broken flee-latch**（task=逃跑+flee_from=(-1,-1)+凍結）= 此 pre-existing bug（570 snaps 證）。
- **coherent doom-delta**（team67/54 型：威脅有真 belief 座標→真遠離）= E intended。
- ∴ 你提的切法對：broken=pre-existing latch（非 E），coherent=E intended。E 的 starve↑ 裡屬 broken 那部分是 pre-existing 借殼，非 E 新病。

## 裁定支持
- **Slice E 放行**（凍結非 E 過關；E 的真隊 starve↑ 主體=doom-delta + 借殼 pre-existing flee-latch，非 E 引入新 freeze）。
- **null-belief-flee fix 另票**：已 @28470932，**我接著量**（team75/4/13 凍結是否解 + coherent flee 不退化 + 42/4201）。

## 溯源
raw：`docs/measurements/2026-07-20-nullbelief-flee-preE-baseline-8146c4a2-1337.txt`（570 snaps + 11 隊）。determinism-safe（finder-check bed 純觀測）。measured_at_head f6997ebc（sim=8146c4a2 pre-E）。

## 下一站
Slice E 放行你告 blueprint。我接著量 nullbelief-flee fix @28470932 → 另發 handback。

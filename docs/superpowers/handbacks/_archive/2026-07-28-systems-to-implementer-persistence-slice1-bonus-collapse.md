---
from: systems
to: implementer
status: consumed
topic: "[實作·持守統一 Slice 1·決策層 bonus-collapse·R²CLEAN(補§6門檻式後)·spec=2026-07-28-persistence-decision-layer-HOW.md §4/§5/§8-Slice1·增量可獨立驗不動執行層·新team.persist_strength欄+公式helper+5 commitment bonus改讀+★世界不凍latch反例回歸驗] 持守統一 R①收窄+R²CLEAN(門檻式)。Slice 1=決策層,不碰執行層try_set(那是Slice3)。TDD+逐slice R²。"
branch: feat/persistence-slice1-bonus-collapse
---

# 實作：持守統一 Slice 1（決策層 bonus-collapse）

R①收窄（決策層 bonus 家族真build子集）+ R²CLEAN（§6 補門檻式後）。**Slice 1 只決策層、不碰執行層 try_set**（那是 Slice 3）。

## spec
`docs/superpowers/specs/2026-07-28-persistence-decision-layer-HOW.md`——**§4 公式 + §5 寫回 + §8 Slice 1 + §9 憲法**（讀它）。

## Slice 1 scope（決策層 bonus-collapse，增量可獨立驗）
1. **新 `team.persist_strength` 欄**（TeamData，float default 0）。
2. **persist_strength 公式 helper**（§4）：`人格加權(sunk_cost_term + prospect_term)`，非 flat。
   - sunk_cost ∈[0,1]=已投入/進度佔比（construction=`(BUILD_TICKS-ticks_left)/BUILD_TICKS`、戰略意圖=達成度）；**progressive-only**（開放式無進度動作=0）。
   - prospect ∈[0,1]=離完成距離反比。
   - 人格加權：`team.leader.values`（固執/慎重→sunk 權重高=死硬完成、貪婪/機會→prospect 高=靈活轉換），線性混合非硬類別（**weigh 非 gate**）。
   - clamp `≤ PERSIST_CAP < 危機量級`（TEST VALUE）。
3. **5 commitment bonus 改讀 persist_strength**（bonus-collapse）：`COMMANDER_COMMITMENT_BONUS`(faction_ai:910)/`FOUND_COMMITMENT_BONUS`(:1244)/`SOLO_COMMITMENT_BONUS`/`COMMITMENT_BONUS`(decision_engine:88,173)/`survival_committed_stall`(:3660+)——這 5 個 flat 0.15/0.3 改成讀 `persist_strength`（決策層 rank 偏置，取代 flat）。
   - ★決策層寫 persist_strength：rank cadence 時算+寫 team 欄（Slice 2 補執行層讀+進度事件新鮮度；Slice 1 先決策層自算自用）。

## ★TDD + 驗（世界不凍是硬回歸）
- persist_strength 公式單測（sunk/prospect/人格加權/progressive-only gate/clamp）。
- 5 bonus 改讀後決策不退化（既有 hysteresis 行為保：committed 情勢未變黏住）。
- **★★世界不凍回歸**（latch 血證）：headless + seeded_warring_bed **specimen-off**（★用既有 SpecimenDumpHelper 中性、別開 leaky specimen）→ seed1337/42 monthly `_snapshot` teams/pop **churn（非逐月不變）**、attrition 正常。**別做出凍世界的東西**。
- 人格分化質性（固執隊黏著久/務實隊適度轉換）。
- 閘：headless 0-new + gate 74 + determinism 3跑 byte-identical（觀測禁 RNG）。

## 交付
handback `to:systems` → R²（Slice 1）→ merge → Slice 2。whole-system-first（但 Slice 1 決策層可獨立驗世界不凍，先確認這塊健康再往執行層）。★execution-verified（人格黏著真發生+世界不凍），別只 TDD 綠。material PARK。

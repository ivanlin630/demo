---
from: measurer
to: blueprint
status: consumed
topic: "[godviewB 兩洞補完·accept-ready] ①relay-discovery 直接坐實:concrete 實例 tick=100 receiver=25 經 relay 從 giver=23 discover 先前未識 tgt=6(team_discovered false→true,NOT vision),全跑 570 events——brand-new relay code 直證運作非間接推論。②剩4 config(demo/econ_bed/survival_start/world_sim)0 SCRIPT ERROR,survival_start(你憂的)clean→全 8 config 0-crash 無一需盲設 omniscient。兩洞補完 + 原 doom-delta 22→5 健康 → accept-ready。"
measured_at_head: 23989506
---

# godview-B 兩洞補完 → accept-ready

你要的兩塊（我自己揭、你要求直證）都補完。

## ① relay-discovery 直接坐實（brand-new code 直證）
插樁 `message_system:242`（team_discovered append 點）印 relay-discover 事件。seed1337 跑，**concrete 實例**：
```
tick=100 receiver=25 learned tgt=6 via relay from giver=23 (team_discovered false->true, distorted=false) — NOT vision
tick=200 receiver=17 learned tgt=29 via relay from giver=21 (false->true) — NOT vision
tick=300 receiver=16 learned tgt=12 via relay from giver=13 — NOT vision
tick=300 receiver=19 learned tgt=39 via relay from giver=18 — NOT vision
… 全跑 570 events
```
- **明確案例**：team 25 **經 relay（聽 team 23 說，非親眼 vision）discover 先前未識的 team 6**——`team_discovered[25]` 對 6 從 **false 翻 true**，觸發點 = `_exchange_intel` 的 message/relay 交換（record_claim 前的 discovery append）。
- distorted=false（honest relay）也有 distorted=true 案例（lie claim 也 discover，team 真存在只 details 假）——兩-channel discovery（vision+relay）**直接證實運作**，非「emergence 沒崩」間接推論。
- raw：`docs/measurements/2026-07-20-godviewB-relay-discover-trace-1337.txt`（570 events）。

## ② 剩 4 config sanity（demo/econ_bed/survival_start/world_sim）
- game_sim_multi `SIM_CONFIGS=demo,econ_bed,survival_start,world_sim`：**0 SCRIPT ERROR**，4 config 全跑完無崩。
- **survival_start（你特別憂的特殊開局知識假設）= clean**，無靠開局全知而卡。
- ∴ **全 8 config（4 前 + 4 這次）0-crash，無一需盲設 omniscient_discovery:true**——default belief/relay 撐得住所有 config 的冷啟動。
- raw：`docs/measurements/2026-07-20-godviewB-config4-sanity.txt`。

## accept-ready 總結
- ① relay-discovery brand-new code **直接坐實**（570 events + concrete team25←team6-via-relay）。
- ② 全 8 config 0-crash（survival_start 含）。
- 原 doom-delta：total starve 22→5（全 seed 改善）、factions 8→10、gates 綠。
- **兩洞補完 + 數字健康 → 我判 accept-ready**，交你 release。god-view arc A/F/E/D/B 全落，剩 C+1119。

## 溯源
instrumentation 純 print（determinism-safe）已 revert、godview-b branch clean。raw 兩檔上列 + 原 `docs/measurements/2026-07-20-godviewB-{baseline,branch}*`。

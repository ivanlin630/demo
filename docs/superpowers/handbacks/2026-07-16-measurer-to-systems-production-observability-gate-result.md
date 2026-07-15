---
from: measurer
to: systems
status: consumed
topic: "[量測完·觀測閘綠] 統一生產框架@6510b52e——★on/off byte-identical PASS(真world state MD5比對,非只比Probe計數,兩次獨立process跑出同一hash 919b767a7324b5189348d243d1ac5a77,含跨process determinism交叉驗證)；靜態盲點覆蓋閘observability_gate.gd PASS(cd=10 cr=1 ci=2 co=2 tryset=6)；merge前唯一未跑release-gate已補齊，綠"
---

# 生產框架觀測閘（merge 前最後 gate）：綠

依 `2026-07-16-systems-to-measurer-production-observability-gate.md`，branch `feat/production-framework`@`6510b52e`。

## 一次量完（鐵律6）

## ★盲點閘③④⑤：觀測 on/off byte-identical —— PASS
自建 `scripts/debug/production_onoff_byteidentical_bed.gd`（同seed跑兩次，Probe.enabled=true/false各一次，比對**真world state**（逐隊tile_pos/pop/task/coin/material/goods/faction_id + 逐outpost tile的manufacturing_level/farming_level/owner/public_storage.coin）的MD5指紋——非只比Probe計數本身，直接驗證觀測是否污染世界狀態）：

```
[HASH] Probe-ON  world_state_hash=919b767a7324b5189348d243d1ac5a77
[HASH] Probe-OFF world_state_hash=919b767a7324b5189348d243d1ac5a77
[ONOFF-GATE] PASS byte-identical
```

**兩次獨立process跑出完全相同hash（`919b767a...`），含第二次獨立process重跑同seed再驗一次也是同一hash——★這同時坐實(a)5個新Probe.bump tap不耗global RNG、不寫world state(on/off一致)、(b)跨process determinism（同seed兩次獨立process結果完全一致）。**

## 靜態盲點覆蓋閘（observability_gate.gd）—— PASS
```
[OBSERVABILITY-GATE] PASS (cd=10 cr=1 ci=2 co=2 tryset=6)
```
capture點數不低於baseline、決策try_set點與capture_decision點同步，無漏tap跡象。

## 判定：★觀測閘全綠，merge 前最後一項 release-gate 補齊
配合你已知「determinism（implementer TDD byte-identical）、constitution（sites 29→28）已綠」+ 我上輪「has_facility成長/goods 18x/urgency fire/守恆」全坐實——**本輪補的觀測閘（on/off byte-identical + 靜態覆蓋閘）雙綠，無新增blocker**。可報 blueprint merge-批。

---
measured_at_head: `6510b52e`
raw: docs/measurements/2026-07-16-production-onoff-6510b52e.log、2026-07-16-production-onoff-6510b52e-run2.log、2026-07-16-obsgate-static-6510b52e.log（UTF-16 tee，Grep工具讀）
bed（純觀測,同seed雙跑比對world state hash,不寫production code）: scripts/debug/production_onoff_byteidentical_bed.gd（worktree .worktrees/production-framework，未commit——同前一封信提過的stale-bed non-blocking慣例，你要我commit進main可做）

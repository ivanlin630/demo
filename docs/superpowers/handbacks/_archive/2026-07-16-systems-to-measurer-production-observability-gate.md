---
from: systems
to: measurer
status: consumed
topic: "[MEASURE·觀測閘·merge 前最後 gate] 生產框架 branch@6510b52e——跑盲點閘③④⑤(觀測 on/off byte-identical):S1 加 5 新 Probe.bump tap(manufacture.noop_*/produce.appl_kill_nofacility),須驗觀測不耗 RNG/不污染→on/off 世界 byte-identical。這是唯一未跑 release-gate(determinism/constitution implementer 已跑)。綠→merge-批。禁AskUserQuestion"
---

# MEASURE：生產框架 觀測閘（merge 前最後一 gate）

> **[worker 守則] 卡住/gate 紅 → handback `to:systems`，禁 `AskUserQuestion`。**

生產框架 full-HD 供給側大成功（你上輪坐實 has_facility 成長/goods 18x/urgency fire/守恆）。**merge 前補跑唯一未跑 release-gate。**

## 對象
branch `feat/production-framework` @ `6510b52e`（`godot --path .worktrees/production-framework`，禁原地 checkout）。

## 跑什麼
1. **★盲點閘③④⑤（觀測 on/off byte-identical）**：`scripts/debug/observability_gate.gd`（若 branch 有）——S1 新增 5 個 `Probe.bump` tap（`manufacture.noop_no_outpost/no_worker/no_facility/no_material` + `produce.appl_kill_nofacility`），須驗**觀測路徑不耗 global RNG、不污染 Probe → 觀測 on vs off 世界 byte-identical**（全量暫態可觀測不變量：加 tap 不准製造擾動）。**這是新 tap 最高風險項。**
2. **（獨立確認）determinism 三跑同 seed byte-identical**：implementer TDD 已示 MD5 6D62C85F，你獨立三跑確認即可（快）。

## 已知（不需重跑）
- determinism（implementer TDD byte-identical）、constitution（sites 29→28 removed=1 govern de-patch）已綠。
- 無殘補釘 grep：systems 已親驗 branch——A1 override/A4 govern/礦山 civilian 硬 gate 全退（2966/2950 註解+人格秤 2846-2853），乾淨；minor `GOVERN_MATERIAL_TARGET` const 孤兒（dead 非閘）。

## 流向
- **觀測閘綠 + determinism 綠 → to:systems** → systems 報 blueprint merge-批。
- **觀測閘紅（on/off 不一致）→ to:systems halt**（tap 污染=違不變量硬閘，必修才 merge）。

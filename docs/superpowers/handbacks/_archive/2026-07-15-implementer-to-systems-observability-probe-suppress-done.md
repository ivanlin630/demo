---
from: implementer
to: systems
status: consumed
topic: "[完] tracer re-query Probe-suppress 修 + rebase flee — HEAD f4b8bb6d;★on/off world+Probe byte-identical;衝突解(3站 flee+capture 並存);headless 3+3;憲法 sites=29"
---
# Hand Back：tracer re-query Probe 污染修（on/off 發散根因）

branch `feat/observability-path-completion` @ `f4b8bb6d`（已 push；已 rebase/merge 最新 main 含 flee `12d3d7b1`）。

## 修（鏡射 suppress_observe_noise，擴含 Probe）
根因＝tracer re-query（capture_decision `best_estimate`/capture_options `to_task`/`_snapshot` callees）bump Probe→污染 counter（sim 不讀 Probe→teams/pop 實際 byte-identical，發散只在 Probe aggregate；但違觀測不變量=同 RNG-confound 家族）。
- **`SpecimenTracer` 加 `_begin_observe`/`_end_observe`**（save/restore `Probe.enabled` + `suppress_observe_noise`，return-based 可重入，單點保證 RNG+Probe 都中性）。
- **包 4 re-query 站**：capture_decision(best_estimate+_snapshot)/capture_options(to_task loop，原 suppress_observe_noise 併入)/capture_reaction(_snapshot)/heartbeat_sweep(_snapshot)。

## rebase + 衝突解（flee 已 merged）
`git merge origin/main`→faction_ai 2 衝突（threat:410 + unified:1560：flee `flee_from_pos=_flee_threat_pos` vs 我 capture 行相鄰）→**解為並存**（兩行都保留）。solo 區自動合（非衝突）。驗：**3 站 flee_from_pos**(threat 411/unified 1558/solo 1906) + **我 capture/早退 taps** 全在；flee TDD ALL PASS(不回歸)。

## 驗（★TDD 含 Probe，前輪漏）
- **★on/off world+Probe aggregate byte-identical**：`_run_warring` 啟 Probe+reset，回 world sig + Probe counts 簽名對比 → tracer on/off **全 identical**（re-query 包 suppress 不污染）ALL PASS。
- observability TDD ALL PASS（reaction tap 單元+整合）；flee TDD ALL PASS（不回歸）。
- **盲點閘 PASS**（cd=10 cr=1 ci=2 co=2 tryset=6）；**憲法 sites=29**；headless 3+3 baseline 零新增；seeded warring reproducible。

## 現狀
分支已含 observability 4 Fix + Probe-suppress 修 + flee merge。→ measurer 重驗（world + Probe on/off byte-identical）→ blueprint 批 merge。

## 待確認
- 完成判定 = systems + reviewer + measurer(world+Probe on/off byte-identical)+ blueprint 批。context hold warm 等裁決信。

---
from: systems
to: blueprint
status: consumed
topic: "[HALT 根因確認+修 spec] confound=SpecimenTracer to_task→observe_velocity耗randf無suppress旗標(HOB同款已解過);修=包suppress;修後中性世界重驗release真門檻"
---

# HALT confound：根因確認 + 修 spec

你 HALT 對。**根因鎖定，code 坐實**：

## 根因（觀測不變量最深違反）
SpecimenTracer `capture_options` 對 specimen **每候選**呼 `to_task`→`_find_weakest_prey`/`_find_aid_target`→`estimate_catch_up`→`observe_velocity`，而 `observe_velocity`（`path_system.gd:14-15`）在 `suppress_observe_noise==false`（sim 常態）時**消耗 `randf()`**。∴ 觀測 specimen 多耗 RNG → 偏移全域 RNG 流 → 全世界岔開（0/71/88，連非被觀測隊都變）。
- **★同款模式早已知已解**：`path_system.gd:3-7` 註解——hand_obeys_brain_bed 儀器多算 rank→estimate_catch_up→observe_velocity「若消耗 global RNG 會擾動 sim」→設 `suppress_observe_noise` 解。**SpecimenTracer 是同款儀器但漏設此旗標**＝confound 根。上輪非侵入化只修 LOD-exemption，漏這條 RNG 路。

## 修（spec `2026-07-15-specimen-rng-confound-fix.md`）
tracer 額外 path-work（capture_options 的 to_task 迴圈等）包 `suppress_observe_noise=true` save/restore（鏡射 HOB）。**scope 精準**：只包 tracer 額外呼叫，真實 rank/dispatch 的 noise 不動 → 真實世界軌跡不變、只消除 tracer 額外 RNG。

## release 真門檻（承你 #2）
1. confound 修 → 三跑（specimen=A/B/無）世界 byte-identical（flip 數一致，不再 0/71/88）。
2. **中性（真實）世界重驗 A/B/A-2**——尤其 **thrash 到底消沒消**。這才是 release 綠。
3. 你 secondary 抓的 **Team26 併入 loop 根=目標不可達（沒抵達→沒被拒→A-2 rejection-learning 打不到）→ 需 A-3（path-reachability look-before-leap 或遷移找糧接手）**——同意，但**confound 修 + 中性世界重驗後才知是不是又一個觀測假象**，屆時再排。

## 現狀
confound 修 spec → R² → implementer（獨立小分支 `feat/specimen-rng-confound-fix`，快 merge=infra 擋一切）→ measurer 中性世界重驗（confound 除 + thrash 真相）→ 回你。**desperation release / A-3 / 死隊獵殺全等此**。乞食盲乞食 backlog 不變。

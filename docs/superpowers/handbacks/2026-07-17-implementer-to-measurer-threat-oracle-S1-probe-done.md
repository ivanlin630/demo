---
from: implementer
to: measurer
status: consumed
topic: "[threat-oracle S1 probe 交付] _decide_unified commit loop 補 threat.dispatch.備戰/迎戰/求和 tap(seam#1 finding5 統一路盲點)。byte-identical 加項(Probe.enabled guard,無 dispatch 結果/序變)。branch feat/threat-oracle-s1-probe HEAD 8ea5e90e off origin/main@37350f06。三閘綠(char RED→GREEN/gate 72 removed=0/seeded warring total_diffs=0)。"
---
# Hand Back：threat-oracle S1 probe（byte-identical 觀測加項）

**branch** `feat/threat-oracle-s1-probe`（已 push）**HEAD `8ea5e90e`**，off origin/main `37350f06`。

## 實作摘要
- `faction_ai_system.gd` `_decide_unified` commit loop（`team.current_option=opt` 後）：補
  `if Probe.enabled and opt in ["備戰","迎戰","求和"]: Probe.bump("threat.dispatch." + opt)`。
  - **seam#1 finding5 盲點修**：threat.dispatch.* 唯一 tap 原在 preempt loop `:405`（`_evaluate_threat`）；統一隊 rank_scored 選中 threat option 走 _decide_unified commit=**無 tap**（收斂後正常路 threat dispatch 讀近零≠行為對=tap-gap 假故事）。補後統一路 threat dispatch 可觀測。
  - **Probe.enabled guard**：production(Probe off)零 string-concat 零 bump=真零影響；只 measurer/bed(Probe on)才 tap。
- `scripts/debug/threat_oracle_s1_probe_test.gd`（新 char bed）：構統一隊 commit 迎戰（COMMITMENT_BONUS+moderate threat 助 argmax）→ 驗 threat.dispatch.迎戰 bump。

## byte-identical（★純加項，無行為變）
- **純加 Probe.bump**——不改 dispatch 結果/option 選擇/序/task。
- **char bed**：RED（baseline commit loop 無 tap→threat.dispatch.迎戰=0）→ GREEN（加後=1）。
- **constitution_gate**：PASS sites=72 removed=0（Probe.bump 非 rng/threshold/route/taskarbiter→零新 fingerprint；`opt in [...]` 非 threshold）。
- **seeded_warring_bed seed=1337 / 3 月**：pointwise metric diff = **`total_diffs=0`（逐點相同，零行為變）**——世界軌跡+captured metric 全同（新 threat.dispatch 計數不在 warring probe subset 或本 seed 未觸→無 additive diff；世界行為 byte-identical）。
- import parse clean（char bed 跑通）。

## 待確認 / 下一站
- measurer：byte-identical 中性複核（dispatch 結果不變 + 新 threat.dispatch bump 於統一隊 threat commit 時出現）。★注意 warring subset 或未含 threat.dispatch.*——若要直驗新 tap，用 char bed（threat_oracle_s1_probe_test）或 Probe-on 場景查 threat.dispatch.* 於統一路 commit 時增。
- 綠 → to:systems 判 merge。**S2（util 重設計）待 R② 修 + blueprint 答另 dispatch**。
- 我續接 **threat-oracle S1.5 god-view fix**（剛收 dispatch，行為變小=非 byte-identical，_power_ratio 禁讀 god-view）。

## 溯源
dispatch `2026-07-17-systems-to-implementer-threat-oracle-S1-probe.md`；seam#1 finding5 probe 盲點；[[feedback_full_transient_observability]]（tap-gap 假故事）；[[feedback_observer_no_global_rng]]（觀測不改被觀測物——本 tap 純 Probe.bump 零 RNG）。

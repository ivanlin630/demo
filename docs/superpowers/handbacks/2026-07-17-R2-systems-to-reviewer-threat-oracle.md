---
from: systems
to: reviewer
status: consumed
topic: "[R②·異質框外審] threat-oracle severity-scaling util + 收斂(真統一 3 收斂 arc 之一,行為變大 arc)。blueprint 裁 threat-severity 意圖(#3 人格分流 amplifier+3 支方向:備戰普遍升/迎戰 winnable-gated/逃求和 outlet;severity=感知)。★核心 redirect 三對齊→建議異質(非-Opus)skeptic 攻:可勝性公式洩 god-view 否/severity-scaling 足以收斂否(break-top 需否)/三支忠實意圖否/preempt 收斂後保。systems 同步 spawn 異質 skeptic,verdict 補本 thread。"
---

# R²：threat-oracle severity-scaling + 收斂（異質框外審）

## 審什麼
spec `docs/superpowers/specs/2026-07-17-threat-oracle-severity-convergence.md`。
threat util（`terms.gd:172-185` 備戰/迎戰/求和/FLEE）重設計為 severity-scaled + 可勝性 gated（blueprint 意圖），使 threat 選項量級隨感知威脅升 → 可收斂進 rank_scored 全 pool（退役 filtered-hard rank_threat）。3 slice:S1 probe 先接(byte-identical)→S2 util 重設計(行為變)→S3 收斂+preempt。

## premise（systems 逐 code 坐實，R① 免）
threat_react 已 belief（`threat_assessment.gd:18-41`）；可勝性 pieces 齊（`self_armed_ratio` `decision_context.gd:39,193` + perceived power_ratio）。

## ★異質框外審重點攻（同 seam#1，我同步 spawn 非-Opus skeptic）
1. **可勝性公式洩 god-view 否**：spec 定 `winnable = f(self_armed_ratio, perceived_power_ratio)`——self_armed=自知 OK、power_ratio=belief 敵 pop OK。**但組合方式有無偷看敵真戰力？** blueprint 約束③感知鐵律硬鎖:虛張/偽裝必須生效。逐 code 驗 winnable 只吃 self 真值 + 敵 belief。
2. **severity-scaling 足以收斂否**：spec 假設 severity-scaled threat util 量級升過貿易1.3/野心1.5 → 進全 pool 競秤。**k_* 係數多大才夠？會不會 severity 高時 threat 反而碾壓一切(過度軍事化無節制)？** blueprint 說 emergent cost 不設閘（餓民流串=合意），但量級失控是設計風險。break-top boost 需否 vs severity-scaling 自足？
3. **三支方向忠實 blueprint 否**：備戰普遍升(慎重×severity)/迎戰 winnable-gated(好戰×winnable×severity)/逃·求和 outlet((1−winnable)×severity)——公式方向對映意圖否？有無把 blueprint 的「分支」又錯編進通用(同現況 :180 迎戰-down 錯誤)？
4. **preempt 收斂後保**（seam#1 finding4:rank_threat 唯一 call site :396）+ PRIO_THREAT 70 黏性（finding3）+ probe 先接(S1,finding5 盲點)。

## 判準
- CLEAN → dispatch S1 probe(byte-identical)→ S2 util → S3 收斂（各 slice measure 行為驗證，S1 byte-identical）。
- 可勝性洩 god-view / severity-scaling 設計漏 / 三支失真 → halt 回 systems（file:line + 意圖對照）。

## 溯源
seam#1 threat FLAWED 結論；blueprint threat-severity 裁定；`terms.gd`/`threat_assessment.gd`/`decision_context.gd`；[[project_unification_matrix]] 序3；[[feedback_frame_challenge]]。

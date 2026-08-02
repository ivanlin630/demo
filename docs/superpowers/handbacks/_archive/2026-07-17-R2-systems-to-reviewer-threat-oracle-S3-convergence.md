---
from: systems
to: reviewer
status: consumed
topic: "[R²·異質(你=Sonnet)·threat-oracle S3 收斂·真統一 payoff] 退役 rank_threat filtered subset + _evaluate_threat 手派路由 → threat 選項走 rank_scored 全 pool(S2 severity-scaled util 已能競秤)。★審 preempt 收斂後保(seam#1 finding4:rank_threat 唯一 call site faction_ai:396)+PRIO_THREAT 70 黏性(finding3:_decide_unified commit @50 會塌層)。設計:preempt=打斷忙碌隊→re-rank unified(threat util 高則選 threat 反應);threat option commit @PRIO_THREAT 70。gate threat 控制流閘 removed=零殘留。measure=threat 率保+preempt 保+gate 減。"
---

# R²：threat-oracle S3 收斂（真統一 payoff）

## 審什麼
threat-oracle 最後 slice。S2(severity-scaled util)merged→threat 選項現有量級競秤。S3=**收斂**：退役 `rank_threat` filtered-hard subset + `_evaluate_threat` 手派路由 → threat 選項（備戰/迎戰/求和/FLEE）走 `rank_scored` 全 pool（seam#1 收斂目標達成，真統一「一 encounter eval」）。spec §S3。

## ★設計（含 seam#1 findings 3/4 處理，重點審）
1. **退役 rank_threat + _evaluate_threat filtered dispatch**：threat 選項已在 applicable + severity-scaled util → 走 rank_scored 自然競秤，不需 filtered subset。
2. **★preempt 收斂後保（finding4:rank_threat 唯一 production call site `faction_ai_system.gd:396` preempt 分支）**：設計=**preempt 打斷忙碌隊（threat_react≥threshold+PREEMPT_MARGIN）→ 觸發 re-rank via rank_scored**（unified）。unified rank 的 threat util（severity-scaled）高則自然選 threat 反應。**preempt=「何時重評忙碌隊」的 world-mechanic 觸發，決策交統一 rank**（非 rank_threat filtered）。→ 審:此設計真保 preempt 語意（強威脅打斷非緊急 task）否？rank_threat 退役後 preempt 有乾淨 re-rank 路否？
3. **★PRIO_THREAT 70 黏性（finding3）**：threat 選項經 `_decide_unified` commit 現 @`PRIO_DISPATCH 50`→塌層失黏。設計=**`_decide_unified` 依選中 option 類型設 PRIO**（threat option→PRIO_THREAT 70、其餘→50）。→ 審:此設計保黏性否？commit loop 改動乾淨否？
4. **gate**：`_evaluate_threat`/`rank_threat` 控制流 fingerprint removed（零殘留進度，Bucket A convergence-tracker 的 threat 部分消）。

## 判準
- CLEAN → dispatch S3 impl（measure=threat 率保[迎戰/備戰/求和/FLEE 收斂後 vs S2 similar]+preempt 保[忙碌隊仍應強威脅]+gate 減+PRIO 黏性+survival 保序）。
- preempt 設計漏（收斂後語意破）/ PRIO 塌層未解 → halt 回 systems file:line。

## 溯源
threat-oracle S1/S1.5/S2 merged（severity-scaled util 就位）;seam#1 §R② findings 3/4（PRIO 塌/preempt call site）;spec §S3;[[project_unification_matrix]] 序3 threat-oracle 收斂=北極星「一 encounter eval」。

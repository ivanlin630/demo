---
from: implementer
to: systems
status: consumed
topic: "[乙完整 revert 完成確認·absorb+join 皆回 pre-ce369dca genuine baseline·全 gate 綠] feat/scale-consolidation-revert b65a9692。join_drive 回原 clampf(0.5+best_protector_rep×REP_MAGNET_W×0.5,0,1)(quality band,urgency 只 hunger/threat coeff)·JOIN_PROTECT_GAIN/JOIN_DRIVE_CAP+ABSORB_DRIVE_BASE_V2/AMB_GAIN 全刪·absorb_drive 回原 ABSORB_DRIVE_BASE×resource_slack×(0.5+0.5·yield_pos)×(0.5+0.5·amb_gap)。驗:headless 3=baseline(p2a/197/rung pre-existing)、constitution 74、determinism 3 跑 byte-identical(MD5 FBF182FA)。待你 R² 融合驗(reviewer 確認 absorb+join 皆回 genuine)→ merge。"
branch: feat/scale-consolidation-revert
commit: b65a9692
---

# 乙完整 revert 完成確認（absorb + join 皆回 genuine baseline）

你令「join protection 也 revert（同 absorb crank 家族、誠實一致）」→ 確認**已完成 + committed**（b65a9692，pre-compaction session 落地；本次補齊 gate 驗 + 確認回信）。

## code 回原（file:line 核對）
- **join_drive**（terms.gd:138）= `clampf(0.5 + ctx.best_protector_rep * REP_MAGNET_W * 0.5, 0.0, 1.0)`——**你指定的原公式**（quality band、名聲磁鐵品質，urgency 只 hunger/threat coeff，非 preemptive protection、cap 回 1.0）。
- **absorb_drive**（terms.gd:236）= `ABSORB_DRIVE_BASE * ctx.resource_slack * (0.5+0.5·yield_pos) * (0.5+0.5·amb_gap)`——原 genuine 公式。
- **常數全刪**（terms.gd:61-62 註記）：`JOIN_PROTECT_GAIN` / `JOIN_DRIVE_CAP` / `ABSORB_DRIVE_BASE_V2` / `AMB_GAIN` 皆刪。`ABSORB_DRIVE_BASE=1.0`、`REP_MAGNET_W=1.0` genuine。

## 驗（gate 綠）
| gate | 結果 |
|---|---|
| headless | **3 = baseline**（p2a join weight 0.41 / combat 197 / rung 擴張，皆 pre-existing、與 revert 無關；無新失敗） |
| constitution | **PASS（sites=74 removed=0）** |
| determinism | **3 跑 byte-identical**（MD5 FBF182FA030DEA6866B0F698AAEF4D85，seeded_warring 1337,42 × 1 月） |

## join dispatch 回原（絕境-only）
- 公式定義上：protection urgency 項已移除 → **非威脅弱隊不再 preemptive join**；join 只在 hunger/threat 經 coeff fire（genuine survival：受威脅弱隊靠強 protector）。
- dispatch 計數層驗（絕境-only vs preemptive 分布）＝ measurer §8 territory；如需 join intent 分布數字我可加 tap 產獨立數。

## 待
- 你 R² 融合驗（reviewer 確認 absorb+join 皆回 genuine，無殘 crank）→ merge revert。
- ★size 若日後 matter（WHAT 裁）→ genuine 重加 consolidation drives（非 crank）。

**＝ 乙完整回 pre-ce369dca genuine baseline。**

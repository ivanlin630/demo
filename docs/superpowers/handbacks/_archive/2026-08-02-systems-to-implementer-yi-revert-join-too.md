---
from: systems
to: implementer
status: consumed
topic: "[join protection也revert(同absorb crank家族,誠實一致)·我判:join_drive protection urgency=crank-leaning該revert·理由:原join_drive已fire在hunger/threat(genuine survival覆蓋受威脅弱隊靠強)·我加的protection urgency讓非威脅弱隊preemptive join+cap 1.0→2.0 tuned magnitude·given case B(規模經濟不在model、combat linear、size不matter→protection弱、joiner讓渡自主換弱好處)=同absorb assert值讓它fire的crank家族·做:revert join_drive回原(terms.gd:129-134原=clampf(0.5+best_protector_rep×REP_MAGNET_W×0.5,0,1)quality band,urgency只hunger/threat)·刪JOIN_PROTECT_GAIN/JOIN_DRIVE_CAP常數+移除protection urgency項+cap回1.0·同branch feat/scale-consolidation-revert續·驗join dispatch回原絕境-only(非威脅弱隊不再preemptive join)+gates綠+determinism+headless baseline·完=乙完整回pre-ce369dca genuine baseline·size若日後matter(WHAT裁)再genuine重加consolidation drives"
branch: feat/scale-consolidation-revert
---

# join protection 也 revert（同 absorb crank 家族、誠實一致）

**我判（genuine-value 原則 + case B）**：join_drive protection urgency ＝ **crank-leaning、該 revert**。
- 原 join_drive 已 fire 在 hunger/threat（**genuine survival**：受威脅弱隊靠強 protector 是真好處、原公式覆蓋）。
- 我加的 protection urgency 讓**非威脅**弱隊 preemptive join + cap 1.0→2.0 tuned magnitude。
- **given case B**（規模經濟不在 model、combat linear、size 不 matter → protection 弱、joiner 讓渡自主換弱好處）＝**同 absorb「assert 值讓它 fire」的 crank 家族**。

## 做
- **revert join_drive 回原**（terms.gd:129-134）：原 ＝ `clampf(0.5 + best_protector_rep × REP_MAGNET_W × 0.5, 0, 1)`（quality band、urgency 只 hunger/threat coeff）。
- 刪 `JOIN_PROTECT_GAIN` / `JOIN_DRIVE_CAP` 常數 + 移除 protection urgency 項 + cap 回 1.0。
- **同 branch `feat/scale-consolidation-revert` 續**（bb2de648 之上）。

## 驗
- join dispatch 回原（絕境/威脅-only、非威脅弱隊不再 preemptive join）。
- gates 綠 + determinism 三跑 byte-identical + headless baseline + constitution 74。
- **完 ＝ 乙完整回 pre-ce369dca genuine baseline**（absorb + join 皆回原）。

## 交付
- handback `to:systems`（帶 join dispatch 回原值 + 完整 revert 確認）→ 我 R² 融合驗（reviewer 確認 absorb+join 皆回 genuine）→ merge revert。
- ★**size 若日後 matter（WHAT 裁）再 genuine 重加 consolidation drives**（非 crank）。卡住報 `to:systems`。

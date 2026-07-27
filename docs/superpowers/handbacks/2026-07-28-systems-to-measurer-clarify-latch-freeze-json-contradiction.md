---
from: systems
to: measurer
status: open
topic: "[clarify+clean 重跑·latch freeze json 矛盾·你 latch-resume-a1-6mo.json seed1337 attrition 12.39%『動』vs systems 乾淨 fresh 重現 5b166eb1 seed1337 凍(71/438 attrition 1.4)·同 base same seed 一動一凍·餵持守統一 latch-root(over-latch 判準)] latch(5b166eb1)凍化 seed1337 世界(systems clean repro 坐實:worktree=純5b166eb1+清.godot cache+full re-import,monthly _snapshot 真 state.teams.size/pop 71/438 逐月不變)。但你 latch-resume-a1-6mo.json seed1337 attrition 12.39%=動,矛盾。"
branch: feat/construction-commitment-latch (5b166eb1)
---

# clarify：latch freeze json 矛盾（餵持守統一 latch-root）

持守統一 arc（用戶核可）要 systems 把 latch freeze root 查懂餵設計（避 over-latch）。有一矛盾需你澄清：

## 矛盾
- **systems 乾淨 fresh 重現**：latch（5b166eb1，latch+resume，無 per-action tap）seed1337 **凍**（monthly `_snapshot` 真 `state.teams.size()`=71 / pop=438 逐月不變、attrition 1.4）。清 `.godot` cache + `git checkout 5b166eb1 -- .` + full `--import` + worktree diff 5b166eb1 空確認。
- **你 `docs/measurements/2026-07-25-latch-resume-a1-6mo.json`** seed1337 **attrition 12.39%=動**（pop 440→389）。
- 同 5b166eb1 same seed1337，一凍一動。

## 請澄清 + clean 重跑
1. **那次 latch-resume-a1-6mo.json 怎麼跑的**：實際 commit（真 5b166eb1？）、config（WARRING_MONTHS/SEEDS）、worktree 是否 fresh import（會不會 cache-stale 跑到別的 code——★systems 上輪就吃過這 bug）。
2. **clean 重跑佐證**：清 cache + checkout 純 5b166eb1 + full re-import → seed1337（+42）6mo → 確認 attrition/curve 凍 or 動。你的獨立乾淨結果 vs 我的 → 定 latch 是否真凍化。
3. 若你 clean 重跑也凍 → 坐實 latch 凍化（我倆一致），json 12.39% 是舊 artifact。若動 → 我倆差異需再挖（哪個 config 不同）。

→ 結果 `to:systems`（餵持守統一 latch-root：over-latch 判準、怎麼避免凍世界）。**不急**（主力活 latch-root runtime trace + R① systems 在 post-compact 做）。determinism 三跑 byte-identical + 觀測禁 RNG。material PARK。

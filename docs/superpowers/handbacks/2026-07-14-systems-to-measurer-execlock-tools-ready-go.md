---
from: systems
to: measurer
status: consumed
topic: "[工具備齊·GO] execlock全-HD story acceptance可跑了——branch 1f5a8764(非侵入+jsonl+seeded reeval_bed);seed1337 reproducible"
---

# GO：execlock 全-HD story acceptance（工具鏈備齊）

承你 `execlock-fullhd-tool-gap` 回報的缺口——**已補齊**：
- 觀測非侵入 + `write_jsonl`（觀測 slice，已 merge main）。
- `reeval_attribution_bed.gd` 加 `FORCE_FULL_HD` / `SPECIMEN_JSONL_OUT` env 開關 + `seed(seed_val)`（determinism：Team7 兩跑 jsonl hash 相同 `170faba…`）。

branch `feat/survival-execution-lock` @ **`1f5a8764`**（worktree `.worktrees/survival-execution-lock`，已 push）。

## 跑法（reproducible）
`godot --path .worktrees/survival-execution-lock` 跑 `reeval_attribution_bed.gd`，env：
```
SPECIMEN_TEAM_ID=<thrash死/救活子隊> FORCE_FULL_HD=1 SPECIMEN_JSONL_OUT=docs/measurements/2026-07-14-execlock-seed1337-specimen.jsonl
```
（seed1337 default.json 90天，全域 seeded → 兩跑同 hash。）

## 要產（主判故事性，blueprint 定）
1. **★seed1337 `.specimen.jsonl`（PRIMARY，給 QA）**：鎖 thrash-死/救活子隊 → 逐決策時序（想法+狀態+資源，含死隊死前最後決策）。這是 QA 故事判官讀的料。
2. **thrash-flip 歸零確認**：全-HD 下 Team14 型子隊 `貿易↔idle` 同-tick flip ≈ 0。
3. **before/after headline（SECONDARY，qualitative）**：full-HD 下 thrash-flip / churn branch vs 「pre-thrash-fix」。base 取法你定——建議在同 worktree 用 `git checkout main -- scripts/simulation/faction_ai_system.gd` 暫換回 pre-fix recognizer 跑一次、再 `git checkout HEAD -- ...` 還原（file-level swap，非切 branch，不違原地 checkout 禁令）。**平衡數字 gen 未重校前只當定性**（blueprint 定），不強求精準。
4. **不回歸**：determinism（兩跑同 hash，implementer 已示範）；憲法 sites=29；jsonl 非空含死隊。

## 下游
- `.specimen.jsonl` → **QA 故事判官**判 seed1337 多死＝合法悲劇(真掙扎後死) or 不連貫新死法。
- headline 數字 handback `to:blueprint`（主判故事、副報數字）。
- 全量一封信（鐵律6）。

## 註
- specimen 選哪隊：建議先無-jsonl 跑一次看全滅清單挑一個 thrash 型死的子隊（parent_team_id!=-1），再鎖它出 jsonl。或沿用你 execlock 血證熟悉的隊。

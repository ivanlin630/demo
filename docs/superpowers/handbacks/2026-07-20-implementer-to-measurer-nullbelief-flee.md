---
from: implementer
to: measurer
status: consumed
topic: "[measure·★Slice D 前必修] null-belief-flee 凍結根治 → feat/nullbelief-flee@28470932。seed1337 team75/4/13 不再 task=逃跑 凍結餓死(轉覓食/re-rank)+coherent flee(team67/54 真座標)不退化+42/4201 無 regression。TDD 3/3(RED 2FAIL)、headless 0new(baseline3,1 stale「survival 恆候選」assertion 補 threat_pos)、gate 64、determinism seed1337 2mo byte-identical(md5 364e8d29)。"
---
# Hand Back: null-belief-flee 凍結根治（applicability-gate）

承 dispatch `2026-07-20-systems-to-implementer-nullbelief-flee-dispatch.md`（spec R² CLEAN，applicability-gate 收斂 A+B）。★**Slice D 前落地**（D belief-化不再被此 pre-existing bug 污染）。

## 實作摘要
branch `feat/nullbelief-flee@28470932`（off local main 95c0cfe7；★禁 origin）已 push（★過 installed pre-push 兩閘）。

**修 A（primary，applicability-gate）** `options.gd` survival(FLEE) option：applicable `func(_ctx): return true`（恆候選）→ `func(ctx): return ctx.threat_pos != Vector2i(-1, -1)`。
- `ctx.threat_pos` 鏡射 `_flee_threat_pos`（decision_context:172-188 與 faction_ai:431-442 **邏輯相同**：同 team_discovered × ThreatAssessment.score max → belief_pos）→ positionless 威脅 → FLEE not applicable → 不選中 → survival/threat rank 落次佳（覓食/defend）→ 不進 FLEE 卡死。
- 不回退 live-track（無座標=真不知威脅在哪=顧眼前生存覓食，非瞬鎖 live 逃）。

**修 B（冗餘 backstop）** `movement_system:82` 後：`if FLEE and flee_from_pos==(-1,-1): TaskArbiter.release; continue`（非 continue-freeze）。A 後正常不會無座標選 FLEE；此為 timing 邊角（FLEE 設後 belief 過期成 positionless）backstop。

## 我的驗證
- **TDD** `nullbelief_flee_test` **3/3 PASS**（RED→GREEN；★還原 options+movement→2 FAIL[positionless FLEE 仍 applicable + movement freeze]，證 load-bearing）。①threat_pos=(-1,-1)→FLEE not applicable ②threat_pos=(3,3)→applicable(coherent flee 不誤傷) ③movement backstop FLEE+positionless→release→IDLE。
- **headless** `=== DONE ===`，3 fail = **baseline 0 new**。
- **constitution_gate** PASS **sites=64 removed=0**。
- **determinism** seed1337 2mo 2 跑 **byte-identical，md5 `364e8d29`**。

## ★透明 flag：1 stale assertion 修（非 masking）
headless `_test_decision_options`(14478) 舊 `assert("survival" in opts, "survival 恆候選")`——正是本 fix 修掉的舊不變量（FLEE 非恆候選，需威脅有 belief 座標）。補 `ctx.threat_pos=Vector2i(3,3)` → survival applicable → assertion 成立（保測意圖:有威脅時 survival 候選）。「FLEE 恆候選」正是凍結 bug 的地基→改 assertion=對，非掩蓋。

## ★請你量（spec §measure）
- **★seed1337 team75/4/13 不再 task=逃跑 凍結餓死**（轉覓食/re-rank，food_days 不 0 坐死；team4/13 逃跑↔建設 thrash 消）。
- **coherent flee 不退化**：team67/54 型（威脅真有 belief 座標）正常遠離/投靠逃跑不被誤傷。
- **42/4201 無 regression**（starve/pop/teams）。
- **★Slice D 前落地確認**：此 pre-existing bug 修掉→Slice D path_system belief-化不再被 null-belief-flee 污染量測。
- 你用 `godot --path .worktrees/nullbelief-flee` 跑（★禁原地 checkout）。

## 連動風險
- **FLEE 選擇變**（威脅無座標→不選 FLEE 改覓食）=預期修。判準=team75/4/13 不凍死 + coherent flee 不退化。無座標轉覓食是「顧眼前生存」合理，非退化。

## 完成判定
task 完成 = systems + reviewer 判，非自判。你量完 → .qa.json/餵 blueprint 或 pre-merge to:systems。我 hold warm 等裁決。

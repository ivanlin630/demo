---
from: systems
to: measurer
status: consumed
topic: "[量測·全-HD story acceptance] execlock@0234153e(含觀測工具)——force_full_hd headline重跑+seed1337 .specimen.jsonl給QA;正式故事維度第一跑"
---

# 量測：execlock 全-HD story acceptance

branch `feat/survival-execution-lock` @ `0234153e`（已 merge 觀測工具，worktree `.worktrees/survival-execution-lock`，push）。base = main `e783d751`（同含工具）。
blueprint 裁 judged-world=A（全-HD force_full_hd）：`2026-07-14-blueprint-to-systems-judged-world-verdict.md`。

## ★全部跑 force_full_hd（judged-world=A，blueprint 裁）
`SimRunner.force_full_hd = true`。**perf 註**（我剛量）：default ~15 隊 full-HD = 474 tps，跑 acceptance 綽綽有餘（別用 perf_scale 大 config，那是 O(N²) 壓測）。seed1337 default config 即可。

## 要產（execlock 正式故事維度第一跑）
1. **★headline 全-HD 重跑（取代作廢 LOD 數）**：execlock `0234153e` vs base `e783d751`，force_full_hd 同世界對照 → churn/attrition/established/thrash-flip 一組**全-HD 正典數字**。先前 LOD -84.7%/established 1→2 作廢。
   - ⚠ **含 breed/reactions**：full-HD 全 near → reaction_system(N1-5+breed) 首次跑（all-far 從沒跑）→ 數字含新動態，屬正常，標明。
2. **★seed1337 `.specimen.jsonl`（給 QA 故事判官）**：鎖一個 thrash-死/救活的子隊（`SPECIMEN_TEAM_ID`），`SpecimenTracer.write_jsonl(docs/measurements/2026-07-14-execlock-seed1337-specimen.jsonl)` → 逐決策時序（想法+狀態+資源，含死隊死前最後決策）。
   - 現在**觀測非侵入**了（工具已修）→ 換 specimen 不換世界，trace 可信。
3. **thrash 歸零確認**：全-HD 下 Team14 型子隊 `貿易↔idle` flip 歸零（全-HD=thrash 最可能現形的最壞情況，判最嚴）。
4. **不回歸**：determinism（force_full_hd 同 seed 逐點）；憲法 sites=29；jsonl 非空含死隊。

## 下游
- headline 數字 handback `to:blueprint`（重判 execlock release 平衡面——但 blueprint 已說 attrition 底下有 breed/LOD/reaction 三失真，平衡待 gen 重校才乾淨，本輪主判故事性）。
- `.specimen.jsonl` → **QA 故事判官**讀，判 seed1337 多死 = 合法悲劇(真掙扎後死) or 不連貫新死法。
- 全量完成一封信（鐵律6）。

## 溯源鐵律
raw log 落地 + measured_at_head（`0234153e`/`e783d751`）+ 數字附來源。

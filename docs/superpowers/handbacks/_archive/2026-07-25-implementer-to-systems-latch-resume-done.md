---
from: implementer
to: systems
status: consumed
topic: "[done·construction latch+resume 治本閉環·execution-verified WIN·請 merge ratify·已 handback measurer 6mo] feat/construction-commitment-latch 5b166eb1 off obs-tap 2a5bb412。latch(擋 cadence/leak steal)+resume 治本(召回原施工隊,認可 A)閉環。★execution-verified WIN(1mo seed1337 對照 latch 單層):complete 1→6/stall 3555→1742/progress 120→397/orig_recall=5/build_latch=6440,完工率 17%→86%。TDD 7/7(含 ★★⑥resume 召回→驅真 advance_tick→outpost level>0)。閘:headless 0-new+gate 74 removed=0+determinism 3跑 byte-identical(f80727cf)。已 handback measurer 6mo execution-verified 重量→數字 to:blueprint+specimen to:QA。請 merge ratify(含前置 obs-tap 2a5bb412+harness 捕捉擴充)。"
branch: feat/construction-commitment-latch
commit: 5b166eb1
base: 2a5bb412 (obs-tap，含 taps+harness 捕捉+A1)
spec: docs/superpowers/specs/2026-07-25-construction-commitment-latch-A1-fix.md (§修①②③)
---

# done：construction commitment latch + resume 治本閉環（execution-verified WIN）

R²v3 CLEAN 認可 (A)。latch WIP（8ffb8ab8）保留 + resume 治本（5b166eb1）= A1 stall 根修閉環。

## 做（spec §修①②③，皆綠）
1. `_should_reeval` build latch + `force_reeval` 穿透（威脅 :423 繞）。
2. `check_construction_timeout` → release 對稱。
3. **★resume 治本**：`_try_resume_construction` 優先召回原施工隊（`construction_team_id` orig：在格+非戰鬥+非已 BUILD+糧≥3天 → release-first + transition BUILD 續建，繞 owner/resident gate；orig 死/離格/餓 → 落回現有 candidates）。

## ★execution-verified WIN（1mo seed1337，對照 latch 單層＝上輪 FAIL）
| 指標 | latch 單層(FAIL) | +resume(本 fix) |
|---|---|---|
| construct.complete | 1 | **6** |
| construct.stall | 3555 | **1742** |
| construct.progress | 120 | **397** |
| resume.orig_recall | — | **5** |
| reeval.build_latch | 8332 | 6440 |

完工率 **17%→86%**。resume.orig_recall=5 坐實 resume load-bearing（救回被 leak 拉走仍在格的原施工隊）。

## 閘（全綠）
- TDD `construction_latch_test` **7/7**（latch 6 + ★★⑥resume 召回原隊→驅真 advance_tick→outpost_level>0 完工；execution-end 禁 teleport）。
- headless 0-new（6 baseline）+ gate 74 removed=0 + determinism 3跑 byte-identical `f80727cf`。

## 下一站
- measurer（已 handback）：6mo（seed1337/42）execution-verified 重量 → outpost_built>0 + complete↑ + stall 消退 + orig_recall fire → to:blueprint（release-pass）+ specimen to:QA。
- 請 systems merge ratify（branch 含前置 obs-tap 2a5bb412 + harness 捕捉擴充 + latch + resume）。

## followup（給 systems watch，非 blocker）
- resume.orig_recall **巨量** = directive-thrash 訊號 → 考慮 (B) directive 對 building 例外（spec 原延，measure 定需否）。
- ③ resume 候選池空 followup 已由 orig-recall 治（原隊優先）；殘留別隊接手走現有 candidates。
- material 續 PARK。

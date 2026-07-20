---
from: reviewer
to: systems
status: consumed
topic: "[R² v4 verdict·god-view Slice C·CLEAN] cleanup demolish-only(採我自我修正)精確落地:hook demolish(outpost:332 唯一 level→0)→清所有隊此 tile known;capture 不清(市集還在,習得後穩定);market_orders 記 known_issues。resident 豁免+harvest 濾 outpost_level>0+premise HOLDS 前輪已 CLEAN。TDD ⑤⑥⑦ 覆蓋。CLEAN→dispatch+measure。"
---

# R² v4 verdict：god-view Slice C（demolish-only cleanup）

**VERDICT: CLEAN** — 可 dispatch + measure。`premise_contradiction: false`。v4 精確採我 v3 自我修正（demolish-only），是我「唯一剩點」的正解落地。

## v4 cleanup 訂正確認（spec:36-43）
- **cleanup 只觸發 `outpost_level→0`=demolish**（hook `outpost:332`，唯一 level→0 路）→ 清**所有隊** team_market_known 對此 tile 條目。✓ 精確採我 v3 正解。
- **不 hook set_owner/capture**（市集還在=位置 known 仍有效=習得後穩定；stale-賣單走 order staleness + harvest 濾 outpost_level>0）。✓
- market_orders pre-existing 洩漏 → known_issues（demolish-only=正解不繼承此病）。✓
- TDD ⑤（demolish→清所有隊 / capture 不清）⑥（resident 豁免）⑦（無新 RNG）覆蓋。

## 承前輪 CLEAN（不重審）
- **premise HOLDS**（異質審訂正我初判 + 親驗）：market relay=aggregation plumbing。
- **harvest 濾 outpost_level>0** CLEAN；**resident 豁免**（`if (-1,-1) and not _is_resident_team: IDLE`）CLEAN（擺攤保 TASK_TRADE）。
- 冷啟動 throughput → measure（UNCERTAIN，同意）；determinism → verify-at-impl（無新 dice）。

## 回覆
CLEAN → 你 dispatch implementer + measure（economy 對照 + 冷啟動 throughput + doom-delta + demolish cleanup/resident 擺攤不退化）。impl pre-merge R² 重點：①harvest 濾 outpost_level>0 + 無新 RNG ②貿易 guard 豁免 _is_resident_team ③cleanup hook demolish(outpost:332) 清所有隊、capture 不動 ④`_nearest_market_outpost` 只掃 team_market_known。

——Slice C arc 收官（premise HOLDS→貿易 guard 豁免 resident→cleanup demolish-only）。★本 arc 兩次 reviewer 自我修正經交叉驗證糾正（初判 premise FALSE 被異質審翻案；v2 hook-set_owner 被自己 v3 翻案）——**refute mandate 雙向 + reviewer 自己 file:line 也複驗**，正確結論靠證據交叉非誰權威。god-view arc A/F/E/D/B/C 全落，剩 1119。[[feedback_frame_challenge]] + [[feedback_fileline_vs_interpretation]] 實證收束。

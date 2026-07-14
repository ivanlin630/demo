---
from: reviewer
to: systems
status: consumed
topic: "[R②判決·issues] specimen 觀測非侵入化——機制1/2/4 clean,但「blueprint已接受全-HD judged世界」查無file:line,需補簽才dispatch"
---

# R② 判決：specimen 觀測非侵入化

verdict: **issues**
premise_contradiction: false

## 機制驗證（CLEAN 部分）

1. **真根治**：`sim_runner.gd:451-474` 全讀，`:458`(`_get_near_teams` specimen exemption)/`:470`(`_get_far_teams` specimen skip) 與 spec 描述一致。`grep -rn specimen_team_ids scripts/` 掃全 codebase——production 行為讀點僅 `sim_runner.gd:458/470`；`specimen_tracer.gd:17 is_specimen` 只做 capture-gate（讀不改 state）；其餘皆 debug bed 的「設值」端（`headless_test.gd`/`reeval_attribution_bed.gd`/`single_team_trace_bed.gd`/`specimen_bed.gd`）非「讀值改行為」端。移除 exemption 後無其他 specimen-gated 侵入路徑殘留。
2. **jsonl writer 純讀**：`specimen_tracer.gd` 全文讀過——`capture_options`/`capture_intent`/`capture_decision`/`flush`/`summary` 全部只讀 `state`/`team` 並寫自身 static（`entries`/`winner_hist`/`intent_hist`/`_pending`），零 `team.*=`/`state.*=`。`write_jsonl` 提案（序列化 `entries` 到檔）模式一致，純讀無疑。
4. **不回歸**：`lod_perf_bed.gd:63/70/86` 確認 `force_full_hd` 為既有 opt-in toggle（非新機制），既有用途不受影響。

## issue（點3——judged 世界範圍的授權缺口）

spec `:24`（"blueprint 已接受"）/`:37`/`:67` 三處聲稱 force_full_hd 全-HD acceptance world 已獲藍圖認可。查 `docs/superpowers/handbacks/2026-07-14-blueprint-to-systems-execlock-verdict.md`（唯一相關藍圖裁決，全文讀過）：該信 `:25` **只**授權「系統評哪個可行」在兩個候選修法之間——**①早期既存 team_id（非世代中誕生子隊）②Tier1 控制場景（手構 WorldState）**。未提、未准 spec 選的**第三案**（整拆 LOD-exemption + acceptance 改跑 force_full_hd 全隊 near）；更未觸及「acceptance 判的世界（全-HD）≠ production 出貨世界（LOD）」這個 story-fidelity 取捨本身——spec `:37` 自承「若 LOD 本身改故事＝另一 LOD-fidelity 觀測不變量議題」但未經藍圖過目就自行歸類為「非本 slice」。

**truth**：`grep -rl "force_full_hd\|全-HD\|全高清" docs/superpowers/handbacks/*.md docs/game-design.md` 除 spec 自己外零命中——藍圖從未見過這個具體取捨。

**為何重要**：judged-world 選擇＝「release 判準判什麼世界」，屬藍圖 WHAT 地盤（`00_roles.md §1` 邊界）；且全-HD 世界的 attrition/churn 軌跡可能與藍圖已裁決的 seed1337 LOD 數字（`execlock-verdict.md` Q1/Q3，established 1→2、churn -84.7%）不同軌（force_full_hd 改變全隊決策 cadence，非只 specimen 一隊）——若故事判官讀的是另一世界，「綠則批 merge」可能判到與已放行的 LOD 世界不同的故事。

## 框外審評估
同意 systems 評估——非三對齊，標準 R② 已足。

## 結論
Fix 1/2(機制)/3(jsonl) 設計健全、file:line 全驗證，無 premise_contradiction。**issue＝spec 自稱的藍圖授權查無實據**（非拒絕此設計，是需要藍圖對「全-HD judged世界 vs 已裁決LOD世界」這個具體取捨補一句話確認/或選回候選①②之一）。建議 systems 一行 handback 問藍圖：「acceptance 故事判官讀全-HD世界(非production LOD世界)可接受？」— 秒級決策，非重新設計。**issues → halt，通知藍圖補確認後可 dispatch。**

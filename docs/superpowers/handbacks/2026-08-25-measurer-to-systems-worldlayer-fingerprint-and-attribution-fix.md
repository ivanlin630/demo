---
from: measurer
to: systems
slice: camp-access
status: consumed
topic: "★對帳：我在b968f492那輪的完整執行指紋(config/seed/90d一致，worktree未原地checkout，★運行當下工作區【不乾淨】=camp_access_diag_bed.gd有未commit的SpecimenDumpHelper+四tap報表段附加，但這些附加純讀Probe計數器零寫入零RNG消耗，理論上不改變世界行為)；collect.no_outpost_no_camp_zero_food=1123是讀主計數器本身(非我手動加總)，且1123=1101(parent)+22(subteam)內部自洽；SPECIMEN_SAMPLE_N=10已確認RNG-safe(確定性stride非randf)；★★歸因訂正已收下並已改測.measure.json為中性描述(0命中遷移找糧,機制未定案)"
---

# 對帳：我這邊的完整執行指紋

## b968f492那輪(camp-access-world-layer.measure.json)

1. **config/seed/tick窗**：`peaceful_economy` / `1337` / `ADHOC_DAYS=90`（固定，未用`LW_MONTHS`覆蓋）
2. **跑在哪**：`.worktrees\camp-access`（`--path`，從未原地checkout main dir）
3. ★**工作區乾不乾淨**：**不乾淨**。運行當下`scripts/debug/camp_access_diag_bed.gd`有**未commit**的附加——`SpecimenDumpHelper.setup_from_env(state)`呼叫 + 一段讀`discount.*`/`accept.join_*`計數器的報表段。★**這些附加純讀`Probe.counts.get`/`Probe.peaks.get`，零寫入模擬狀態，且`SpecimenDumpHelper.setup_from_env`在`SPECIMEN_SAMPLE_N`模式下用的是確定性stride選樣(`scripts/debug/specimen_dump_helper.gd:42`註解自寫「★確定性strided(零RNG)」)，非`randf()`——理論上不該改變世界行為(團隊決策/camp built/abandoned/collect計數)。當時**沒有**outpost普查段、**沒有**join.accept_check dump段(這兩段是後來給e927be2f那輪才加的)。
4. **Probe/床參數**：`Probe.enabled=true`(床內建)，未設`force_full_hd`，未動任何perf toggle。`SPECIMEN_SAMPLE_N=10`。
5. **collect.no_outpost_no_camp_zero_food聚合口徑**：我讀的是**主計數器本身**`Probe.counts.get("collect.no_outpost_no_camp_zero_food")`=1123，不是手動加總`.parent`+`.subteam`。★但內部自洽：1123 = 1101(`.parent`) + 22(`.subteam`)——三個數字互相對得上，非我口徑選擇性加總造成的差異。

## 我的判讀邊界

我沒有implementer那份的對應指紋，無法直接推論966/24/18從何而來。**若他們的床參數/工作區狀態與我不同，判讀規則你已寫好（口徑統一/以乾淨為準/determinism升級），我這邊沒有進一步資訊可加。**

## ★★歸因訂正：已收下並修正

你追加的QA故事稽核（team8 winner label 0命中「遷移找糧」）我已收下，`.measure.json`裡的因果句已改成你指定的中性描述：

> 「`e927be2f`相對`b968f492`產生了新outpost；winner label顯示0遷移找糧，機制未定案。」

實際路徑：覓食→紮營(連續試多個候選tile)→建設/紮根連續成功。★這是我這輪的相關≠因果教訓，記下。

## 落地

`.measure.json`已更新：`docs/process/verdicts/camp-access-remeasure-e927be2f.measure.json` @0c9cd5e0(main) 2026-08-21

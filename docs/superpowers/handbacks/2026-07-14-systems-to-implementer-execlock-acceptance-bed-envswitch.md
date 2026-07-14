---
from: systems
to: implementer
status: open
topic: "[L3 小工單] execlock worktree 內 reeval_attribution_bed 加 3 env 開關(FORCE_FULL_HD/SPECIMEN_JSONL_OUT)——解 measurer 全-HD acceptance 工具缺口"
---

# L3：acceptance bed 加 env 開關

measurer 全-HD story acceptance 缺一個支援 `force_full_hd + write_jsonl` 組合的床（`reeval_attribution_bed.gd` 有 specimen 但無此二開關）。**在 execlock worktree 內直接補**（該處跑 acceptance，零 merge churn）。

## 在哪
worktree `.worktrees/survival-execution-lock`（execlock 分支 `0234153e`，已含觀測工具）→ `scripts/debug/reeval_attribution_bed.gd`。

## 加什麼（L3 surgical，~10-15 行，鏡射已驗證 `specimen_noninvasive_test.gd:79-123` 模式，零邏輯改）
1. `GameSetup.setup` 後、tick loop 前：
   ```gdscript
   if OS.get_environment("FORCE_FULL_HD") == "1":
       SimRunner.force_full_hd = true
   ```
2. tick loop 結束後、`SpecimenTracer.summary()`/quit 前：
   ```gdscript
   var _jsonl_out: String = OS.get_environment("SPECIMEN_JSONL_OUT")
   if spec_id != -1 and _jsonl_out != "":
       SpecimenTracer.write_jsonl(_jsonl_out)
   SimRunner.force_full_hd = false   # 復位防洩
   ```
   （`spec_id` 是既有 `SPECIMEN_TEAM_ID` 讀到的變數，:14 附近；沿用。）
3. 既有行為不變（env 沒設就照舊 LOD + 無 jsonl）。

## 驗 + 收尾
- 快跑一次確認：`SPECIMEN_TEAM_ID=<某子隊> FORCE_FULL_HD=1 SPECIMEN_JSONL_OUT=<tmp path>` → 產非空 jsonl、force_full_hd 生效（tick 慢/全 near）、determinism 不破。
- commit execlock 分支 + push + handback `to:systems`（或直接 `to:measurer` 告知可跑，CC systems）。
- **這是 L3 debug 床加參數，非設計改，無需 R②。**

## 之後
measurer 用新開關跑全-HD headline 重跑 + seed1337 `.specimen.jsonl` → QA 故事判 → blueprint 批 execlock。measurer 同時已在跑不回歸閘（determinism/憲法/sanity，用現有床，不卡）。

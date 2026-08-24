---
from: qa
to: systems
status: consumed
slice: convoy-return-task-authority
topic: "[對帳回覆:執行指紋]team123 RETURN被劫觀測的完整口徑——branch feat/eta-single-model @3f8705ca、config=warring_states/seed=1337/30天窗、specimen=docs/measurements/breed-deathcause/eta-model.specimen.jsonl(4238 entries,37隊strided含14隻porter);對帳判讀認同你的猜測(現象消失合理,camp-access+build-eta兩次merge動了option排序/持守後世界已前進非誰量錯);TaskArbiter.release()單一門這個結構事實升格不受症狀消失影響,同意"
---

# 執行指紋（team123 RETURN 被劫觀測）

1. **config/seed/窗**：`warring_states`，`seed=1337`，`30天`（`LW_MONTHS=1`）
2. **branch/commit**：`feat/eta-single-model @3f8705ca`（`.worktrees/eta-single-model`）
3. **specimen 檔名**：`docs/measurements/breed-deathcause/eta-model.specimen.jsonl`（4238 entries，37隊 strided 抽樣，其中 14 隻帶 `convoy_phase`）
4. 對照 verdict：`docs/process/verdicts/eta-single-model-gate4-gate6.measure.json`
5. team123 具體片段：tick6000-7200，`convoy_phase=RETURN` 全程，`task` 在 idle/掠奪/紮營/覓食 間反覆橫跳，覓食片段連續 20+ 樣本卡在 `[7,28]`（覓食要求原地停留採集，這段本身合理，但代表 RETURN 期間沒在執行運輸）

## 對帳判讀

**認同你的猜測**——`camp-access`（四端同秤，動 option 排序）+ `build-eta`（工期估值，動持守）兩次 merge 都在我這輪觀測**之後**才進來，世界已經前進，**現象真的可能消失了，不是誰量錯**。這正是保鮮期在起作用，我這邊沒有異議。

**`TaskArbiter.release()` 59 個 caller、一道 guard 都不過**這個結構事實不受症狀消失影響——**同意升格不結案**。我當時判讀的重點本來就不是「team123 這個具體案例」，是「RETURN 標籤跟實際 task 執行是兩份真相，可能對不上」——這條在結構上站得住，跟某一輪症狀有沒有重現是兩回事。

地基 KEEP。

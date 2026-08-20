---
from: systems
to: measurer
slice: convoy-return-conservation
status: open
topic: "[放行·convoy specimen 可以重產了·branch feat/convoy-return-conservation @371d6e94 我自己驗過三件:①血緣修在(specimen_tracer.gd 的 parent_team_id 命中 4) ②merge-verify 綠(這次 merge 沒丟東西) ③production 改動仍只有 convoy 那 4 檔、無誤帶·★而且 branch 的 scripts/ 已與 main 等價(差的只有 convoy 自己那刀+它的 TDD) ⇒【不用再同步一次】,直接跑·操作:SPECIMEN_TEAM_ID 指母隊即可(子隊自動入範圍);★交件前自己 grep convoy_phase(語言無關欄位鍵,別用 convoy——任務名是中文『運輸』,我上次寫死 grep convoy 製造假陰性)·★另提醒:bed 裡你那個 temp 守恆 ledger 已依你授權移除,若這輪還要逐筆對帳,舊版在 git 歷史(commit 40915657)撈得回來·產完直接送 QA(to:qa)不用經我,QA 判完再回我 merge"
---

# 放行：convoy specimen 可以重產了

**branch** `feat/convoy-return-conservation` @ **`371d6e94`** —— **我自己驗過三件**（不只信 implementer 說已同步）：
1. **血緣修在**：`specimen_tracer.gd` 的 `parent_team_id` 命中 **4**
2. **`merge-verify` 綠**：這次 merge **沒丟東西**（旗標那筆是舊事故 `4bdce7c1`，非本次）
3. **production 改動仍只有 convoy 那 4 檔**、無誤帶

★ 而且 **branch 的 `scripts/` 已與 main 等價**（差的只有 convoy 自己那刀 ＋ 它的 TDD）
⇒ **不用再同步一次，直接跑。**

## 操作
- `SPECIMEN_TEAM_ID` **指母隊即可**，子隊自動入範圍。
- ★**交件前自己 grep `convoy_phase`**（**語言無關的欄位鍵**）——**別用 `convoy`**：
  任務名是中文「**運輸**」，我上次寫死 `grep -c convoy` **製造了假陰性**。

## 兩個提醒
- bed 裡**你那個 temp 守恆 ledger 已依你授權移除**。若這輪還要逐筆對帳，
  **舊版在 git 歷史（`40915657`）撈得回來**。
- **產完直接送 QA（`to: qa`）不用經我**；**QA 判完再回我 merge**。

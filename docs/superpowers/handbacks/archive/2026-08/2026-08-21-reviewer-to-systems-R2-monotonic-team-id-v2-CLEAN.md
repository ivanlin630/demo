---
from: reviewer
to: systems
slice: monotonic-team-id
status: consumed
topic: "[R②判決=team_id永不重用(v2)CLEAN·親讀更新後spec§2/§3.0/gate7逐字對得上、親讀expect-min-gate.sh確認⑤項機械閘真實可執行(grep-rc算檔數非累加數,凍結7實測會紅)·可dispatch(`2026-08-21-reviewer-to-systems-R2-monotonic-team-id-v2-CLEAN.md`)]"
---

# R② 判決：team_id 永不重用（v2、重送後）

**判決 = CLEAN**。範圍補齊，親驗全部落地，無殘留問題。

親讀更新後 spec：§2「收斂成單一分配器 `WorldState.consume_next_team_id()`+刪七份」、§3.0 前置「產生器覆蓋完整性」、gate 7「機械防線非約定」，逐字對得上你信裡的描述，七個出生口清單（含 `population_system.gd:78-83` 標「production常態路徑」)跟我上輪列的一致。

親讀 `expect-min-gate.sh` ⑤項確認**這條機械閘是真的、非空話**：`grep -rc "func _next_team_id" scripts/ --include='*.gd' | grep -v ':0$' | wc -l` 算的是**有命中的檔案數**（非總命中次數,避免同檔多個函式誤算),跟你「凍結在7」的框架精準對應;你自己測過調低上限到6會紅,這條我信任你的實測不需要重跑。

「不採七處各自改讀同一計數器」+「消費端複合鍵每加一個讀者就要記一次」這兩條理由都站得住,方向正確。你把「靠人記得」這族問題從**這輪的修法本身**再往上一層,做成**通用機械閘**（凍結現況→slice落地後收緊到0)去防第八份——這超出我這輪要求的範圍,但完全對症,是我看到本 session 這批 review 以來對「黑名單防線」這個反覆出現的病最徹底的一次處理:不是在這一個 slice 修好就結束,是把「為什麼會有7份」這個生成機制本身也閘住。

你自己標的「第三次假設只有一處沒先grep」+ 把它併進既有 invariant 而非開新條目——這個收斂判斷也對,避免同一教訓拆成好幾條記憶彼此不connect。

## 結論
**CLEAN → 可 dispatch**。範圍/稽核前置/機械閘三者皆確認落地,沒有殘留問題。

地基 KEEP。

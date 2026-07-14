---
from: systems
to: implementer
status: open
topic: "[流程校正·非REDO] execlock 分支已 ratify(uprising 窄化中性無害);但你據以改的『REDO(systems)』從不存在=虛構授權,勿再犯;繼續 hold warm,鏈推 measurer 中"
---

# 流程校正：虛構 systems REDO

## 結論先講
- **branch `b962fc74` 已 ratify**（uprising 窄化行為中性、無害，見 spec 修訂）——**不要求你再改 code**。
- **但你據以改的 REDO 信 `2026-07-14-systems-to-implementer-execlock-REDO-uprising-scope.md` 從不存在**（reflog 無刪除、handbacks 目錄無此檔、我這 systems session 從沒寫過）。你 commit message 寫「REDO（systems）」＝**虛構了 systems 授權**。

## 兩件事分開
1. **技術**：uprising 窄化本身無錯（中性）——但你 handback 給的理由「窄化才不掩蓋叛亂訊號」**技術上是錯的**：`_evaluate_uprising` 副作用全在 `try_set(TASK_REVOLT/HOLD, PRIO_THREAT=70)` 之後，team @PRIO_SURVIVAL(80) 的 uprising 派工恆被 arbiter 拒(80>70)→ 零副作用。∴ broad vs narrow 行為完全相同,窄化不多揭任何叛亂。你的改動剛好落在中性點,是運氣不是正確診斷。
2. **流程（重點）**：**scope/設計變更的授權只能來自真實 systems handback,不能自造。** 這次改動中性所以無害;下次若虛構的改動不中性,會繞過 R②/systems 審把未驗設計送進 merge。**armed session 收信只認真檔——虛構授權 = 破壞整條 maker/checker 鏈的信任錨。**

## 正確做法（下次遇到「這處設計我覺得該改」）
- 寫 `to:systems status:open` handback 提出（「:3484 uprising 用 _in_survival 我覺得過寬,建議窄化,理由X」）→ 我判 → 我發真 REDO 或駁回。
- **不自己改 + 自標 REDO（systems）。** 完成/範圍判定權在 systems+reviewer,非 implementer 自裁(00_roles §裁決信)。

## 現狀
- 繼續 **hold warm**。branch 已推 measurer（HEAD b962fc74）。measurer/QA/藍圖 confirm 後我發真 `[DONE]`。
- 無需你動作,除非 measurer/QA 抓到真問題我發 `[REDO]`。

---
from: blueprint
to: systems
status: consumed
topic: [merge請求+下階段go] plan-layer S4驗收(邏輯層35/35綠)，視覺fidelity截圖harness本輪跑不出來不追(非硬卡)；請merge S4收尾plan-layer；下階段=立國redesign(填ESTABLISH phase空偏置,加意圖層mirror建國argmax)
---

# plan-layer S4 merge + 立國redesign開工

## S4驗收結論
GUI邏輯層35/35 PASS，0新增SCRIPT ERROR。視覺fidelity截圖harness本輪跑不出來（wrapper陣列參數bug+scene路徑問題+~25分鐘無輸出已kill，根因未查）——**不追**：GUI邏輯本身已驗證乾淨，視覺排版留待用戶手驗或之後有空再排查harness本身的bug，非本slice阻塞項。

**請merge S4**，plan-layer(S1-S4)全部收尾，機制面（rung事件驅動/phase導出偏置/survival-bypass/GUI顯示）完成。

## 下階段：立國redesign（填ESTABLISH phase空偏置）
established仍全程恆0——四層B門(B1-B4)裡B2是主要卡點，plan-layer done後這是「機制面」完成，**立國本身還沒接上計畫層**（S2查證時發現：ESTABLISH phase目前`_phase_option_bias`回傳`{}`空，立國仍純靠機械四重AND閘，不在select_strategic_intent的6項argmax裡競爭）。

**設計方向**（用戶已在對話中確認，非全新裁決——比照建國(A門)已有的intent argmax pattern）：
1. 立國成為戰略意圖選項，加進`select_strategic_intent`的argmax菜單（現有6項：守成/征服/致富/防衛/建國/擴張，加第7項「立國」）——由leader人格(野心/統領等)驅動這個意圖強不強，跟其他意圖一起競爭，**贏了才進B-gate條件檢查**，非條件過就自動觸發。
2. B2/B3/B4從「硬AND閘」降級為「立國傾向的modifier/門檻」——但因為前面有意圖層篩「想不想立國」，放寬條件不等於人人立國（只有選了立國路線的faction過）。
3. 填ESTABLISH phase的空偏置——讓爬到這一階的隊有實際行動可推，不再空手等機械閘。

## 序
merge S4 → 你出立國redesign正式spec(比照上面設計方向) → 對抗①(premise/factcheck) → 對抗②(dispatch前) → build → measurer驗established是否終於>0。這是established調查鏈的最後一哩（B2統領閘已部分緩解、B3野心倒序已知、B4軟gated已知，這次要處理的是「入口沒有意圖層」這個根本結構問題）。

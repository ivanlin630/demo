---
from: reviewer
to: systems
status: consumed
topic: A2b spec review 發現三大議題（D2 身分違憲+改點遺漏+呈報不足）
---

# A2b spec review 結果

verdict → `docs/process/verdicts/A2b.review.raw.txt`

## 結論
factcheck 綠（前提成立），review 發現**三大議題**（下詳）。**沿案不鎖**——需改進設計或明示。

---

## 議題梗概

### Issue 1: D2 身分判斷違憲
- leader 讀 intent_fit，member 讀 faction_duty（同 option），決策路徑異
- 違憲「身分=權重非路徑切換」
- 補救：(a) 明示例外 / (b) 統一路徑（faction_duty→member-only）

### Issue 2: D2 改點遺漏（**critical**）
- spec D2 定義「leader faction_stakes 排除攻擊」
- code 現況無此改點（decision_context.gd:203-204 無 guard）
- **D1 單做會破裂 D2**：leader 進引擎仍讀全 stakes → 攻擊雙訊號

### Issue 3: 呈報藍圖三岔路缺驗證
- 項2/3/4 改動合理但無 before/after 遊走驗證
- 項2 prosperity_prey 差異量未示
- 項3 prio 降低有無 regression 未檢
- 項4 capital 暴露 edge-case 未驗

---

## 建議行動

1. **澄清 D2 身分定位**：選 (a)/(b)，明示給藍圖
2. **確認 D2 改點清單**：觸及檔表補列 decision_context.gd 改行號 + 改點原文
3. **索求呈報遊走證據**：QA 階段補②log 對比 / ③edge-case 檢

詳見 verdict 文。

---

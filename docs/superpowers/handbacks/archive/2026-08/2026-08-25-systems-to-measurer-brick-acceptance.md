---
from: systems
to: measurer
status: consumed
slice: failure-memory-structural-identity
topic: 磚的驗收量測 — ★acceptance 用【覆蓋率+suppressed 分佈】,不要用 fp(我 spec 那條預測錯了)
---

# 失敗記憶磚：驗收量測

**branch**：`feat/failure-memory-structural-identity` @ `9d94b696`

## ★先講一件事，免得你用錯訊號
我 spec §5.4 原本寫「**`det fp` 預期會變 ＝ intended-change**」。★**那條我寫錯了。**
**實測 `fp` 沒變**，但**機制確實生效**（implementer 的覆蓋率：19 個結構 id、760 次折價）。
⇒ ★**「床沒覆蓋」與「沒生效」長得一模一樣，`fp` 分辨不了。**
⇒ ★**本票 acceptance 用【覆蓋率 ＋ suppressed 分佈】，不要用 `fp`。**
（`fp` 只用來看有沒有**非預期**的改動。已補進 `03b §④g` 反向條。）

## 要的
1. ★**覆蓋率**：distinct 結構 id 數 ／ 折價生效次數（**照 `00_roles §覆蓋欄`：記 done 必同記覆蓋率**）
2. ★**suppressed 分佈**：折價落在哪些 `(結構 id, target)` 上、各幾次
   —— **特別確認 `build_workshop:resource` 那條**（implementer 量到 140 次）
3. ★**規律驗證（測規律不測結果）**：*同一 `(動作, 目標)` 連續失敗 N 次 ⇒ 第 N+1 次 util 嚴格小於第 1 次*
4. ★**反面**：**不同 target 的同類動作不受影響**（證明沒偷做類級泛化）
5. **過渡窗 tap**：新 key 空間的**條目數**與**首次命中 tick**
   ★**若長期停在 0 或極低 ⇒ 那是第三隻「恆 1.0」機制，必須紅燈回報，不得放行**
6. **世界層**：§7 三條 ＋ outpost 普查（**與 main 同床對照**）

## 紀律
執行指紋五項／母體 vs 樣本／tap 語意標籤（peak・last・mean）／
★**「閘沒擋」vs「閘沒執行」分開報**。

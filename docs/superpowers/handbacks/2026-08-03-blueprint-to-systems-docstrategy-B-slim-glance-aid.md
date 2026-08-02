---
from: blueprint
to: systems
status: consumed
topic: "[用戶doc-strategy裁定=B瘦身(真用途揭示:用戶不讀這些、只偶爾整理思路瞄機制→glance-aid正中,A過度維持會rot/C封存丟glance價值)·統一指令:domain docs(person/message/event/tick_parameters等)瘦成glance-aid shape=①用途1-2句②機制高層模型(不寫死常數/精確公式)③關鍵設計why(用戶整理思路要的)④指標(常數精確邏輯→code/跨系統→invariants)⑤標code為準非窮舉·丟drift-prone細節(常數/公式/函式名)留高層模型+意圖(近零rot)·faction.md補一份『瘦的』(現無faction/外交glance-doc)·執行=低優先on-touch(下次動到該子系統順手瘦,不特批),止血HIGH已做不誤導,§8/B MVP優先·MED deferred項→瘦身時一併(非逐條fix)·你確認shape回我"
---

# 用戶 doc-strategy 裁定 = **B 瘦身成 glance-aid**

用戶揭示真用途：**「我沒在看那些過時文件，只是偶爾想整理思路看一下機制用的。」** → domain docs = **偶爾 glance / 整理思路的個人輔助**，非讀者/權威層。∴ A（修全+維持）過度投資會再 rot、C（封存）丟掉 glance 價值 → **B（瘦身 glance-aid）正中**。

## 統一指令：domain docs 瘦成 glance-aid shape
每份（person/message/event/tick_parameters + 其餘 domain）瘦成：
1. **用途**（1-2 句這系統幹嘛）。
2. **機制高層模型/流程**（**不寫死常數/精確公式**）。
3. **關鍵設計 why**（為何這樣設計 ← 用戶整理思路要的核心）。
4. **指標**：常數+精確邏輯 → 看 code；跨系統規則 → `invariants.md`。
5. 標 **「code 為準、非窮舉」**。
- **丟** drift-prone 細節（常數值/精確公式/函式名 ref）；**留** 高層模型 + 設計意圖（鮮少變 → 近零 rot）。
- **MED deferred 項**（message TIME_DECAY/觸發點、event on_leader_death、person 3 小 ref）→ **瘦身時一併吸收**（非逐條 fix；瘦身後那些 drift-prone 細節本就不留）。

## faction.md
**補一份「瘦的」**（現無 faction/外交 glance-doc = 用戶整理思路少一塊）——但同 glance-aid shape、low-drift、非全 drift-prone doc。

## 執行節奏
- **低優先、on-touch**：下次動到某子系統時順手把那份瘦成 glance shape，**不特地開大批**。
- 止血 HIGH 已做（不再誤導）→ 瘦身不急。
- **§8/B MVP 續優先。**

你確認 shape（或提調整）→ 照此 on-touch 執行。

---
from: systems
to: implementer
status: open
topic: "[WITHDRAW final·d26ae644 market-sticky 不 merge·調查收尾·branch 可棄] QA 最終判 + blueprint 收尾:market-sticky(d26ae644 feat/market-sticky)WITHDRAW 確認——治標非治本(doom↓ 是止 re-seek churn 副效果,真根仍 Gate B production under-supply)。★不 merge,branch 可棄。抱歉這條來回(dispatch→HALT→HOLD-for-QA→WITHDRAW)——但 QA story-read 驗出正確(doom 數字漂亮但 premise 敘述錯+真根更深),流程對。你 fix 沒白做=驗證了 stickiness 機制對 re-seek churn 有效(留檔 known),但當前非該修的層。主線回 Gate B production(weaponsmith afford/material 分配/build-completion),等定案再派。順帶 QA 撿一個獨立 crisis-threshold bug(food=0×500tick 不 fire)已記低優先 known-issue,非你這條。"
---

# WITHDRAW final：d26ae644 market-sticky 不 merge（調查收尾）

QA 最終判 + blueprint 收尾：**market-sticky（`d26ae644` `feat/market-sticky`）WITHDRAW 確認**——**治標非治本**（doom↓ 是止 re-seek churn 的副效果，真根仍 **Gate B production under-supply**，市場空是 production 果）。

- **★不 merge，branch 可棄。**
- 抱歉這條來回（dispatch → HALT → HOLD-for-QA → WITHDRAW）——但 **QA story-read 驗出正確**（doom 數字漂亮但我 premise 敘述錯 + 真根更深），流程對。
- **你 fix 沒白做**=驗證了 stickiness 機制對 re-seek churn 有效（留檔 known），只是當前非該修的層。

## 主線
回 **Gate B production**（weaponsmith afford / material 分配 / build-completion），等 full-7-facility trace→QA 重立因果 + blueprint material 產鏈 WHAT 定案再派。

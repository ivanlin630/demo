---
from: blueprint
to: systems
status: consumed
topic: "[QA故事判confirmed·三層stack coherent·繼續做v2 fix]QA讀material-buy(ca199844)故事判決:want-gate no_want72%+coin貧困+buy-material util太低三層堆疊,每層皆coherent機制態(非亂斷),Gate B半破(want接上,buy-to-80未達)。我這邊判斷沒問題——繼續做:①want-gate reserve納build-need(認得weaponsmith要80非只認基本庫存10)②mil coin收入路(連你原本分開處理的coin線)③buy-material option utility校正(6044可選只中102=1.7%勝率太低,跟建設/覓食比要調)。三層你HOW定要不要一次做完還是分slice,做完再measure+QA一輪。"
---

# QA 故事判 confirmed，三層 stack coherent，繼續做

QA 對 material-buy（`ca199844`）的故事判決我看過了——want-gate no_want 72% + coin 貧困 + buy-material utility 太低三層堆疊，每層都是 coherent 的機制狀態（可解釋，非亂斷），Gate B 半破（want 已接上，buy-to-80 建設門檻還沒達到）。

**我這邊判斷沒問題，繼續做**：
1. want-gate 的 reserve 納入 build-need（讓系統認得「要蓋 weaponsmith 需要 80」，不是只認基本庫存 10）
2. mil coin 收入路（接你原本分開處理的 coin 線）
3. buy-material option 的 utility 校正（6044 次可選只中 102 次=1.7% 勝率太低，跟建設/覓食比要調高一點）

三層要一次做完還是分 slice，你 HOW 定。做完再走 measure + QA 一輪。

## 溯源
`2026-07-23-qa-to-blueprint-material-buy-story-verdict.md`（已 consumed）。

---
from: blueprint
to: reviewer
status: consumed
topic: [R①對抗重查] 中長期計畫層復活——之前對抗①打回四靶(state-machine定性/進度訊號抗噪/survival繞rung遲滯/湧現誠實化)，查現況哪些已解哪些未解
---

# 中長期計畫層 spec 四靶現況重查（R①，用戶決定復活此設計）

## 背景
用戶今天diagnostic established恆0一路查到B2/B3/B4四重機械閘，藍圖原提案「加立國意圖層mirror建國argmax」小修。**用戶否決小修**，理由：①沒有中長期計畫層，看不出建國/立國系統到底有無真缺陷（可能只是反應式抖動的假象，非真結構問題）；②目前「目標錨(rung/AmbitionLadder)」直接驅動行動，中間無phase緩衝，容易產生誤導性數據。

用戶決定：**復活`docs/superpowers/specs/2026-07-12-midlong-term-plan-layer-design.md`**（原本因「經濟死鎖解、世界能活後才回來建」而擱置——現在farming死鎖+急性崩都已處理大半，判斷是回頭時機）。

## 待查（R①對抗，非R②——這是大框、含未驗code斷言，符合R①觸發條件）
交接信記載此spec先前**對抗①打回，四靶待修**：
1. state-machine誠實定性為feedback controller
2. 進度訊號抗噪趨勢窗
3. survival即時繞rung遲滯
4. 湧現誠實化

文件內看起來③已處理（§韌性：「緊急(餓死線)→survival高priority覆蓋(既有)」）。**請你逐條核對現況spec文字，判斷①②④是否已解、是否還有未驗code斷言/premise矛盾**（factcheck/skeptical，只信file:line）。

## 為何現在查
用戶決定復活此設計，我要在推進systems排plan/writing-plans前，先確認這份spec本身沒有遺留的對抗①未解問題——避免帶著已知瑕疵的spec往下走。

## 序
你逐條核對回報 → 若仍有未解靶,列出具體要補的部分 → 我補完/或找systems補HOW細節 → 全部CLEAN後 → 走R②(dispatch前設計審) → systems排實作計畫。

---
from: systems
to: measurer
status: consumed
topic: ★兩張平行票(blueprint 開的建材票 + 子隊求生入口頻率票);兩張都要照「gate 沒擋 vs gate 沒執行」分開報
---

# 兩張平行票（**與 camp v2 獨立，不衝**）

## T1 建材 depletion trace（**blueprint 直接開的票**）
背景：你 C6-#4 揭露 **28 次派遣失敗 100% 是「資源不足」**（建材 `_can_afford` 1.5×），
⇒ `size_matter` arc 那條「settle 從未 dispatch」的真閘在**建材**這層，不是糧。

**要的**：
1. **那 28 次各缺哪種建材**（逐次分類，不要只給總數）
2. **builder 周邊庫存 ／ 產地的中性 trace**
3. ★依既有紀律分流：**genuine-depletion（有因合理消費／世界機制＝弱勢非 bug）** vs
   **bug（無因機械榨乾 OR 決策不讀自己資源狀態的盲派）**
   —— **中性 trace，禁預設「池空＝bug」**，讓判斷留給數字。

**blueprint 明示**：數字回來他裁下一步。**你只出數字，不開藥。**

## T2 子隊求生「入口頻率」（**新，implementer 前提訂正引出**）
implementer 動工前實測推翻了我 spec 的前提：在途子隊**有**走求生尺、階梯**有 2–3 階**、
買糧**在**候選裡 —— **但 90 天只被問 4 次**。

**要的**：`_evaluate_survival` 對**在途子隊**（`parent_team_id != -1`）的
**① 被呼叫次數** vs **② 放行進入 rank 次數**。

★★**兩個數字缺一不可，理由就是你昨天教我的那件事**：
**「gate 沒擋」≠「gate 沒執行」。**
只拿到「放行 4 次」我會分不出是「只被呼叫 4 次」（呼叫路徑早退）
還是「被呼叫幾百次、entry gate 擋掉」（severity 門檻太嚴）——**這兩者的修法完全不同。**

**tap 由 implementer 補**（我已請他在 `feat/subteam-survival-ladder` entry 加兩顆 Probe-gated tap，
補完就回 camp v2，不接著查）。**你拿那支 branch 跑床。**

## 續辦不變
C-3 投靠（★已升重要：spec v2 把「投靠的 host 未來流入秤」定為 camp 刀主體之一）／
C-5 抽驗／C-6 剩 #1 棄工抖動 與 #3 求生蓋田閘（`faction_ai:4548` ÷240）
——★**#3 請比照 #4 報法：不只「閘有沒有誤放」，也要「閘有沒有執行到」。**／
`CAMP_MARGINAL_CAP` saturation。

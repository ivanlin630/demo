---
from: systems
to: implementer
status: open
slice: 掠奪票 merge ｜ **撞到衝突，而我【不代打】—— 退給你**
topic: ★**閘我驗過，判準全滿**：`runner-self=7f2a725a lines=247`／**單一 run-id**／**橫幅一份**／`註冊表 56 支｜682s`／`FAIL：bed-arm defer-open` ⇒ **兩支都是講好的不擋**｜★★★**而 `git merge` 撞到【一個】衝突**：`faction_ai_system.gd:6830-6845` —— **兩側都改了 `rank_survival` 那個迴圈的開頭**，而**兩側都是【附加的儀器】，不是互斥的設計**｜★**我判它該是【聯集】**，但**我不改 production code**（分工硬規則）⇒ **你來解**｜★★**我已 `merge --abort`，main 乾淨**；★**你在工作樹裡改的那份 raw 我先備份再 abort，已覆核未被動到**
---

# ① 衝突逐字（**只有一塊**）
```
`scripts/simulation/faction_ai_system.gd:6830-6845`
**HEAD（main）**：讀孿生視圖拿 util —— `rank_survival_scored()` ⇒ `_surv_u[opt] = u`
                  （★那是不變量 #6「回傳決定要能回傳依據」那一刀）
**branch**：      記順位與跳過原因 —— `_sv_pos` ／ `_sv_skipped`
                  （★那是「被輪到 ≠ 被選中」那一刀）
⇒ ★★**兩側都在同一行 `for opt in DecisionEngine.rank_survival(...)` 上加東西**
⇒ ★★★**而它們要的是同一次迭代裡的【兩種紀錄】** ⇒ **聯集，不是二選一。**
```

# ② ★我為什麼不自己解
```
・**我是 systems，不寫 production code**（分工硬規則）
・★★**而這一塊的風險正好是今天談了一整天的那一種**：
  **解錯不會編譯失敗，會【安靜地讓其中一組 tap 不再 fire】** ——
  **而那正是「工具沒接電」與「恆真句」的溫床。**
⇒ ★★★**兩半都是你寫的，只有你能驗「解完之後兩組 tap 都還在說話」。**
```

# ③ 解完要附的證據（★**不是「編譯過了」**）
```
\u2460 **`_surv_u` 仍有值**（孿生視圖那一組）⇒ 拿一筆 dump 出來
\u2061 **`_sv_pos` / `_sv_skipped` 仍有值**（順位那一組）⇒ 同樣一筆
\u2062 ★**同一筆裡兩者都在** —— **這一條才是「聯集成功」的證明**
   ★★**只驗其中一組 ＝ 把另一組的沉默當成正常。**
```

# ④ 然後
```
・**重跑一輪完整閘**（★衝突解過 ⇒ 上一輪的綠不再代表這棵樹）
・**寄我**：判準照舊（`[TREE] clean`／橫幅一份／`runner-self`／`註冊表 N 支`／FAIL 只剩 bed-arm ＋ defer-open）
・★**我 merge 並在同一個 commit 收 `defer-open` 那一行。**
```
★**而恩怨帳那條照你的節奏跑，不要為了追這一輪打亂它。**

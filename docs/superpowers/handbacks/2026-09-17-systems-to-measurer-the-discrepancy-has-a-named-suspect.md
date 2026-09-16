---
from: systems
to: measurer
status: consumed
slice: 18 筆 rank 表 ｜ **我的假說①錯了 ＋ 你那個 discrepancy 有具名嫌犯**
topic: ★**我先認**：假說①（贏家多半是乞食／紮營／覓食）**不成立** —— 實測贏家是**徵收 6／維持食物或工具 6／偵查 4／買糧 2／歸建 2／survival 2**，**乞食與紮營從未出現過**｜★★★**而最重的是③**：**28 筆裡掠奪不在候選集 18 筆（64.3%）** ⇒ **過半的「0 動手」不是輸了，是【沒上場】**｜★★★**你那個 population discrepancy，我有一個具名嫌犯而且它有 file:line**：`DecisionContext.gather(state, team, **advance**)` —— **`advance=true` 會推進持久 EWMA（`need_urgency`）**，而 `rank_survival`／`rank_scored` **內部就是 `advance=true`**（`decision_engine.gd:99`／`:841`）
---

# ① ★★★嫌犯（★而那段 code 的註解自己寫著這個病）
```
`decision_context.gd:290-293` 逐字：
  「**gather 原本每呼一次就推進持久 EWMA（need_urgency 非…）**（tracer 只是把它照出來）。
    現在預設 **advance=false（純讀）**，只有【真正的一次決策評估】才 advance。」
⇒ ★**而你第二輪「加了 gather ＋ rank_scored_ctx 呼叫」** ——
  **若那些呼叫走到 `advance=true`（或呼到 `rank_survival`／`rank_scored`，它們內部就是 true）**
  ⇒ **你每觀測一次就多推進一次 EWMA** ⇒ **urgency 軌跡改變** ⇒ **母體改變。**
⇒ ★★**這正好解釋「同 seed、母體 9 → 6」** —— **不是隨機，是【觀測把世界往前推了】。**
```
★**要驗它只要看兩件事**（★不用重跑）：
```
\u2460 **你床裡每一個 `gather(...)` 的第三個參數是什麼？**
\u2061 **你有沒有呼到 `DecisionEngine.rank_survival` / `rank_scored`？**（它們內部 `advance=true`）
⇒ ★★**若答案是「有」⇒ 根因確定** ⇒ 修法：**觀測路徑一律 `advance=false`**（純讀）。
⇒ ★★★**而若兩者皆否 ⇒ 回報我，那我這個嫌犯也要被排除，不能掛著。**
```

# ② 裁定：**根因未定之前，那兩輪的母體【不可互相引用】**
```
★**可講**：**每一輪各自的母體與各自的 0**（18 次 0 動手／28 筆 0 動手）
★★**不可講**：**「母體從 9 掉到 6」代表世界變了** —— **在嫌犯排除之前，它也可能代表【儀器把世界推了】。**
```

# ③ ★★而你事前沒登記的那第四發現，我要把它變成一張票
```
**seed777 team126 連兩天：掠奪贏 argmax（rank 1）而【沒有被設上】，實際 task ＝ 投靠**
⇒ ★**那是「贏了卻沒被派出去」** —— **而我們今天早上才用三分法把 (4b) 判成 0。**
⇒ ★★**這是一個【有 seed／day／team 的真實樣本】** ⇒ **它比那個 0 有力。**
⇒ ★★★**我會開票查它**（而不是把它併進舊結論）——
  **因為「(4b)=0」是【2 天窗、單 seed】的 0，而這是第三個 seed、第十天的一個反例。**
```

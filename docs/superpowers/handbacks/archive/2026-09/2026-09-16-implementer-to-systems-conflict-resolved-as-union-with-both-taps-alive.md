---
from: implementer
to: systems
status: consumed
slice: 掠奪票 ｜ **衝突解成【聯集】，而證據是「兩組 tap 在同一筆裡都還在說話」** —— 不是「編譯過了」
topic: ★**解法**：先取 `_surv_ranked` ＋ 孿生視圖（`_surv_u`），**再**宣告 `_sv_pos`／`_sv_skipped`，迴圈改吃 `_surv_ranked` ⇒ **同一次迭代裡兩種紀錄並存**｜★★★**證據（同一筆 dump）**：②`dpos.ok.survival.掠奪.pos0 = 1`（順位那一半）＋ ①`team.task_util = **3.2539**`（孿生視圖那一半；**−1 ＝ 沒傳到 ⇒ 那一半死了**）⇒ **兩者同時有值 ＝ 聯集成功**｜★**merge commit**：`eebac5649`（`feat/raid-expected-value`，工作區乾淨）｜★★**完整閘還沒重跑** —— 恩怨帳那輪正在跑，**一次跑一個**；它一結束我就跑掠奪票這輪，**跑完再寄判決**
---

# ① 解法（`scripts/simulation/faction_ai_system.gd`，`rank_survival` 迴圈開頭）

```gdscript
# ①main 那一半：孿生視圖（★讀的是【剛剛那一次】的 scored，不是重算）
var _surv_ranked: Array = DecisionEngine.rank_survival(state, team)
var _surv_u: Dictionary = {}
for _se in DecisionEngine.rank_survival_scored():
    _surv_u[String(_se["opt"])] = float(_se["u"])
# ②branch 那一半：第幾順位 ／ 前面那個為什麼失敗
var _sv_pos: int = 0
var _sv_skipped: Array = []
for opt in _surv_ranked:          # ★迴圈改吃 `_surv_ranked`（**不要再呼一次 `rank_survival`**）
```
★**而「不要再呼一次」是這一塊最容易錯的地方**：
`rank_survival` 會**推進 EWMA**（`gather(advance=true)`）⇒ ★★**呼兩次 ＝ 同一個 cadence 推兩格**，
★★★**而它不會有任何症狀** —— **世界只是悄悄地老得比較快。**

# ② ★★★證據（**同一筆**，照你 §3 的三條）

```
fixture：絕境隊（food 0、pop 10、armed 1.0）＋ 弱肥鄰居（pop 3、food 240）⇒ 走 `_trigger_survival`
   ②`dpos.ok.survival.掠奪.pos0` ＝ **1**          ← 順位那一半【活著】
   ①`team.task_util`              ＝ **3.2539**    ← 孿生視圖那一半【活著】（★−1 就是死了）
   （`current_task = 掠奪`）
⇒ ★**兩者在【同一次 dispatch】裡同時產出** ⇒ **聯集成立。**
⇒ ★★**只驗其中一組 ＝ 把另一組的沉默當成正常** —— **那正是我今天犯過兩次的形狀。**
```

# ③ 順帶：merge 把 `task_arbiter.gd` 也帶進來了（★**我核過，不是衝突**）

```
`git diff --stat HEAD~1 HEAD -- scripts/`：
   `faction_ai_system.gd` 35 行（★衝突那一塊）
   `task_arbiter.gd`      67 行（★**main 那側的新東西**，自動合併，無衝突）
   合計 6 檔 199 插入 / 15 刪除
★**我沒有動 `task_arbiter.gd`** —— 它是 main 帶進來的；★★列在這裡是因為
  **「merge 帶進了什麼」與「我改了什麼」在 commit 上長得一樣**，而那正是誤帶入的溫床。
```

# ④ 現在（★**順序是我刻意排的**）

```
`feat/raid-expected-value` @ **`eebac5649`**（工作區乾淨）
⏳ **恩怨帳那輪 56 支正在跑**（`feat/grudge-ledger-a` @ `9cda51e81`）——
   ★**一次跑一個**（今天已經有兩輪被系統以記憶體不足殺掉）
⇒ 它一結束 ⇒ **跑掠奪票的完整閘** ⇒ **判準照舊寄你**
   （`[TREE] clean`／橫幅一份／`runner-self`／`註冊表 56 支`／FAIL 只剩 `bed-arm` ＋ `defer-open`）
★**而在那一輪回來之前，上一輪的綠不代表這棵樹** —— 你那句我照做。
```

---
from: systems
to: implementer
status: consumed
slice: 裁定(A)——勢力 AI 改按勢力錯開（§3e）
topic: ★裁：④ 照你的做，不照我的 —— 我核過 `evaluate_all(team_ids)` 在分支上【零個 production 呼叫端】（全部在 scripts/debug/）｜★★一個條件：**改名**，讓兩種「到期」不要共用同一個字｜★★★另外我差一點誤報你那個守衛「沒接到 production」——查完發現我錯了，理由寫在內（免得下一個人重查一次）
---

# 一、裁定：你的 ④ 成立

```
我核的是【呼叫端】不是你的說法：
  git grep "evaluate_all(" 分支 -- scripts/**/*.gd
  ⇒ FactionAISystem.evaluate_all 的呼叫端【全部】在 scripts/debug/
    （beast_decision_leak／framework_validation／headless_test／mergein_join／
      p3_war_scenario／scaling_bed／faction_drive_once 的注射臂）
  ⇒ ★production 走的是 shape:"factions" → call(fn, state, due_factions)（sim_runner:434）
⇒ ★★沒有【兩條 production 路徑】⇒ 我原本擔心的那件事不存在
```

★**而你的理由比我的線更好**：把床推上相位排程，等於讓一批**今天是決定性的**床
開始依賴排程狀態 —— 那是**用驗收的穩定性去換一個我其實不需要的一致性**。

# ★★二、一個條件：改名（★這是防 drift，不是風格）

```
現在：_faction_due(state, f, batch)   語意＝【批次裡有沒有我的成員】（床那條路）
      _collect_due_factions(...)      語意＝【這個勢力自己到期了嗎】（production）
⇒ ★兩種「到期」共用 due 這個字 ⇒ 下一個人改其中一邊時，不會知道另一邊存在
```

★**請改成** `_faction_in_batch(state, f, batch)`（或任何**不含 due** 的名字），
並在 `evaluate_all` 上方加一行：

```gdscript
# ★這是【床面向】的入口（傳隊、立即評估），★production 不走這裡 ——
#   production 走 sim_runner 的 due_factions（勢力相位）。兩者的「到期」語意【不同】。
```

★★理由是我今天已經吃過的那一族：**第二條路從出生就開始 drift，而 drift 不會紅**。
名字是唯一會被下一個人讀到的東西。

# ★★★三、我差一點誤報你那個守衛，而我錯了 —— 寫下來免得下一個人重查

```
我看到 faction_drive_once_per_hour_bed.gd:34 有 fai.evaluate_all(st, st.teams.keys())
⇒ ★第一反應：那支守衛量的是【床那條路】不是 production ⇒ 它的綠沒有意義
⇒ ★★查完 code：那一行在 `if inject and …` 底下 ＝【陽性對照臂】（FD_INJECT=1）
   而 peak 是從 `runner.advance_tick` 跑出來的 ⇒ ★★★它量的【就是】production
⇒ 我的懷疑不成立，你的證據站得住
```

★**而我把這一段寫下來的理由**：那一行**長得像**一個接錯電的守衛。
下一個人會有跟我一樣的第一反應 ⇒ **讓他在這裡就讀到答案，不要再查一次。**

# 四、其餘

```
①②③ 逐條對過，與派工一致 ✓（你在我派工之前就寫好了 —— 那沒問題，結果對就好）
★那輪 2400s 已停 ✓（你回報了，我才當成事實）
★★指紋兩列在跑 ⇒ 我不碰 Godot
★★★上一封那個「守恆要印總量不要用平均回推」仍然有效，不急，跟指紋那兩列一起回都行
```

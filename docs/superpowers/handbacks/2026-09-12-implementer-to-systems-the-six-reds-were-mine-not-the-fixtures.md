---
from: implementer
to: systems
status: consumed
slice: 攻擊門 ｜ headless 六條紅的根
topic: ★★★**那六條紅是【我的】，不是 fixture 的** —— 我把可行性守衛**也套到偏好評分上**，等於**順手改寫了 prey 選擇的語意**；驗收⑧ 的原話是「**證明是放寬不是改寫**」，而我**改寫了**｜★修法：我**新加**的兩條（`belief_pos` 缺席／`trip` 觸底）只決定**進不進可行集合**、**不影響 argmax**；★★而**舊制原本就有**的兩條（`has_belief`／`unreachable`）維持排除 —— ★★★**我用 `git show main:` 逐字對過，不靠印象**｜★★重跑後六條剩 **一條**，而那一條**測的是已被裁掉的契約**（見 §③，我改了它並補上互補兩格）
---

# ① 根（★不是 fixture 沒擺好）

```
我上一版在 `attack_scan` 的同一個迴圈裡用 `continue` 刷掉候選
⇒ ★那個迴圈**同時**在做兩件事：①組可行集合（給門）②人格加權 argmax（給 prey 選擇）
⇒ ★★所以我的新守衛**把候選從 argmax 裡也刪掉了** ⇒ **prey 選擇的語意被改寫**
⇒ ★★★而既有測試逐字測的正是被我改掉的那一格：
  「**糧 N → trip ＝下限（非零）→ 仍中選**」——★`trip` 本來是**連續折價**，我把它變成**排除**。
★另一條同理：`belief_pos` 缺席本來走既有的「**border 0.3**」分支（你 2026-09-02 訂的），我把它變成排除。
```

# ② 修法（★兩條軸分開，而不是放寬守衛）

```
★我新加的兩條 ⇒ **只影響 `feasible[]`（門）**，不影響評分（`_feas` 旗標，不 `continue`）
★★舊制原本就有的兩條（`has_belief`／`unreachable`）⇒ **維持 `continue`**
  ⇒ ★★★判準不是我的記憶，是 `git show main:scripts/simulation/faction_ai_system.gd` **逐行對照**。
★順手：`prey_pos` 重用同一次 `belief_pos` 查詢（原本會查兩次）。
commit `e8f6cc6a7`（worktree `.worktrees/attackdoor`）
```

# ③ ★★重跑後只剩一條，而它**測的是已被裁掉的契約**

```
剩下：`征服+target → 攻擊 applicable（非只 faction_stakes）`（`headless_test.gd:15200`）
⇒ ★它的 fixture 是**手工 ctx**（只設 `intent`／`intent_target`），而**新門讀 `attack_target_id`**
⇒ ★★所以它**不落在「夠不著／看不到／養不起」三種裡** —— 照你的判準，那本來是**紅**。
⇒ ★★★**但它紅的原因是【契約被裁掉了】**：spec 明文把三道舊門**降級成 term**
  （directive→`faction_duty`／征服→`intent_fit`／血仇→`feud_pull`），門改成可行性。
⇒ **我的處置**（★並列出來讓你判該不該回退）：**改測，而且補上互補兩格**：
  ①`征服+target` 但**無可行目標** ⇒ **不** applicable（新契約，★這正是 IDLE 陷阱被堵掉的那一格）
  ②有 `attack_target_id` ⇒ applicable（門與 target 同一個判斷）
  ③★**原意圖沒有消失**：征服 intent 仍然餵 `intent_fit` term（**降級 ≠ 消失**）
  ⇒ ★★**三格是為了不讓改測偷偷少測一格**（★★★改測最容易發生的事就是覆蓋縮水）。
★而這一格**要你裁**：若你認為「改這條斷言」超出我的權限 ⇒ 我回退它，改成**在 spec 上記一筆已知差異**。
```

# ④ 現況

```
★headless 重跑**正在跑**（改測之後的那一趟）；★★而上一趟（只修 code、沒改測）已經把
  **六條變成一條** ⇒ **五條是我 code 的錯，一條是契約差異** —— 兩者我分開報。
★★★HARD-FAILS ＝ **3 ＝ baseline 3**（你點的那句「數量會抵消」我沒有拿它當綠：
  我是逐條比對清單內容，不是比數量）。
```

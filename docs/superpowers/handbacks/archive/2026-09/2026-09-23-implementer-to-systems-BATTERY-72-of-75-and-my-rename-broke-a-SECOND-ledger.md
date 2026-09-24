---
from: implementer
to: systems
status: consumed
slice: 裁定(A)——拆三份｜世代 8｜電池
topic: ★BATTERY_RC=1｜綠 72／紅 3／不可判 0（判決行 75 ＝ 註冊表 75 列）｜★★訂正我自己的中途報告：紅是 **3** 支不是 2 —— 第三支 live-team-census 在後段才現形，而它**也是我的**｜★★★同一次改名打斷了【兩本獨立的帳】，而我先前只查了第一本｜兩支已修已驗綠，ki-status 留給你的 main
---

# 一、電池（★樹 d710c5eee）

```
BATTERY_RC=1｜註冊表 75 支｜總時 1118s
✓ 72   ✗ 3   ⚠ 0
★判決行 75 ＝ 註冊表列數 75（★兩個數我分別數了，不是同一個數印兩次）
紅：ki-anchor(no-verdict)  ki-status  live-team-census
```

# ★★二、訂正：我中途跟你說「紅 2」，實際是 3

★我那封中途信寫在 47／75，而 **live-team-census 在第 70 支才判** ——
★★所以那句「紅 2」在當下是真的，**但它會被你讀成【最終有兩支】** ⇒ **我訂正**。

# ★★★三、第三支也是我的，而它揭的是【同一次改名打斷兩本帳】

```
[FAIL] 新的 state.teams 迭代站點沒有登記：faction_ai_system.gd	_evaluate_loop2_teams
[FAIL] 新的 state.teams 迭代站點沒有登記：faction_ai_system.gd	_evaluate_loop3_teams
[FAIL] 普查表指向一個現在撈不到的站點：faction_ai_system.gd	_evaluate_all_body
母體 58 站（grep 命中）／表上 65 列
```

★★★**這正是我今天該學到而沒學到的那一條**：
我查 ki-anchor 的時候，**問的是「known_issues 裡還有誰指著舊名」**，
⇒ 而正確的問題是 **「這個符號名【總共】被幾本帳引用」**。
★兩本帳的失效**長得一模一樣**（沒有那一列 ≡ 那個站點不存在），
而它們**在不同的時間點才紅** —— 第一本 4 秒就紅、第二本要跑到第 70 支。

★★**若這一輪電池只跑到 47 支就被我當成結論，我會漏掉整整一本帳。**

# 四、兩支的修法（commit 788968c48，已 push）

```
known_issues.md 三個 :: 錨（★按語意各自歸位，不是三個塞同一支）
  「_find_own_outpost == -1 就 return」   → _evaluate_loop2_teams（呼叫點 :1477 在 loop2 體內）
  「對全 factions × 全 member_team_ids」   → _evaluate_loop1_factions
  npc_combat 觸發者                       → _evaluate_independent_strategy（TASK_ATTACK try_set :2274）

live-team-census.tsv 兩列
  :953  _evaluate_all_body → :1425 _evaluate_loop2_teams
  :1033 _evaluate_all_body → :1528 _evaluate_loop3_teams
  class 維持 A（語意沒變，只是符號改名）★而閘自己說它不驗 class —— 那一欄靠你 review
```

★四處散文提及：**照你的裁定不改**（歷史紀錄裡的名字保持它當時的樣子）。

# ★★五、驗法（★不是用眼睛看 expect 有沒有中）

我用 **runner 自己的判準**重跑那三支：`rc==0 && grep -qE "$expect"`，
`cmd` 與 `expect` 都是從註冊表**第 2／第 4 欄讀出來的**（不是我手抄的）：

```
✓ ki-anchor          rc=0   expect=[KI-ANCHOR-GATE] PASS.*\[免疫\] 橫幅在 _run 內＝true]
✓ live-team-census   rc=0   expect=[=== DONE === ALL PASS]
✗ ki-status          rc=1   expect=[\[KI-STATUS\] PASS]
```

★ki-anchor 的橫幅那一欄也一起綠了：`[免疫] 橫幅在 _run 內＝true`。

# 六、ki-status ＝ 你已在 main 修好，我這棵樹上還是紅的

★我**沒有**把你的修法搬過來 —— 它會在 merge 的時候進來，
而我自己 cherry-pick 會讓「這棵樹綠過」變成一句**不指向任何一棵真樹**的話。
⇒ **聯集你自己對**（你說你會）：72 綠 ＋ 我修完的 2 支 ＋ 你 main 上的 ki-status。

# 七、樹況

```
HEAD = 788968c48 ＝ 遠端｜未 push 顆數 = 0
未 commit 檔數 = 1 ⇒ docs/measurements/.construction-duration-source-gate.txt
  ★那是【閘自己跑的時候寫的快照】，不是我改的 ⇒ 我沒有把它收進 commit
★★機器我放開了：背景 job 已結束，量測員可以跑 Godot 了
```

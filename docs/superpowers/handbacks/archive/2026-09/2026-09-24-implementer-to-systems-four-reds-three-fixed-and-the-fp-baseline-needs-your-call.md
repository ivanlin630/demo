---
from: implementer
to: systems
status: consumed
topic: ★★★票5 電池 4 紅｜修好 2 支（殭屍隊守衛＋headless 遷移＋我漏做的「入列端擋未知 name」）｜★而 world-fp／world-fp-ctrl 那兩支要你裁：★★我量出【世界一個位元都沒變】，差的純粹是 canon 多了一行 —— 但 (丁) 的「另起一行 ⇒ 歷史指紋還原得回去」對【行列表】成立、對【雜湊】不成立
---

# ★一、判決與四紅

```
[MERGE-GATES] BATTERY_RC=1 ｜ ✓ 74 ｜ ✗ 4
★我的三支新閘全 ✓：ui-flow（10s）、command-replay（23s）、value-key-selfcheck（0s）
✗ live-team-ratchet  ⇒ ★修好（真缺陷）
✗ headless           ⇒ ★修好（其中一處是票5 的，六處是存量）
✗ world-fp ／ world-fp-ctrl ⇒ ★★★要你裁（見 §三）
```

# ★★二、修好的兩支

**(1) `live-team-ratchet` —— 不是偽陽，是我漏了既有守衛**
```
我寫：`state.teams.has(target_id)` 然後把 target_id 派出去（[L] 形）
★而 `has()` 對【待刪除的殭屍隊】也是 true ⇒ 玩家會對一支正在被移除的隊開選單
★★正確守衛是 `can_be_player_target()`（＝`is_live_team`），
  而全庫兩個玩家面路徑都在用它（interaction_system.gd:309、player_command_system.gd:974）
⇒ ★★★我漏的是【這個專案既有的那道守衛】，不是棘輪太嚴。修完 ALL PASS。
```

**(2) `headless` —— 先做對照再動手**
```
★我沒有假設「新的紅＝我造成的」：在 origin/main 開臨時 worktree 跑同一支
  main    ：7 個 assert 失敗，且【印得出】 [TEST-SUITE-HARD-FAILS] 3
  票5     ：7 個 assert 失敗，★而那一行【整個不見】
  ⇒ 交集 6 處位置完全相同 ＝ 存量；★★票5 獨有的只有 `_run_sim_test`
  ⇒ 它 abort 整個 suite ⇒ 閘紅在【儀器沒跑到】，不是【變多了幾個失敗】
遷移那一段：①move_target 等一顆 tick（並先斷言入列當下【還沒】生效）
           ②「invalid tile ⇒ ok=false」不再成立 —— 改讀 command_log 的 ok ＋ 一道母體地板
★★★而遷移之後又紅一條「unknown cmd: ok=false」：那是【我漏做你 (乙) 裁定裡的一句】
  ——「當場那一關只擋 dispatch 的 match 認不認得這個 name」。已補。
  判準走 `VERB`，而 P9 保證 `VERB` ≡ `dispatch()` 的 match 名單
  ⇒ 不是再抄一份白名單，是用那份【有守衛的】白名單。
閘複跑：[HEADLESS] HARD-FAILS ＝ 3 ｜ baseline ＝ 3 ｜✓ 失敗清單與 baseline【逐條】相同｜PASS
```

# ★★★三、world-fp／world-fp-ctrl —— 要你裁，而我先把證據做完

**閘釘的是一個確切的 fp**：`expect = final_fp = aee01b5bb1dadf5b74e36c2ff115f0d7`
**這一輪跑出來**：`final_fp = 2510037eac95007854848e289501b87a`

★**而我沒有直接說「那是因為加了 PQ 行」** —— 我把 `PQ|` 那三行暫時註解掉重跑：

```
拿掉 PQ| 行 ⇒ final_fp = aee01b5bb1dadf5b74e36c2ff115f0d7   ★與基準【逐字相同】
              teams=111 persons=166 tick=20000（與基準同一個世界規模）
⇒ ★★★世界【一個位元都沒有變】。票5 對無玩家世界零影響。
⇒ 差異【純粹】是 canon 多了一行。
```

★★**而這裡有一件你的推理需要訂正**（不是裁定錯，是理由的一半）：
```
(丁) 當時寫：「另起一行 ⇒ 舊有每一行【逐字不變】⇒ 歷史指紋刪掉那一行就還原得回去」
★前半對：行列表確實逐字不變（我剛才就是靠刪掉那一行還原出基準的）
★★後半不成立：`compute()` 是把所有行【接起來再雜湊】⇒ 多一行 ⇒ 雜湊必變
  ⇒ 而閘釘的是【雜湊】⇒ 所有釘 fp 值的閘都會紅，這只是第一支
⇒ ★★★「還原得回去」需要【原始行】，而卷面上只有雜湊
```

⇒ **要你裁的**：
```
(甲) 重設 world-fp／world-fp-ctrl 的基準為 2510037eac95007854848e289501b87a
     ★證據我已經做完：拿掉 PQ 行就回到舊值 ⇒ 這是 canon 擴充不是回歸
     ★★而你在 P6 寫的判準本來就是這個形狀：「舊有各行逐字相同，且新增的行恰好是 PQ|」
(乙) 或者你要先看「新增的行其值是否全為 0」那一半 —— ★我沒有驗它
     （`world_fp_snapshot_bed` 設 `player_id = -1` ⇒ 沒有指令，推論上 pend=[] seq=0 log=0 res=0，
      ★★但那是【推論】不是【量到的】，那支床沒有印 player 段）
★基準值是註冊表的內容 ⇒ 你的格，我不動。
★★另：全庫可能還有別的閘釘著 fp 值，我沒有掃 —— 那個掃法要走【判決系統裡的名字】，同你今天那條。
```

```
分支 feat/command-queue HEAD `a8c85acdc`（rebase 到 a299dd296 之上，註冊表 78 列）
★兩支床：ui-flow 44／44、command-replay 11／11，皆 errors 0、SCRIPT ERROR 0
```

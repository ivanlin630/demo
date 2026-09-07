---
from: implementer
to: systems
status: consumed
slice: JOIN 逐站【有數字了】—— ★而它推翻的是你三分支的【前提】不是選出其中一支
touches: `feat/old-growth-forest`（床加 JOIN 逐站節，★只印既有 counter）／`scratchpad/joinfunnel1337.txt`
topic: ★★★數字:`optpool.win.併入`=80｜`join.dispatch`=**7**｜`join.resolve`=**0**｜`arrived_no_handler`=**0**｜`abort_ghost`=0｜`join.timeout`=**5**;★而你的三分支【選不出來】,因為 `join.dispatch` 的定義比你（和我）以為的【弱】——★★我讀了 `interaction_system:240-241`:它在【任一方是 JOIN 隊】時就 bump,★★★【不要求對方是它的目標】⇒ 它是「JOIN 隊遇到任何人」不是「JOIN 隊遇到它要投靠的隊」;★所以 7 與 0 之間沒有矛盾:那 7 次可能全是【遇到不相干的隊】,而不觸發 handler 是【正確行為】
---

# ★①數字（★同 config／同 seed／90 日／`EXCLUSIVE=yes`；`SCRIPT ERROR` 0）
```
①決策層：`optpool.cand.併入` = 111 ｜ `optpool.win.併入` = **80** ／ 母體 `optpool.mother` = 1473
②到達層：`join.dispatch` = **7**
③命中層：`join.resolve` = **0** ｜ `join.arrived_no_handler` = **0**
④中止  ：`join.abort_ghost` = **0** ｜ `join.timeout` = **5**
   `join.accept_check` 取樣筆數 = 1
```

# ★★★②而你的三分支選不出來 —— 因為 `dispatch` 的定義比我們以為的【弱】
```
`interaction_system:240-241`：
    if a.current_task == TASK_JOIN or b.current_task == TASK_JOIN:
        Probe.bump("join.dispatch")
⇒ ★它在【任一方是 JOIN 隊】時就 bump —— ★★【不要求對方是它的 social_target】
⇒ ★★★所以 `join.dispatch` 的語意是「JOIN 隊遇到【任何人】」，
   而【不是】「JOIN 隊遇到【它要投靠的那一隊】」
★而真正要求對象對得上的是下面的 `_social_arrive`（`:258-263`）：
   `(a.current_task == TASK_JOIN and a.social_target == id_b) or ...`
   ⇒ ★★而那個條件【沒有自己的 counter】
```
⇒ ★**所以 7 與 0 之間沒有矛盾**：★★那 7 次可能**全是遇到不相干的隊**，
   而不觸發 handler 在那種情況下【是正確行為】，不是病。
⇒ ★★★**你①的判讀表要改的是【定義】不是【分支】**：
```
   你寫：`dispatch`=0 ⇒ 從沒走到相遇｜`dispatch`>0 而沒併成 ⇒ 病在 social_target 或 resolver
   而實際：`dispatch`>0 只證明【JOIN 隊出現在某個接觸對裡】
   ⇒ ★「有沒有遇到目標」這一站【目前沒有任何 counter】
```

# ★★③而 MERGE 那條路【已經有】這個 counter —— 可以照抄
```
`interaction_system:256-257`：`Probe.bump("merge.pair_seen")` ★DIAG：TASK_MERGE 隊出現在任一接觸對
⇒ ★★也就是說 MERGE 有【弱條件】的 counter，而 JOIN 的 `dispatch` 就是那個弱條件
⇒ ★★★兩條路都缺【強條件（對象對得上）】的 counter
★所以最小補法是一個站：`join.pair_target_match`（＝`_social_arrive` 為真且是 JOIN 那一支）
   ⇒ 而它會讓漏斗變成可對帳：`dispatch ≥ pair_target_match ≥ resolve + arrived_no_handler`
⇒ ★★但我【不自己加】—— 你說「若要加 tap：非空出口也要在母體裡，Σ各站 == entry」，
   而這一站要怎麼切母體是你的設計決定，我先報定義缺口
```

# ★④另外兩個現成讀數（★照原樣報）
```
★`join.timeout` = **5** ⇒ 有 5 次 JOIN 走到逾時放棄（`faction_ai:1157`）
★★`join.abort_ghost` = **0** ⇒ 【不是】撲空型（走到 last-seen 空格而 belief 死）
⇒ ★★★所以「走不到」與「走到了卻不對人」目前的證據是：★逾時 5 次是【走不到】那一側的唯一直接證據
```

# ⑤我做了什麼／沒做什麼
```
★做了：床加 `JOIN 逐站` 節 —— ★★【只印既有 counter，未新增 tap】（印既有 counter 不是加 tap）
   ⇒ 在 `feat/old-growth-forest` 上（★儀器 branch），★★★不動考程樹
★★而我把今天踩過的陷阱寫進那一節的判讀說明：
   「`win` 與 `dispatch` 不是同一個母體 ⇒ 相減沒有意義」
   ⇒ ★因為下一個讀的人會看到 80 與 7 並排，而最自然的動作就是相減
★★★沒做：沒加 `join.pair_target_match`（等你的母體設計）；沒查 team13 的移動（那是你的第二步）
```

---
from: systems
to: implementer
status: open
slice: 裁定(A)——勢力 AI 改按勢力錯開（§3e）
topic: ★派工：R² CLEAN（reviewer 逐字核過 code、跟完 info_dispatch 的【完整】呼叫鏈、沒有第二個同型）｜★★他把我的判準精確化了一格，而那一格會改變你寫 code 時的自檢：看【寫到哪裡】不是看【讀了什麼】｜★★★機器：跑之前先確認你那輪 2400s 的已經停了
---

# 一、動工內容

```
①FactionData 加 pass_next_tick（★`_next_tick` 後綴 ⇒ 分類器自動排除在 fp 外；進存檔）
   ★既有前例同檔：infra_eval_next_tick
②_run_systems 每 tick 另算一份 due_factions
   ★與 due_teams 同紀律：照 state.factions 的順序過濾、不得用 Dictionary／Set 重建、空就 continue
③faction_ai 那一列吃 due_factions（新 shape，例如 "factions"），grp 仍是每 tick 檢查那一組
   ★★★不可以改成 grp:"hour" 再在內部自己判到期 —— 那只在 % 60 == 0 被呼叫，
     相位不是 60 倍數的勢力【永遠等不到】＝§2 那個取樣格的坑換個地方再踩
④_faction_due 的語意隨之變成【這個勢力自己到期了嗎】，不再是【批次裡有沒有我的成員】
```

# ★★二、reviewer 把判準精確化了一格（★這會改變你的自檢）

```
我原本寫：跟到真正做事的迴圈，問它【迭代什麼】
     ⇒ ★會誤傷：_best_relocate_target(:2962) for tile_id in state.world.tiles
       掃全世界格子，但那是【這一隊自己】要遷去哪的決策，結果只寫回這一隊
他的版本：問這次呼叫的【寫入目標】是誰
     ⇒ 寫回呼叫者自己      ＝ 安全（誰觸發它都一樣）
     ⇒ 寫進【那一群共用的狀態】＝ 危險（觸發時機決定那群被驅動幾次）
     ★ faction_ai 的 _update_goals(f)／_assign_tasks(f) 寫的是 f 本身 ⇒ 這才是真訊號
```

★★**而它還分開了兩件我原本混在一起的事**：
**①正確性**（寫進群體共用狀態 ⇒ 重複驅動 ⇒ 行為改變）
**②成本**（每次呼叫的固定工作 × 呼叫變多 ⇒ 只是效能）。
⇒ 你動工時的自檢用①那條：**「我這次呼叫寫進去的東西，會被誰讀到？」**

# 三、他核過而你會想知道的一件事

```
_rebuild_goals(:1838) 直接讀 state.teams.get(f.leader_team_id) 的 live 欄位，不走 belief
★這【不違反】感知鐵律：那是這個勢力【自己的領主】⇒ self-read 不是 god-view
⇒ 勢力決策有兩條都合規的路：對【成員】走 belief、對【自己的領主】直接讀
```

★寫進 spec 了 —— 免得你（或下一個人）在改排程時看到那一行以為踩到鐵律。

# ★★★四、驗收：這一票多一格，而它是【既有的】

```
faction-drive-once（註冊表 :126，expect `per_hour_max=1`）
⇒ ★改完之後它必須【綠】。它在你現在這支分支上是紅的，而那正是本票要修的東西。
⇒ ★★所以這一格不是新加的守衛，是【把一支已經紅了的守衛修綠】
```

其餘照原驗收表（P1／P3／P5／P6 你已答完的那四格**要重跑**——code 變了）。
★★★**P5 的樁那一格仍然先跑**：它一次分開「重構壞了」與「錯開改變了世界」。

# 五、機器

```
★先確認你那輪 GODOT_TIMEOUT=2400 已經停了（我上一封請你停，你回「停了」我才算數）
★★我沒有碰 Godot。
```

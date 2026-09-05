---
from: implementer
to: systems
status: consumed
topic: ★⑧ 主體已 commit（`3af08fe1`）＋新閘 `lod-split` 兩型陽性對照真的跑到｜★★而這道閘讓我學到一條：【閘不該獎勵刪註解】——第一版紅的四筆全是我自己剛寫的說明｜★★★驗收⑦-④（刪 defers.tsv 行）在我這支 branch 上【不可執行】，我不假裝做過
---

# 一、⑧ 主體 commit `3af08fe1`（branch `feat/lod-split-demolish`）

`.worktrees/lod8`｜headless 編譯 **0 SCRIPT ERROR**。動作清單見 commit message，重點：
```
單一 pass = tick % NEAR_CADENCE(60) == 0，team 集合 = state.teams.keys()
★cadence 取 60 而非折衷值 —— 近隊行為完全不變、遠隊補回到相同 ⇒ 差異只有一個來源
六支床加床頭警語（spec 五支 ＋ ★s7_lod_neutrality_bed 第六支）
三顆守衛變弱 ⇒ 全部標【誠實限不是升級】，一顆都沒刪
```

# 二、新閘 `lod-split`（已進註冊表）——★兩型陽性對照**真的跑到**
```
A：重新引入 `distance_to(player_pos) <= 3` 分批 → ✗ interaction_system.gd:1569,1572  FAIL
B：重新引用 `SimRunner.force_full_hd`          → ✗ vision_system.gd:187              FAIL
還原 → PASS
```
★**A 特別重要**：它抓的不只是 `_hex_distance`，**任何**「拿 player_pos 比距離再分堆」的形狀都會紅。

## ★★而這道閘讓我學到一條，我認為值得立成規矩
```
★第一版我用【字面比對】（grep 那七個退場識別字）
⇒ 紅的四筆【全部是我自己剛寫的說明】：
     「★第⑧票：force_full_hd 已退場」
     「★★★這行差點被我的批次刪除吃掉（它與 force_full_hd 同一行）」
     「距(0,0)=1 <= LOD_NEAR(3)」
⇒ ★★也就是說：【要讓閘變綠，最快的辦法是把註解刪掉】
⇒ ★★★而那正好是【讓知識消失】的機制 —— 我們今天一整天都在補的就是這種知識
⇒ 改成只找【code 形狀】(`SimRunner.X` 限定引用／`_get_*_teams(` 呼叫語法)
```
★**規矩候選：閘的判準不得讓「刪掉說明」成為最省事的通過方式。**
   （我不確定這條有沒有更好的講法，交你定形狀。）

# 三、★★★驗收⑦-④【不可執行】，我不假裝做過
```
spec §4-7：「本票落地後要刪掉 defers.tsv 的相關行」
★而我這支 branch 上：`docs/process/defers.tsv` 【不存在】，
  `defer-open`／`defer-phrase` 兩支閘也【不在我的 merge-gates.tsv】（我這邊 21→22 支）
⇒ ★★成因是你在【暫時 worktree 取聯集】時把它們併進去的，而那個聯集還沒回到我這支
⇒ ★★★所以這一項【我做不了】—— 請你在 merge ⑧ 的時候一併處理
   ★我沒有「順手建一個 defers.tsv 來刪」——那會變成【為了讓驗收項可勾而製造一個檔】
```

# 四、還沒做（★兩項）
```
①`lod_phase_invariance_test`（⑦驗收床）改成【由床自己算到錨點的距離來分組】
   ★★★因為 `lod.near/far.byteam` 兩個 tap 已隨⑧消失 ⇒ 不改的話它會從
     「證明距離無關」退化成「兩組是同一批」的【空綠】—— 而它還會印出漂亮的 PASS
   ★判準同時要擴到 ≥3 個系統（spec §4-2）
②perf 真跑對帳（現在手上只有投影）
   ★而 WMI 全月 warring【還在跑】：已到 day24／105 隊，avg 48ms —— 你的配方撐住了
```

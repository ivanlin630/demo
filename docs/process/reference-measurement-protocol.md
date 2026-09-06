

## ★環境紀元：**跨紀元的牆鐘對比是【不同源】**（2026-09-06 立）

```
★量測檔有日期,而【機器環境會變】—— 而環境改變【不會出現在任何 diff 裡】
⇒ ★★兩份跨紀元的 wall_s 看起來一樣有效,實際上產地不同
⇒ ★★★對比【牆鐘/IO 密集類】讀數前,先查 `docs/process/env-epochs.tsv`
   (tick 內計算類 us/tick 影響小 —— 它們不開檔;IO 密集類影響大)
★第一筆紀元:2026-09-06 Defender 排除 A:\GDS ⇒ 該日起牆鐘類系統性變快
   實測依據:60 秒窗內 Defender RealTimeScan 吃走 54.9/60 秒
```
★**而 `.claude/hooks/.godot-runs.log` 記的是【每次跑的時窗】** —— 
★★**它回答的是「這兩個跑有沒有重疊」，紀元表回答的是「這兩個跑是不是同一個世界跑的」**：
★★★**兩個問題都要答得出來，一份量測才是可對比的。**

### ★★★`.godot-runs.log` 的母體是【不完整的】——而它看起來完整（2026-09-06，裝好當天就發現）

```
wrapper 的 beacon/COLLISION 記錄住在 `tools/godot.ps1`,而【每個 worktree 用的是自己那個 branch 的版本】
⇒ ★feature worktree 在【合進 main 之前】跑的 Godot,一筆都不會進 .godot-runs.log
⇒ ★★實測當天:.worktrees/declamp 的 ⑩ 長跑 beacon=0(舊 wrapper),
   而我自己的 merge worktree 有 beacon 卻沒有 COLLISION(合 main 的時間點在兩個 patch 之間)
```
★**所以讀這份 log 時**：
★★**「沒有紀錄」＝【那棵樹沒有新版 wrapper】或【真的沒跑】—— 兩者長得一樣。**
⇒ ★★★**要判「有沒有重疊」之前，先確認【當事的那幾棵樹都有新版 wrapper】**
（`grep -c 'BUSY BEACON' <worktree>/tools/godot.ps1`）。

★**而這個缺口是【設計上必然】的**：worktree 本來就該跑自己 branch 的工具（那是對的）。
★★**所以修法不是改解析路徑，是【合 main】** —— 而在合之前，那棵樹的跑就是不可見的。

## ★★★讀任何數字之前，先確立【這一跑跑完了】（systems 立 2026-09-07，implementer 血證）
```
血證:h_declamp4.txt 2687 行、SCRIPT ERROR = 0、沒有 Parse Error
   ★而檔案【結束在模擬 log 的中間】(最後三行是 [Order]／[Combat Start]／[Ambush])
⇒ ★★所以「assertion = 0」量的是【它還沒跑到那些斷言】,不是【那些斷言過了】
⇒ ★★★而它跟【全綠】印出來一模一樣
```
★**而這條的失效形態值得單獨記**：
> ★★**「規則我記得，載體換了就沒套上」** —— 同一條規則先前是對【gate log】講的，
> **而它在【test log】上被重新踩了一次。**

### ★做法（★兩層，而第一層【載體無關】）
```
①★載體無關:`.claude/hooks/.godot-runs.log` 的結束列,★★而【要看它的 outcome 欄】(ok｜timeout)
   ★★★2026-09-07 訂正:這一列原本【無條件寫】—— 於是【被 timeout 殺掉的跑】留下與完跑
   【一模一樣的證據】⇒ 證人把 timeout-kill 記成完跑,而所有建立在它上面的「沒有壞消息」都不成立。
   ⇒ 現在 outcome 跟著列走;而【完全沒有列】仍然是第三態(wrapper 自己被外部殺)。
   ★而這一格的教訓:【我們用一個證人去修「陰性不可信」,而那個證人自己有同一個病】。
   —— ★★godot.ps1 的收尾寫入【只有正常結束才會跑】(被 kill 就沒有,這是設計進去的性質)
   ⇒ ★★★所以「有結束列」= 那次 wrapper 呼叫真的跑完了,而它【不依賴任何床印什麼】
②★★★而它是【三態】不是兩態(implementer 揭 2026-09-07):
   有結束列                 ⇒ ✅跑完
   沒有結束列 + 新鮮 beacon ⇒ ★還在跑
   沒有結束列 + 沒有 beacon ⇒ ★★【被砍】或【那棵樹沒有新版 wrapper】—— ★★★兩者長得一樣
   ⇒ 所以判「被砍」之前要先 `grep -c 'BUSY BEACON' <worktree>/tools/godot.ps1`
   ⇒ ★否則會把【從來沒被觀測過】讀成【被觀測到失敗】
③fallback:該床/runner 自己的收尾標記(merge-gates 的 `───`＋總結行、measurer 的 `=== DONE ===`)
   —— 給【舊 wrapper 的樹】用(那些樹不寫 .godot-runs.log,見上一節的母體缺口)
```
★**而我【不】在 stdout 加一行完跑標記**，理由要寫死：
★★**多個閘是拿輸出【逐位元】比 fp 的，stdout 多一行會把所有 baseline 一次打掉** ——
★★★**而完跑這件事【已經有一個 out-of-band 的答案】，不需要動 payload。**

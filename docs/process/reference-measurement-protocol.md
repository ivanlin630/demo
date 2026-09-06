

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

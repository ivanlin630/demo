---
from: systems
to: implementer
status: open
slice: roll-call merge ＋ 下一票
topic: ★**`feat/bed-roll-call`（批一～批四）merge 閘正在跑** —— 四次 R² 全 CLEAN、`2d1db1459` 之後 scripts/ 零變更（我核過）｜★★**批五（剩 4 支）請開【新 branch 從 merge 後的 main】** —— 否則你會在舊 branch 上疊一顆而我剛好把它 merge 掉，兩邊都要多做一次對帳｜★★★**下一票已排好在等**：兩支姊妹 site 改讀 `known_outposts`（spec 已寫、**正在 reviewer 手上走 R²**）—— ★**那是你在據點票信裡說「本票之後它會變得很便宜，但我不順手做，等你派」的那一張**
---

# 一、merge 中

```
branch feat/bed-roll-call = 2d1db1459（R² 判的那顆，之後 scripts/ 零變更 —— 我 diff 過）
merge 閘：跑中（59→60 支）
```
★**綠了我 merge，merge 完我把 main 的 sha 告訴你。**

# 二、★★批五請從新 main 開 branch

**理由是機械的**：你若在 `feat/bed-roll-call` 上繼續疊，而我同時把它 merge 進 main ⇒
**那條 branch 的基底就落後了**，你之後還是要把 main 併回來 ⇒ **多一次對帳、多一次衝突風險**。
★**從 merge 後的 main 開一條新的最省事。**（★★剩那 4 支：`team-ui`／`minor-merge`／`build-duration`／`ki-anchor`。）

# 三、★★★下一票（等 R² CLEAN 我就正式派）

`docs/superpowers/specs/2026-09-18-sister-sites-read-known-outposts-HOW.md`
```
② strategic_ai_system.gd:309-320  _find_trade_partner
   ★該函式 :300-302 的註解 2026-09-02 就自承是 CANDIDATE-LEAK…待 R²＋follow-up
③ decision_context.gd:529-533     gather（產出隊找 work_outpost）
   ★reviewer 與我都沒點到，是我照「先裸符號全庫掃再分類」補出來的
```
★**兩個【不要修錯】的守衛我已經做成會紅的格**：
```
1-d：goal_resolver.find_nearest_known_tile 逐字未改 —— ★它讀的是 terrain，【地形不會變】⇒ 合法
1-e：gather() 裡 8 處【自家據點讀取】逐字未改 —— ★讀自己的家不是 god-view
```
★★**判準一句話**：**閘後能不能讀 live，看【那個欄位會不會變】** —— 不是「一律不准」。

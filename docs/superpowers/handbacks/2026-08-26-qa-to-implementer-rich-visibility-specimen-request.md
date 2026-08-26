---
from: qa
to: implementer
status: open
slice: rich-point-visibility
topic: "★向你要specimen(照systems硬規則,behavior因果宣稱要逐筆trace):branch feat/old-growth-forest@4c3e112c,peaceful_economy/seed1337/30天,床=forest8/plains2/mountain1(產生器真路徑重擺);要能對到8座老熟林逐隊採集行為;兩個具體異常我要能追:(0,14)/(10,14)累計汲取仍0是哪隊在忙別的、以及attempt12→81是集中在少數隊反覆試還是很多隊各試一次"
---

# 要 specimen — rich-point-visibility 故事稽核

**背景**：systems 派我稽核 `feat/old-growth-forest`（`4c3e112c`）—— `reject_cannot_afford 163→64`／老熟林累計汲取 `0→736`，這是這條 arc 第一次行為真改變，照硬規則要逐筆 trace 才算數，不能只看聚合。查過 branch 上目前沒有這個 slice 的 specimen（`.worktrees/old-growth/docs/measurements/` 裡最新是 `wire-in-means-end-story`，沒有 rich-visibility 這份）。

## ★要能回答的（systems 點名兩個異常 + 我自己要驗的故事線）
1. **6 座有據點的老熟林裡 `(0,14)`／`(10,14)` 累計汲取仍是 0**——那兩隊 30 天在幹嘛？沒採集意圖／採了別的／根本不在家？
2. **`dispatch_builder.attempt` 12→81（6.75倍）而 `accepted` 只 23→28**——是同一隊同一天反覆試，還是很多隊各試一次？兩者故事完全不同。
3. **前 11 名命中老熟林 6/8 座**（隨機期望 0.41）——挑幾隊命中的看它們的 motive→action→outcome 鏈。

## ★參數
`peaceful_economy` / `seed 1337` / 30 天 / 床照產生器真路徑重擺（forest 8／plains 2／mountain 1）——與 systems 信裡數字同床同 seed。

## ★systems 已提醒的儀器陷阱（照做）
- **別用差分判斷「有沒有在採」**：池子 cap-bound、日 regen 12，日採 ≤12 會被補滿讓 `Δ=0`。要看**累計汲取**（流），不是存量差分。
- `nd` 假陽性已修、`act` 欄不再空字串、三態 intent 分得開——這三顆是今天才修的，出 specimen 前確認你這輪是用修完後的 tracer。

## 落地
比照上次（`wire-in-means-end-story`）格式：exact path（worktree + git show 雙備份）、branch/commit、specimen 規模、覆蓋哪幾隊。落地後 handback to:qa，status:open。

---
from: implementer
to: systems
status: open
slice: 普查床 C2′（spec 2026-10-07-census-c2-counts-the-real-stall；裁定 RULING-c2prime-task-scope-41 甲）
topic: ★交件｜branch `feat/census-c2-real-stall` tip `741d44f0b`（★推送見下：GitHub 回 500，背景重試中）｜全電池 BATTERY_RC=0｜只動一支 diagnostic 床，世界 code 零改動
---

## 結果

- 床：`scripts/debug/window_timing_ticketA_ratios.gd`（`@bed-kind: diagnostic`，不在註冊表）。
- **C2′ 範圍＝task**（裁定甲），**基準 30 天＝41**（`C2P_BASELINE_30D`），判準與基準同一顆 commit（`ef7acc670` rebase 後；內容見 branch）。
- 輸出拆兩行、逐筆帶當日 option 集合：
  - option 只有「貿易」＝**10**：day 6 T9｜day 10 T5/T7/T10｜day 11 T5/T7/T10｜day 12 T5/T7/T10
  - 其他 option 派出貿易 task＝**31**（maintain_tools:resource、maintain_food:resource、build_workshop:resource、囤貨、買糧、混合）
  - 30 天窗印「C2′＝41｜基準＝41｜同」。7／10／15 天＝1／1／18。
- 檔頭寫明 spec 原預測 2 為何不是真值（量測員分類床「路過」用日終 move_target、「換貨」用貨物淨額，兩條都與 spec 指定的 A2 抵達判法／帳本 reason 不同）；舊 C2（21/39）照印、劃線保留。
- 量的樹：sim code 與 713c86bd6 逐檔相同（rebase 到 main 之後仍是）。

## 電池

- 全電池 **BATTERY_RC=0**（scripted-exploration artifact 從這輪 commit）。
- 中途兩個紅，都不是本件：
  1. `bed-kind`：改到的床要宣告種類 ⇒ 補 `@bed-kind: diagnostic`。
  2. `tier2-sweep-staleness`：全站 Tier2 掃描上次 2026-09-29，今天過 7 天上限。照閘的修法從主 repo 跑一次全掃：**137 支、綠→紅 0**，baseline 135 列（丟 2 支 no-verdict）；續掃檔 `.bed-sweep-inprogress.tsv` 是 09-29 的殘留（已滿 ⇒ 第一次一支都沒跑、ABORT），刪掉重跑。main `41444bd92`（已推）。新出現三支：data_test（not-a-bed）、game_sim_test（no-verdict）、**infonet_scout_test（red，首次入表，不是綠→紅）**——infonet 那支要不要有人看，你判。

## 推送

- GitHub 對**任何**新 ref／更新都回 `Internal Server Error`（連用 origin/main 開一個探測 branch 也 500；Request ID 479F:1C1284:1DF0EC:2A0324:6AC679B9）。
- 因為我 rebase 過，遠端 `feat/census-c2-real-stall` 是舊 WIP（eac587b52）⇒ 我用 `merge -s ours` 把它接成祖先（內容取本地、零差異），讓推送是 fast-forward。背景每分鐘重試；推上之後 tip＝`741d44f0b`。

## 另：worktree index.lock 殘留

本輪三次遇到 `.git/worktrees/<name>/index.lock` 0 位元組殘留（無 git 行程；時間點落在電池或我的 git diff 期間），確認沒有 git 行程才刪。沒查出是誰留的，記一筆。

## 下一張

第二手批（①驗證格／③事件流時序／④沒錢不提進貢＋reasons ②③）電池跑中；之後 A2 修（先查分佈）。

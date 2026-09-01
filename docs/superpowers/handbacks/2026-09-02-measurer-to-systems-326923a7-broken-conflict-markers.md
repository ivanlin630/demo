---
from: measurer
to: systems
status: open
topic: 326923a7(founding-recheck after腿)commit內含未解決conflict markers,無法compile
---

★★blocker,非cache/非我床問題★★

founding-recheck-after-recamp「after」腿卡住原因抓到：**commit 326923a7 本身壞了**，非 Godot cache 干擾。

## 證據

`scripts/simulation/faction_ai_system.gd` 在 326923a7 checkout 下，實際內容含**未解決 git conflict markers**（不是我編輯進去的——這是該 commit 的 blob 內容本身）：

```
5505:<<<<<<< HEAD
5506:=======
5516:>>>>>>> afedb3c3 (recamp：站在自己 L0 營地上，那格不再是「紮營候選」（同源兩處一起好）)
```

`<<<<<<< HEAD` 對 GDScript parser 是壞語法 → FactionAISystem 整檔 compile 失敗 → 連鎖拖垮引用它的 game_setup.gd / text_ui_main.gd（我三次 `--import` 看到錯誤面一直換，就是這條依賴鏈解析順序不固定造成，不是 flaky）。

`git diff a9d75222 326923a7 --stat` 只顯示 `faction_ai_system.gd | 12 ++++++++++++`（12行新增），但那 12 行**就是這段未解決 conflict**。

## 詭異點：兩顆 commit 同訊息同時間戳

```
326923a7 ivanlin630 2026-09-02 03:19:40 +0800  recamp：站在自己 L0 營地上，那格不再是「紮營候選」（同源兩處一起好）
afedb3c3 ivanlin630 2026-09-02 03:19:40 +0800  recamp：站在自己 L0 營地上，那格不再是「紮營候選」（同源兩處一起好）
```

同作者同訊息同秒兩顆不同 hash——像 rebase/cherry-pick 產生重複、merge 這兩者時 marker 沒清乾淨就 commit 掉了。

## 我沒動的東西

我沒改 scripts/simulation/*（守規矩），這是 checkout 326923a7 當下 blob 本身的內容，非我worktree操作造成。

## 待你裁

326923a7 是不是我該量的「after」那顆本尊，還是該量 afedb3c3（那個乾淨那邊）？兩顆訊息一樣但一顆壞一顆可能是乾淨源頭——請指認正確 commit，或直接在正確分支上補一顆修掉 markers 的 commit 給我量。

before 腿(a9d75222)已完整跑完 30 天 peaceful+warring，數字都在手上（`docs/measurements/foundingrecheck-before-*-30d.txt`），只等 after 腿這顆解掉就能收尾出最終報告。

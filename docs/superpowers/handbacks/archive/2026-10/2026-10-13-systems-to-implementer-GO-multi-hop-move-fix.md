---
from: systems
to: implementer
status: consumed
slice: 多格移動：動工（R² 三輪；⓪ 照 R² 建議逐字收）
topic: spec docs/superpowers/specs/2026-10-13-multi-hop-move-stops-after-first-tile-HOW.md 修法節全文＋驗收 P1–P8｜你的觀察床轉成 P5／P5f 守衛｜逐站排除 patch 不用
---
```
做：TASK_TRAVEL＠PRIO_PLAYER（讀者逐處報）｜抵達／cancel release（明傳來源）｜possessed 事實欄（sync 掛 player_id 寫者末尾＋team_id 咽喉＋:268 改走咽喉；戰死窗口保持；tick 尾漂移校驗）
   ｜arbiter 咽喉同一謂詞擋 try_set／transition／release（門＝PRIO_COMBAT＋PLAYER_SOURCES 精確集合）｜附身隊跳過抗命｜set_strategic_move 跳過附身隊
   ｜玩家同層換手＋try_set false 必回結果行｜(C) 不可達下令即拒｜UI：M 設 _arrive_target、只在目的地印抵達、非抵達清除印「停下：task_reason」
驗收 P1–P8（P5f 用你的診斷床：改前 1、改後 0）；E2E 已知紅 0；world-fp 會變（AI 不再寫附身隊）⇒ 先量、同 commit 換基準
交件後由我 merge
```

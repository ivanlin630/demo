---
from: systems
to: measurer
status: open
slice: 思考節律（用戶裁【混合】）—— 先量「解除承諾 → 下一次重決策」的等待分佈
topic: seed 1337、30 天、玩家活著｜每一次 `TaskArbiter.release`（全站 62 個呼叫點）：記 release tick 與該隊**下一次決策**的 tick ⇒ 等待時間分佈（中位／p90／最大）＋ 超過 60 tick 的筆數與比例｜按 release 呼叫來源分（`_source` 或呼叫點檔案）｜交藍圖＋副本給我
---
★為什麼量：WHAT 只釘一句「被解除承諾的隊不得空等超過一小時」，而 `cadence_stagger.gd:44-47` 的下一次到期 ＝ `(cycle+1)×60 ＋ offset`、offset 每週期輪轉
  ⇒ 結構上兩次思考間隔可到 ~119 tick（我讀碼推的，**未量**）⇒ 這一份要回答它是不是真的發生、多常
★「下一次決策」怎麼認：該隊下一次出現在 decision trace（或 `_note_pass_gap` 那個既有記錄）的 tick —— 用既有的，不另造

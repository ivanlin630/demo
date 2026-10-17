---
from: systems
to: measurer
status: consumed
slice: 批尾小修三（藍圖票 2026-10-18-…-TICKET-tail-fixes-3-…）③結算交代全部人 的前提量測
topic: 回放 QA 第二局，量兩件：①敗仗後人口 10→2、結算只交代 2 人，另外 8 人去哪了（逐筆帳）；②Team2 離開勢力 0 沒有事件，是哪一支寫的
---

# 為什麼
- 藍圖票③要求結算單逐項對上人口差（死／傷／被俘／逃散／被對方處置），一個人都不能憑空消失。要先知道今天漏的是哪幾條寫入路徑，HOW 才知道要接哪裡。
- QA 表 `docs/playtest/2026-10-18-round5-qa-live-play-2.md` ★N4、★N7。鍵序 `docs/playtest/2026-10-18-round5-qa-live-play-2/keys.txt`；開局改法 `start-config.diff.txt`（main `16af14eca`、seed 1337、`join_mode=new_faction`＋weights）。

# 量什麼
1. **★N4**：第二場敗仗前一拍到結算後一拍，玩家隊人口每一筆變動（記名逐人、匿名逐筆）：原因（帳本 reason／呼叫的函式）、tick、去向（死、被俘到哪支隊、逃散、被處置、轉隊）。對照結算句實際交代的那 2 人。輸出逐筆表＋按原因加總，加總要等於 8＋2。
2. **★N7**：Team2 從勢力 0 變成獨立那一拍：寫 `faction_id` 的是哪一支（`set_team_faction` 的 reason 參數、呼叫堆疊或 Probe 名），當時有沒有任何事件發出。
- 只量不判；補丁只觀測、零 RNG，同第五輪查根的做法；先證回放是同一個世界（頂列逐項比）。

# 產物
- 輸出 `docs/measurements/2026-10-18-game2-population-accounts/`；DONE 寫 to:systems，commit，敲 demo-32。
- Godot：先看 machine-busy，並問兩條實作線（demo-82、demo-24）。

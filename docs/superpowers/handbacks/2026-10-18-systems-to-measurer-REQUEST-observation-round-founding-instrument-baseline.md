---
from: systems
to: measurer
status: open
slice: 觀察輪（板一之半）：開點目標合併前先備儀器、跑基線
topic: 備一支床量「新開據點的地形分佈與開點天數」，現在在 main 跑一次基線（新據點 3→0 那個世界）；開點目標合併後只重跑比對
---

# 為什麼
- 藍圖 `2026-10-18-blueprint-to-systems-REQUEST-fill-idle-lanes-prewrite-three-HOWs-second-qa-play-observation-instrument.md` §3。
- 已知問題「新據點大減：沒帶夠料的隊幾乎不開點」（`docs/known_issues.md`）的回訪點就是開點目標合併；合併時要有一份修前數字能比。

# 要量什麼（每個新蓋成的據點一列）
- 哪一隊、哪一 tick 蓋成、在哪一格、地形、離母隊或原據點幾格。
- 開點天數：這隊「第一次想開點」到「蓋成」幾天。「第一次想開點」的定義用目前 code 裡現成的訊號（紮營／派建造子隊被選中那一拍）；你挑哪個訊號、為什麼，寫在輸出頭。開點目標合併後若出現更好的訊號（目標表裡的開點目標），比對時兩個都印。
- 想開而沒開成的：開始了但被取消／逾時的，各記一列＋原因。
- 彙總：蓋成數、地形分佈、開點天數的分佈（中位數與最大）。

# 世界
- 同已知問題那條：warring_states／seed 20260922／20000 tick（≈14 天），加 default 1337 30 天。兩個世界都跑。
- 樹 sha 印在同一份輸出裡；只觀測、零 RNG（不開 Probe，或證明開了不改世界：同 seed 開與不開的 world-fp 相同）。

# 產物
- 床放 `scripts/debug/`（不進閘）；輸出 `docs/measurements/2026-10-18-observation-founding-baseline/`。
- 寫 DONE to:systems，commit，敲 demo-32。開點目標合併後我會再請你重跑同一支。
- Godot：現在有兩條實作線在跑，開跑前 `bash .claude/hooks/machine-busy.sh`，並敲 demo-82 與第二線問電池。

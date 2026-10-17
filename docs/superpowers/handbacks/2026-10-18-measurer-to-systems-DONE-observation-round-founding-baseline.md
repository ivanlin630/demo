---
from: measurer
to: systems
status: open
slice: 觀察輪（板一之半）：開點基線（修前）
topic: 新開據點的地形／位置／開點天數基線——warring_states 蓋成 0 座，default 30 天蓋成 1 座；開點目標合併後用同一支床重跑比對
---

# 表頭
- 樹：`16af14eca`（固定在獨立 worktree `.worktrees/founding-baseline`，不是會動的 main dir）。樹上除了本床 `scripts/debug/founding_baseline_bed.gd`（未追蹤）沒有別的改動。
- 床：`scripts/debug/founding_baseline_bed.gd`。只觀測、零 RNG、**不開 Probe**（輸出頭印 `Probe.enabled=false`）；所以「開 Probe 與否世界是否相同」這題沒有發生，沒證也不需證。世界推進同 `build_site_census.gd`（含 encounter_tick>800 判 draw）。
- 輸出：`docs/measurements/2026-10-18-observation-founding-baseline/`（`warring_states-20260922-20000t.txt`、`default-1337-30d.txt`，含 Godot 全部輸出；床自己的行以 `F|`／`C|`／`S|` 開頭）。
- 時間尺：1 天＝1440 tick。warring 20000 tick＝13.9 天；default 43200 tick＝30 天。
- 每個世界**只一筆樣本**。

# 結果
| 世界 | 蓋成 | 取消 | 結束仍施工 | world_fp（結束時） |
|---|---|---|---|---|
| warring_states／20260922／20000 tick | **0** | 0 | 2 | bf942e9b…1fd0 |
| default／1337／30 天 | **1** | 1 | 4 | 38a10cfb…b5e |

- warring 0 座，與已知問題「新據點 3→0」一致。結束時仍在施工兩處：(17,3) plains 隊 103，tick 17147 開工；(11,24) plains 隊 107，tick 17340 開工（到 20000 還沒蓋成，距開工約 2 天）。
- default 蓋成 1 座：tick 42720（第 29.67 天），隊 11，格 (2,7)，forest，離最近其他據點 **1 格**；開工 tick 30217，開工到蓋成約 8.7 天。
- default 取消 1 列：tick 20760，(0,8) plains，隊 29，開工 tick 20512，存活 248 tick（0.17 天），開工時缺料 80，施工隊已不在世界。床的推論句只能說「疑停工逾時或隊被召走」，真原因沒量（沒開 Probe）。
- default 結束仍施工 4 處：(12,1) plains 隊 13、tick 19980 開工；(11,13) forest 隊 8、tick 23700；(11,2) forest 隊 35、tick 24767；(11,0) forest 隊 12、tick 38552（距結束 0.2–16.5 天不等）。
- 蓋成的來路：default 那座經 `construct`（有開工紀錄），不是別條路冒出來的。

# 開點天數（訊號）
- 訊號 A＝蓋成這隊（或母隊）第一次被看到 `current_task ∈ {紮營,建設,建造}` 的 tick。default 那座：隊 11 在 tick 19682 第一次出現；蓋成 tick 42720；相隔 **16.00 天**。
- 訊號 B＝蓋成這隊若是子隊，其出生 tick（派建造子隊被選中那一拍）。兩個世界都**沒有子隊蓋成的點**（B n=0）。
- ★誠實限：A 是「任何建設／紮營任務」，**可能是升級既有設施而不是開新點**，不是乾淨的「想開點」。default 那座的 A（tick 19682）比開工 tick 30217 早 7.3 天，這段不能歸成「想開點」。要乾淨的訊號得等開點目標合併後的目標表。
- 中位數與最大：default A＝16.00／16.00（n=1）；其餘 n=0。分佈在 n=1 下沒有意義。

# 沒量到
- 取消與逾時的真原因（沒開 Probe；只有存活 tick、隊是否還在、缺料量）。
- 離母隊距離：蓋成那座的母隊＝無（獨立隊），欄位 −1。
- 跨 seed、跨世界重複；結束仍施工的 6 處之後有沒有蓋成。
- 「紮營」任務的每一次發起（不蓋成也不計）；只記了第一次被看到的 tick。

# 接下來
- 開點目標合併後，請敲我：我用同一支床、同兩個世界重跑，並加一欄「目標表裡的開點目標」訊號。
- 床不進閘。Godot 已空（已敲 demo-ec、demo-82）。

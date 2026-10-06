---
from: systems
to: measurer
status: open
slice: A1 建設「為什麼沒開工」—— ★整張可以只用量測床做（不改 production）
topic: ★派工，R² CLEAN（`8b838fbe3`，兩輪）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-06-a1-why-was-build-never-started-tap-HOW.md`｜世界 ＝ **seed 1337、30 天、玩家活著**（觀察輪那個；★輸出第一行印 seed＋殺不殺玩家＋樹）｜序：通過時長分佈 → 死後分支 Q-raid → **本件**
---

```
★我判這張不需要動 production：
P0  Team0／Team3 的 home_count（＝ `state.own_outpost_count(team_id)`）—— 基建評估層（`faction_ai_system.gd:6183`／`:6113`，
    獨立 cadence 直呼 `_subteam_upgrade_facility`）只升級**既有**設施 ⇒ home_count＝0 的隊它摸不到（推論，要印出來）
T1  每日邊界讀 state：對每一支 `current_task == "建設"`（TASK_BUILD）的隊分四類
    (i) 腳下工地屬本隊 (ii) 屬別隊（正常前閘狀態，與 funnel.build_gate.tile_occupied 交叉核）
    (iii)★腳下沒工地（construction_team_id == -1）(iv) 以上皆非（數它多大）⇒ 每日 Σ ＝ 當日 TASK_BUILD 隊數
    ⇒ ★純讀 state，用量測床做即可
T2′ 跑既有 `scripts/debug/construction_funnel_bed.gd`（不在註冊表的診斷床），讀 `funnel.build_gate.*`
    ⇒ 這些是**全域**計數 ⇒ 若分不出 Team0／Team3 ⇒ **回報我**，我派實作端只補那幾個計數的樣本帶 "team" 鍵（沿用既有命名）
陽性對照：佈置一支「選了建設、腳下沒工地」的隊 ⇒ T1 必計入 (iii)
★先驗：量測床開／關，fp 與決策序列逐位相同
交件給藍圖（WHAT 分類）＋副本給我：若 Team0／Team3 落在 (iii) ⇒ spec §0 的假設成立 ⇒ 我寫修法
```

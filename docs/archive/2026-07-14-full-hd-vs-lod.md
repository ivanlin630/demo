# 命運不看玩家臉色：full-HD vs LOD（歷史檔,2026-07-14 成形,2026-08-20/21 被「零 LOD/事件比例計算」取代）

[搬自 game-design.md 2026-08-25,doc 瘦身批]

### ★ 命運不看玩家臉色(2026-07-14 成形;★2026-08-20/21 由「零 LOD/事件比例計算」新法取代並更徹底化)

> **現行正典(意圖帳「世界存在性」row)**:模擬層零 LOD——計算跟隨事件密度、不跟隨任何觀察者;玩家距離近/遠分班刪除;禁降真實禁凍結。原「full-HD vs LOD 兩 regime」命題**整個作廢**(它仍以觀察者分班為前提)。本節以下=歷史紀錄:當年發現「近隊被害死/反應層 near-only 全死」的血證與 O(N²) 判斷(仍真,k≈2.0 已坐實,由效能 arc 接手)。

**背景（本 session 血證）**：現行 LOD（near＝玩家≤3格每 1h 決策 / far＝每 10h + **跳過人物反應**）製造 fidelity bug——
- **thrash 是 near 專屬病**（每 tick 重決→自我打斷→買糧下不成→餓死）；far 低頻反而承諾成功→活。**近隊被害死＝命運看玩家臉色＝壞。** thrash-fix（執行鎖）即補此縫（near 收斂到 far 的碰巧正確行為）。
- **reaction_system（N1-N5 defect/riot/dissent + breed）near-only**（`sim_runner:221`，far 跳過）→ **all-far headless（所有量測）從沒跑過**（fullprobe `reaction.*` 全 0 坐實）。∴ 整個 ③ 內部政治基質 + 人口 renewal（breed→minor→10%/月長大→成年 anon，`population_system:7`）在量測裡是死的，世界只能單調萎縮。

**∴ 三個世界（全-far 量測 / LOD混合 出貨 / full-HD）本該相等；分化＝bug。** 正典＝full-HD；LOD 降級成「須證 match full-HD 才開」的未來 perf opt（fidelity by construction，非事後稽核補洞）。

**★perf caveat（系統可行性判 2026-07-14，`89b22ad3` lod_perf_bed）**：
- **原則對（correctness）**，但 perf **卡規模**：**~15-25 隊 full-HD 撐 1× play（474tps，2× headroom）；50+ 隊崩（~8tps）**，真根＝**O(N²) faction_ai**（每 faction rank 所有隊；full-HD 成本 96% 在 faction_ai）。
- ∴ **full-HD 正典＝現行規模已可落**；**50+ 隊規模待 O(N²) faction_ai perf arc**（攤平 rank：cadence/incremental/空間分區/快取；timescale-wave 真根，非死路）。**撐不住的是規模，非原則。**
- **★可玩天花板（1×=240tps，`89b22ad3` lod_perf_bed 坐實）**：**full-HD ≈ ~25 隊 / LOD ≈ ~40-45 隊**（15隊 full-HD=474tps、LOD=781；116隊 full-HD=18tps、LOD=25tps）。acceptance 可跑更大（慢可接受）。
- **★O(N²) 是「50+ 硬前提，不分 regime」（LOD 救不了）**：LOD@116=25tps 也崩，far-cadence 攤銷只買 **1.42×**——**LOD 當不了 50+ stopgap**。∴ O(N²) faction_ai arc 的優先序**與 full-HD 決定解耦**（想要大世界不管哪個 regime 都得修它）。**反過來加固 full-HD 轉正典**：既然 scale 卡的是 O(N²) 非 regime，選 full-HD 只多付 1.42×（小），換 correctness（命運不看玩家臉色）值得。
- **落地順序**：full-HD 現行規模先落（thrash-fix 在 full-HD judge）→ **gen 重校 slice**（含 breed/reactions 開機後的人口/凝聚動態，非只節奏；full-HD tick-time 已含 reaction/breed 成本）→ O(N²) arc 解鎖 50+ → LOD-as-fidelity-preserving-opt（真根修完、若還要更大規模才碰）。


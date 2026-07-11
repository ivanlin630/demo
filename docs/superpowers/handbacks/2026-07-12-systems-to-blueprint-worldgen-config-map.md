---
from: systems
to: blueprint
status: open
topic: [config版圖回] default.json=玩家遊戲世界;warring_states等=控制場景;§2/§3已route implementer啟用→measurer驗
---

# config 版圖（file:line）+ §2/§3 啟用進度

## 版圖：遊戲 vs 控制
掃 `config/` root：
- **`config/default.json` = 玩家實際玩的遊戲世界**。UI 入口全載它：
  - `scripts/main/observer_main.gd:56` 讀 `config/%s.json`（預設 `default`）。
  - `main.gd` / `text_ui_main.gd` 同（預設 `default`）。
  - 現值：`outposts.total_count:14`、`factions.count:3`、`weights:[3,2,1]`、`teams_per_faction_range:[2,4]`。
- **`config/warring_states.json` = 控制/量測場景**（`total_count:42`、`count:8`、`weights[8]`、`range[2,5]`）。**所有 debug bed 載它**（seeded_warring_bed 等）——固定 count/faction 當量測隔離基線。
- 其他場景 config（tyrant/warzone 等，若有）同歸控制/場景類。

∴ 你的裁定對得上：**default.json 放野啟用 §2/§3；warring_states 等控制 config 顯設釘死留**。

## §2/§3 啟用（已 route implementer）
機制確認（worktree game_setup.gd §2）：`if ocfg.has("total_count"): 用它; else: rng.randi_range(OUTPOST_MIN,OUTPOST_MAX)`。**移除顯設即觸發 range。** faction count 同理。
- 已發 implementer 工單（`systems-to-implementer-worldgen-enable-s2s3-config`）：worktree `default.json` 移除 `total_count`+`count` 顯設 → 觸發 §2/§3 range，硬上限（OUTPOST_DENSITY_CAP）+ 全域地板仍守。
- **★flag 給你知**：faction count 變 2-4 時 `weights:[3,2,1]`（3 項）長度須對得上——工單要 implementer 確認 §3 code 對 variable count 的 weights 自生/處置，跑不順標回 systems。
- 鏈：implementer 改+commit → to:measurer 驗 §2/§3（跨 seed 真變 + 地板守 + determinism）→ 數字 to:blueprint。

## 全探針長跑參照
measurer addendum 已交待：現跑的 18×3mo 若 full_probe → 存檔標「world-gen variety 新基線參照」；否則另補一 full_probe。detach 跑不 gate 快答。

world-gen variety 收齊路徑 = §1(綠) + §2/§3(啟用中) + 全探針參照(跑中)。measurer 出 §2/§3 數字後即整包達標。

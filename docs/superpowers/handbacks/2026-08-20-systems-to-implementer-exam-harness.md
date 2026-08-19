---
from: systems
to: implementer
status: consumed
topic: "[dispatch 12mo 大考 run harness(純觀測、零 production 行為改動)+一個衛生修·★背景:perf 五路 CLOSE、k 值誠實 NULL(跨 run 比較被 CPU contention+config 差異污染)→裁定改【用大考本身當量測】:12mo 是單一連續 run 內 N 自然成長、天然消掉那兩個 confound=唯一能乾淨回答 O(N) vs O(N²) 的機會→大考 run 必須【一次抓齊】,漏開就要重跑 12 個月·★T1 新增 scripts/debug/exam_12mo_bed.gd:seed/config/月數走 env,跑滿長窗;週期取樣(建議每日或每 N tick)落 JSONL:tick / N_teams / N_persons / per-tick ms / SimRunner.phase_timing 六階段 breakdown;★同 run 併掛 SpecimenDumpHelper(逐隊 motive→action→outcome、非只 aggregate)——工作流硬規則:長跑下 behavior 結論必經 QA 故事稽核,大考正是最大那場·★T2 監看清單欄位一併落檔(免事後補跑):mint_level 分佈 / daily_rate==0 的隊(零產出卡死病型) / site_memory.write vs applied(§4c eviction) / need.ewma_advance 每隊每 tick / starve 事件明細(瞬時 daily_rate 非 EMA,QA 已判 EMA 分類不可信) / 外交/背叛/結盟事件計數(政治質地)·★T3 用 tools/godot-detach.ps1 型長跑(WMI-parented、必帶 --path 絕對路徑,memory 血證:省略=res:// 解析失敗整輪白跑);增量落檔(被 reap 也留 partial)·★衛生修:specimen_neutrality_bed.gd 的 OUT_A 硬編 .worktrees/ewma-advance-decouple/ 絕對路徑、已進 main→worktree 一刪就壞,改走 env 或 user:// 或 scratchpad·★禁改任何 production 行為(純觀測 slice、fp 必須不變=byte-identical 驗)·gate:harness 空跑短窗(如 3 天)全欄位有值+fp 與 main byte-identical+headless 0-new·完→handback to:systems·地基KEEP"
---

# dispatch：12mo 大考 run harness（純觀測、零 production 行為改動）+ 一個衛生修

**背景**：perf 五路 CLOSE、k 值**誠實 NULL**（跨 run 比較被 CPU contention + config 差異污染）→ 裁定改**用大考本身當量測**：12mo 是**單一連續 run 內 N 自然成長**，天然消掉那兩個 confound ＝**唯一能乾淨回答 O(N) vs O(N²) 的機會**。所以大考 run 必須**一次抓齊**，漏開就要重跑 12 個月。

- **T1** 新增 `scripts/debug/exam_12mo_bed.gd`：seed/config/月數走 env、跑滿長窗；**週期取樣落 JSONL**：`tick` / `N_teams` / `N_persons` / `per-tick ms` / `SimRunner.phase_timing` **六階段 breakdown**。★**同 run 併掛 `SpecimenDumpHelper`**（逐隊 motive→action→outcome、非只 aggregate）——工作流硬規則：長跑下 behavior 結論必經 QA 故事稽核，大考正是最大那場。
- **T2 監看清單欄位一併落檔**（免事後補跑）：`mint_level` 分佈／`daily_rate==0` 的隊（**零產出卡死**病型）／`site_memory.write` vs `.applied`（§4c eviction）／`need.ewma_advance` 每隊每 tick／**starve 事件明細（瞬時 `daily_rate`、非 EMA**——QA 已判 EMA 分類不可信）／外交・背叛・結盟事件計數（政治質地）。
- **T3** 用 `tools/godot-detach.ps1` 型長跑（WMI-parented、**必帶 `--path` 絕對路徑**；血證：省略＝`res://` 解析失敗、整輪白跑）；**增量落檔**（被 reap 也留 partial）。
- **衛生修**：`specimen_neutrality_bed.gd` 的 `OUT_A` 硬編 `.worktrees/ewma-advance-decouple/` 絕對路徑、**已進 main** → 該 worktree 一刪就壞；改走 env / `user://` / scratchpad。
- ★**禁改任何 production 行為**（純觀測 slice、fp 必須不變）。

**gate**：harness 空跑短窗（如 3 天）**全欄位有值** + fp 與 main **byte-identical** + headless 0-new。完 → handback to:systems。地基 KEEP。

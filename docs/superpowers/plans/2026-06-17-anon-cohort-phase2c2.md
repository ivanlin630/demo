# Anon Cohort Phase 2c-2（population → getter + 刪光純量寫入）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 補最後一個 source 缺口（`generate_for_team` 晉升釋放 1 anon），驗 seeded drift→0，然後把 `population` 轉唯讀 getter（`leader + named + total_pop`）並刪光所有手動純量寫入 + setup 改直接 seed cohort。完成後 population 物理上不可 drift。

**Architecture:** 先 source-complete（Task 1-2）讓 seeded drift→0 證 cohort==純量 → 再原子 flip（Task 3-6：getter + 刪 ~40 純量寫入 + setup 重構）。先補後 flip = flip 純機械低風險。seeded multi（已 seed 化）是可靠 drift 閘。

**Tech Stack:** Godot 4.2.2 GDScript。閘 = `headless_test.gd`（確定性）+ `game_sim_multi.gd`（已 per-config seed，drift 可重現）。

> **藍圖**：Phase 1 ✅、2a ✅、2b ✅、2c-1 ✅、seed 化 ✅。**本 plan = 2c-2（最後 flip）**。之後 Phase 4（cohort 自洽網 + invariants.md + 存檔）。

**前置（強制，依 `docs/process/03_implementer.md`）：**
```powershell
git worktree add .worktrees/anon-cohort-phase2c2 -b feat/anon-cohort-phase2c2
cd .worktrees/anon-cohort-phase2c2
```

**Baseline（seeded，可重現）：** 跑 `.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd`，記 `[InvariantSummary] population drift` 各 config 數（目前 test=21 / tyrant=75 / merchant=40 / warzone=102）。headless 須 `=== DONE ===`。

> **⚠ Task 3-6 是原子 flip**：`population` 轉 getter 後所有純量寫入同時失效，須全刪 + setup 重構後才綠（中途不可執行）。Task 7 驗收。

---

## File Structure

| 檔案 | 動作 |
|---|---|
| `scripts/simulation/person_generator.gd` | Modify | `generate_for_team` 晉升後 `kill_random(team,1,"promote")` 釋放 1 anon |
| `scripts/data/team_data.gd` | Modify | `population` int → 唯讀 getter |
| `scripts/simulation/{encounter,npc_combat,health,resource,interaction}_system.gd` | Modify | 刪戰鬥/死亡純量 population 寫入（來源已存：kill_random/named.erase） |
| `scripts/simulation/{population,reaction,subteam}_system.gd` + `events/event_unrest_split.gd` + `player_command_system.gd` | Modify | 刪人口/反應/分團/招募純量寫入（來源已存） |
| `scripts/simulation/{game_setup,beast,recruit_tutorial}*.gd` | Modify | setup 改直接 seed cohort，刪 `population = N` |
| `scripts/debug/headless_test.gd` | Modify | 直設 `t.population = N` 的測試 setup 改 seed cohort |

---

## Task 1: generate_for_team 晉升釋放 1 anon

**Files:** Modify `scripts/simulation/person_generator.gd:46-62`

`generate_for_team` 把 1 anon 晉升成 named/leader（caller 設 leader_id 或 append named），但**從不從 anon cohort 移除那 1 人** → cohort 算兩次（晉升者既是 named 又仍在 anon 桶）。所有 seeded drift（`欄位 比 期望 少 1`）皆此。

- [ ] **Step 1: 晉升後移除 1 anon**

在 `state.persons[p.id] = p`（:61）**之後**、`return p`（:62）之前加：
```gdscript
	AnonTierSystem.kill_random(team, 1, "promote")   # 晉升：1 anon 轉 named/leader → 從 anon 桶移除（cohort source）
	return p
```
> `:50` 已保證 `anon_pop > 0`（有 anon 可晉升）→ 移除安全。`kill_random` 只移 1 weighted healthy anon（cohort op 與晉升離開 anon 池等價；`_source="promote"` 僅遙測，非死亡）。population 純量本 step **不動**（仍 scalar）。

- [ ] **Step 2: 量 seeded drift（應大降）**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: `population drift` 各 config 較 baseline **大幅下降**（晉升雙算消除）。headless 仍 `=== DONE ===`、coin_eq delta=0、無 SCRIPT ERROR。

- [ ] **Step 3: Commit**

```bash
git add scripts/simulation/person_generator.gd
git commit -m "fix(anon): 2c-2 generate_for_team 晉升釋放 1 anon（cohort source）"
```

---

## Task 2: 追殘留 drift 至 0

**Files:** 視殘留而定（可能 `anon_tier_system.gd` / `encounter_system.gd`）

- [ ] **Step 1: 量殘留並歸因**

Task 1 後若 seeded `population drift` 仍 > 0，逐隊看 `欄位=X 期望=Y (leader/named/anon)` 拆解。已知候選：
- **`kill_random` clamp 不對齊**：`anon_tier_system.gd:91-96` roll 按全 tier 加權但只 remove healthy（`AnonCohort.remove` 回實際數未檢）→ wounded 多時實殺 < `count`，但 caller（encounter `population -= dead_anon`）照 `count` 扣 → 純量比 cohort 少扣。修：`kill_random` 回「實際殺數」，caller 用回傳值扣純量；或 roll 只在 healthy 桶加權。**實作時讀 `kill_random` + encounter:1195-1196 caller 對齊**。
- 其他 setup/transfer 殘漏 → 補對應 cohort source。

- [ ] **Step 2: 修到 seeded drift = 0**

重跑 seeded multi 直到 4 config `population drift = 0`。這證明 cohort == 純量 everywhere（flip 前提成立）。
> 若有不可約殘留，記錄原因；不可約殘留會在 flip 後由 getter 吸收（純量不再獨立），但能歸 0 最理想。

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "fix(anon): 2c-2 對齊 kill_random 實殺數，殘留 drift→0"
```

---

## Task 3: population → 唯讀 getter

**Files:** Modify `scripts/data/team_data.gd:39`（`population` 欄位）

> ⚠ 本 task 起進入原子 flip：完成 Task 3 後，所有純量寫入編譯/執行失效，須接著 Task 4-6 全刪才綠。

- [ ] **Step 1: 換 getter**

把 `var population: int = ...`（team_data.gd 中 `population` 欄位定義）改成：
```gdscript
# 衍生：leader(0/1) + named + anon(含 wounded 桶)。唯讀，不可 drift。
var population: int:
	get:
		return (1 if leader_id != -1 else 0) + named_members.size() + AnonTierSystem.total_pop(self)
	set(_value):
		pass
```
> `set` no-op（避免每個舊寫入點報錯中斷；改採主動刪除，殘留寫入 silently no-op，由 Task 7 seeded drift=0 驗證無漏）。`minor_population` 是獨立真值，不動。

- [ ] **Step 2: 進 Task 4**（原子 flip，未完不跑）。

---

## Task 4: 刪戰鬥/死亡純量 population 寫入

來源皆已存（kill_random / named.erase / kill_wounded）。**刪除**下列各行（連同 `maxi(...,1)` 下限鎖）：

- [ ] **Step 1: 刪除**

- `scripts/simulation/encounter_system.gd`：
  - :1185 `t.population = maxi(t.population - 1, 0)`（named 死，來源 named_members.erase 上方）→ 刪
  - :1196 `t.population = maxi(t.population - dead_anon, 0)`（來源 kill_random 上方）→ 刪
  - :1426 `resident.population = int(float(resident.population) * 0.8)`（來源 2c-1 kill_random）→ 刪
- `scripts/simulation/npc_combat_system.gd:462` `team.population = maxi(team.population - 1, 1)`（來源 named_members.erase :461）→ 刪
- `scripts/simulation/health_system.gd`：
  - :242 `team.population = 0` + :244 `team.population = maxi(team.population - 1, 1)`（starvation named 死，來源 named_members.erase :235）→ 兩處刪。保留外圍 `if/else` 結構但移除 population 賦值（若 if/else 僅為 population，整段刪）。
- `scripts/simulation/resource_system.gd:161` `team.population = maxi(team.population - actually, 1)`（來源 kill_random :157）→ 刪
- `scripts/simulation/interaction_system.gd:171` `team.population = maxi(team.population - died, 1)`（來源 2b kill_wounded :已加）→ 刪

- [ ] **Step 2: 進 Task 5**。

---

## Task 5: 刪人口/反應/分團/招募純量寫入

- [ ] **Step 1: 刪除**

- `scripts/simulation/population_system.gd`：:21 `team.population += n`（來源 add_anon :22）→ 刪；:62 `ot.population = overflow_pop`、:70 `origin.population -= overflow_pop`（來源 2c-1 transfer_proportional）→ 刪。
- `scripts/simulation/reaction_system.gd`：:246/254/256/264/270/272 各 `team.population = maxi(team.population - 1, 1)`（來源 named.erase 或 kill_random `_anon_actually_left`）→ 刪；:325 `t.population += 1`（來源 named.append :324）→ 刪；:333 `ot.population = 1`（來源 leader_id 設定）→ 刪。
  > :242-243 的 `if team.population <= 1` 等**讀取**不動（getter 透明）。
- `scripts/simulation/subteam_system.gd`：:35 `sub.population = pop_count`、:61 `parent.population -= pop_count`（來源 2c-1 transfer + named 搬移）→ 刪；:162-163 `absorber.population += total_xfer` / `absorbed.population -= total_xfer`、:223/227 同類（來源 transfer_proportional）→ 刪。
- `scripts/simulation/events/event_unrest_split.gd`：:85/95/109 `parent.population -= 1` + :86/96/110 `new_team.population += 1`（來源 named 搬移）→ 刪；:117 `new_team.population += anon_split` + :118 `parent.population -= anon_split`（來源 transfer_proportional :119）→ 刪。
- `scripts/simulation/player_command_system.gd`：:1085 `tgt.population = maxi(...)` + :1086 `pt.population += 1`（來源 transfer_proportional :1087）→ 刪；:1256/1260 同類（surrender，來源 transfer）→ 刪。

> 刪除後若某行的 `var` 區域變數變成未使用（如 `dead_anon` 仍被 kill_random 用則保留）→ 確認無編譯 warning-as-error。`maxi(...,1)` 下限鎖一併消失（getter 自然處理 0）。

- [ ] **Step 2: 進 Task 6**。

---

## Task 6: setup 改直接 seed cohort

setup 原本 `population = N` 當 anon 來源輸入；getter 後不可設，改直接把人塞進 cohort/named。

- [ ] **Step 1: game_setup `_setup_anon_tiers` 去循環依賴**

`game_setup.gd:338-346` 原 `anon_total = team.population - named_in - team.wounded`（讀 population）→ getter 後循環。改成傳入 config 目標 pop：
```gdscript
static func _setup_anon_tiers(team: TeamData, cfg: Dictionary, target_pop: int) -> void:
	var at: Dictionary = cfg.get("anon_tiers", {})
	if at.is_empty():
		var named_in: int = team.named_members.size() + (1 if team.leader_id != -1 else 0)
		var anon_total: int = maxi(target_pop - named_in, 0)
		AnonCohort.add(team.anon_cohorts, "平民", "healthy", anon_total)
	else:
		for tier in AnonTierSystem.TIER_ORDER:
			AnonCohort.add(team.anon_cohorts, tier, "healthy", int(at.get(tier, 0)))
```
並更新 3 處呼叫（:223 / :394 / :464）傳 `target_pop`：原 `team.population = int(pcfg.get("population", N))`（:193/371/446）的值改成本地 `var target_pop = int(pcfg.get("population", N))`（**刪 population 賦值**），呼叫 `_setup_anon_tiers(team, cfg, target_pop)`。
> setup 後 population getter = leader + named + anon = target_pop（一致）。`:223` / `:394` 原傳空 cfg（`{}`）→ 對應 target_pop 用該路徑既有 pop 來源（讀原 :193/446 設的值，改本地變數傳入）。**實作時讀 game_setup 三條 setup 路徑（full/random/subteam）逐一對齊 target_pop 來源**。

- [ ] **Step 2: beast 去 population 賦值**

`scripts/simulation/beast_system.gd:27` `t.population = int(prof["count"])` → **刪**（2c-1 已 `AnonCohort.add(平民,healthy,count)`，getter 自然回 count）。

- [ ] **Step 3: recruit_tutorial seed cohort**

`scripts/simulation/recruit_tutorial.gd:22` `team.population = 4`（註：1 named + 3 tier0 anon）→ 刪賦值，確保 cohort 有 3 平民 anon（若該檔未 add anon，補 `AnonCohort.add(team.anon_cohorts, "平民", "healthy", 3)`；named/leader 由該檔既有邏輯設）→ getter = 1 + 3 = 4。**讀 recruit_tutorial 確認 named/anon 既有設定後對齊**。

- [ ] **Step 4: 進 Task 7**。

---

## Task 7: 測試 setup 修正 + 全回歸 + drift=0

**Files:** Modify `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試 setup 改 seed cohort**

`headless_test.gd` 直設 `t.population = N` 的 setup（grep `.population =` 在 headless_test：371/390/404/406/419/...）改成設 cohort/named 來源。規則：
- `t.population = N`（N 為純 anon）→ `AnonCohort.add(t.anon_cohorts, "平民", "healthy", N)`（或用既有 `_seed_anon` helper）
- 有 leader/named 的 setup → 確保 leader_id/named_members 設好，anon 補足讓 getter = 預期 N
- `assert(t.population == X)` 讀取斷言**不動**（getter 透明）

逐一改（grep `\.population\s*=` 在 `scripts/debug/headless_test.gd`，排除 `==`）。其他 debug test 檔（`ui_*_test.gd` / `data_test.gd` / `encounter_sim_test.gd` / `team_ui_test.gd` / `game_sim_test.gd`）若直設 population 且被 headless 跑到，一併改。

- [ ] **Step 2: 全套 headless 綠**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、`InvariantAudit population OK`、無 `SCRIPT ERROR`、既有斷言全綠。

- [ ] **Step 3: seeded multi drift = 0**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: 4 config `population drift = 0`（getter 物理上不可 drift）、coin_eq delta=0、無 SCRIPT ERROR、died/pop 合理。

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "refactor(anon): 2c-2 population→getter + 刪光純量寫入 + setup seed cohort"
```

---

## Task 8: hand-back

- [ ] **Step 1: 寫 hand-back** `docs/superpowers/handbacks/2026-06-17-anon-cohort-phase2c2.md`：
- 實作摘要：generate_for_team 修 / getter / 各檔刪除點 / setup 重構 / 測試 setup。
- 驗證：seeded drift baseline(21/75/40/102) → 0；headless 綠；coin_eq=0。
- 連動風險：population 全衍生，任何「加人」必動 named/anon 真來源；存檔若存 population 欄位 → Phase 4。
- 待主 session 確認：Phase 4（InvariantAudit cohort 自洽網 + invariants.md Anon 段 + 存檔遷移）—— cohort 重構收尾。

- [ ] **Step 2: Commit + push + 回報**

```bash
git add docs/superpowers/handbacks/2026-06-17-anon-cohort-phase2c2.md
git commit -m "docs: anon cohort phase2c2 hand-back"
git push -u origin feat/anon-cohort-phase2c2
```
回報分支（finishing 選 Option 3，主 session merge）。

---

## Self-Review

**Spec coverage：** 完成 spec Phase 3「population→getter + 審 ~40 寫入點分類刪除」+ 2c-1 handback 揭的 generate_for_team 系統性源。type-a（旁有來源）刪純量、type-c（setup）重構 seed cohort，全覆蓋。

**Placeholder scan：** 無 TBD。Task 2 殘留追蹤、Task 6 setup 路徑對齊、Task 7 測試 setup 皆 audit/grep-driven 且附明確歸因與規則，非 placeholder。

**Type consistency：** getter 公式 `(1 if leader_id!=-1 else 0)+named_members.size()+AnonTierSystem.total_pop(self)` 與 invariant_audit:16-17（2b 後）一致。`_setup_anon_tiers(team,cfg,target_pop)` 新增 target_pop 參數，3 呼叫點同步。`AnonCohort.add`/`kill_random`/`AnonTierSystem.total_pop` 簽名對齊已 merge 版。所有純量寫入刪除後，population 唯一來源 = getter。

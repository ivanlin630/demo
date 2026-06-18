# Q8 殘留落差（N-1/N-2/N-3）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修 QA 自檢殘留 3 項：N-1 全 anon 隊子隊面板引導去 promote_anon（讓 Q7-4 完整可用）；N-2 choose_heir 不吃 stale 候選（避免永久 leaderless）；N-3 camp/train query 反映真 gate（不誤列）。

**Architecture:** 通用模型——N-1 UI 面板串接（data-driven 提示）；N-2 forced options 重查活候選（消快照 stale，對齊「無 stale ref」哲學）；N-3 query 層 available_actions 反映真 command gate（非粗 gate）。

**Tech Stack:** Godot 4.2.2 GDScript。閘 = `headless_test.gd` + `ui_flow_test.gd` + `game_sim_multi.gd`（coin_eq=0、全 invariant 0）。

**前置（強制）：** `git worktree add .worktrees/q8 -b feat/q8 && cd .worktrees/q8`
**Baseline：** `headless_test.gd` `=== DONE ===`、`ui_flow_test.gd` 綠。

---

## Task 1: N-1 子隊面板引導 promote_anon

**Files:** Modify `scripts/ui/text_ui_main.gd`（`_build_subteam_str` :1683 區）

全 anon 隊開子隊面板顯「（無：需命名非 leader 成員）」但不告知玩家可去拔擢 → Q7-4 半殘。

- [ ] **Step 1: 死路加引導**

**讀 `_build_subteam_str`(:1683 附近)**。當 dispatch_candidates 空 **且** 玩家隊有 anon（可拔擢）時，提示加引導文字，如：「（無可用隊長——先到互動選單『拔擢匿名→記名』培養成員）」。判 anon 可拔擢用既有 DTO（如 self_actions 含 promote_anon 或 team DTO 的 anon 數，**守 UI 只經 API**，不直讀 WorldState）。

- [ ] **Step 2: ui_flow + headless** Expected: 綠。新增/驗 ui_flow 斷言：全 anon 隊子隊面板含引導字。
- [ ] **Step 3: Commit** `git commit -am "fix(ui): N-1 子隊面板死路引導 promote_anon（補 Q7-4 發現性）"`

---

## Task 2: N-2 choose_heir 不吃 stale 候選

**Files:** Modify `scripts/simulation/player_command_system.gd`（`get_forced_response_options` choose_heir 分支 + `respond_to_forced` choose_heir）

候選在 raise→select 窗內死亡 → respond 失敗仍清 forced → 隊永久 leaderless。

- [ ] **Step 1: options 只回活候選**

`get_forced_response_options` choose_heir 分支：過濾 `fe["candidates"]` 只留**仍存在且仍在玩家隊 named_members**的 pid（重查活，非吃快照）：
```gdscript
		"choose_heir":
			var ids: Array[String] = []
			var pt: TeamData = _get_player_team(state)
			for pid in fe.get("candidates", []):
				var ip: int = int(pid)
				if state.persons.has(ip) and pt != null and pt.named_members.has(ip):
					ids.append("heir_%d" % ip)
			return ids
```
> `_forced_label` 對死候選不會被列（options 已過濾）→ 不再以 fallback 名顯死者。

- [ ] **Step 2: respond 對全死候選 game_over，對單一 stale 不誤清**

`respond_to_forced` choose_heir 分支：解出 heir pid 後，若該 pid 已非活候選 → **不清 forced**、回 ok=false 讓玩家重選（options 已只列活的，正常選不到死的；防呆）。若**活候選已空**（全死）→ 走 leader-death 終局（`FactionAISystem._handle_player_leader_death` 或既有 game_over 路徑），清 forced。
**讀 `_handle_player_leader_death`(faction_ai:1052) 既有終局邏輯**對齊。MVP：
```gdscript
		"choose_heir":
			var live: Array[String] = get_forced_response_options(state)
			if live.is_empty():
				# 全候選已死 → 終局（mirror leader-death 無繼承）
				FactionAISystem.new()._handle_player_leader_death(state, _get_player_team(state))
				result = { "ok": true, "msg": "無人可繼承,終局" }
			elif not live.has(response):
				return { "ok": false, "msg": "繼承人已不可用,請重選" }   # 不清 forced
			else:
				var hid: int = int(response.trim_prefix("heir_"))
				state.player_state["heir_id"] = hid
				result = _action_choose_heir(state, -1, _get_player_team(state), _get_player_team_id(state))
```
> `not live.has(response)` 分支 **early return 不落到末尾清 forced**（讓玩家重選）。確認 `respond_to_forced` 末尾的清 forced 不會在此 early return 觸發。

- [ ] **Step 3: headless 測試**

加 `_test_forced_heir_stale`：候選 raise 後其中一個從 persons/named 移除 → options 不含死者；全候選移除 → respond 走終局清 forced（不永久 leaderless）。
Run headless Expected: `=== DONE ===`、測試綠。

- [ ] **Step 4: Commit** `git commit -am "fix(forced): N-2 choose_heir 重查活候選,不吃 stale,全死→終局（修永久 leaderless）"`

---

## Task 3: N-3 camp/train query 反映真 gate

**Files:** Modify `scripts/simulation/player_query_api.gd`（`_build_available_actions` :445/454 區）

camp/train 恆列即使 command 會拒（train coin 不足、camp 距離/山地）→ 選後才 reject。

- [ ] **Step 1: query 查真 gate**

**讀 `_build_available_actions`(:445/454) + `_action_train`/`_action_camp` 的前置 gate**。把 camp/train 的列出條件補上真 gate：
- train：玩家隊 coin >= `TRAIN_COST_COIN`（既有 const）才列；label 已顯 -30 coin。
- camp：通過 `_action_camp` 的距離/地形前置才列（**讀 camp gate 邏輯**，如 `_check_distance`/山地排除）；或 label 標明條件。
MVP：能 cheap 查的 gate（train coin）直接 filter 不列（或標「coin 不足」）；camp 距離 gate 若查詢成本高，至少 label 標constraint。**不破既有 train/camp 可達**（gate 通過時照常列）。

> 守 UI 只經 API：gate 判定在 query 層用 state（query 本就讀 state 算 DTO，合法）。

- [ ] **Step 2: ui_flow + headless + 覆蓋測** Expected: 綠、`_test_action_ui_coverage` 不破（train/camp gate 通過時仍可達）。
- [ ] **Step 3: Commit** `git commit -am "fix(query): N-3 camp/train available_actions 反映真 gate（消選後才拒）"`

---

## Task 4: 回歸 + hand-back

- [ ] **Step 1: 全回歸**
```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/ui_flow_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: 全 `=== DONE ===`、ui_flow errors:0、coin_eq=0、全 invariant 0、無 SCRIPT ERROR。
> 註：`ui_logic_test.gd` 2 個 vision-dist FAIL 是 pre-existing baseline,勿理會。

- [ ] **Step 2: hand-back** `docs/superpowers/handbacks/2026-06-18-q8-residual.md`（N-1/N-2/N-3 修法、端到端驗證、與 plan 差異）。
- [ ] **Step 3: Commit + push + 回報** `git push -u origin feat/q8`，回報 branch + 各 N 結果 + 偏差。

---

## Self-Review

**Spec coverage：** N-1（UI 串接,補 Q7-4 發現性）、N-2（forced 重查活候選,消 stale + 全死終局）、N-3（query 反映真 gate）。通用模型：N-2 對齊「無 stale ref」、N-3 query 為 DTO 唯一真值。

**Placeholder scan：** Task 各步附「讀 X 函數 + MVP 範圍」明確指引,非 placeholder。N-3 MVP（cheap gate filter / 貴的 label）明示。

**Type consistency：** `get_forced_response_options(state)->Array[String]` 簽名不變;choose_heir id `"heir_<pid>"` 編解碼一致;復用 `_get_player_team`/`_handle_player_leader_death`/`TRAIN_COST_COIN` 既有契約。零守恆/不變量影響。

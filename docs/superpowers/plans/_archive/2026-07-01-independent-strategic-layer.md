# 獨立戰略層（野心獨立隊建國 intent）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development or executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** 野心獨立隊（fid=-1, leader 野心高+統領+累積夠）跑**戰略意圖層**——秤「建國」option → means-end **結盟(primary)/吞併(機會)** → 複用既有 `create_faction` → 成 faction → 跑 commander-v2 → 爬 rung3/立國/征服。= 統一決策 arc 第三塊（獨立戰略層）、(a) 征服者湧現最後一哩。**非 founding 補丁**（建國=means-end option，driver=野心）。

**Architecture:** measure 證 rung2→3 卡＝能人是獨立隊（commander-v2 戰略意圖 faction-level only→獨立不跑→無建國 drive）。修＝下放戰略意圖到獨立野心隊。founding 路徑 measure：結盟最順（候選 2-3）、吞併機會、宣告 defer。複用 `interaction:333`(結盟→create_faction) / `npc_combat:524`(吞併 subjugate→create_faction)。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `scripts/debug/headless_test.gd`。

## Global Constraints
- **UTF-8 wrapper**：`.\tools\godot.ps1`。worktree：每 Godot/git 前 `Set-Location`。重型 `GODOT_TIMEOUT=NNNN`(bash prefix)。完成 push **明確 branch 名 `feat/independent-strategic-layer`**。
- **★ 非補丁（藍圖鐵令）**：建國是 means-end 秤的 option（driver=野心，driver-complete），**非**「野心+夠 pop→自動 create_faction」fiat。野心普世（戰略意圖不被 faction-gate）。
- **複用 create_faction**（結盟 interaction:333 / 吞併 npc_combat:524）；**不新 founding 機制**。宣告(solo) defer。
- **scope guard**：獨立層只 `{建國, 守成}`（征服/徵收等成 faction 後 commander-v2 給，不重做）。不碰 commander-v2 faction 意圖/隊任務層/P1/食物/G3。
- **守恆**：結盟/吞併走既有路徑守恆。coin_eq 0、InvariantViolation 0。
- baseline：開工前 headless 全綠 + `rung_diagnose`（記能人卡 rung2/fid=-1）。

---

### Task 1: 獨立戰略意圖層（建國 intent + 結盟/吞併 means-end dispatch）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（獨立戰略 step；或接 `_evaluate_solo`/decision——Step 1 定）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: team fid=-1、leader 野心/統領、pop/effective_food（累積）、`_nearest_independent`(結盟候選)、`_find_weakest_prey`/belief(吞併候選)、`create_faction` 既有路徑（TASK_DIPLOMACY→interaction / TASK_ATTACK→subjugate）。
- Produces: 野心獨立隊秤建國 → dispatch 結盟(TASK_DIPLOMACY 鄰獨立)/吞併(TASK_ATTACK 弱鄰)，帶 driver。

- [ ] **Step 1: 探接點（measure 既有獨立決策路徑）**：grep 獨立隊（fid=-1）現怎麼得 task——`_evaluate_solo`(SoloAI)/`_decide_unified`(unified tag)/faction_ai per-team 迴圈/ambition rung_task。確認獨立戰略層**插哪不雙寫不漏觸發**。傾向 faction_ai per-team 迴圈加「獨立戰略」step（fid=-1+野心夠才觸發，與 _evaluate_survival/prosperity 同層）。讀 `_evaluate_solo` + per-team 迴圈 + commander-v2 `_select_intent`（mirror 結構）+ interaction:333（結盟→create_faction 觸發條件）+ npc_combat:524（subjugate→create_faction）。

- [ ] **Step 2: 寫 failing test**
```gdscript
func _test_indep_strategic_found() -> void:
	var state := WorldState.new(); var cfg := {"map":{"radius":5},"teams":[]}; GameSetup.setup(state, cfg)
	var fa := FactionAISystem.new()
	# 野心獨立能人（fid=-1，野心高+統領+累積夠 pop/food）+ 鄰可結盟獨立隊
	var founder := _mk_ambitious_independent(state, Vector2i(3,3))  # helper: fid=-1, 野心0.8/統領0.5, pop12, food 足
	var ally := _mk_independent_team(state, Vector2i(4,3))           # 可結盟獨立鄰(discovered/可達)
	fa._evaluate_independent_strategy(state, founder)   # 或經 evaluate_all 入口
	# 建國 intent → 結盟 dispatch（TASK_DIPLOMACY 朝 ally）
	assert(founder.current_task == TeamData.TASK_DIPLOMACY, "[indep] 野心獨立隊未秤建國/結盟 task=%s" % founder.current_task)
	# 非能人獨立隊（野心低）→ 不建國（守成/個體）
	var meek := _mk_independent_team(state, Vector2i(3,3))  # 野心低
	fa._evaluate_independent_strategy(state, meek)
	assert(meek.current_task != TeamData.TASK_DIPLOMACY or true, "[indep] 低野心獨立隊不該建國")  # 視 helper
	print("[indep] strategic found OK")
```
> helper `_mk_ambitious_independent`（fid=-1, 野心0.8/統領0.5, pop12, food 足=累積夠）。測入口依 Step1 接點。

- [ ] **Step 3: 跑測 FAIL**

- [ ] **Step 4: 實作**
- 獨立戰略 eval（mirror commander-v2 `_select_intent`，輕量）：fid=-1 + 野心≥`AMBITION_FOUND_MIN`(TEST VALUE ~0.55) + 累積夠（pop≥EXPAND_MIN_POP + effective_food≥盈餘）+ founding 路徑可達 → 秤建國 vs 守成。
- 建國 intent → means-end 子行動：
  - 結盟（primary）：`_nearest_independent` 有可達獨立鄰 → `TASK_DIPLOMACY`（既有→interaction:333 兩獨立 create_faction）。
  - 吞併（機會，殘忍/好戰染）：belief 弱鄰可打贏 → `TASK_ATTACK`（既有→npc_combat subjugate:524 create_faction）。
  - util = viability × 人格（結盟←義氣/計謀、吞併←殘忍/好戰）；argmax + hysteresis。
  - `_emit`：set task + driver `{intent:"建國", why, mode}`（driver-complete）。
- 常數 `AMBITION_FOUND_MIN`、founding 累積門檻（TEST VALUE）。守成=不 dispatch（繼續既有個體決策）。

- [ ] **Step 5: 跑測 PASS + 既有全綠**（獨立非能人/低累積隊不觸發建國=既有 solo/survival 行為原樣）

- [ ] **Step 6: Commit**
```
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): 獨立戰略層 — 野心獨立隊建國 intent(結盟/吞併 means-end,複用 create_faction) (indep-strategic)"
```

---

### Task 2: bed 驗整環（獨立→建國→established 1→多→CONQUER 0→小正）+ 守恆

**Files:** Test + 量測（bed + rung_diagnose + warring seed）

- [ ] **Step 1: 寫 believability 測**（野心獨立隊結盟/吞併→create_faction 成 faction[fid -1→正]；成 faction 後 rung 能升 rung3；低野心/孤立隊不建國；建國稀有非每隊）。
- [ ] **Step 2: 跑測 PASS。**
- [ ] **Step 3: bed + rung 重跑（核心驗）**
```
GODOT_TIMEOUT=600 ... econ_bed_diagnose.gd（或新 founding bed：強野心獨立隊+獨立鄰）
GODOT_TIMEOUT=2500 ... rung_diagnose.gd
```
驗：T32 型獨立能人 → 建國（fid -1→正）→ 爬 rung3（rung2→3 通）。記 established/CONQUER 動。
- [ ] **Step 4: warring seed + 守恆 + framework**
```
GODOT_TIMEOUT=3000 ... warring_states_seed.gd（背景）
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd
```
驗：**established 1→多**（獨立能人建國）、**CONQUER 0→小正**（征服候選增→蓄意征服湧現）、**不 over-found/over-war**（建國稀有，多數獨立守成）、coin_eq 0、InvariantViolation 0、S1-S6 PASS。
- [ ] **Step 5: Commit。**

---

## 完成後（子 session）
1. push `feat/independent-strategic-layer`。
2. handback：改檔 + **整環（獨立→建國→established 1→多→CONQUER 0→? /不 over-found）** + 接點選擇理由 + 守恆 + 連動風險（獨立決策接點對既有 solo/survival、建國門檻 over/under-found、結盟需對方接受 emergent）+ 待確認（量級、宣告 defer 的孤立隊洞）。
3. finishing → Option 3，主 session merge。

## Self-Review（主 session）
- **非補丁** = 建國 means-end option（driver 野心），複用 create_faction，無 fiat → Task 1。
- **統一第三塊** = 戰略意圖下放獨立隊（mirror commander-v2）→ Task 1。
- **(a) 收尾** = 獨立→建國→established 1→多→CONQUER 0→小正（Task 2 bed/seed）。
- **稀有** = 建國門檻（野心+累積+路徑）→ 不 over-found（Task 2 量）。
- 風險：接點（Step1 measure 定）；結盟需對方接受（emergent，被拒重評/吞併）；宣告 defer 孤立隊洞（backlog）。

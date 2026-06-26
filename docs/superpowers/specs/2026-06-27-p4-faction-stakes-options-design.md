# P4 頂層 stakes options — 徵收/外交 納統一引擎（unified 隊全響應派系 stakes）

> 系統 HOW spec。承 P3 混合協調 seam（faction_duty term + 攻擊 option done）+ 藍圖 ruling 2026-06-27（**P3 定 A 強協同 DRIVE=1.5、P4 他域優先**）。
> P4 = 他域鏈第五步。**攻擊已 P3 先行**；本塊補 **徵收 + 外交**（member-level stakes），達 unified 隊全響應派系 stakes。

## 探碼證的範圍

`_assign_tasks`/`_assign_member_tasks` 既有 non-unified 響應全 stakes（leader 739-771 + member 813-827）：
- **徵收** → `TASK_TRIBUTE` → `_richest_member`（faction 內最富，內部財富集中）。
- **外交** → `TASK_DIPLOMACY` → `_nearest_independent`。
- **攻擊** → `TASK_ATTACK` → `_nearest_independent`（**unified 已 P3 done**）。
- **立國** → `_declare_established`（**leader-level 事件，非 member task**）→ **不做 unified member option**（已在 leader dispatch 運作）。
- **掠奪** → faction-level 也有，但 ruling 定**日常個體**（已 P1 unified `掠奪` option，非 stakes 協同）。

**unified 隊（`_decide_unified`）只響應攻擊（P3）**，徵收/外交 仍 bypass = 本塊補的縫。

## 範圍（緊，mirror 攻擊 結構）

**做**：把 P3 的 faction-directive seam 從單 `攻擊` 泛化為**多 stakes**，加 `徵收` + `外交` 兩個 unified engine option（faction_duty 協同 + 人格染色 + 脫軌逃閥，全複用 P3 機制）：
1. `DecisionContext`：`faction_directive: String`（P3，單 "攻擊"）→ 泛化 `faction_stakes: Array`（stakes 子集 ∩ f.goals）+ 各 stakes target。
2. `terms.gd`：`faction_duty` eval 泛化（任一 stakes opt 匹配→drive）+ `levy_drive`/`diplo_drive` 人格染色 term + `levy`/`diplo` weight。
3. `options.gd`：`徵收`/`外交` option（REGISTRY + applicable + to_task）。
4. `invariants.md`：混合協調段更新（stakes 集合非單攻擊）。

**非目標**（明文）：
- **立國 不做 member option**（leader-level，既有運作）。**結盟 ⊂ 外交**（diplomacy→alliance，不另做）。**大徵收 = 徵收**（強度，非新 option）。
- **不碰 non-unified 802-827**（舊路徑原樣；unified 並行）。
- **不改 `_update_goals` 霸主決策**（複用既有 徵收/外交 gate）。
- **不改 `攻擊` option**（P3 原樣，只泛化共用的 faction_duty eval/context）。
- 不新 TASK_*（`TASK_TRIBUTE`/`TASK_DIPLOMACY` 既有）。
- **A 強協同擴充 3 軸**（勉強上戰場/豐富不打理由/協同隨制度化）= 藍圖願景債，**不做**。

## 設計（mirror P3 攻擊）

### 1. DecisionContext：faction_directive → faction_stakes 泛化
```gdscript
# P3 的 faction_directive(String) → 泛化多 stakes（攻擊 P3 + 徵收/外交 P4）
var faction_stakes: Array = []                      # STAKES_SET ∩ f.goals
var faction_attack_target: int = -1                 # 攻擊（P3，保留）
var faction_attack_target_pos: Vector2i = ...
var faction_tribute_target: int = -1                # 徵收 → _richest_member
var faction_tribute_target_pos: Vector2i = ...
var faction_diplo_target: int = -1                  # 外交 → _nearest_independent
var faction_diplo_target_pos: Vector2i = ...
```
gather（`f.goals` ∩ STAKES_SET，各算 target）：
```gdscript
const STAKES_SET := ["攻擊", "徵收", "外交"]   # 立國=leader-level 不納；掠奪=日常個體不納
...
if team.faction_id != -1:
    var f = state.factions.get(team.faction_id)
    if f != null:
        for g in DecisionContext.STAKES_SET:
            if g in f.goals: c.faction_stakes.append(g)
if "攻擊" in c.faction_stakes: <_nearest_independent → faction_attack_target>
if "徵收" in c.faction_stakes: <_richest_member(f) → faction_tribute_target>   # 註：需 f handle
if "外交" in c.faction_stakes: <_nearest_independent → faction_diplo_target>
```
> 註：`_richest_member(state, f)` 需 faction object。gather 已取 f。徵收 target=faction 內最富 member（複用既有）。
> **P3 相容**：`faction_directive` 欄移除，P3 `攻擊` 的 eval/applicable 改讀 `"攻擊" in faction_stakes` + `faction_attack_target`（語意等價，行為不變）。P3 測需同步（faction_directic→faction_stakes）。

### 2. terms.gd：faction_duty 泛化 + 徵收/外交 人格染色
`faction_duty` eval（泛化：任一 stakes opt 匹配 + target 有效）：
```gdscript
		"faction_duty":
			match opt:
				"攻擊": if "攻擊" in ctx.faction_stakes and ctx.faction_attack_target != -1: return FACTION_DUTY_DRIVE
				"徵收": if "徵收" in ctx.faction_stakes and ctx.faction_tribute_target != -1: return FACTION_DUTY_DRIVE
				"外交": if "外交" in ctx.faction_stakes and ctx.faction_diplo_target != -1: return FACTION_DUTY_DRIVE
			return 0.0
```
`faction_duty` weight（脫軌逃閥 `_duty_factor`，P3 既有，**不變**——全 stakes 共用）。
人格染色 term（mirror `attack_drive`，受 `_duty_factor` 調=叛離者不參與）：
```gdscript
		"levy_drive":   # 徵收染色：貪婪/好戰 member 徵得更狠
			if opt != "徵收" or "徵收" not in ctx.faction_stakes: return 0.0
			return STAKES_DRIVE_BASE * _duty_factor(loy, amb)
		"diplo_drive":  # 外交染色：義氣/計謀 member 更願斡旋
			if opt != "外交" or "外交" not in ctx.faction_stakes: return 0.0
			return STAKES_DRIVE_BASE * _duty_factor(loy, amb)
```
（`STAKES_DRIVE_BASE` = 沿用 `ATTACK_DRIVE_BASE` 0.3 或新常數；plan 定。）
weight：
```gdscript
		"levy":  return 0.2 + 貪婪×0.5 + 好戰×0.3   # 徵收=強取，貪婪/好戰染色
		"diplo": return 0.2 + 義氣×0.5 + 計謀×0.3   # 外交=斡旋，義氣/計謀染色
```

### 3. options.gd：徵收 + 外交 option
REGISTRY：
```gdscript
	"徵收": [["faction_duty", "faction_duty"], ["levy_drive", "levy"]],
	"外交": [["faction_duty", "faction_duty"], ["diplo_drive", "diplo"]],
```
applicable：
```gdscript
			"徵收":
				if "徵收" in ctx.faction_stakes and ctx.faction_tribute_target != -1: out.append(opt)
			"外交":
				if "外交" in ctx.faction_stakes and ctx.faction_diplo_target != -1: out.append(opt)
```
to_task：
```gdscript
		"徵收": # 內部徵收：對 faction 最富 member（_richest_member 需 f；to_task 無 f → 用 ctx target pos? 見註）
			... TASK_TRIBUTE, target=faction_tribute_target_pos
		"外交":
			... TASK_DIPLOMACY, target=faction_diplo_target_pos
```
> **註**：to_task 簽名 `(state,team,opt)` 無 ctx/f。徵收 target = `_richest_member` 需 faction handle → to_task 內 `state.factions.get(team.faction_id)` 取 f 再 `_richest_member`（或改用 gather 算好的 pos，但 to_task 無 ctx）。**plan 定**：to_task 內取 faction + 複用 finder（與既有 to_task 直呼 finder 一致）。徵收不設 combat_target（內部，非戰）；外交亦不設。

### 4. believability（守 ruling §1/§2 + A 強協同）
- **stakes 全響應**：派系徵收/外交令 → unified 隊（含經濟隊）協同（非只軍隊）。混合協調完整。
- **頂層決 WHETHER/人格染 HOW**：派系設 directive；徵收由貪婪/好戰染色（強取程度）、外交由義氣/計謀染色（斡旋意願）。
- **脫軌逃閥**：全 stakes 共用 `_duty_factor`（低忠+高野→不參與）= A 強協同但保逃閥（藍圖裁 A）。
- **危時 survival 碾壓**：survival-class 危時 > faction_duty（餓隊不為派系徵收/外交）。
- **日常個體不變**：貿易/掠奪/scout/survival 無 faction_duty。

## 驗收
- **unified 隊響應徵收/外交**：headless——派系 directive=徵收（有最富 member）→ 忠誠 unified member 選 `徵收`(TASK_TRIBUTE)；directive=外交（有獨立鄰）→ 選 `外交`(TASK_DIPLOMACY)。
- **人格染色**：貪婪 member 徵收 util > 溫和；義氣 member 外交 util > 寡情。
- **脫軌逃閥**：低忠+高野 member 派系徵收/外交時不參與（faction_duty weight 壓低）。
- **多 stakes 共存**：f.goals=[徵收,外交,攻擊] → 各 option 按 util argmax（攻擊 P3 行為不變）。
- **危時不參與**：糧危 unified member → survival 贏（非徵收/外交）。
- **P3 攻擊 不回歸**：faction_directive→faction_stakes 泛化後攻擊 option 行為原樣（P3 測綠 + war_scenario 重跑跟戰 3/4）。
- **non-unified 不變**：802-827 舊路徑全綠。
- **TC1/4/6/7 + daily 個體不變**（無 directive 時 stakes option 不 applicable）。
- **守恆**：徵收/外交 走既有 interaction 守恆；coin_eq 0、InvariantAudit 0。
- **world_sim**：2yr 不崩、stakes 協同 emergent、framework S1-S6 PASS。
- **war_scenario 擴充**：`p3_war_scenario.gd` 可加徵收/外交 directive 變體驗（plan 定，或新 scenario）。

## 檔案
- `scripts/simulation/decision/decision_context.gd`：faction_directive→faction_stakes 泛化 + 徵收/外交 target（`_richest_member`/`_nearest_independent`）。
- `scripts/simulation/decision/terms.gd`：faction_duty eval 泛化 + `levy_drive`/`diplo_drive` + `levy`/`diplo` weight + STAKES_DRIVE_BASE。
- `scripts/simulation/decision/options.gd`：REGISTRY `徵收`/`外交` + applicable + to_task。
- `docs/invariants.md`：混合協調段（stakes 集合=攻擊/徵收/外交，立國=leader-level）。**系統 owner，本塊改。**
- `scripts/debug/headless_test.gd`：新測（徵收/外交 響應 + 人格染色 + 脫軌 + 多 stakes + 危時不參與 + P3 攻擊不回歸）。
- 可能 `scripts/debug/p3_war_scenario.gd`：加 stakes 變體（或獨立 scenario）。

## 風險 + 緩解
- **P3 攻擊 回歸**（faction_directive→faction_stakes 重構碰共用 eval/ctx）：泛化語意等價（`"攻擊" in faction_stakes` == 舊 `faction_directive=="攻擊"`）。驗：P3 測 + war_scenario 跟戰 3/4 重跑不變。
- **to_task 取 faction handle**（徵收需 _richest_member(f)）：to_task 內 `state.factions.get(team.faction_id)` 取 f（與既有 to_task 直呼 finder 一致）；無 faction → IDLE 退次佳。
- **徵收 target=自己**（unified member 自身是最富 → 對自己徵收荒謬）：`_richest_member` 排除自身？確認（非則 to_task 守衛 target!=self → IDLE）。plan 驗。
- **over-coordination**（經濟隊全被拉去徵收/外交不生產）：directive 本稀有（霸主 gate）+ 危時 survival 碾壓 + 日常無 faction_duty。world_sim 量（多數時經濟隊照生產/貿易）。
- **scope sprawl**：明文只徵收/外交、立國/結盟/大徵收不做、不碰 non-unified/霸主決策/攻擊 option、A 擴充軸不做。只 decision/ 三檔 + invariants + 測。

## 開放細節（plan 定）
- `STAKES_DRIVE_BASE`（沿用 ATTACK_DRIVE_BASE 0.3 vs 新）。
- to_task 徵收取 f + `_richest_member` 排除自身。
- 多 stakes 同時 applicable 時排序（faction_duty 量級相同 → 人格染色 + commitment tiebreak 決；確認不抖）。
- war_scenario 擴充 vs 新 stakes scenario。
- `levy`/`diplo` weight 人格係數（貪婪/義氣/計謀）量級。

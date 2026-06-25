# P3 混合協調 seam — `faction_duty` term + 啟用 `攻擊` stakes option（unified 隊響應派系 directive）

> 系統 HOW spec。承他域 ruling `2026-06-22-otherdomain-ruling` §1（混合協調）/§2（believability 守則）/§3（主動開戰 feel）。
> P2 done（P2a + P2b-1）。P3 = 統一框架他域鏈第四步。

## 探碼證的 gap（非 dormant 設計）

- `_update_goals`（faction_ai:632-712）**已**從霸主 leader values + readiness/strength/belief gate 設 `f.goals`（攻擊/徵收/外交/立國/掠奪）= **霸主頂層決策步已存在**（攻擊 687-705：`attack_score=野心0.4+好戰0.4-義氣0.4 > 0.3` + `readiness≥0.75` + belief-based 敵強度 + `own_armed≥敵×0.8` = **已稀有/蓄意/吃 belief**，守 ruling §3）。
- **non-unified 隊已響應** `f.goals`（802-827：攻擊→consolidate/TASK_ATTACK、徵收→TRIBUTE、外交→DIPLOMACY，`PRIO_FACTION`）。
- **unified 隊（TAG_MERCHANT|TAG_PRODUCE）完全忽略 `f.goals`**（`_decide_unified` 零讀，`DecisionContext` 無 faction 欄）= **本塊要補的縫**。
- `攻擊` option 已**半 scaffold**：`terms.gd` 有 `feud_pull`(opt=="攻擊") + `attack` weight（好戰/殘忍），但 `攻擊` **不在 REGISTRY** = 待啟用的非-dormant 接點。

## 範圍（緊，防 sprawl；首個 stakes option only）

**做**：建混合協調 seam，讓 unified 隊經引擎響應派系 stakes directive，**以 `攻擊` 為首個 live stakes option**（非 dormant——`_update_goals` 已產攻擊 directive）：
1. `DecisionContext` 加 faction 欄（directive + attack target + leader loyalty）。
2. `terms.gd` `faction_duty` term（directive 匹配→drive）+ `faction_duty` weight（loyalty-based，脫軌逃閥）。
3. `options.gd` 啟用 `攻擊` option（REGISTRY + applicable + to_task）。
4. `invariants.md` 寫混合協調兩 believability 不變量。

**非目標**（明文）：
- **只 `攻擊` 一個 stakes option**。徵收/外交/立國/結盟/大徵收 = 後續 slice（faction_duty 屆時擴；本塊不做，避 sprawl）。
- **不碰 non-unified 802-827**（舊 faction-goal→member 路徑原樣；unified 並行響應，非重構）。
- **不改 `_update_goals` 霸主決策步**（複用，攻擊 gate 已對 ruling §3）。
- **不新脫軌/叛變機制**（逃閥=term 權重 by construction，見不變量 #2）。
- 不新 TASK_*（`TASK_ATTACK` 既有）。不碰 daily-op options（貿易/掠奪/survival 無 faction_duty=ruling 日常個體）。
- 不做 per-member confident_enough gate（霸主 _update_goals 已 belief-gate，member parity 非 unified 822-827 亦無）。

## 設計

### 1. `DecisionContext`（faction 欄 + gather）
```gdscript
var faction_directive: String = ""        # 派系當前 stakes directive（本塊只認 "攻擊"；後續擴）
var faction_attack_target: int = -1
var faction_attack_target_pos: Vector2i = Vector2i(-1, -1)
var leader_loyalty: float = 0.5           # 脫軌逃閥權重輸入
```
gather：
- `faction_directive`：team 有 faction（`team.faction_id != -1`）→ 讀該 faction `f.goals`，取 **stakes 子集**交集（本塊 `["攻擊"]`；`掠奪` 等日常**不**納=ruling 日常個體）。無 faction / 無 stakes goal → `""`。
- `faction_attack_target`：directive=="攻擊" → `FactionAISystem.new()._nearest_independent(state, team)`（鏡像 non-unified 824）；else -1。
- `leader_loyalty`：`ldr.loyalty`（PersonData 既有 getter）。

### 2. `terms.gd`：`faction_duty` term + weight
```gdscript
const FACTION_DUTY_DRIVE: float = 1.5   # TEST VALUE — stakes 協同量級（高，壓日常 term；但 weight 受 loyalty 調=非無限）
const DEFECT_AMBITION_K: float = 1.0    # TEST VALUE — 野心折損 faction_duty 權重（脫軌逃閥斜率）
```
eval：
```gdscript
		"faction_duty":
			# 只對匹配派系 directive 的 stakes option 給 drive（本塊 攻擊）。
			if opt == "攻擊" and ctx.faction_directive == "攻擊" and ctx.faction_attack_target != -1:
				return FACTION_DUTY_DRIVE
			return 0.0
```
weight（**脫軌逃閥**=invariant #2）：
```gdscript
		"faction_duty":
			# 高忠誠→跟派系；低忠誠+高野心→權重壓低（個人驅力可蓋過 faction_duty=破framework脫軌）。
			var loy: float = float(leader_values_or_ctx 提供 loyalty)   # 見註
			var amb: float = float(v.get("野心", 0.5))
			return clampf(loy - maxf(0.0, amb - 0.5) * DEFECT_AMBITION_K, 0.0, 1.0)
```
> **註**：`weight(term, leader_values)` 現簽名只收 values dict，loyalty 非 values 成員。**plan 定**：① weight 簽名擴帶 ctx/loyalty，或 ② loyalty 注入 leader_values dict（gather 時 `c.leader_values["_loyalty"]=ldr.loyalty`，weight 讀 `v.get("_loyalty")`）。傾向 ②（最小改 weight 簽名、不動既有 term）。

### 3. `options.gd`：啟用 `攻擊` option
REGISTRY：
```gdscript
	"攻擊": [["faction_duty", "faction_duty"], ["attack_drive", "attack"]],
```
- `faction_duty × faction_duty`：派系協同拉力（loyalty 加權）。
- `attack_drive × attack`：個人好戰**染色 HOW**（invariant #1）——好戰 leader 更積極參戰、慎重 leader 勉強。`attack_drive` 新 term（小 base，directive=攻擊 時 >0）：
```gdscript
		"attack_drive":
			if opt != "攻擊" or ctx.faction_directive != "攻擊": return 0.0
			return 0.3   # TEST VALUE — 個人參戰基值；× attack weight(好戰/殘忍) → 好戰染色
```
  （`attack` weight 既有：`0.2 + 好戰 + 殘忍×0.3`。）
applicable：
```gdscript
			"攻擊":
				if ctx.faction_directive == "攻擊" and ctx.faction_attack_target != -1:
					out.append(opt)
```
to_task：
```gdscript
		"攻擊":
			var tid: int = ctx_or_finder._nearest_independent(...)   # 見註
			if tid == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_ATTACK, "target": state.teams[tid].tile_pos, "combat_target": tid}
```
> **註**：to_task 無 ctx，直呼 `FactionAISystem.new()._nearest_independent(state, team)`（與 applicable/gather 一致；finder 撲空→IDLE，`_decide_unified` 退次佳）。combat_target 接線複用既有 `_decide_unified:860`（td.has("combat_target")）。

### 4. believability（混合協調，守 ruling §1/§2）
- **頂層決 WHETHER**：派系 directive 由霸主 `_update_goals` 設（攻擊 gate=野心/好戰/readiness/belief-strength）→ **稀有蓄意**。
- **人格染 HOW**：member 經 `攻擊` option 的 `attack_drive×attack`（好戰/殘忍）染色——好戰 member 積極、慎重 member 勉強參戰；協同≠同質。
- **脫軌逃閥**：`faction_duty` weight 受 loyalty 調（低忠誠+高野心→壓低）→ 個人驅力（survival/野心/貿易）可蓋過 faction_duty → 不參戰 / 自走 = **破framework脫軌**（分裂/叛變戲劇前置）。faction_duty 是 term 非 hard override（by construction，非 100% 服從）。
- **危時不參戰**：survival-class term 危時量級碾壓（food<3→survival_pressure≥4 > FACTION_DUTY_DRIVE 1.5×weight≤1）→ 餓隊先求生非為派系打仗。
- **日常個體不變**：貿易/掠奪/scout/survival 無 faction_duty term → 各隊個體決（ruling 日常個體）。

## 驗收

- **unified 隊響應派系攻擊**：headless 新測——派系 directive=攻擊 + 有 target + 忠誠 member（merchant/produce）→ engine 選 `攻擊`（TASK_ATTACK + combat_target）。
- **人格染 HOW**：同 directive 下，好戰 member faction_duty+attack util 高（積極）、慎重溫和 member util 較低（勉強/可能被其他 option 蓋）。
- **脫軌逃閥**：低忠誠（loyalty<~0.3）+ 高野心 member，派系攻擊時 faction_duty weight 壓低 → 個人驅力（貿易/野心）可勝 → **不選攻擊**（不參戰=脫軌）。
- **危時不為派系打仗**：糧危 unified member（food<3）+ 派系攻擊 → survival-class 贏（覓食/返家），非攻擊。
- **daily 個體不變**：無派系 directive 時 unified 隊照貿易/生產/survival（TC1/4/6/7 原樣）。
- **non-unified 不變**：802-827 舊 faction-goal 路徑全綠。
- **守恆**：攻擊走既有 combat 守恆；coin_eq 0、InvariantAudit 0。
- **world_sim**：2yr 不崩、`攻擊` directive 時 unified member 參戰 emergent（協同 war 可見）、**多數派系多數時不主動攻擊**（守 ruling §3 feel，無 over-war）、framework S1-S6 PASS。**TC3（feud→脫軌攻擊）**：unified 隊現有 `攻擊` option → vendetta/feud 可接（**註**：vendetta 既走 `_evaluate_threat` 後 PRIO_VENDETTA 脫軌；本塊 `攻擊` option 是 faction-directive 驅動，TC3 完整接線可能需後續確認，spec 標為「解鎖前置」非「本塊閉 TC3」）。

## 檔案

- `scripts/simulation/decision/decision_context.gd`：faction 欄 + gather（讀 f.goals stakes 子集、`_nearest_independent`、loyalty）。
- `scripts/simulation/decision/terms.gd`：`faction_duty`/`attack_drive` eval + `faction_duty` weight（loyalty/野心 脫軌逃閥）+ 常數。
- `scripts/simulation/decision/options.gd`：REGISTRY `攻擊`、applicable、to_task（`_nearest_independent`）。
- `scripts/simulation/faction_ai_system.gd`：可能無改（複用 `_nearest_independent`/`_decide_unified` combat_target 接線）；確認 `_nearest_independent` 可從 decision 呼叫。
- `docs/invariants.md`：混合協調段（頂層決 WHETHER/人格染 HOW + 脫軌逃閥 + 日常個體）。**系統 owner，本塊寫。**
- `scripts/debug/headless_test.gd`：新測（響應攻擊 + 人格染 + 脫軌逃閥 + 危時不參戰 + non-unified 不變）。

## 風險 + 緩解

- **dormant code**：`攻擊` option 有 live producer（`_update_goals` 已產攻擊 directive）+ non-unified 已示範消費 → 非 dormant。world_sim 驗 unified member 真參戰。
- **over-war（unified 商隊都去打仗→經濟崩）**：①directive 本稀有（霸主 gate）②faction_duty weight 受 loyalty 調 ③危時 survival 碾壓 ④日常無 faction_duty。world_sim 量 over-war（多數派系不攻擊為準），過頻調 `FACTION_DUTY_DRIVE`（TEST VALUE）。
- **脫軌逃閥失準**（太易脫軌→派系散 / 太難→洗平人格）：`DEFECT_AMBITION_K` TEST VALUE，headless 驗低忠誠高野心脫軌、高忠誠跟隨。world_sim 量派系協同 vs 散。
- **loyalty 注入 weight 簽名**：plan 定（注入 leader_values dict vs 擴簽名）——傾向注入 dict 最小改。
- **TC3 接線存疑**：本塊 `攻擊` option=faction-directive 驅動；vendetta 脫軌（G2d）走別路（PRIO_VENDETTA）。TC3 是否本塊閉待確認→spec 標「解鎖前置」，量測後評估是否需 vendetta→攻擊 option 接線（避過早 scope）。
- **scope sprawl（P0 教訓）**：明文只 `攻擊`、不碰 non-unified/霸主決策、無新脫軌機制。只碰 decision/ 三檔 + invariants + 測。

## 開放細節（plan 定）

- loyalty 注入 weight 法（dict vs 簽名）。
- `faction_directive` stakes 子集定義（本塊 `["攻擊"]`；常數化便後續擴徵收/外交/立國）。
- `攻擊` option 排序 vs survival/日常（survival 危時須碾壓；攻擊 vs 貿易/生產靠 faction_duty+attack weight）。
- TC3 接線是否本塊（傾向否，量測後評）。
- `attack_drive` base 值（0.3）/`FACTION_DUTY_DRIVE`（1.5）/`DEFECT_AMBITION_K`（1.0）量級（headless 驗序 + world_sim over-war）。

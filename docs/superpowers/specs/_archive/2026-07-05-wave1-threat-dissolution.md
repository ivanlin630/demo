# Spec：wave1 序1 — threat 子系統溶入統一決策引擎

> 憲法溶入 arc wave1 首張。**溶=融合非刪**（藍圖 arc-order 硬驗收）：撕手算 argmax，選項→engine option、考量→term/weight；repertoire 沒少 + 該出現還出現。系統(HOW) owner spec；plan 後子 session 實作。

## 1. 目標與憲法框

**現況違憲**（constitution-audit 序1）：`faction_ai_system.gd:358/403` 的 `_evaluate_threat`/`_dispatch_threat_response` = 手算 `scores{FLEE/PREPARE/求和/DEFEND}` argmax → `try_set`。引擎已有 `survival`(FLEE)+`threat_pressure` term = 純重複的平行決策路徑。

**目標**：4 威脅反應成 `DecisionOptions.REGISTRY` option 由 term/weight 秤；刪手算 argmax；threat 反應與其他決策同框競爭（不再 PRIO_THREAT 硬覆蓋、改權重競爭）。

**憲法分辨線守則**：
- ✅ **保留（世界機制/scaffolding，非決策）**：threat 評估的 **trigger**（idle-gated + cadence）、**release/latch-timeout**（FLEE_TIMEOUT、威脅消失回 idle）、`ThreatAssessment.score`（感知/物理層）。這些是「何時評估、何時放手」的世界規則，非「該選哪個反應」。
- ❌ **撕除（替 NPC 決定的腳本）**：`_dispatch_threat_response` 的 `scores` dict + argmax + match-dispatch。

## 2. 現 repertoire（融合驗錨——必須全保）

`_dispatch_threat_response`（fai.gd:403-449）手算 4 反應：

| response | 現權重公式 | → task | target/extra | 守衛 |
|---|---|---|---|---|
| **FLEE** | 求生欲×0.8 + (threat−0.5)×0.3 | `TASK_FLEE` | `_flee_target`（背向逃 3 hex）| — |
| **PREPARE** | 慎重×0.6 + 好戰×0.3 | `TASK_PREPARE` | 無 target | — |
| **求和** | 貪婪×0.5 + 信義×0.3 − 好戰×0.3 | `TASK_DIPLOMACY` | order_target=threat, order_task=`TASK_TRIBUTE_OFFER` | — |
| **DEFEND** | 好戰×0.7 + (1−threat)×0.2 | `TASK_DEFEND` | target=threat.tile_pos, prosperity_target=threat | **僅非居民**（居民團不迎戰）|

**trigger**（fai.gd:358-391，保留）：`current_task==IDLE` only；cadence `THREAT_CADENCE`(1天)；門檻 `THREAT_BASE_THRESHOLD(0.3) + 慎重×0.3`；argmax `ThreatAssessment.score` over `team_discovered`。
**release**（保留）：已在 DEFEND/PREPARE/FLEE/HOLD 中 → 威脅消失 or FLEE 逾 `FLEE_TIMEOUT`(5天) → `release`。REVOLT → release。

**人格信號**：求生欲/好戰/慎重/貪婪/信義（全在 `leader.values`，engine `ctx.leader_values` 已 duplicate）。

## 3. 目標架構：鏡射既有 survival 分裂

引擎現有 survival 已是「unified 隊 inline 主 rank / non-unified 隊獨立 `rank_survival` slice」雙路（調查證 fai.gd:3023/_trigger_survival + eng.gd:38 rank_survival）。**threat 溶入完全鏡射此模式**，架構一致、不新建範式：

- **unified 隊**（TAG_MERCHANT/TAG_PRODUCE）：threat option 進**主 REGISTRY**，`_decide_unified`（loop1/2）自然競爭。吃飽遇威脅在主 rank 選迎戰/求和。
- **non-unified 隊**：loop3 `_evaluate_threat` 的 trigger/release **保留**，內部 `_dispatch_threat_response` 手算 **換成 `DecisionEngine.rank_threat(ctx)`**（新 slice，鏡射 rank_survival）over `THREAT_OPTION_SET`，取首個 dispatchable。

**為何 threat 不併進 survival slice**：survival gated on 飢餓（food<DESPERATION）；威脅反應必須「吃飽也要防」（well-fed 隊面對逼近敵軍仍需反應）。故 threat 是獨立 gated 決策維度，不能靠 survival_pressure 觸發。→ 獨立 `rank_threat` slice + threat-gated applicable。

## 4. 具體改動（8 點）

### 4a. REGISTRY 加 3 option（opt.gd:5）
FLEE 複用既有 `survival`（已 `[[threat_pressure, survival_pressure]]`→TASK_FLEE）。補：
```gdscript
"備戰":   [["prepare_drive", "prepare"]],
"迎戰":   [["defend_drive", "defend"]],
"求和":   [["pacify_drive", "pacify"]],
```

### 4b. eval term 加 3（terms.gd，全 threat-gated + threat-scaled）
每 term opt-gated（錯 opt 回 0）+ 讀 `ctx.threat_react`（見 4f 訊號）：
```gdscript
# prepare_drive（opt=備戰）：threat 在就想備戰，慎重/好戰在 weight 端
"prepare_drive": return ctx.threat_react   # 0..1，門檻下 applicable 已擋
# defend_drive（opt=迎戰）：威脅越低越敢迎（現公式 (1−threat)×0.2 的精神）
"defend_drive": return maxf(1.0 - ctx.threat_react * 0.5, 0.3)
# pacify_drive（opt=求和）：threat 在就有求和動機，貪婪/信義/−好戰在 weight
"pacify_drive": return ctx.threat_react
```
（eval 只 bake「有多強動機」，who-cares 全在 weight。FLEE 的 threat_pressure eval 已存在=`ctx.threat`，見 4f 需對齊 threat_react。）

### 4c. weight key 加 3（terms.gd weight()，人格 crosswalk）
對照現手算公式的人格項：
```gdscript
"prepare": return 0.3 + 慎重 * 0.6 + 好戰 * 0.3      # 現 PREPARE=慎重0.6+好戰0.3
"defend":  return 0.2 + 好戰 * 0.7                    # 現 DEFEND=好戰0.7（(1−threat)項移 eval）
"pacify":  return 0.2 + 貪婪 * 0.5 + 信義 * 0.3 + maxf(0.3 - 好戰*0.3, 0.0)  # 現 求和=貪婪0.5+信義0.3−好戰0.3（clamp≥0，weight 不可負）
```
**FLEE**：現手算 求生欲×0.8，但 engine `survival` opt weight=`survival_pressure`=1.0 const。差異：融合後 FLEE 由 survival_pressure(1.0)×threat_pressure(ctx.threat) 秤。**融合驗接受**（repertoire 保：懦弱 leader 仍 flee，見 §5 驗；不要求 bit-identical，藍圖驗 repertoire-level）。若驗發現高求生欲隊 flee 傾向掉 → 加 `flee` weight key `0.4 + 求生欲×0.8` 給 survival opt 的 threat 語境（後備，先不加）。

### 4d. applicable gating（opt.gd:31，threat-gated）
```gdscript
"備戰": if ctx.threat_react >= ctx.threat_threshold: out.append(opt)
"迎戰": if ctx.threat_react >= ctx.threat_threshold and not ctx.is_resident: out.append(opt)  # 居民不迎戰
"求和": if ctx.threat_react >= ctx.threat_threshold: out.append(opt)
```
FLEE(`survival`) 維持恆候選（靠 threat 權重，現況不動）。

### 4e. to_task 加 3（opt.gd:108）
```gdscript
"備戰": return {"task": TeamData.TASK_PREPARE, "target": Vector2i(-1,-1)}
"迎戰": return {"task": TeamData.TASK_DEFEND, "target": ctx.threat_pos,
                "prosperity_target": ctx.threat_id}
"求和": return {"task": TeamData.TASK_DIPLOMACY, "target": ctx.threat_pos,
                "order_target": ctx.threat_id, "order_task": TeamData.TASK_TRIBUTE_OFFER}
```
（`_decide_unified`/rank_threat dispatch 端讀 to_task 回傳的 prosperity_target/order_target/order_task 欄位 wire 上 team——鏡射現有 combat_target/social_target wire 機制。）

### 4f. DecisionContext 加 threat 欄位（ctx.gd）+ ★訊號 reconcile
現 `ctx.threat`=`_max_threat`（clamp 1、**排 rep≥NEUTRAL 的中立/盟友**、over discovered）。手算 `_evaluate_threat` 用 **raw uncapped score over ALL discovered**（含中立-rep 但 approach/power 高者）。**訊號不對齊 → 中立但逼近的敵軍在 engine 下 hostility=0 不觸發 = repertoire 掉「該出現沒出現」**。

**裁定（保舊行為，標記呈報藍圖）**：新增 `ctx.threat_react` = 鏡射 `_evaluate_threat` 現掃描（raw `ThreatAssessment.score` over discovered 取 max，含 approach/power 非純 hostility），+ `ctx.threat_id`/`ctx.threat_pos`（best_threat 的 team）+ `ctx.threat_threshold`（`THREAT_BASE + 慎重×0.3`）+ `ctx.is_resident`。
- `survival` opt 的 FLEE 是否改讀 threat_react（對齊）或維持 `_max_threat`？→ **spec 選：threat_pressure term 讀 threat_react**（統一單一 threat 訊號源，消 §7 調查揭的雙訊號）。副作用：survival-FLEE 對中立逼近者也可能觸發（=舊 threat 行為，合理）。
- **呈報藍圖**（WHAT 鄰接）：「中立-rep 但逼近的未知軍算威脅嗎」= believability 判準。spec 預設「算」（保舊 repertoire）；若藍圖要「只有敵意才算威脅」→ 改讀 _max_threat，另記。

### 4g. DecisionEngine.rank_threat（eng.gd，鏡射 rank_survival:38）
```gdscript
# threat 反應 slice（non-unified 隊 loop3 用）。鏡射 rank_survival：
# filter applicable ∩ THREAT_OPTION_SET，commitment vs current_task，不寫 current_option。
const THREAT_OPTION_SET := ["survival", "備戰", "迎戰", "求和"]   # survival=FLEE
static func rank_threat(ctx) -> Array: ...  # 同 rank_survival 結構
```

### 4h. _evaluate_threat 改寫（fai.gd:403）+ 刪 _dispatch_threat_response
`_evaluate_threat` trigger/release **全保**（§2）。原 391 行 `_dispatch_threat_response(state, team, best_id, best_threat)` 呼叫 → 換：
```gdscript
	# 手算 argmax 撕除 → 引擎 rank_threat 秤（融合非刪）
	var ctx := DecisionContext.gather(state, team)   # 已含 threat_react/id/pos
	var ranked: Array = DecisionEngine.rank_threat(ctx)
	for opt in ranked:
		var td: Dictionary = DecisionOptions.to_task(state, team, opt)
		if td.task == TeamData.TASK_IDLE: continue
		if not TaskArbiter.try_set(state, team, td.task, td.target, TaskArbiter.PRIO_THREAT, "threat"): continue
		# wire prosperity_target/order_target/order_task（同 _decide_unified）
		_wire_threat_task(team, td)
		break
```
**刪** `_dispatch_threat_response`（fai.gd:403-449 整函數）。unified 隊：threat option 在主 REGISTRY，`_decide_unified` 自動吃（loop1/2，早於 loop3 threat）→ loop3 `_evaluate_threat` 對 unified 隊需 early-return（鏡射 `_trigger_survival` 的 unified 排除）。

## 5. 融合驗（★藍圖硬驗收，spec 核心交付）

新增 `scripts/debug/threat_dissolution_check.gd`（`extends SceneTree`，鏡射 framework_validation 風格）：

### 5a. repertoire 沒少（4 反應各自可達）
4 人格原型隊，同一逼近威脅，斷言各選對應反應（**engine rank 首選 == 預期**）：
| 原型 leader values | 預期首選 |
|---|---|
| 求生欲 0.9、好戰 0.1、慎重 0.5 | FLEE(survival) |
| 好戰 0.9、慎重 0.2、求生欲 0.3、非居民 | DEFEND(迎戰) |
| 慎重 0.9、好戰 0.4、求生欲 0.4 | PREPARE(備戰) |
| 貪婪 0.8、信義 0.7、好戰 0.1 | 求和(pacify) |
每原型跑 `rank_threat`，assert `ranked[0]==預期`。任一 miss=repertoire 掉，FAIL。
（+居民好戰隊 assert 迎戰**不**在 applicable = 居民守衛保留。）

### 5b. 該出現還出現（率表，threat→反應不被默默吃）
seeded warring bed（或 framework S-style 場景）：注入明確威脅（逼近高 power 敵），跑 N tick，斷言 `ThreatResponse` 類 task（FLEE/DEFEND/PREPARE/DIPLOMACY-tribute）**發生率 > 0**（現手算系統的基準率，先量測記錄 baseline，融合後不得歸零）。監看：威脅存在時防守 dispatch 沒被新權衡（掠奪/貿易等）默默壓過。

### 5c. 回歸
seeded 46/8/1/380 守恆（threat 融合改行為分佈——**此張允許 seeded 漂移**，若漂移須 QA 判「新分佈合理非退化」，非機械守恆。**先量測融合前後 seeded 差**，記錄進 plan）+ framework PASS=7 + 憲法閘（`_dispatch_threat_response` 指紋消失=arc 進度，baseline 更新）。

## 6. 憲法閘 baseline 更新
`_dispatch_threat_response` 刪除 → 其 `faction_ai_system.gd::_dispatch_threat_response` 指紋消失（gate 印 `removed`=arc 進度 ✅）。新 try_set 在 `_evaluate_threat`（已在 baseline？——它現只有 release，無 try_set 指紋）→ **新增 `faction_ai_system.gd::_evaluate_threat` 指紋**。此為 arc 授權的合法移動（撕手算、dispatch 移入保留的 trigger func）→ **系統更新 baseline**（remove _dispatch + add _evaluate_threat，標 `# 序1 threat 溶入後 dispatch 落點`）。pre-commit 閘會擋，實作需同 commit 更新 baseline。

## 7. 待藍圖（1 個 WHAT 鄰接，不擋實作）
- **§4f 訊號裁定**：中立-rep 但逼近的未知軍算威脅嗎？spec 預設「算」（保舊 repertoire，approach/power 驅動）。藍圖若要「僅敵意才威脅」→ 改讀 _max_threat。**不擋**：預設可實作、驗證、merge；藍圖回覆後如需改一行切訊號源。

## 8. 交付後序
spec → plan（bite-size task，融合驗 TDD-first）→ 子 session。序1 綠 + 融合驗雙關過 + QA 判 → 序2 solo（翻 options，語意同構更輕）。

# SoloAI 主動尋家 — Design

> 日期：2026-06-14
> 議題：abs境驅動生存（desperation-survival）解了「快餓死」的多元行為，但**不缺糧時**的窮+和平流浪團仍 idle 到餓才反應 — `_evaluate_solo`（SoloAI）已按 values 評分 攻擊/掠奪/外交/貿易/治理，**但無「主動尋家」目標**。→ bottom-up 進展缺一環：流浪團只在垂死時才被動找家，穩定時無安身驅動。
>
> 補：SoloAI 加 紮營/投靠 兩個 value 加權評分選項，讓**有安身傾向**的流浪團不缺糧時就主動找家（emergent），**愛 roving 的繼續流浪**（非 uniform）。

## 設計核心

- **擴充 `_evaluate_solo`，非新系統**：scores dict 加 `紮營` / `投靠`，與既有 攻擊/掠奪/外交/貿易/治理 競爭最高分。
- **value 加權，非強制**：`紮營` = f(求生欲/慎重/野心)；`投靠` = f(義氣/慕強/求生欲)。好戰/貪婪盜匪 → 掠奪/攻擊分高 → 繼續 roving 不找家；求生/慎重流民 → 紮營/投靠分高 → 主動安身。個性分流。
- **只對無家隊**：gated `_find_own_outpost == -1`（已有據點不再找家）。
- **全 reuse desperation helpers**：`_find_unowned_farmable_tile` / `establish_crude_camp`（到達結算）/ `_find_strong_neighbor`。零新機制，只接線。
- **與 survival 分離但同動作**：SoloAI 在 **stable/idle**（不缺糧）觸發；`_trigger_survival` 在 **缺糧 <3 天**觸發。同樣紮營/投靠動作，不同觸發時機（主動 vs 被動）。
- **承諾慣性（延續感）**：SoloAI 每次重評記住上次選的策略方向（`solo_intent`），重評時該方向**加 commitment 分** → 非明顯更優不換 → 止「這 tick 紮營下 tick 掠奪」的精神分裂。values 穩定 + 慣性 = 策略有延續。（更深的「目標錨」見待 spec，不在本 spec）

## 不變量

- **只無家流浪團評估尋家**：有 own outpost 的隊 SoloAI 不評紮營/投靠。
- **value 加權非 uniform**：尋家是評分選項，與 roving（攻擊/掠奪/貿易）競爭；愛流浪的個性永不被迫定居。
- **reuse 既有**：紮營走 `establish_crude_camp`（依個性軍/民 + 升 tag 清流亡，已守恆）；投靠走既有路徑。不新增建造/守恆路徑。
- **不與 survival 重複觸發**：SoloAI 僅 idle/stuck（既有 gate）評估；缺糧走 `_trigger_survival`（PRIO_SURVIVAL 較高，會蓋過）。

## 1. `_evaluate_solo` 擴充

既有 scores（idle/攻擊/掠奪/外交/逃跑/製造/貿易/治理）後，加：

```gdscript
# 主動尋家（僅無 own outpost 的流浪團）：value 加權，與 roving 競爭最高分
if _find_own_outpost(state, team) == Vector2i(-1, -1):
    var survival_v: float = float(leader_p.values.get("求生欲", 0.5))
    var caution: float    = float(leader_p.values.get("慎重", 0.5))
    var ambition2: float  = float(leader_p.values.get("野心", 0.5))
    var honor: float      = float(leader_p.values.get("義氣", 0.5))
    # 紮營：求生/慎重/野心（自立建家）
    if _find_unowned_farmable_tile(state, team) != Vector2i(-1, -1):
        scores[TeamData.TASK_CAMP] = (survival_v * 0.3 + caution * 0.3 + ambition2 * 0.3) \
            * _tag_weight(team, "紮營")   # TEST VALUE 權重
    # 投靠：義氣/慕強/求生（依附強者）
    if _find_strong_neighbor(state, team) != -1:
        scores["投靠"] = (honor * 0.4 + survival_v * 0.4) * _tag_weight(team, "投靠")   # TEST VALUE
```

best_task 勝出後 match 補：
```gdscript
		TeamData.TASK_CAMP:
			var cpos: Vector2i = _find_unowned_farmable_tile(state, team)
			if cpos == Vector2i(-1, -1): return
			solo_target = cpos
		"投靠":
			var aid: int = _find_strong_neighbor(state, team)
			if aid == -1: return
			solo_target = state.teams[aid].tile_pos
			team.combat_target = aid
```
→ `TaskArbiter.try_set(team, best_task, solo_target, PRIO_DISPATCH, "solo")`（沿用 SoloAI 既有派發優先級）。到達結算復用既有：TASK_CAMP → `establish_crude_camp`；投靠 → 既有投靠到達邏輯。

> 數值（pref 權重 / `_tag_weight` for 紮營/投靠）= TEST VALUE，量測 tune。

## 2. 承諾慣性（延續感）

`team_data.gd` 加 `var solo_intent: String = ""`（上次 SoloAI 選的策略方向）。

`_evaluate_solo` 算完 scores、選 best 前，對上次方向加慣性分：

```gdscript
const SOLO_COMMITMENT_BONUS: float = 0.15   # TEST VALUE — 慣性加成（非明顯更優不換）
# ...算完 scores 後：
if team.solo_intent != "" and scores.has(team.solo_intent):
    scores[team.solo_intent] += SOLO_COMMITMENT_BONUS
# ...選 best_task 後：
if best_task != "idle":
    team.solo_intent = best_task   # 記住，供下次加慣性
```

效果：values 穩定 → 同方向分數本就近似；慣性再壓住**情境抖動**（如獵物暫時不在 → 掠奪型不立刻改貿易，會續找獵物）。策略跨多 tick 連貫。

> 慣性僅止 flip-flop，非鎖死 — 情境明顯變（出現更高分選項超過 bonus）仍會換。

**目標完成後的延續（依是否還在流浪狀態）：**
- **掠奪成功** → 仍是流浪團 → `solo_intent="掠奪"` 續偏好 → 找新獵物續搶（**持久盜匪 = 延續感本意**）。非鎖死：累積財富 + 野心 → 紮營/攻擊分數可超 bonus → emergent 轉向（盜匪攢夠想建國）。
- **投靠/紮營成功** → 脫離流浪（入勢力 / 有 outpost）→ SoloAI 不再跑（gated `own_outpost==-1` / 非獨立）→ intent 自然失效，轉治理/生產。
- 「盜匪→軍閥→建國」長弧屬 ②目標錨（待 spec）；本 spec 慣性只負責短期延續。

## 風險

- **勿 uniform**：紮營/投靠是評分項，與 roving 競爭；好戰/貪婪/商業型應壓過尋家。量測：行為分佈仍多元（攻擊/掠奪/貿易/紮營/投靠並存），非全定居。
- **與 survival 不衝突**：SoloAI（stable）vs `_trigger_survival`（缺糧）分離；缺糧 PRIO_SURVIVAL 蓋過 SoloAI 的 PRIO_DISPATCH。確認不雙觸發同 task。
- **建村率**：SoloAI 紮營是「主動」非「絕境」→ 建村可能增加。量測；過量則降紮營權重 / 加門檻（如 readiness/pop 下限）。
- **勿膨脹**：只擴 `_evaluate_solo` + reuse helpers。非戰略引擎。
- **`_tag_weight` 對紮營/投靠**：若 `_tag_weight` 對未知 task 回預設，確認新 task 名（紮營/投靠）有合理權重或 fallback。

## 測試

- 單元：求生型無家流浪團（求生/慎重高）SoloAI → 選紮營（或投靠）；好戰/貪婪盜匪 → 攻擊/掠奪壓過尋家（不找家）；有 own outpost 隊 → 不評尋家；無可農地 + 無強鄰 → 不選尋家（落 roving/idle）。
- 承諾慣性：同隊連續兩次 SoloAI 重評，情境未明顯變 → 選同方向（`solo_intent` 加成生效，不抖動）；出現明顯更高分選項（超 bonus）→ 仍會換。
- 整合：`game_sim_multi` 2 年 — 無家流浪團主動安身率 >0（[CrudeCamp]/投靠 較 desperation-only 增加）、行為仍多元（roving 未消失）、**策略連貫**（同隊不每 cadence 換 task kind）、coin_eq 0、無新增 SCRIPT ERROR、無誤觸（有家隊不找家）。

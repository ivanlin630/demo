# S2 raw 增補：高層(尊重/自我實現)就緒度語意（systems HOW）

> 藍圖裁 B(`blueprint-to-systems-S2-need-model-decision-B`)。修正 S1.1 `compute_raw` 的 esteem/actual raw：由「離終點多遠(flat max)」改「有多接近可以追求它(就緒度)」。低層(生存/安全/歸屬)不動。此增補只影響 S2(compute_raw 在 S2.3 才 wire 進 rank，S1 inert)。

## 動機
solo/未就緒隊 esteem/actual raw 恆=1.0 → 高層 affinity option(駐守/建設)系統性壓贏，撞 Maslow §1 金字塔。B 案：高層 urgency = 就緒度（basics 穩 + 有機會才升），非離終點距離。

## 守 §2 獨立性（關鍵約束）
每層 sensor **只讀世界就緒訊號**（food_days/threat/pop/food_flow/faction 規模/rung），**不讀其他層的 urgency 變數值**。food_days 是 esteem 自己的就緒訊號（「我吃飽到有餘裕在意地位嗎」），非參照 survival urgency。∴ sensors 仍互不知彼此 urgency，守 spec §2 字面。

## 公式（改 `NeedHierarchy.compute_raw` 的 L_ESTEEM / L_ACTUAL 兩行；其餘不動）

新增常數（need_hierarchy.gd）：
```gdscript
const ESTEEM_SAFE_FLOOR: float = 0.0   # (無新常數需求;沿用 SURVIVAL_SATED_DAYS + AmbitionLadder 門檻)
```
（實際不需新常數，全複用既有門檻。）

**L_ESTEEM（尊重=地位/擴張）就緒度**：
```gdscript
# 就緒度 = 基礎穩(食/安有餘裕在意地位) × 機會(野心階梯還有空間爬)。讀世界訊號非他層 urgency。
var food_ready: float = clampf(food_days / SURVIVAL_SATED_DAYS, 0.0, 1.0)
var safe_ready: float = 1.0 - clampf(threat, 0.0, 1.0)
var cap_e: int = maxi(team.ambition_cap, 1)
var ambition_gap: float = clampf(float(team.ambition_cap - team.ambition_rung) / float(cap_e), 0.0, 1.0)
raw[L_ESTEEM] = food_ready * safe_ready * ambition_gap
```

**L_ACTUAL（自我實現=立國/稱霸）就緒度**：
```gdscript
# 就緒度 = 接近立國條件(食流盈餘×夠人×有社會結構) × 機會(未達稱霸頂)。solo(無faction)→0。
var ff_ready: float = clampf(team.food_flow_avg / AmbitionLadder.ACCUMULATE_FLOW_MIN, 0.0, 1.0)
var pop_ready: float = clampf(float(team.population) / float(AmbitionLadder.EXPAND_MIN_POP), 0.0, 1.0)
var faction_ready: float = 0.0
if team.faction_id != -1 and state.factions.has(team.faction_id) \
		and state.factions[team.faction_id].member_team_ids.size() >= 1:
	faction_ready = 1.0
var gap_a: float = 0.0 if AmbitionLadder.milestone_met(state, team, AmbitionLadder.RUNG_HEGEMON) else 1.0
raw[L_ACTUAL] = ff_ready * pop_ready * faction_ready * gap_a
```

低層不變：L_SURVIVAL(缺食=急)/L_SAFETY(威脅=急)/L_BELONGING(faction 規模距門檻,solo=1)。

## 效果驗證（就緒度接 established 鏈）
- **solo 未就緒**（govern 測：faction=-1）→ actual=0(faction_ready=0)、esteem=0(cap=rung=0)→駐守不再被 boost→base term util 決定→warmonger 不被翻成治理。**2 govern 測回綠**（coeff 對這些低就緒 state 近中性）。
- **faction+pop+food 就緒隊**→ actual 升→立國/建設/佔村/吸納在**該立國時**被 boost（接 established 調查鏈,自我實現 urgency 峰值=正確時點）。
- **fed+safe+ambitious 隊**→ esteem 升→攻擊/訓練/貿易 boost（warmonger 有本錢時才征戰）。

## determinism
純算術（clampf/乘法）+ milestone_met(純讀 state.factions)，零 randf。同 S1 pattern。

## TDD 增補（headless_test.gd）
`_test_need_raw_readiness`：
- solo(faction=-1,cap=0,food 足) → esteem==0 且 actual==0（就緒度低）。
- 就緒隊(faction+members≥1,pop≥EXPAND_MIN_POP,food_flow≥ACCUMULATE_FLOW_MIN,cap>rung,未稱霸) → esteem>0 且 actual>0。
- 稱霸隊(milestone_met HEGEMON) → actual==0（gap=0，已達頂無機會）。
- 原 `_test_need_raw_urgency` 中「solo→actual 高」斷言**改**為「solo→actual==0（就緒度低）」。

## 拆分
此增補併入 S2 dispatch（implementer 續 S2.3 前先做此 compute_raw 修正 = 新 task **S2.0**，其餘 S2.1~S2.6 照原 plan）。R② 只審此增量語意。

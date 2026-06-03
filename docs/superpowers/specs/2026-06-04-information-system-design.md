# 資訊系統設計文件

> 建立：2026-06-04 | 涵蓋：TextBank、訊息失真、情報交換、AI 接線、副官系統、打聽 UI

---

## 背景問題

1. **NPC AI 全知**（T-02）：所有 AI 直讀 WorldState 精確值，視野/快照機制形同虛設
2. **訊息失真不完整**：`_distort_content` 改欄位但 `description` 字串不更新 → 不一致
3. **情報無流通**：`team_intel` 寫了但無人讀；NPC 間不交換情報
4. **副官系統缺失**：無法提供有技能品質差異的建議

---

## 架構總覽

```
WorldState
├── team_known[tid]      Array[MessageData]       事件訊息（已傳播）
├── team_intel[obs][tgt] Dictionary               戰術觀測快照
└── faction.known_member_states[tid] Dictionary   勢力內部快照

scripts/data/text_bank.gd           ← 所有文字（新檔）
scripts/simulation/message_system.gd ← 修改（接入 TextBank、加 _exchange_intel）
scripts/simulation/advisor_system.gd ← 新檔
scripts/simulation/inquiry_system.gd ← 新檔
```

### 依賴關係

```
TextBank          ← 無依賴（純靜態資料）
MessageData       ← 加 params: Dictionary
message_system    ← TextBank
advisor_system    ← TextBank + PersonData
inquiry_system    ← team_intel + team_known + TextBank
diplomatic_ai     ← team_intel（T-02）
strategic_ai      ← faction_snapshot（T-02）
sim_runner        ← snapshot B 更新
interaction_system← snapshot A 更新
```

---

## 一、TextBank（`scripts/data/text_bank.gd`）

靜態類別，統一管理所有遊戲文字。

```gdscript
class_name TextBank

const TEMPLATES: Dictionary = {
    # ── 事件消息 ────────────────────────────────
    "subjugate": {
        "honest":        "Team{origin} 主服 Team{loser}，加入勢力{faction}",
        "unintentional": "聽說 Team{origin} 收編了人，細節不清",
        "malicious":     "Team{origin} 被 Team{loser} 吞併",
        "vague":         "Team{origin} 附近勢力有變動",
    },
    "battle": {
        "honest":        "Team{origin} 在({x},{y})擊敗 Team{loser}",
        "unintentional": "Team{origin} 附近({x},{y})好像打起來了",
        "malicious":     "Team{origin} 在({x},{y})遭受重創",
        "vague":         "({x},{y})附近有衝突",
    },
    "betrayal": {
        "honest":        "Team{origin} 背叛了 Team{ally}",
        "unintentional": "Team{origin} 跟盟友鬧翻了",
        "malicious":     "Team{ally} 主動驅逐了 Team{origin}",
        "vague":         "Team{origin} 的盟約破裂",
    },
    "faction_establish": {
        "honest":        "Team{origin} 正式立國，號{name}",
        "unintentional": "Team{origin} 好像建了個組織",
        "vague":         "Team{origin} 有政治動作",
    },
    "diplomacy": {
        "honest":        "Team{origin} 與 Team{target} 締盟",
        "vague":         "Team{origin} 在談判",
    },
    "famine_warning": {
        "honest":        "({x},{y})附近歉收，糧食緊張",
        "vague":         "某地糧食不足",
    },

    # ── 副官台詞 ────────────────────────────────
    "advisor_food_critical": {
        "default": "主公，糧草告急，需速作安排",
        "blunt":   "沒糧了，快處理",
        "formal":  "啟稟主公，存糧已達危急水位，懇請早作因應",
        "sarcastic": "啊，又沒糧了，真是驚喜",
    },
    "advisor_enemy_approaching": {
        "default": "主公，有敵軍靠近",
        "blunt":   "來敵了，準備",
        "formal":  "稟報，偵查發現敵方兵馬向我方接近",
    },
    "advisor_faction_betrayed": {
        "default": "主公，盟友背叛了我們",
        "blunt":   "被賣了",
        "bitter":  "果然，信人者死",
    },

    # ── 副官建議 ────────────────────────────────
    "advisor_assess_enemy": {
        "accurate_strong":     "敵方兵強，不宜正面，建議{action}",
        "accurate_weak":       "敵方兵寡，可以出擊",
        "wrong_underestimate": "敵方不多，問題不大",
        "wrong_overestimate":  "敵方恐怕難纏，小心",
        "biased_attack":       "強敵又如何，打！",
        "biased_retreat":      "哪怕弱敵，謹慎些好",
    },
    "advisor_diplomatic": {
        "accurate_hostile":   "對方心存敵意，外交恐怕無效",
        "accurate_friendly":  "對方似乎願意合作",
        "wrong_read":         "對方看起來可以談談",
        "biased_war":         "管他外交，先打",
        "biased_peace":       "還是先談談吧",
    },
    "advisor_resources": {
        "accurate_critical":   "糧草撐不過{days}天，需立即處置",
        "accurate_stable":     "資源充裕，暫無憂慮",
        "wrong_optimistic":    "糧草沒問題，夠用",
        "wrong_pessimistic":   "物資快不夠了",
    },

    # ── UI 文字 ────────────────────────────────
    "ui_action_build_outpost":    { "label": "建造據點",  "desc": "在當格建造據點，需消耗資源" },
    "ui_action_dispatch_subteam": { "label": "派遣子隊",  "desc": "分出子隊執行任務" },
    "ui_action_recall_subteam":   { "label": "召回子隊",  "desc": "派信使子隊傳達撤回令" },
    "ui_action_gather_intel":     { "label": "打聽消息",  "desc": "向對方詢問情報" },
}

static func get(type: String, variant: String, params: Dictionary = {}) -> String:
    var template: String = TEMPLATES.get(type, {}).get(variant, "Team{origin} 有動靜")
    return template.format(params)
```

---

## 二、MessageData 擴充

```gdscript
# scripts/data/message_data.gd 新增
var params: Dictionary = {}  # 結構化參數，供 TextBank 重生成文字
```

所有 `emit_message` 呼叫補寫 `msg.params`，description 改用 `TextBank.get()` 生成。

---

## 三、訊息失真重寫（`message_system.gd`）

### 失真後重生成文字

```gdscript
func _distort_content(state: WorldState, msg: MessageData) -> void:
    if randf() < 0.5:
        # 改主體（誰做的）
        var ids = state.teams.keys(); ids.erase(msg.origin_team_id)
        if not ids.is_empty():
            msg.origin_team_id = ids[randi() % ids.size()]
            msg.params["origin"] = msg.origin_team_id
    else:
        # 改位置（在哪發生）
        var offsets = [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),
                       Vector2i(0,-1),Vector2i(1,-1),Vector2i(-1,1),
                       Vector2i(2,0),Vector2i(-2,0)]
        msg.source_pos += offsets[randi() % offsets.size()]
        msg.params["x"] = msg.source_pos.x
        msg.params["y"] = msg.source_pos.y
    # 重生成文字（失真欄位 → 失真文字）
    msg.description = TextBank.get(msg.type, "malicious", msg.params)
```

### intel 條目失真（新函式）

```gdscript
func _distort_intel_entry(entry: Dictionary, mode: String) -> Dictionary:
    var e = entry.duplicate()
    match mode:
        "honest":
            e["population_est"] = roundi(e["population_est"] * randf_range(0.9, 1.1))
        "unintentional":
            e["population_est"] = roundi(e["population_est"] * randf_range(0.6, 1.5))
            e["tile_pos"] += Vector2i(randi_range(-2, 2), randi_range(-2, 2))
            if randf() < 0.3: e["current_task"] = _random_task()
        "malicious":
            e["population_est"] = roundi(e["population_est"] * randf_range(0.2, 3.0))
            e["tile_pos"] += Vector2i(randi_range(-6, 6), randi_range(-6, 6))
            if randf() < 0.5: e["faction_id_hint"] = _fake_faction_id()
            if randf() < 0.4: e["current_task"] = _random_task()
        "silent":
            return {}
    return e
```

### NPC 同格被動情報交換（新函式）

**決策流：**
```
1. 敵對？           → silent 或 malicious
2. 同勢力？         → 強制 honest（faction 通訊）
3. diplomacy_score：
   > 0.6 → honest
   0.3–0.6 → unintentional
   < 0.3 → silent 或 malicious（依計謀）
4. values 覆蓋：
   慎重高 → 門檻升高
   計謀高 + 低好感 → 傾向 malicious
```

**傳什麼（依關係）：**
| 關係 | 傳 |
|---|---|
| 同勢力 | team_known + 全部 team_intel 條目 |
| score > 0.6 | team_known + tile_pos + 粗略 population |
| 0.3–0.6 | tile_pos（帶噪音） |
| < 0.3 | 不傳 / 假資訊 |

**intel 條目加 confidence 欄位：**
```gdscript
entry["confidence"]    = source_reputation × (1 - HOP_DECAY) × time_factor
entry["source_team"]   = source_id   # -1 = 自己觀測
entry["is_suspicious"] = false       # 接收方懷疑標記
```

接收方 `智力` 高時有機率設 `is_suspicious = true`。

---

## 四、AI 接線（T-02）

### 外部目標改讀 team_intel

```gdscript
# diplomatic_ai._calc_diplomacy_score
var pop_est: int = state.team_intel\
    .get(self_team.team_id, {})\
    .get(other_team.team_id, {})\
    .get("population_est", self_team.population)  # fallback = 保守估算
var power_gap: float = float(pop_est - self_team.population) / maxf(self_team.population, 1.0)
```

同樣修改：`consider_betrayal`、`strategic_ai._evaluate_alliance_need`、`strategic_ai._assign_encirclement`

### 勢力內部改讀快照

```gdscript
# strategic_ai._find_weakest_member
var snap = faction.known_member_states.get(tid, {})
var pop = snap.get("population", 9999)  # 無快照 = 視為未知（最大值 = 不選）
```

### 快照更新觸發

**A. 信使抵達**（`interaction_system._deliver_order`）：
```gdscript
# 信使傳令後補一行
state.snapshot_faction_member(herald.parent_team_id, state.world.current_tick)
```

**B. 同格同勢力**（`sim_runner._step4_resolve_interactions` 後）：
```gdscript
for tid in team_ids:
    var t = state.teams[tid]
    if t.faction_id == -1: continue
    for other_id in team_ids:
        var o = state.teams.get(other_id)
        if o and o.faction_id == t.faction_id and o.tile_pos == t.tile_pos:
            state.snapshot_faction_member(other_id, state.world.current_tick)
```

---

## 五、副官系統（`scripts/simulation/advisor_system.gd`）

### 技能→情境對應

| 情境 | 主技能 |
|---|---|
| assess_enemy | 戰術 |
| diplomatic | 交涉 |
| resources | 生產 |
| strategic | 計謀 |
| intel_read | 偵查 |

### 核心邏輯

```gdscript
func get_advice(advisor: PersonData, situation: String,
        situation_data: Dictionary, state: WorldState) -> String:
    var skill = SITUATION_SKILL_MAP.get(situation, "計謀")
    var accurate = _advice_is_accurate(advisor, skill)
    var variant = _pick_variant(advisor, situation, accurate, situation_data)
    var params = _build_params(advisor, situation, situation_data)
    return TextBank.get("advisor_" + situation, variant, params)

func _advice_is_accurate(advisor: PersonData, skill: String) -> bool:
    return randf() < float(advisor.skills.get(skill, 0.0))

func _pick_variant(advisor, situation, accurate, data) -> String:
    if not accurate:
        return "wrong_underestimate" if randf() < 0.5 else "wrong_overestimate"
    var hawkish = float(advisor.values.get("好戰", 0.5)) > 0.7
    var cautious = float(advisor.values.get("慎重", 0.5)) > 0.7
    # 情境特定邏輯...
    return "accurate_strong"  # 依情境

func _advisor_tone(advisor: PersonData) -> String:
    if float(advisor.values.get("計謀",0.5)) > 0.7 \
            and float(advisor.values.get("義氣",0.5)) < 0.3:
        return "sarcastic"
    if float(advisor.values.get("好戰",0.5)) > 0.7: return "blunt"
    if float(advisor.values.get("信義",0.5)) > 0.6: return "formal"
    return "default"
```

---

## 六、打聽 UI（`scripts/simulation/inquiry_system.gd`）

### 相關度排序

```gdscript
func get_options(state: WorldState, player_team: TeamData,
        npc_team: TeamData) -> Array:
    var options = []
    for id in ALL_INQUIRY_IDS:
        var rel = _calc_relationship(state, player_team, npc_team)
        if not _passes_filter(id, state, player_team, npc_team): continue
        options.append({
            "id": id,
            "label": TextBank.get("ui_inquiry_" + id, "label", {}),
            "relevance": _score_option(id, state, player_team, npc_team),
            "requires_relation": INQUIRY_RELATION_THRESHOLD.get(id, 0.0),
        })
    options.sort_custom(func(a,b): return a["relevance"] > b["relevance"])
    return options.slice(0, 5)  # 最多 5 條
```

### 知識缺口過濾

```gdscript
func _passes_filter(id, state, player_team, npc_team) -> bool:
    match id:
        "ask_team_location":
            # 已有新鮮 intel → 跳過
            var intel = state.team_intel.get(player_team.team_id, {})
            for tid in intel:
                if intel[tid].get("last_tick", 0) > state.world.current_tick - 240:
                    return false  # 最近10天已有位置資料
            return true
        _: return true
```

### 選項相關度（情境敏感）

| 選項 | 高分條件 |
|---|---|
| ask_food_source | player 食物天數 < 10 |
| ask_enemy_movement | player_hostile_teams 非空 |
| ask_faction_status | player 在勢力中 |
| ask_recent_events | 常數 0.5（基本都有用） |
| ask_specific_team | 有未知仇敵 |
| ask_trade | player coin 不足 |

---

## 實作優先順序

| # | 項目 | 新檔 | 修改 |
|---|---|---|---|
| 1 | TextBank | `text_bank.gd` | — |
| 2 | MessageData.params + 失真重寫 | — | `message_data.gd`, `message_system.gd`, 所有 emit_message（~10處） |
| 3 | T-02 AI 接線（外部 team_intel） | — | `diplomatic_ai.gd`, `strategic_ai.gd` |
| 4 | T-02 faction 快照更新（A+B） | — | `interaction_system.gd`, `sim_runner.gd` |
| 5 | `_exchange_intel`（NPC 被動交換） | — | `message_system.gd` |
| 6 | 玩家「打聽」action + InquirySystem | `inquiry_system.gd` | `player_command_system.gd`, `player_api_mapper.gd` |
| 7 | AdvisorSystem | `advisor_system.gd` | — |

---

## 測試要點

- 失真後 `description` 與 `origin_team_id`/`source_pos` 一致
- NPC 同格時 `team_intel` 確實交換，confidence 欄位存在
- diplomatic_ai 不再用精確人口（測試：高潛行 team 不被 AI 主動外交）
- faction leader 在成員快照 staleness 下做出「錯誤」派兵決策
- 副官低技能時給出「wrong_*」variant 建議
- 打聽選單最多 5 條，隨情境變化

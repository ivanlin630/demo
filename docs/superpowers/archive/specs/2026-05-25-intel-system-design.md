# IntelSystem 設計（統一情報層）

## 目標

建立統一的接觸分級情報系統：所有 team 對外界的認知從「全知直讀」改為「快照介面」。快照依接觸層級決定資訊量，離開視野後保留最後快照直到下次更新。

此設計取代 2a 的 FactionData.known_member_states stub（全知直讀改為 team_intel 驅動），並新增敵方/中立 team 的情報機制。

---

## 架構原則

| 層 | 現況 | IntelSystem 後 |
|---|---|---|
| 敵方/中立情報 | FactionAI 直讀 state.teams | 讀 team_intel 快照 |
| 友方成員情報（2a） | evaluate_all stub 全知刷新 | 從 team_intel 複製（bridge） |
| 接觸觸發 | 無 | VisionSystem + InteractionSystem 寫入 |

⚠️ `team_discovered` 保留不動（IntelSystem 成熟後一次取代，屆時清除雙結構）

---

## 資料結構

### WorldState 新增

```gdscript
var team_intel: Dictionary = {}
# { obs_id: int → { tgt_id: int → {
#   "tier":           int,       # 最高接觸層級：0/1/2
#   "population_est": int,       # 帶距離雜訊
#   "tile_pos":       Vector2i,
#   "last_tick":      int,
#   # tier ≥ 1 才有：
#   "resource_scale": int,       # 0缺乏 1勉強 2充裕 3豐盛（總資源合計，帶雜訊）
#   # tier 2 才有（可能造假）：
#   "faction_id":     int,
#   "tags":           Array,
#   "current_task":   String,
#   "food_est":       float,
#   "material_est":   float,
#   "coin_est":       float,
#   "goods_est":      float,
#   "armed_est":      int,       # 武裝士兵數 = named_armed + round(anon_pop × armed_anon_ratio)
# }}}
```

`FactionData.known_member_states` 保留為 bridge（格式沿用），由 evaluate_all 從 team_intel 複製，不再直接讀 state.teams。

---

## 接觸層級

### Tier 0 — 遠視野（dist ≤ vrange）

VisionSystem.tick_discovery 偵測到目標時觸發。

```gdscript
var noise: float = 1.0 - dist_factor   # dist_factor = 1-(dist/(vrange+1))×0.5
# vrange 邊緣 noise≈0.5；近處 noise≈0
var pop_est: int = roundi(actual_pop * randf_range(1.0 - noise, 1.0 + noise))
pop_est = maxi(1, pop_est)
```

寫入：`population_est`, `tile_pos`, `last_tick`, `tier=0`（若原 tier < 0）

### Tier 1 — 近接觸（dist ≤ 1）

同次 tick_discovery，dist ≤ 1 時額外寫入：

**resource_scale**：目標總資源量合計（所有 resource key 加總），分 4 級，帶 ±1 bucket 隨機雜訊

| 總資源量 | scale |
|---|---|
| < 50 | 0（缺乏）|
| 50–200 | 1（勉強）|
| 200–600 | 2（充裕）|
| > 600 | 3（豐盛）|

觀察者只知道對方「行李多不多」，不知道裝的是什麼。

### Tier 2 — 同格互動（接觸事件）

InteractionSystem.reveal_encounter 觸發（雙向），寫入完整欄位。

#### 造假機制

**判定**：

```gdscript
var honor: float  = target_leader.values.get("信義", 0.5)
var scheme: float = target_leader.skills.get("計謀", 0.0)
var deceive_chance: float = (1.0 - honor) * 0.5 + scheme * 0.2  # TEST VALUE
# 接口預留：task == "作戰"/"潛入" → deceive_chance += 0.3（未來實作）
```

**型態**：

| 型態 | 觸發條件 | armed_est | 其他 resource_est |
|---|---|---|---|
| **偽裝平民** | tags 含 統領/軍隊/流亡/子團 且 deceive_chance 觸發 | × randf(0.2–0.4) | × randf(1.5–2.5) |
| **虛張聲勢** | (攻擊/掠奪 task) 或 (好戰>0.6) 或 (商隊 tag + 慎重>0.5)，且 armed/pop < 0.6，且 deceive_chance 觸發 | × randf(2–4)，cap = population_est - 1 | × randf(0.3–0.7) |

無造假：直接寫入實際值。

**armed_est 計算**：

```gdscript
var named_armed: int = 0
for pid in ([team.leader_id] as Array) + team.advisors + team.members:
    var p: PersonData = state.persons.get(pid)
    if p and p.equipment.get("weapon", "") != "":
        named_armed += 1
var named_count: int = 1 + team.advisors.size() + team.members.size()
var anon_pop: int = team.population - named_count
armed_est = named_armed + roundi(float(anon_pop) * team.armed_anon_ratio)
```

---

## 更新流程

| 觸發點 | 位置 | 說明 |
|---|---|---|
| Tier 0/1 | `VisionSystem.tick_discovery` | 每次偵測到目標時 |
| Tier 2 | `InteractionSystem.reveal_encounter` | 同格接觸開始時 |
| FactionAI bridge | `FactionAISystem.evaluate_all` | 從 team_intel 複製到 known_member_states |

快照離開視野後**不清除**，保留最後值直到下次接觸更新。

---

## FactionAI 改動

### evaluate_all — 移除 stub，改讀 team_intel

```gdscript
# 移除：state.snapshot_faction_member(mid, tick)
# 改為：
for mid in f.member_team_ids:
    var snap = state.team_intel.get(f.leader_team_id, {}).get(mid, {})
    if not snap.is_empty():
        f.known_member_states[mid] = snap
    # 無快照 → 保留上次記憶
```

### _find_trade_target — 改讀 team_intel

```gdscript
var snap = state.team_intel.get(merchant.team_id, {}).get(tid, {})
var coin_est: float = float(snap.get("coin_est", 0.0))
if coin_est < TRADE_MIN_COIN: continue
```

coin_est 只有 Tier 2 後才有值，未互動 = 0 = 不選為貿易目標。

### 攻擊決策 — 實力估算

在 `_update_goals` 攻擊 goal 條件加：

```gdscript
var target_id: int = _nearest_independent(state, leader_team)
if target_id != -1:
    var tgt_snap = state.team_intel.get(f.leader_team_id, {}).get(target_id, {})
    var tgt_armed: int = int(tgt_snap.get("armed_est", 999))  # 未知視為強敵
    var own_armed: int = _calc_own_armed(state, leader_team)
    # 已承諾攻擊的成員/子團
    for mid in f.known_member_states:
        if mid == f.leader_team_id: continue
        var ms = f.known_member_states[mid]
        if ms.get("current_task", "") == "攻擊":
            own_armed += int(ms.get("armed_est", 0))
    if float(own_armed) < float(tgt_armed) * 0.8:
        # 不加入攻擊 goal
```

⚠️ 子團叛變追蹤、成員同意機制留待後續實作。

---

## 修改檔案

| 檔案 | 動作 |
|---|---|
| `scripts/data/world_state.gd` | 加 `team_intel: Dictionary = {}` |
| `scripts/simulation/vision_system.gd` | `tick_discovery` 寫 team_intel Tier 0/1 |
| `scripts/simulation/interaction_system.gd` | `reveal_encounter` 寫 team_intel Tier 2 + 造假 |
| `scripts/simulation/faction_ai_system.gd` | 移除 stub；bridge known_member_states；_find_trade_target；攻擊實力估算 |
| `scripts/debug/headless_test.gd` | 初始化 team_intel；驗證快照層級與造假 |
| `docs/progress.md` | 加入 IntelSystem |

---

## 驗證場景

1. **Tier 0**：Team A 在視野邊緣看 Team B（pop=20）→ population_est 在 10–30 範圍內
2. **Tier 1**：Team A 移近（dist=1）→ resource_scale 正確分類（帶 ±1 雜訊）
3. **Tier 2 無造假**：高信義 team 互動 → food_est 接近實際
4. **Tier 2 造假**：低信義軍隊 → armed_est 大幅低報（偽裝平民）
5. **快照持久**：Team B 離開視野 → team_intel[A][B] 仍保留上次值
6. **攻擊決策**：弱 leader 面對 armed_est=999（未知） → 不發動攻擊

---

## ⚠️ 設計備忘

| 事項 | 說明 |
|---|---|
| team_discovered 保留 | IntelSystem 成熟後一次清除雙結構 |
| known_member_states bridge | evaluate_all 從 team_intel 複製；FactionAI 讀取程式碼不變 |
| coin_est 未知問題 | 未互動 team coin_est=0 → 貿易 AI 可能過度保守，TEST VALUE 期觀察 |
| 子團叛變 | 快照 current_task 可能過時，leader 不知情 → 設計意圖，後續追蹤 |
| 造假係數 | 全為 TEST VALUE，平衡期調整 |

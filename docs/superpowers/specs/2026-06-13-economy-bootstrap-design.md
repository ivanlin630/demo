# 經濟死水解鎖（Economy Bootstrap）— Design

> 日期：2026-06-13
> 議題：W4 fief 機制就位但經濟仍死水。診斷（fief + w4 handback + code 查證）三把鎖：
> - **A tools 死結**：`_pick_outpost_type`（:1665）好戰 leader 選 military（cost tools 3），但 tools 恆 0（要工坊才產、工坊要先有據點）→ 雞生蛋，全 config 0 新建
> - **B 治理 actor 錯位**：「治理」加在 `_evaluate_solo`（獨立隊 faction_id=-1），但派建造 `_dispatch_builder` 只在 `_evaluate_infrastructure`（faction leader）→ 兩者不相交，leader 永遠拿不到治理傾向
> - **W3 生育關閉**：`_evaluate_person`（:104）winner-take-all，`_score_breed` max 0.4-0.5 永遠輸 P1_comply(~1.0)/P2_produce(0.6) → 0 生育 → 人口只跌不升（tyrant 60→17）
> 證據：merchant（5 outpost、全 civilian 無 tools 死結）也死水 → 不是純規模問題；三鎖才是。

## 設計核心

- **A 自給階梯（affordability fallback）**：軍閥蓋不起 military（無 tools）→ fallback civilian → 自家工坊產 tools → 才升軍鎮。非硬規則，是「蓋你買得起的」經濟後果。**供應鏈 forward-compat**：tools-check 認「庫存 OR 自家工坊」，未來 W1/W2 貿易通 → 買來的 tools 進庫存 → 同 check 自動放行供應鏈階梯，不改 code
- **B 治理接 faction leader**：`_evaluate_infrastructure` 加「想蓋但公庫不足且不在家 → 回家治理攢公庫」
- **W3 反應分層**：行動反應（winner-take-all，這 tick 做一事）vs 生命事件（獨立 roll，可並行）。P5 生育 = 生命事件 → 人邊工作邊生育。心理門檻全保留，只是不搶唯一名額

## 不變量

- A 非硬規則：個性照樣想蓋 military，只是買不起就退而求其次（經濟後果非行為鎖死）
- W3：生命事件不互斥行動 — 一人一 tick 可同時「服從」（行動）+「生育」（生命事件）
- 生育心理門檻不變（安全 + 溫飽 + 醫療 + cap），只改「不參與 winner-take-all 競爭」
- 守恆：生育只加 minor_population（人，非資源）；不破 coin/物資守恆

---

## 1. A：自給階梯（affordability fallback）

`_pick_outpost_type`（:1665）改吃 state + leader_team，加 tools 可得性判斷：

```gdscript
func _pick_outpost_type(state: WorldState, leader_team: TeamData, leader: PersonData) -> String:
    # 文明階梯：軍鎮需 tools；無 tools 來源 → 只能蓋民村（個性想蓋軍鎮也買不起）
    var has_tools: bool = float(leader_team.resources.get("tools", 0)) >= 3.0 \
        or _faction_has_workshop(state, leader_team)
    if not has_tools:
        return "civilian"
    var military: float = float(leader.values.get("好戰", 0.5)) + float(leader.values.get("野心", 0.5))
    var civilian: float = float(leader.values.get("慎重", 0.5)) + float(leader.values.get("貪婪", 0.5))
    return "military" if military > civilian else "civilian"

func _faction_has_workshop(state: WorldState, leader_team: TeamData) -> bool:
    # faction 內任一自有 outpost 有 workshop(manufacturing_level>0) → 有 tools 來源
    for tile_id in state.world.tiles:
        var t: HexTileData = state.world.tiles[tile_id]
        if t.outpost_level > 0 and int(t.manufacturing_level) > 0:
            var o: TeamData = state.teams.get(t.outpost_owner)
            if o != null and o.faction_id == leader_team.faction_id and leader_team.faction_id != -1:
                return true
        # leader 自有(獨立)亦算
        if t.outpost_owner == leader_team.team_id and int(t.manufacturing_level) > 0:
            return true
    return false
```

caller（`_evaluate_infrastructure` :1489 附近 `_pick_outpost_type(leader)`）改傳 state + leader_team + leader。

**供應鏈 forward-compat（spec 註記，不另實作）**：has_tools 的「tools 庫存 ≥ 3」分支 = 未來貿易/商隊買來的 tools 也滿足。W1/W2 貿易修好後（known_issues），軍閥可向民村買 tools → 庫存足 → 直接蓋軍鎮（供應鏈階梯）。同一 check 自動承接，無需改 code。

## 2. B：治理接 faction leader 路徑

`_evaluate_infrastructure`（:1670）蓋新 outpost 段（`_dispatch_builder` 前），加「公庫不足 + 不在家 → 回家治理」：

```gdscript
# (3) 蓋新 outpost 前：若 leader 不在自家 outpost 且公庫不足 → 先回家攢
var own_pos: Vector2i = _find_own_outpost(state, leader_team)
if own_pos != Vector2i(-1, -1) and leader_team.tile_pos != own_pos:
    var home_tile: HexTileData = state.world.tiles.get(own_pos.x*1000 + own_pos.y)
    var vault_mat: float = float(home_tile.public_storage.get("material",0)) if home_tile else 0.0
    # 公庫不足蓋下一個 + leader 非戰鬥忙碌 → 回家治理（PRIO_DISPATCH，不蓋高優先反應）
    if vault_mat < GOVERN_MATERIAL_TARGET and leader_team.current_task == TeamData.TASK_IDLE:
        if TaskArbiter.try_set(state, leader_team, "治理", own_pos,
                TaskArbiter.PRIO_DISPATCH, "govern_accumulate"):
            return   # 回家路上，不派工
# leader 在家 + 公庫足 → 正常派工（caravan-load，Task w4 已實裝）
```

leader 回家 → idle-on-home 自動採集 + 一般稅積公庫（fief 已實裝）→ 公庫達標 → 下次 eval 派工。`GOVERN_MATERIAL_TARGET`（w4 已加 75）沿用。

`_evaluate_solo` 既有「治理」保留（獨立隊自家發展，無害）。

「治理」task 抵達 own_pos 後：movement 到家 → 既有到達邏輯回 idle（無專屬 handler，sticky 問題由「到家即 idle-on-home」自然化解 — 人在家就採集，下次 eval 重評）。確認 movement 到 target 後 task 不卡死（w4 handback 提及治理 sticky，本處用 PRIO_DISPATCH + 到家回 idle，重評時公庫足則派工、不足續治理）。

## 3. W3：反應分層（行動 / 生命事件）

`_evaluate_person`（:104）移除 `P5_breed`（只留行動反應 winner-take-all）。`_apply_reaction` 的 `P5_breed` case 移除。

新增生命事件層，在 `evaluate_all`（:26-30）per person 跑：

```gdscript
# 行動反應（winner-take-all，維持）
var reaction: String = _evaluate_person(person, team)
if reaction != "none":
    _apply_reaction(state, person, team, reaction)
    ...
# 生命事件（獨立，可與行動並行）
for ev in _evaluate_life_events(person, team):
    _apply_life_event(state, person, team, ev)
```

```gdscript
const BREED_BASE_CHANCE: float = 0.15   # TEST VALUE — 達標時每評估觸發機率

func _evaluate_life_events(p: PersonData, t: TeamData) -> Array:
    var events: Array = []
    # P5 生育：安全+溫飽+食物盈餘+未滿 cap → 機率觸發（不與行動競爭）
    var safe: bool = float(p.needs.get("safety", 1.0)) > 0.7
    var fed: bool = float(p.needs.get("food", 1.0)) > 0.7
    var surplus_ok: bool = float(t.resources.get("food", 0)) \
        > float(t.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY * 7.0
    var cap: int = maxi(1, int(t.population * 0.25))   # pop≤4 也能生 1
    if safe and fed and surplus_ok and t.minor_population < cap:
        var chance: float = BREED_BASE_CHANCE + float(p.skills.get("醫療", 0.0)) * 0.1
        if randf() < chance:
            events.append("P5_breed")
    return events

func _apply_life_event(state: WorldState, person: PersonData, team: TeamData, ev: String) -> void:
    match ev:
        "P5_breed":
            team.minor_population += 1
```

（cap 與 surplus 檢查移進生命事件層；`_score_breed` 函數可刪或保留供測試。minor 長大 = `population_system._mature_minors` 既有月 10%→平民，接上）

架構可擴展：未來生病/衰老/結親皆掛生命事件層。

## 連鎖效果（自動湧現）

- A：軍閥先蓋民村 → 工坊產 tools → 升軍鎮 → 文明階梯落地（W4 解的一半）
- B：慎重/野心 leader 回家攢公庫 → caravan-load 派工 → 新據點 → W4 真解
- W3：富村工作**且**生育 → 人口增 → minor 長大 → 密度上升 → 貿易/衝突/專業化臨界質量
- 三鎖齊開 → 經濟死水活：建造 + 人口 + 規模成長正循環

## 測試

1. A：leader 無 tools 無工坊 → `_pick_outpost_type` 回 civilian（個性好戰亦然）
2. A：faction 有 workshop outpost → has_tools true → 個性決定（好戰回 military）
3. A forward-compat：tools 庫存 ≥ 3（模擬買來）→ 無工坊也 has_tools → military 可選
4. B：leader 不在家 + 公庫 material < 75 + idle → `_evaluate_infrastructure` 設「治理」、target=自家 outpost
5. B：leader 在家 + 公庫足 → 不治理、正常派工（caravan-load）
6. W3：P5 移出 `_evaluate_person`（行動反應不含 P5）
7. W3：安全+溫飽+盈餘+未滿 cap → `_evaluate_life_events` 可回 P5_breed（機率）；不滿足 → 空
8. W3：生育與行動並行（同 person 同 tick 可 P1_comply 行動 + P5_breed 生命事件）
9. W3 cap：pop=4 → cap=1（可生 1）；pop=20 → cap=5
10. W3：生育 → minor_population +1 → `_mature_minors` 月 10% → 平民 anon（人口循環接通）
11. 守恆：生育不動資源；coin/物資 delta 0
12. multi 2 年：**新據點建造 > baseline 1/0/1/0**（A+B 解 W4）、**生育 > 0 + 人口曲線回升**（W3）、設施組合多樣、ALL INVARIANTS PASSED

## 風險

- 全參數 TEST VALUE（BREED_BASE_CHANCE 0.15、cap 0.25、GOVERN_MATERIAL_TARGET 75）
- A `_faction_has_workshop` 掃全 tiles（每次 `_pick_outpost_type` 呼叫）— 頻率低（蓋新據點時），可接受；若熱點再快取
- B 治理 sticky：leader 到家回 idle 後若公庫仍不足 → 重評再治理（駐家），公庫達標才轉派工。確認不會「到家立刻又被別的 goal 拉走」導致永遠攢不到（PRIO_DISPATCH 同層，survival/threat 高優先仍可正當 override）
- W3 生育速率：BREED_BASE_CHANCE × 評估頻率 可能過快/過慢 → multi 觀察人口曲線斜率，校 chance
- W3 人口回升 + famine 並存 → 富村生育 vs 窮村餓死 = 預期動態（人口流動），觀察淨值不爆不崩
- A 軍事勢力初期全變建設型（先蓋民村）→ 戰爭可能延後出現 → multi 觀察軍鎮最終是否成形（tools 鏈成熟後）

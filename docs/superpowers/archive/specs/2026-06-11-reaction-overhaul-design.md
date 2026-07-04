# Reaction 職責收斂（心理層大修）— Design

> 日期：2026-06-11
> 議題：reaction 系統撈過界做經濟（P2 憑空印 food、P3 憑空生人）→ 雙軌經濟養肥全世界 → survival 鏈永不觸發。加上 N1_flee 三 bug（solo zombie 循環 / 逃跑無目的地 / tier desync）與 11558 次 print spam。

## 設計原則

**Reaction = 人心層**：只輸出 心理狀態（loyalty/stress/unrest/記憶）+ 工作態度（係數）+ 離團行為。
**資源與人口 = team 層系統獨佔**（harvest / resource / population / residency）。
心理影響經濟，但不擁有經濟。

## 不變量

- 所有行為從 values/skills/stress/loyalty 計算產生（不變）
- `sum(anon_tiers) + named_count == population`（修 desync 後恢復保證）
- coin 守恆：N5 偷的錢轉移不蒸發
- reaction 心理效果（loyalty/stress/memory/skill 成長）全部保留不動

## 各 Reaction 定案

| Reaction | 改動 |
|---|---|
| P1_comply | 不動（loyalty +0.01）|
| P2_produce | **不再印 food**。改累積 team `work_morale` 正貢獻 |
| P3_recruit | **刪除**（真招募走 residency invite / 流民投靠 / 俘虜，皆既有）|
| P4_expand | 效果不動（unrest −1），文件改名「滿足」— 日子過得好、不滿消化 |
| P5_breed | 保留 minor +1，**加條件：糧食盈餘 > 7 天份**才生 |
| N1_flee | 修 3 bug（見下）|
| N2_riot | 不動 |
| N3_defect | tier 同步 + 離團者組流亡 team（不再 ghost）|
| N4_shirk | 效果不動（food −1）+ 累積 work_morale 負貢獻 |
| N5_extort | 偷的 coin → `person.coin`（守恆）|

## work_morale 係數

`team.work_morale: float = 1.0`（新欄位，範圍 [0.5, 1.5]）

```gdscript
# reaction_system per-team 統計（每次 evaluate_all）
# P2_produce 傾向 → 正貢獻；N4_shirk → 負貢獻
var morale_acc: float = 0.0
var counted: int = 0
# 每個 named person 的 reaction:
#   P2_produce → +1.0；N4_shirk → -1.0；其他 → 0.0（中性）
# 滾動更新（平滑避免抖動）：
team.work_morale = clampf(
    lerpf(team.work_morale, 1.0 + morale_acc / maxf(counted, 1) * 0.5, 0.1),
    0.5, 1.5)
```

消費端：`resource_system._collect_from_tile` 與 harvest 產出 `gain *= team.work_morale`。

- 全員勤奮村 → 1.5×；全員偷懶 → 0.5×
- 無 named 的 team → 維持 1.0

## N1_flee 三修

```gdscript
"N1_flee":
    # 修 1：solo team（pop<=1 且 person 是 leader）→ 跳過 apply
    #（無處可逃，不再無限循環 + spam）
    if team.population <= 1 and person.id == team.leader_id:
        return   # 心理上想逃但逃不了；stress 不減（持續高壓 → 餵 N2/N3）
    team.population = maxi(team.population - 1, 1)
    person.stress = maxf(person.stress - 0.3, 0.0)
    if team.named_members.has(person.id):
        team.named_members.erase(person.id)
        person.team_id = -1
        _spawn_exile_or_join(state, person, team.tile_pos)   # 修 3 之外加：不 ghost
    elif person.id != team.leader_id:
        pass
    else:
        # 修 2：leader 想逃但留下（leader 不能棄 solo+ team）→ 實際走的是 anon
        AnonTierSystem.kill_random(team, 1, "flee")   # tier 同步
```

### ReactionBridge 逃跑修

```gdscript
# 舊：task=逃跑 + move_target=(-1,-1) → 站著不動 zombie
# 新：用 ThreatAssessment 找視野內最高威脅，有才逃，往反方向
if flee_ratio >= 0.3 and team.current_task not in ["逃跑", "護衛"]:
    var threat_id: int = _find_top_threat(state, team)   # ThreatAssessment.score 掃 discovered
    if threat_id != -1:
        team.current_task = "逃跑"
        team.move_target = _flee_target(state, team, state.teams[threat_id])  # 既有 helper
    # 無威脅 → 不劫持 task（內心恐慌但無處可逃）
```

## N3_defect 修

```gdscript
"N3_defect":
    team.population = maxi(team.population - 1, 1)
    person.loyalty = 0.0
    if team.named_members.has(person.id):
        team.named_members.erase(person.id)
        person.team_id = -1
        _spawn_exile_or_join(state, person, team.tile_pos)
    elif person.id == team.leader_id:
        AnonTierSystem.kill_random(team, 1, "defect")   # tier 同步（leader 案實際走 anon）
```

`_spawn_exile_or_join`：同格有流亡 team → 加入（named_members + pop+1）；否則建 1 人流亡 team（leader = 離團者，tags=["流亡"]，仿 population_system 獨立流亡路徑）。

## P5_breed 條件

```gdscript
"P5_breed":
    var surplus_ok: bool = float(team.resources.get("food", 0)) \
        > float(team.population) * FOOD_PER_PERSON_PER_DAY * 7.0
    if not surplus_ok: return
    var cap: int = int(team.population * 0.2)
    if team.minor_population < cap:
        team.minor_population += 1
```

## Print 整治（diff-only）

- per-person reaction print：`person.last_reaction` 欄位，**變化才印**
- ReactionBridge 逃跑 print：task 真的從非逃跑 → 逃跑 才印
- 預估 log 砍 ~90%（11558 → 千以下）

## 風險

- **世界變窮**：P2 免費食物關掉 → food 經濟全靠 harvest/outpost → 可能大規模飢餓 → survival 鏈大量觸發（這是目的，但 config 初始糧 + harvest 參數需觀察，可能要 tune）
- **人口淨萎縮**：P3 刪除 + minor 不長大（user 決定不進本 spec）→ 人口只出不進。已記 known_issues / 人口結構待辦
- **work_morale 雙重影響**：morale 低 → 產出低 → 更窮 → stress 高 → morale 更低 = 死亡螺旋。clamp 0.5 下限 + lerp 平滑緩衝，仍需 multi 觀察
- **離團者組流亡 team** → team 數膨脹；但流亡 team 是 invite_settle / 掠奪目標，屬活水。觀察 team 總數
- **N1 solo 跳過後 stress 不洩壓** → solo leader stress 恆高 → N2/N3 連發；N3 leader 案走 anon → solo team 無 anon 可走 → 同樣卡。pop=1 流亡 team 永遠高壓 = 合理（流亡孤狼日子難過）
- P3 刪除影響既有測試（grep P3_recruit 的 test 要改）

## 測試

1. P2 不再加 food；work_morale 隨 P2/N4 比例升降，clamp [0.5, 1.5]
2. harvest gain 乘 work_morale（morale 0.5 vs 1.5 產出差 3×）
3. P3 已刪：grep 無 P3_recruit；reaction scores 不含 P3
4. P5 糧 < 7 天份不生；盈餘才生
5. N1 solo leader：不減 pop、不印 spam、stress 不減
6. N1 leader 案（pop>1）：pop −1 + tier 同步（sum 不變式恢復）
7. N1/N3 named 離團 → 同格流亡 team 加入 or 新建 1 人流亡 team，不 ghost
8. N5 偷錢進 person.coin，team coin + person coin 總和不變
9. Bridge：無威脅不劫持 task；有威脅 → 逃跑 + 真 move_target
10. print diff-only：同 reaction 連發只印第一次
11. multi 4 config × 90 天：survival 鏈觸發 > 0（掠奪/乞食/return_home 出現）、無 invariant violation、log 行數對比

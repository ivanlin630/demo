# 飢餓致死鏈（Famine Death）— Design

> 日期：2026-06-13
> 議題：餓死機制不存在（重寫時遺失 — known_issues U4/S5 描述的是 5 月舊 prototype）。流浪團 food=0 連續 2 年不死、PopSample 2 年全平。survival 鏈（乞食/掠奪/投靠）壓力純心理、失敗無後果。順帶：BLOOD_COMA_THRESHOLD 死碼（失血昏迷沒實裝）、blood 歸 0 不死（戰場失血流光照常活動）。

## 設計核心

- **判定團級**（糧 = 團帳）：`satisfaction < 0.3 持續 → famine_days 累積`
- **後果分層**（依資料粒度）：minor/anon = 團級統計耗損；named = 個人 `hunger` 累積 → 復用 `blood` 衰弱管道
- **餓死不是新傷害系統** — 是把既有 blood/失能/俘虜鏈接完整

## 不變量

- 飢餓判定唯一來源 = 團糧 satisfaction（個人不另算餓不餓，named 跟團吃同鍋）
- `person.hunger` 跟人走不跟團（中途加入者 hunger=0 不繼承團時鐘；饑荒團叛逃者帶著餓垮的身體入新團）
- 死亡順序：minor → anon → named（弱者先死，頭目最後倒）
- anon 餓死走 `kill_random(team, n, "famine")`（tier 同步，`sum(tiers)+named == pop` 保持）
- blood = 0 → 死（全死因通用，不限飢餓 — 修戰場失血不死的洞）

## 1. 團級：famine_days + minor/anon 耗損

`team_data.gd`：

```gdscript
var famine_days: int = 0   # 連續斷糧天數（satisfaction < 0.3）
```

`resource_system.resolve_consumption`（日邊界結算，cadence 累積換算）：

```gdscript
const FAMINE_SATISFACTION_THRESHOLD: float = 0.3
const FAMINE_GRACE_DAYS: int = 7          # 斷糧 7 天才開始死
const FAMINE_MINOR_DEATH_RATE: float = 0.10   # 每日 minor 死亡比例
const FAMINE_ANON_DEATH_RATE: float = 0.05    # 每日 anon 死亡比例

# satisfaction < 0.3 → famine_days +1（日換算）；>= 0.3 → 歸 0
# famine_days > GRACE：
#   1. minor 先死：n = ceili(minor_population × 0.10)
#   2. minor 歸 0 後 anon：n = maxi(ceili(anon_total × 0.05), 1)
#      → AnonTierSystem.kill_random(team, n, "famine")，population 同步扣
#   3. named 不在此處理（走個人 hunger，見 2）
# print "[Famine] TeamN 餓死 minor X / anon Y (famine_days=Z)" — diff/事件性，無 spam
```

人死 → 消耗降 → satisfaction 可能回升 → 自然止損（饑荒自我調節，倖存者夠吃）。

## 2. 個人級：hunger → blood 餓傷

`person_data.gd`：

```gdscript
var hunger: float = 0.0   # 個人飢餓累積 [0,1]（負面狀態，跟 stress/fear 同層）
```

`resolve_consumption` per named（含 leader）：

```gdscript
const HUNGER_GAIN_PER_DAY: float = 0.05    # satisfaction=0 時的累積率（按缺糧程度比例）
const HUNGER_RECOVER_PER_DAY: float = 0.1  # 吃飽恢復
const HUNGER_BLOOD_THRESHOLD: float = 0.7  # 開始餓傷
const HUNGER_BLOOD_DRAIN_PER_DAY: float = 5.0

if satisfaction < 0.3:
    p.hunger = minf(p.hunger + HUNGER_GAIN_PER_DAY * day_fraction
        * (0.3 - satisfaction) / 0.3, 1.0)
else:
    p.hunger = maxf(p.hunger - HUNGER_RECOVER_PER_DAY * day_fraction, 0.0)
```

`health_system.tick_natural_regen` 改：hunger ≥ 0.7 的人 **blood 不再生反流失**（HUNGER_BLOOD_DRAIN_PER_DAY × day 換算）。衰弱湧現全免費：blood 低 → `get_speed_mult` 自動慢（既有 blood_mult）。

## 3. 昏迷接線（死碼復活）

`encounter_system.is_combat_capable` 加一行：

```gdscript
# 失血/餓暈 昏迷：blood < 30 → 倒地失能（BLOOD_COMA_THRESHOLD 實裝）
var p: PersonData = state.persons.get(unit.get("person_id", -1))
if p != null and p.blood < HealthSystem.BLOOD_COMA_THRESHOLD: return false
```

→ 餓暈/失血暈的 named 戰場倒地 → 既有俘虜鏈直接吃到（看守/俘虜判定不用動）。

## 4. blood = 0 → 死亡（通用死因）

新增日邊界檢查（health_system 或 resolve_consumption 同點）：

```gdscript
# named blood 歸 0 → 死亡（餓死/失血致死通用）
# 處理同戰死：named_members.erase / leader 死 → 繼承鏈（既有 on_leader_death / 玩家 choose_heir）
# print "[Famine] PersonN 餓死" or "[Death] PersonN 失血而亡"（依 hunger 高低標死因）
```

玩家 leader 餓死 → 既有 `_handle_player_leader_death` forced event（D2 機制直接吃到）。

## 5. 文件勘誤

known_issues U4/S5 註明「描述為 5 月舊 prototype 行為，現行架構由本 spec 補實」。

## 連鎖效果（不另實作，自動湧現）

- 乞食失敗 → 真死人；圍城斷糧 → 守軍餓死；饑荒村 → 先逃難（N1）後死亡（耗損）= 難民潮敘事
- 餓暈的敵兵戰場被俘（is_combat_capable 接線）
- 饑荒倖存 named 帶 traumatic 記憶（famine 死亡可發 reaction 記憶 — 餓死同伴）
- 人口曲線終於會動：famine 死亡 vs P5 生育（W3 修好後）= 真實人口動態

## 測試

1. famine_days 累積/歸零（satisfaction 跨 0.3 邊界）
2. grace 7 天內不死人
3. minor 先死（10%/日）；minor 空後 anon 死（5%/日，kill_random tier 同步 + population 扣）
4. 人死 → 消耗降 → satisfaction 回升 → famine_days 歸零（自我調節）
5. named hunger 累積/恢復；中途加入者 hunger=0
6. hunger ≥ 0.7 → blood 流失取代再生；< 0.7 恢復再生
7. blood < 30 → is_combat_capable false（昏迷可俘）
8. blood = 0 → named 死亡 + named_members 清理；leader 死 → 繼承；玩家 → forced event
9. 守恆：famine 死亡不掉資源（人死物資留團）；coin 等值不變
10. multi 2 年：流浪團不再永生（人口耗損出現）、居民村不受影響、PopSample 曲線會動、ALL INVARIANTS PASSED

## 風險

- **開局衝擊**：現 config 多 team 開局糧緊 — grace 7 天 + 先逃難後死的順序應緩衝，但可能出現開局滅團潮，需 multi 觀察（必要時調 grace/比例）
- 死亡率 0.10/0.05、grace 7、HUNGER 參數全 TEST VALUE
- blood=0 死亡是**通用**改動 — 戰場上 bleeding 流光也會死（原本不死）→ 戰鬥致死率上升，俘虜可能變屍體（resolve_negative_flags 在戰後處理出血，順序要對：先止血結算再判死）
- N1 逃難潮 + famine 死亡同時作用 → 流浪小團可能快速消失（設計意圖，但 team 數曲線觀察）
- 玩家 team 同規則（餓死 named/leader）— 玩家有 food_critical 警告（既有 G-04），公平

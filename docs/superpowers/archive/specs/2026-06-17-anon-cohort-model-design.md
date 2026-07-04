# Anon Cohort 模型（匿名人口統一表示）— Design

> 來源：2026-06-17 Phase 2 研究。原 spec `2026-06-17-invariant-architecture-design.md` 把 wounded/population 當「個別欄位改 getter」分階段修。研究 health_system + npc_combat + AnonTierSystem 後發現：root 不是單一欄位，是 **anon 表示法本身** —— tier/health/armed 三個維度各存平行純量、各自手維護 → 每個都是 drift 點，且每加一個 anon 狀態就再生一個。
> 目標：用**單一權威 cohort 容器**取代所有平行純量，所有聚合變純投影 getter。新 anon 狀態 = 容器零重構即可擴充。此 spec **取代**舊 spec 的 Phase 2（wounded getter）+ Phase 3（population getter）。

## 問題

anon 狀態現散在 4 處平行結構（team_data.gd）：
- `anon_tiers: {tier: count}` —— 4 階（平民/新兵/老兵/菁英），base 人口
- `anon_exp: {tier: float}` —— 晉升 exp（3 階，菁英無）
- `wounded: int` —— 受傷 anon 數（**漏水累加 bug**：resolve_anon_units 每場 encounter 盲目 `+=1`，bleed+fracture 可 +2，anon 無自然恢復 → 單調膨脹，污染 npc_combat 戰力分母 `population - wounded`）
- `armed_anon_ratio: float` —— 武裝比例

tier × health × armed 是同一群人的三個正交維度，卻拆成三個獨立結構手維護 → drift class。

**對比正面**：`anon_combat_skill`/`anon_wage` 已是 computed getter（team_data.gd:95-107）投影自 anon_tiers → 不會 drift。cohort 模型把**所有** anon 聚合都變成這種投影。

## 設計：單一 cohort 容器 + 投影 getter + 單一 mutation 入口

### 資料結構（team_data.gd）

```gdscript
# 取代 anon_tiers + wounded
var anon_cohorts: Dictionary = {}   # 複合鍵 → count，稀疏（只存非零桶）
# 鍵 = "tier|health"，v1: health ∈ {healthy, wounded}
# 例: { "平民|healthy": 3, "新兵|healthy": 2, "老兵|wounded": 1 }

var anon_exp: Dictionary = { "平民":0.0, "新兵":0.0, "老兵":0.0 }   # 不變：exp 與 health 正交，維持 tier-keyed
```

**為何複合鍵 dict（非 array-of-cohorts）**：dict 鍵天生唯一 → 不可能「兩個同屬性 cohort」這種新 drift class（array 要自己防重複合併）。稀疏 = 桶數不爆（只存有人的）。維度無關 = 加維度只是鍵變長，容器與不關心該維度的 getter 零改。

**鍵編碼**：字串 `"tier|health"`，用 `AnonCohort._key(tier, health)` / `_parse(key)` 集中編解碼。字串易序列化、易 debug print。

### 維度範圍：v1 只收 {tier, health}

- **v1 折入**：`anon_tiers` + `wounded` → 一個 `anon_cohorts`。解決 wounded 膨脹 + population 雙重計數。
- **armed / morale / disease = 未來純擴充**：鍵加段 `"老兵|healthy|armed"`，容器與既有 getter 零重構（不關心 armed 的 getter 照樣 Σ 正確）。armed 現為 float ratio + 牽動 equip 子系統 → **v1 不碰**，留作後續「證明擴充零成本」。

### 單一 mutation 入口（規則 2）

新 `scripts/simulation/anon_cohort.gd`（或併入 AnonTierSystem，class 改名）。所有 anon 增減只走三入口，散落的直接 `anon_tiers[t] += / wounded +=` 全改走它：

```gdscript
add(team, tier, health, n)              # 招募/生育 → add(t, "healthy", n)
move(team, from_key, to_key, n)         # 受傷 healthy→wounded；晉升 t0→t1（保 health）；治癒 wounded→healthy
remove(team, tier, health, n) -> int    # 死亡/離隊，回實際移除數
```

`add`/`remove` 維持「桶=0 時從 dict 刪鍵」保稀疏。`move` = remove(from) + add(to) 原子包裝。

### 投影 getter（純衍生，不存欄位，物理上不可 drift）

```gdscript
total_pop(team)      = Σ values
healthy_pop(team)    = Σ where health=healthy        # combat 用這個（取代 pop - wounded - named）
wounded(team)        = Σ where health=wounded        # 取代 wounded 欄位
tier_count(team, t)  = Σ where key.tier==t（跨 health）
avg_combat_skill     = Σ count×TIER_STATS[tier].combat / total_pop
avg_speed            = Σ count×TIER_STATS[tier].speed / total_pop
total_wage           = Σ count×TIER_STATS[tier].base_wage
```

`team_data.gd` 既有 `wounded: int` 欄位 → 改 computed getter（read-only，舊 set no-op），轉發 `AnonCohort.wounded(self)`。對齊 `anon_combat_skill` 範本，所有現有 `team.wounded = / +=` 編譯即報錯 → 強迫改走 cohort 入口。

### 既有 AnonTierSystem 1:1 遷移

| 現在 | cohort 後 |
|---|---|
| `add_anon(t, n)` | `add(t, "healthy", n)` |
| `remove_anon(t, n)` | `remove(t, health, n)`（healthy 優先扣，不足再扣 wounded） |
| `kill_random(n)` | weighted over 全 cohort（含 wounded 桶） |
| `transfer_proportional` | over 全 cohort（保 health 屬性） |
| `try_promote(from→to)` | 每桶 `move(from\|h → to\|h)` 保 health |
| `total_pop` / `avg_combat_skill` / `avg_speed` / `total_wage` | 投影改 Σ 全 cohort |
| `tier_count` / `tier_breakdown` | tier 投影（跨 health 加總） |

### health/combat 增傷點改走 cohort

- `health_system.resolve_anon_units`：受傷 anon 由 `team.wounded += 1` → `move(tier|healthy → tier|wounded, 1)`，weighted 選 tier（encounter unit 屬哪 tier 需確認；無 tier 資訊則 weighted random 對齊 kill_random）。**修漏水**：anon 傷單一增源，停雙記（_apply_casualties 與 resolve_anon_units 擇一，實作時釘死）。
- `npc_combat._apply_casualties`：anon 傷 `team.wounded += 1` → `move(healthy→wounded)`。
- `interaction._treat_wounded`：救活 → `move(wounded→healthy)`；治療失敗死 → `remove(tier, "wounded")`。pop 自動減（getter），刪掉手動 `population -= died`。

### combat / population 解耦

- `npc_combat` 所有 `population - wounded - named_count` / `population - wounded` → `AnonCohort.healthy_pop(team)`（healthy anon 直接拿，語意不變，**不動平衡係數**）。
- `npc_combat` wounded ratio（:176-177）→ `wounded(team) / total_pop(team)`。
- population getter（team_data.gd，本 spec 一併做）：`(1 if leader_id != -1 else 0) + named_members.size() + AnonCohort.total_pop(self)`。**wounded anon 已在 cohort 內算一次** → 無 `+wounded` 分離項 → 舊 invariant 雙重計數消。
- `invariant_audit.gd` population 公式同步：`leader + named + AnonCohort.total_pop`（移除 `+ wounded` 項）。

### 審計網（規則 3，框架已存在）

`InvariantAudit.check` 加 cohort 自洽檢查：
- 每桶 `count >= 0`
- 鍵合法：tier ∈ TIER_ORDER，health ∈ {healthy, wounded}
- `total_pop == healthy_pop + wounded`（投影自洽 sanity，過渡期防呆）
- population getter 化後，舊 population drift 網理論恆綠（getter 不可 drift）→ 保留當回歸守門

## 階段（plan 拆 task）

1. **AnonCohort class + 容器欄位**：新 `anon_cohorts` + `_key`/`_parse` + add/move/remove/getter。team_data 加 `anon_cohorts`，`wounded` 轉 getter。**舊 `anon_tiers` 暫留**，AnonTierSystem 投影改讀 cohort（橋接）→ 跑 headless 確認綠。
2. **遷移寫入點**：所有 `anon_tiers[t] +=` / `wounded +=/-=` / `remove_anon` / `kill_random` / `transfer` / `try_promote` 改走 cohort 入口。health_system/npc_combat/interaction 增傷·治療·死亡改走 move/remove。修漏水（單一增源）。刪 `anon_tiers` 欄位。
3. **population getter + 解耦**：population 轉 getter（含 total_pop，無 +wounded）；npc_combat 改 healthy_pop；invariant_audit population 公式同步。刪散落 `population +=/-=` / `maxi(pop-1,1)` 下限鎖。
4. **審計網 + 文件**：InvariantAudit 加 cohort 自洽網；invariants.md 寫「anon 用 cohort 單一容器，聚合走投影 getter，新狀態加維度」規則。world_generator/存檔（若有）建 anon 改走 add。

每階段：headless `=== DONE ===` 無 SCRIPT ERROR、multi sanity（coin_eq delta=0、InvariantViolation 0、died/pop 合理）。

## 連動 / 風險

- **combat 平衡**：`pop - wounded - named` → `healthy_pop`。語意應等價（healthy anon = 可戰），但 named 是否算入舊式分母需逐一核（舊式 named 在 pop 內被減掉，healthy_pop 不含 named → 公式其他項要對齊）。**Task 3 逐點核，不改係數**。
- **encounter unit ↔ tier 對應**：resolve_anon_units 的 encounter unit 是否帶 tier 資訊決定受傷 move 選哪桶。實作先讀確認；無則 weighted random（對齊 kill_random 分布）。
- **序列化/存檔**：若有 save/load，`anon_tiers` → `anon_cohorts` 格式遷移（字串鍵易存）。Task 4 確認專案是否有存檔路徑。
- **效能**：getter 每讀 iterate 稀疏 dict（≤ ~8 桶）。population/healthy_pop 讀頻繁；預期無感。真有問題退快取（失 drift 根治，故先試純投影）。
- **GDScript getter 唯讀**：`wounded`/`population` 改 getter → 所有現有寫入點編譯報錯 = 強迫全改（特性非 bug，逐一處理）。
- **既有測試**：headless_test 直設 `t.wounded = N` / `t.population = N` 的 setup 會報錯 → 改成設 cohort 來源。各 Task 同步改測試 setup。

## 測試標準

- 每階段 headless `=== DONE ===`、InvariantAudit 全綠、multi sanity coin_eq delta=0 + InvariantViolation 0、died/pop 合理。
- 端到端：anon 受傷 → wounded getter +1、healthy_pop −1、total_pop 不變；anon 死 → total_pop −1、population −1（自動）；治療救活 → wounded −1 healthy +1；named 死 → population −1（自動，無雙重計數）。
- 擴充驗證（文件層，不實作）：說明加 `armed` 維度 = 鍵加段 + 一個 getter，容器與既有 getter 零改。

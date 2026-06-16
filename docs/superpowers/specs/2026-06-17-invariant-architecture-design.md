# 不變量架構收口（散亂聚合/雙向連結根治 + 通用 audit 框架）— Design

> 來源：2026-06-17 架構審計（research session）。玩家報「named 死 pop 沒減」→ 追到 population 被 44 處散改維持、無安全網 → 揭露整類「不變量靠慣例散落維持」架構債。
> 目標：**不只修個案，建立結構性規則讓這整類債未來無法再生**（使用者要 future-proof）。

## 問題（這一類債）

某些值是**權威來源的聚合/關係**，但存成可變欄位、靠多處手動 mutation 維持 → 漏改就默默 drift，無安全網直到玩家肉眼抓到。

審計確認的實例：
- **D1 population**（team_data.gd:39）：應 = `1(leader) + named_members.size() + anon_tiers 總和 + wounded`，但 **44 處** `+=/-=/=` 散在 14 檔維持。`maxi(pop-1,1)` 下限鎖**主動製造 over-count**。**無安全網**（harness `_total_pop` 只 sum 漂移欄位不重算）。已造成 bug（named 死漏減）。
- **D2 wounded**（team_data.gd:82）：應 = 「目前帶傷單位數」（可由 body_parts 衍生），卻被 health_system 每 tick `+=1` **不清零** → 單調膨脹，污染 npc_combat 戰力分母（`population - wounded`）。無網。
- **D3 雙向連結**：`team.faction_id ↔ faction.member_team_ids`、`team.parent_team_id ↔ parent.subteam_ids`，靠慣例成對維持。已知破口：`encounter_system._massacre_residents`(:1417) 滅團未走 `_on_team_extinct` → `member_team_ids` 懸空引用。

**對比正面**：`anon_combat_skill`/`anon_wage`（team_data.gd:95-107）**已是 computed getter**（無 setter，舊寫入 no-op）→ 無法 drift。`coin` 散在 24 處但有 `coin_eq` delta 審計守 → 不會默默壞。`_armed_count`/`anon_total` 是 on-demand 函數（不存欄位）→ 無 drift。**這些就是目標 pattern。**

## 設計：3 條結構規則 + 1 審計框架 + 文件化

### 規則 1：可衍生聚合 → computed getter（不存可變欄位）
任何「= f(權威來源)」的值改 computed getter（照 `anon_combat_skill` 範本），刪掉所有手動 mutation。物理上不可能 drift；未來想加人**必須**動真來源（named_members / anon_tiers），不能偷 bump 數字。

**目標（掃描確認，僅這兩個存欄位的可衍生聚合）**：
- `population` → getter：`(1 if leader_id != -1 else 0) + named_members.size() + AnonTierSystem.total_pop(self) + wounded`
- `wounded` → getter：帶傷（disabling injury）單位數，由各 named 的 body_parts + anon 受傷追蹤衍生（見下「wounded 來源」）

> 註：`armed_count`/`anon_total` 已是 on-demand 函數（非存欄位），不需改。minor_population 是獨立真值（小孩，非 population 一部分），保留。

### 規則 2：來源變更走單一入口
named_members 增減 → `TeamData.add_named(pid)` / `remove_named(pid)`（後者順帶 leader_id 清理）。anon 已有 `AnonTierSystem` 單一入口。→ 「改真人」有唯一可查入口，未來好追、好下斷點。**現有散落的 `named_members.append/erase` 全改走 helper。**

### 規則 3：雙向關係 → 單一入口維持兩側
- `WorldState.set_team_faction(team, fid)` / `clear_team_faction(team)`：一處同改 `team.faction_id` + `faction.member_team_ids`。
- `WorldState.set_subteam_parent(child, parent)` / `detach_subteam(child)`：一處同改 `child.parent_team_id` + `parent.subteam_ids`。
- 所有散落的雙邊手動更新改走入口。**`_massacre_residents` 滅團改走 `_on_team_extinct`（或入口）→ 修懸空引用。**

### 框架：通用 InvariantAudit
新 `scripts/debug/invariant_audit.gd`（或 simulation 下，harness 用）：`check(state) -> Array[String]`（回違反清單），列**所有**不變量檢查函數：
- **衍生一致性**（過渡期/防呆）：getter 化後理論不需，但保留「named/anon mutation 後 population 合理」的 sanity；主要用於**重構過程**驗證。
- **守恆**：把既有 `coin_eq` delta 檢查收進來（真存值不能衍生 → 靠 audit 守）。
- **雙向一致性**：`∀ tid ∈ faction.member_team_ids: teams[tid].faction_id == fid`（雙向）；subteam 同理。
- **範圍**：`prisoner_population <= population`、`anon_tiers 各 ≥ 0` 等既有 assert 收編。

**接入**：`game_sim_multi` 每 N tick 呼 `check` → 非空即印 `[InvariantViolation]` + 測試 fail；headless 加 `_test_invariants` 端到端。**加新不變量 = 加一個檢查函數**（extensible）。

### 文件：invariants.md
新增「資料模型不變量規則」節：
- 可衍生聚合用 computed getter，**不存可變欄位**
- 來源/雙向關係走單一入口 helper
- 真存的守恆量（coin/treasury）+ 不能衍生的不變量 → 註冊進 `InvariantAudit.check`
- 改資料模型前讀此節

---

## wounded 來源（D2 衍生公式）

現況：health_system 每 tick 對帶傷單位 `wounded += 1`（累加 bug）。改為**衍生**：
- wounded 真義 = team 中「因傷喪失戰鬥力但未死」的成員數。
- 來源：named 成員的 `body_parts` 狀態（critical/disabled）+ anon 的受傷追蹤。**需確認 anon 個體傷況怎麼存**（anon 無個體 body_parts；可能 team 級 anon 傷況欄位或比例）。實作 Phase 2 先讀 health_system 確認 anon 傷況來源，再定 getter 公式。
- 若 anon 傷況無權威來源（只有 wounded 這個累加器在記）→ 需先補 anon 傷況的真來源（team 級 `anon_wounded` 計數，受傷時 +、治療/死亡時 −），wounded getter = named 帶傷數 + anon_wounded。**這點 Phase 2 spec-in-plan 時釘死。**

## 階段（plan 拆 task）

1. **InvariantAudit 框架 + 註冊 D1/D2/D3 net**（不改行為，純加檢查）→ 跑 → **現有 drift 現形（紅燈）**，當基準。harness + headless 接入。
2. **wounded → getter**（先確認/補 anon 傷況來源 → getter 公式 → 刪 health 累加）→ D2 net 綠。
3. **population → getter**（照範本）+ **審 44 寫入點分類**：(a) 對應真來源改動（如 anon 死已有 anon_tiers 改）→ 直接刪 population mutation；(b) 裸 population 改動無對應來源（如生育 `population+=1`）→ 轉成來源改動（`add_anon`）；(c) `maxi(pop-1,1)` 下限鎖 → 刪。→ D1 net 綠。
4. **規則 2/3 單一入口**：`add_named/remove_named`、`set_team_faction`、`set_subteam_parent` + 散落改走入口 + `_massacre_residents` 修 → D3 net 綠。
5. **掃殘餘可衍生聚合**（確認無漏）+ **invariants.md 文件化**。

每階段跑 headless + multi sanity（coin_eq + 新 InvariantAudit 全綠、died/pop 合理）。

## 連動 / 風險

- **population getter 含 wounded** → 必須 Phase 2（wounded 正確）先於 Phase 3，否則 pop 衍生帶錯。
- **裸 population 改動轉來源**（Phase 3 步 b）= 最易出錯：漏轉一個 → 該情境「人沒了」（getter 算不到）。InvariantAudit Phase 1 的網 + 端到端測在此守。逐一審 44 點，每個分類註記。
- **效能**：population getter 每讀 iterate anon_tiers ~4 項；population 讀頻繁。預期無感（4 dict 查），真有問題退回「快取欄位 + 變動時 recompute」（但失去 drift 根治，故先試 getter）。
- **GDScript getter**：`var population: int: get: ...` 為唯讀 → 所有現有寫入點編譯報錯 = 強迫全刪（這是特性非 bug，逐一處理）。
- **既有測試**：依賴手動設 `team.population = N` 的 setup 測試會報錯（無 setter）→ 改成設 named/anon 來源。Phase 3 同步改測試 setup。

## 測試標準

- 每階段 headless `=== DONE ===`、新 `_test_invariants` 綠、multi sanity coin_eq delta=0 + `[InvariantViolation]` 0、died/pop 合理。
- Phase 1 預期**先紅**（現有 drift 現形）= 正確；修完各階段轉綠。
- population/wounded getter 端到端：named 死 → pop 自動 −1（不需手動）、anon 死 → pop 自動減、生育 → pop 自動 +。

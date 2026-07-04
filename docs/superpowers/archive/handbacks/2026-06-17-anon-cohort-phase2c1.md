# Hand Back: Anon Cohort Phase 2c-1（來源補全，純量保留）

## 實作摘要

5 個 type-b/雙重扣缺口全部按 plan 實作（每檔一行）：

| 檔案 | 改動 | commit |
|---|---|---|
| `subteam_system.gd` | dispatch 子隊補 `transfer_proportional(parent→sub, pop_count - named)` | 3fdb84d |
| `population_system.gd` | overflow 流亡隊補 `transfer_proportional(origin→ot, overflow_pop)` | cd44751 |
| `encounter_system.gd` | 屠村 `_force_occupy` 補 `kill_random(resident, occ_dead, "occupy")` | cf52163 |
| `health_system.gd` | `resolve_anon_units` 死亡 anon 移除純量 `population -= 1`（保 `continue`） | e4abc32 |
| `beast_system.gd` | 野獸群數 `AnonCohort.add(平民/healthy, count)`（純量並存） | 99fa189 |

所有純量寫入保留（本 phase 不轉 getter，留 2c-2）。

## 驗證

- **headless（確定性，seed 控制）**：`=== DONE ===`、`InvariantAudit population OK`、無 SCRIPT ERROR。**全 5 task 每步皆綠。** 此為專案真實回歸閘。
- **coin 守恆**：4 config `coin_eq delta=0`（含屠村/獸戰路徑）。
- **multi sanity drift**：tyrant **85 → 0**（穩定，多次量測一致）。

### ⚠️ 量測重大發現：multi sanity 是「非確定性」指標

`game_sim_multi.gd` **不設全域 RNG seed**（`world_generator` 自帶 local seed，但戰鬥/死亡走全域 `randf/randi` 未 seed）。同一 HEAD 連跑兩次：

```
run A: tyrant=54  | run B: tyrant=0   （同 commit！）
```

→ **單次 drift 數字不可作為 task 通過/回歸的判據**。我注入臨時 `seed()` 做確定性比對（已還原，未 commit），但發現第二層問題：**cohort 狀態改動會改下游決策分支 → 改變後續 randi 消耗 → butterfly**，連「無 randi」的改動（t1/t2/t4）也讓 game_sim_test（第一個 config）數字漂移。故 **per-task 確定性歸因亦不可靠**。

確定性比對（seed 20260617）唯一穩超噪音的訊號：**tyrant 85→0（t1 subteam dispatch 補搬，因果明確）**。merchant/warzone 的 ±10~15 波動落在噪音底（unseeded tyrant 曾 0↔54↔87）。

**最終 drift 未歸 0**（multi 取樣 test≈0-40 / tyrant=0 / merchant≈27-42 / warzone≈85-126）—— 與 plan「drift→0」目標有落差，原因見下。

## 與 spec / plan 差異

- 採 plan 既定 two-step（2c-1 補來源純量保留 / 2c-2 flip getter），未一次 flip。
- **plan Task 4 前提「死亡 anon 雙重扣」存疑**：隔離測試（baseline + 僅 t4）game_sim_test 維持 0、tyrant 85→75、merchant/warzone 近 baseline → t4 單獨**近中性**，非淨改善亦非明顯回歸。`resolve_anon_units` 與 encounter 1187-1196 的死亡集是否真重疊，無確定性證據佐證 plan 假設；但移除後 headless InvariantAudit 仍綠，保留 plan 實作。**建議 2c-2 釐清此路徑語意**（見下）。

## 連動風險 / 殘留 drift 來源（給 2c-2）

drift 仍 >0，主要來自 **plan 明確 defer 的 type-a + 系統性 cohort 不同步**，非本 5 task 引入：

1. **leader 晉升不釋放 anon slot（系統性，最大宗）**：`PersonGenerator.generate_for_team` 是「晉升」——設 `leader_id`/加 named，但**不減 `population`、也不從 anon cohort 移除 1**。cohort 被填滿後，凡晉升 leader 的隊就 `期望 = leader1 + anon(N) = N+1 > 純量 N`。drift 首例大量 `欄位=1 期望=2 (leader1+anon1)` 即此。baseline cohort 空時不顯，2c-1 填 cohort 後曝光。**影響所有 generate_for_team 呼叫點**（overflow / 各晉升）。
   - 連帶：**task2 overflow 隊有 +1/隊殘留**（transfer `overflow_pop` 後又 generate leader，未釋放 anon）。本可在 `_create_overflow_team` leader 晉升後補移除 1 anon，但因屬上述系統性問題、且 generate_for_team 多處共用，未在 2c-1 單點修（避免不一致 + scope creep），交 2c-2 統一處理。

2. **`kill_random` clamp**：只殺 healthy 桶，roll 卻按全 tier（含 wounded）加權（`anon_tier_system.gd:91-96` 無檢 remove 回傳）→ wounded 多時實殺 < `count`，但 encounter `population -= dead_anon` 照扣 → `欄位<期望`。影響 encounter combat（既有）+ 本 phase task3 force_occupy。

3. **type-a 點**（reaction 死亡 / unrest_split / recruit / mature / famine / npc_combat named 死）：plan 明確留 2c-2 刪純量，本 phase 未動。

- 野獸 cohort 化後：beast combat 傷亡經 cohort（kill_random/wound_random）作用於獸群，headless 驗無破；獸戰 spawn 仍讀 `team.population` 純量。

## 待主 session 確認

1. **multi sanity 加固定 seed**？目前無 seed → drift 數字不可重現、不可作回歸閘。建議 2c-2 前先 seed 化（或加「跑 N 次取分佈」），否則 cohort 工作無可靠量測。
2. **2c-2 啟動**：`population → getter`（= leader + named + cohort_total）+ 刪光純量寫入 + setup 直接 seed cohort。**flip getter 後，上述「leader 晉升不釋放 anon」「kill_random clamp」會自動使純量隨 cohort**，多數殘留 drift 應隨之消失（純量不再獨立漂移）—— 這也佐證 2c-1 補來源是對的方向，純量/cohort 雙寫期間的 mismatch 本就是過渡態。
3. **釐清 `resolve_anon_units` 死亡路徑語意**（plan Task 4 前提）：確認死亡 anon 是否真由 encounter 1187-1196 單一處理，或 resolve 路徑有獨立未補 cohort 的死亡。

# Hand Back: 代碼健康 批次3（殘留 task 常數收尾）

## 實作摘要

純去重，零行為變更（字串值不變）。完成批次2 遺留的 7 個 task 字串常數，TASK_* 成為唯一 task 名權威（模擬碼零裸 task 字串）。

### 補的常數（`scripts/data/team_data.gd`，TASK_* 區）
```gdscript
const TASK_GOVERN      := "治理"
const TASK_HOLD        := "守城"
const TASK_MIGRATE     := "遷徙"
const TASK_CONSTRUCT   := "建造"   # 注意：與既有 TASK_BUILD := "建設" 不同字串
const TASK_UPGRADE     := "升級"
const TASK_EXPAND      := "擴建"
const TASK_TRIBUTE_OFFER := "tribute_offer"   # order_task（提供納貢），非 current_task
```

### 轉換站（task 欄位 context，逐一驗證後轉）
- `scripts/simulation/faction_ai_system.gd`
  - L934 `scores[TASK_GOVERN]` + `_tag_weight(team, TASK_GOVERN)`（`_tag_weight` 第二參數即 `task: String`，與既有 TASK_MANUFACTURE/TASK_TRADE 同呼叫慣例）
  - L971 `match best_task` 的 `TASK_GOVERN:` case（best_task 來自 scores 鍵 → try_set 設 current_task）
  - L1823 `try_set(..., TASK_GOVERN, ...)`（設 current_task）
  - L200 / L2356 `current_task in [..., TASK_HOLD]` 比較
  - L2375 `try_set(..., TASK_HOLD, ...)`（uprising 設 current_task）
  - L1489 `dispatch(..., TASK_CONSTRUCT, ...)`、L1520 `TASK_UPGRADE`、L1640 `TASK_EXPAND`（`SubteamSystem.dispatch` 第5參 task → `sub.current_task = task`）
  - L280 `team.order_task = TASK_TRIBUTE_OFFER`
- `scripts/simulation/movement_system.gd`
  - L54 居民鎖 `current_task not in [..., TASK_MIGRATE, ...]`
  - L231 基建子隊 `current_task in [TASK_CONSTRUCT, TASK_UPGRADE, TASK_EXPAND]`
- `scripts/simulation/outpost_system.gd`
  - L495/499/502 `match team.current_task` 的 `TASK_CONSTRUCT/TASK_UPGRADE/TASK_EXPAND` case

### 判為非 task / 未轉者
- `scripts/simulation/faction_ai_system.gd` L1460/L1503/L1622：純說明性註解（`task="建造"` 等），文件性質，未轉。
- `scripts/debug/ui_flow_test.gd` L201：`s.contains("擴建")` 檢 UI 顯示文字（outpost 面板），非 task 欄位 → 未轉。
- `scripts/debug/headless_test.gd`：多處 `current_task == "治理"` / `order_task == "tribute_offer"` 等斷言，雖為 task 欄位比較，但**刻意保留字面值**作為常數值的獨立錨點（轉成常數會使斷言自證、失去驗證常數正確性的作用）。零行為影響。若主 session 偏好全轉，可後續一併處理（低風險）。

## 連動風險
- 無已知連動風險。`TASK_CONSTRUCT := "建造"` 與既有 `TASK_BUILD := "建設"` 為**不同**字串，已確認無誤用/碰撞。所有轉換站字串值不變，行為等價（headless 全綠 + multi coin_eq=0 + invariant=0 驗證）。

## 驗證數據
- `headless_test.gd` → `=== DONE ===`，無 `SCRIPT ERROR` / `Parse Error`。
- `game_sim_multi.gd`（4 scenario）全部：
  - game_sim_test: coin_eq delta=0.00，違反取樣=0
  - tyrant: delta=0.00，違反=0
  - merchant: delta=-0.00，違反=0
  - warzone: delta=0.00，違反=0
  - 無 `SCRIPT ERROR`。行為等價。

## 待主 session 確認 / 收尾聲明
- **TASK_* 單一源完成**：模擬碼（scripts/simulation/*）已零裸 task 字串；TeamData.TASK_* 為唯一 task 名權威。批次1（常數去重）✅、批次2（TASK_* 主體）✅、批次3（本批殘留）✅。
- **ResourceKeys / get_res 判 YAGNI 緩**：資源鍵（"food"/"material"/"coin"...）無 value-drift 風險（字面穩定、語意固定），high churn / low value，暫不抽常數層。理由與 plan 一致。
- 建議（可選）：是否將 `headless_test.gd` 斷言內的 task 字面值一併轉常數（見上「未轉者」說明）；目前刻意保留作獨立錨點。

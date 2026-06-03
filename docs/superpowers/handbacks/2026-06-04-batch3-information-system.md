# Hand Back: batch3-information-system

## 實作摘要
- `scripts/data/text_bank.gd`（新建）：靜態 TextBank，`fmt(type, variant, params)` 方法（原 plan 寫 `get`，因與 GDScript 內建衝突改為 `fmt`）
- `scripts/data/message_data.gd`：加 `params: Dictionary = {}` 欄位
- `scripts/simulation/message_system.gd`：`emit_message` 加 `params` 參數；`_copy_message` 補 params 複製；`_distort_content` 重寫用 TextBank；加 `exchange_intel_on_arrival`、`_exchange_intel`、`_distort_intel_entry`、`_decide_exchange_mode`
- `scripts/simulation/interaction_system.gd`：8 個 `emit_message` 補 params，部分改用 `TextBank.fmt` 生成 description
- `scripts/simulation/outpost_system.gd`：1 個 `emit_message` 補 params + TextBank.fmt
- `scripts/simulation/faction_ai_system.gd`：1 個 `emit_message` 補 params + TextBank.fmt
- `scripts/simulation/events/event_faction_defect.gd`：1 個 emit_message 補 params
- `scripts/simulation/events/event_unrest_replace.gd`：1 個 emit_message 補 params
- `scripts/simulation/events/event_unrest_split.gd`：1 個 emit_message 補 params
- `scripts/simulation/sim_runner.gd`：加 `_step3b_exchange_intel`，在近/遠區 `_step3` 後呼叫
- `scripts/simulation/advisor_system.gd`（新建）：AdvisorSystem，技能影響準確度 + values 影響語氣
- `scripts/simulation/inquiry_system.gd`（新建）：InquirySystem，5 種打聽選項，依關係/情境過濾
- `scripts/simulation/player_command_system.gd`：加 `gather_intel`、`confirm_gather_intel` action
- `scripts/debug/headless_test.gd`：加 AdvisorSystem 與 InquirySystem 驗證區塊

## 與 spec 的差異
- `TextBank.get()` → `TextBank.fmt()`（GDScript 內建 `Object.get()` 衝突，必要修改）
- plan 表格中「sim_runner × 3 emit_message」實際上 sim_runner 無 emit_message 呼叫，跳過（其他系統已覆蓋所有呼叫點）
- `harvest_system.gd` 有 `famine_warning` emit_message 但不在 plan 清單，維持原樣

## 連動風險
- `SimMessageSystem.emit_message` 簽名加了 `params: Dictionary = {}`（有預設值），所有舊呼叫點向下相容，無破壞
- `TextBank.fmt` 如找不到 type/variant 回傳 `"Team{origin} 有動靜"`，params 未含 `origin` 時 format 輸出含 `{origin}` 字串（UI 顯示可能奇怪，但不崩潰）
- `_exchange_intel` 每次 arrival 都執行，高密度 team 格子可能有輕微效能影響

## 待主 session 確認
- `TextBank.fmt` 命名是否保留，或 plan 中所有 `TextBank.get` 要統一改名
- `harvest_system.gd` 的 `famine_warning` emit_message 是否也要補 params（plan 未列）
- `advisor_system.gd` 的 `交涉` 技能 key 需確認 PersonData.skills 是否有此 key（目前 fallback 為 `計謀`）

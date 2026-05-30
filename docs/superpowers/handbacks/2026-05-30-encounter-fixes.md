# Hand Back: 遭遇戰修正（encounter-fixes）

## 實作摘要

- `scripts/data/team_data.gd`：加 `prisoner_population: int = 0` 欄位（在 `minor_population` 下方）
- `scripts/simulation/encounter_system.gd`：
  - 加 `ANON_UNIT_CAP = 30` 常數（TEST VALUE）
  - `resolve_encounter_end`：俘虜改存入 `prisoner_population`（上限 = winner population），不再直接加 `population`
  - `_spawn_team_units`：改為只 spawn 武裝匿名人口（`armed_anon_ratio`），加 `ANON_UNIT_CAP` 硬上限
  - `init_encounter`（非 pursuit 分支）：position 計算改與新 spawn 邏輯一致
  - `advance_round`：退役為 deprecation wrapper，呼叫 `advance_encounter_tick`
- `scripts/simulation/sim_runner.gd`：`advance_tick` encounter 分支改呼叫 `advance_encounter_tick`（移除 `round_num` 傳參）
- `scripts/debug/headless_test.gd`：
  - 舊 `advance_round` 呼叫改為 `advance_encounter_tick`（2處）
  - EncounterCombat 測試 team 加 `armed_anon_ratio = 1.0`（原為 0.0 會 spawn 0 unit 導致 assert 失敗）
  - 加 `prisoner_population` 驗證 block 及 spawn cap 觀察 print

### 與 spec 的差異

無重大差異。headless_test.gd 的 `advance_round` caller 更新及 EncounterCombat 測試修正為 spec 未覆蓋但必要的修正，屬實作合理範圍內。

---

## 連動風險

- `EquipmentSystem`：`armed_anon_ratio` 原本由 `equipment_system.update_armed_ratio()` 計算，世界生成後未立即呼叫時 ratio = 0.0。現在 spawn 直接依賴此值，**初始 ratio 為 0 的 team 在遭遇戰中只有具名成員參戰**。目前 1000 tick 模擬中世界正常運行時 EquipmentSystem 會更新 ratio，應無問題，但若有測試或場景在 ratio 尚未更新前觸發遭遇戰，結果與預期不同。
- `prisoner_population` 目前只寫入，無任何系統讀取（如: 勞動力、贖金、暴動計算）。主 session 可依設計需求決定是否後續擴充。

---

## 待主 session 確認

- **設計決策**：`prisoner_population` 上限用 `winner_team.population`。若 winner team 人口極少（如 1），俘虜上限也很低。是否改為固定上限或其他計算？
- **建議後續 task**：
  - `prisoner_population` 讀取邏輯（勞動力加成、贖金事件、暴動風險）
  - `ANON_UNIT_CAP = 30` 測試值，正式調整應配合平均 team 規模與效能測試
  - 世界生成後是否需要呼叫一次 `EquipmentSystem.update_armed_ratio` 確保初始 ratio 正確

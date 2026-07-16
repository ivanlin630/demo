---
from: blueprint
to: systems
status: consumed
topic: 觀測方向——inspect 擴充(隊全資源+據點可選詳情);用戶親提;並行 A2c-1;附 observer dump perf 限制回報
---

# 觀測 GUI inspect 擴充（藍圖 → 系統）

用戶親跑 observer GUI 提兩缺口。願景：**觀測力＝看懂世界＝判好戲的基礎**（無玩家也要能自己讀出故事）。用戶要**兩個都做、並行 A2c-1**（不同子系統，可平行派）。

## 缺口 1：隊詳情資源顯示不全
- `TeamData.resources`（team_data.gd:83）有 **20 種**（food/material/coin/goods/gem + ore×4 + weapon×6 + mounts/wagons/arrows/medicine/tools + armor×2）。
- `observer_inspect_panel.gd:82` **只露 food + coin**，其餘 18 藏著。
- **願景**：隊詳情能看到完整資源持有（至少非零項；礦/武器/馬/藥等是征服 bootstrap 與經濟的關鍵訊號）。呈現形式你自決（全列 / 非零列 / 分組）。

## 缺口 2：據點不能選/看
- `TileData` 有 outpost_type/level/owner、weaponsmith_level、garrison、resources、resource_cap——資料齊，但**無 inspect path**。
- 現況：inspect 是 teams-only（`query_all_teams`/`query_team`），map 點擊只 `team_picked`。據點沒 pick、沒 query API、沒 panel。
- **願景**：map 點據點 → 看據點詳情（類型/等級/擁有勢力/駐軍/武器坊/資源產出）。玩家能理解「這據點是誰的、產什麼、多強」。seam（tile-pick path / query_outpost API / 面板複用 or 新建）你自決。

## 邊界
- 純觀測 read-only 呈現 = 無平衡/體感風險 → **你自決 seam + 切法，不需回我 sign-off**。
- 唯一願景約束：呈現要**人看得懂**（承既有 ticker「人話」原則，非 raw dump）。

## 附：observer dump perf 限制（實測回報，順帶）
- 我跑 `--obs-ticker-dump` 判好戲時實測：**warring_states 41 隊，observer dump <12 tick/s**，3 月（21600t）撞 GODOT_TIMEOUT 1800s 跑不完（純 seeded_warring_bed 快得多）。
- observer per-tick overhead（render/ticker/inspect refresh）壓垮月級敘事落檔——**③戲感審計工具在 warring 尺度實質不可用**。
- 非本 slice 要你修，但**記一筆**：若 ③審計要能跑真產品世界月級流，observer dump 需 headless 快路徑（跳 render/UI refresh，純 sim+event 落檔）。可併入本觀測 arc 或另立。

## 流程
你 spec（兩缺口可一 slice 或拆）→ reviewer 審 → 下游做。與 A2c-1 平行，互不擋。

# Player Interaction UI Design Spec

**Date:** 2026-05-31
**Status:** Approved → Awaiting Plan

---

## 目標

將 `PlayerCommandSystem` 接入 `text_ui_main.gd`，讓玩家能透過文字 UI 實際使用互動系統。同時修正 `_accept_diplomacy` stub 使外交接受產生實際效果。

**文字 UI 定位：** debug / 原型用途，不追求視覺精緻，架構需與圖形 UI 銜接相容。

---

## 架構

### 新增狀態（`text_ui_main.gd`）

```gdscript
var _interact_mode:   bool = false
var _interact_target: int  = -1
# -1 = 目標選擇階段
# >= 0 = 已選定 pending_target，顯示行動清單
var _player_cmd: PlayerCommandSystem = PlayerCommandSystem.new()
```

### 按鍵對照

| 按鍵 | 條件 | 行為 |
|---|---|---|
| T | 一般模式 | 開啟 `_interact_mode`（關閉 `_inv_mode`/`_member_mode`） |
| T / ESC | `_interact_mode`，`_interact_target == -1` | 關閉 mode |
| ESC | `_interact_mode`，`_interact_target >= 0` | 退回目標清單（`_interact_target = -1`） |
| 1–9 | `_interact_mode`，`_interact_target == -1` | 選 forced_event 回應 或 pending_targets 目標 |
| 1–9 | `_interact_mode`，`_interact_target >= 0` | 執行行動 |

---

## 顯示設計

### event_label 區（`_interact_mode` 啟用時，取代 log/member/inv）

**階段一：目標 / 強制事件清單**

```
── 互動 ──
[!] Team2 要求同盟 [1]接受 [2]拒絕
[3] Team3 @(4,4) 獨立 pop:15
[4] Team7 @(4,4) 勢力1 pop:8
── [T/Esc]關閉 ──
```

- `forced_event` 非空 → 排第一，顯示 `[!]` 前綴及 `[1][2]` 回應選項
- `pending_targets` 接在後面，依序編號（forced_event 佔了幾個號碼就從後面接）
- 若兩者皆空 → 顯示「無可互動目標」

**階段二：行動清單（已選 pending target）**

```
── Team3 行動 ──
[1]貿易  [2]提議同盟  [3]要求納貢
[4]攻擊  [5]勒索  [6]招募  [7]忽略
── [Esc]返回 ──
```

- 行動清單由 `_player_cmd.get_available_actions(state, target_id)` 決定
- 編號對應清單索引（0-based → 顯示 1-based）

### state panel 提示（`_interact_mode` 關閉時）

`_build_state_str()` 末尾加一行，有互動待處理時才顯示：

```gdscript
var pending_n: int = state.player_pending_targets.size()
var forced_n:  int = 0 if state.player_forced_event.is_empty() else 1
if pending_n > 0 or forced_n > 0:
    var hint: String = "[T] 互動"
    if pending_n > 0: hint += ": 同格%d隊" % pending_n
    if forced_n > 0:  hint += "  ⚠強制事件"
    lines.append(hint)
```

---

## 資料流

```
WorldState.player_pending_targets / player_forced_event
        ↓ (read only)
text_ui_main._build_interact_str()   ← 純顯示，不直接寫 WorldState
        ↓ (user input → number key)
_player_cmd.respond_to_forced(state, response)   # forced_event 回應
_player_cmd.execute_action(state, target_id, action)   # pending 行動
        ↓ (PlayerCommandSystem 寫回 WorldState)
WorldState（pending 清除 / forced_event 清除）
        ↓
_refresh() 重繪
```

`text_ui_main` 不直接操作 `player_pending_targets` 或 `player_forced_event`，一律透過 `_player_cmd`。

---

## `_accept_diplomacy` 修正（`player_command_system.gd`）

原 stub 無效果，改為呼叫 `DiplomaticAiSystem._form_alliance`：

```gdscript
func _accept_diplomacy(state: WorldState, from_id: int, proposal: String) -> Dictionary:
    var from_team: TeamData = state.teams.get(from_id)
    var pt: TeamData = _get_player_team(state)
    if from_team == null or pt == null:
        return { "ok": false, "msg": "隊伍不存在" }
    match proposal:
        "alliance", "surrender":
            # 雙方皆獨立時，_form_alliance 無 else 分支，需先建立勢力
            if from_team.faction_id == -1 and pt.faction_id == -1:
                state.create_faction(from_id)   # NPC 為領袖
            _diplomatic._form_alliance(state, from_team, pt)
            return { "ok": true, "msg": "接受同盟，加入勢力%d" % from_team.faction_id }
        "tribute":
            return _pay_extortion(state, from_id)
    return { "ok": false, "msg": "未知提案類型：%s" % proposal }
```

`_form_alliance` 為 `DiplomaticAiSystem` 現有方法，GDScript 不強制 private 封裝，可直接呼叫。

---

## 修改檔案清單

| 檔案 | 動作 |
|---|---|
| `scripts/ui/text_ui_main.gd` | 加 `_interact_mode`、`_interact_target`、`_player_cmd`；T 鍵處理；`_handle_interact_mode()`；`_build_interact_str()`；state panel 提示行 |
| `scripts/simulation/player_command_system.gd` | 修 `_accept_diplomacy` stub → 呼叫 `_form_alliance` / `_pay_extortion` |
| `scripts/debug/headless_test.gd` | 加 `_accept_diplomacy` 驗證：模擬玩家接受 NPC alliance，確認 faction_id 變化 |

---

## headless_test 驗證

```gdscript
print("--- _accept_diplomacy 驗證 ---")
var cmd2 := PlayerCommandSystem.new()
# 確保 NPC team 有勢力
var npc_faction_id: int = state.create_faction(1)   # Team1 為領袖
state.player_forced_event = { "from_id": 1, "action": "diplomacy", "proposal": "alliance" }
var pt_id2: int = state.persons.get(state.player_id).team_id
var pt2: TeamData = state.teams[pt_id2]
assert(pt2.faction_id == -1, "接受前玩家無勢力")
var resp2 := cmd2.respond_to_forced(state, "accept")
assert(resp2.get("ok"), "accept 應成功")
assert(pt2.faction_id == npc_faction_id, "接受後玩家加入 NPC 勢力")
assert(state.player_forced_event.is_empty(), "forced_event 清除")
print("--- _accept_diplomacy 驗證 PASSED ---")
```

---

## 注意事項

- `forced_event` 號碼佔位：若 `forced_event` 存在且有兩個回應選項（[1][2]），`pending_targets` 從 [3] 開始。若 forced_event 為空，pending_targets 從 [1] 開始。
- `_interact_mode` 啟用時，數字鍵 1–9 由 `_handle_interact_mode()` 截取，不觸發其他按鍵邏輯。
- 行動執行後（`execute_action` 或 `respond_to_forced`）：`_interact_target = -1`（回到目標清單），呼叫 `_refresh()`。
- 圖形 UI 銜接：`PlayerCommandSystem` API 不變，圖形 UI 只需讀取同樣的 WorldState 欄位並呼叫同樣的方法。

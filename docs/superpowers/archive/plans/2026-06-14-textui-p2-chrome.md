# 文字 UI 翻新 Phase 2：chrome 重整 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** text_ui chrome 重整 — 常駐 status（含 P1 暴露的 food_days/precarity + 資源趨勢 + 成員健康）/ hint 行（當前模式可用鍵）/ last-result feedback 行（指令成敗著色）/ event LogStrip（與 panel 共存）。**只動 `scripts/ui/`，經既有 DTO，不改 sim/API。**

**Architecture:** 新 chrome Label 動態建立（仿既有 `_alert_bar`，不改 .tscn）。新顯示邏輯抽成**可測 helper**（趨勢/健康/keymap）供 `ui_logic_test` 單元覆蓋；視覺佈局靠 run-verify。資料一律取自 `_cached_snapshot`（P1 DTO）。

**Tech Stack:** Godot 4.2.2 GDScript；headless + `ui_logic_test`/`team_ui_test`；`.\tools\godot.ps1` wrapper。

依據 spec：`docs/superpowers/specs/2026-06-14-textui-overhaul-design.md`（§3 chrome 重整）。P3（全動作覆蓋+stage-1 互動渲染）後續。

現況參考（已讀）：`_ready` 動態建 `_alert_bar`（Label，插於 `_input_bar` 前）；`_refresh()` 設 `_state_label=_build_state_str()`、`_event_label=` 模式面板 **XOR** 事件 log（互斥 → 進 panel 丟事件感知）；`_log_event` append `_events`（≤100）。`controlled_team` DTO 現有 `food_days`/`starving`（P1）。

---

## 檔案結構

- `scripts/ui/text_ui_main.gd`（改）：`_ready` 建 3 新 Label（HintLine/FeedbackLine/LogStrip）；`_build_state_str` 增強；新 helper `_resource_trend`/`_member_health_line`/`_mode_keymap`/`_set_feedback`；`_refresh` 設新區。
- `scripts/debug/ui_logic_test.gd`（改）：新 helper 單元測試。

---

## Task 1: status 增強（food_days/precarity + 成員健康一行）

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`（`_build_state_str` + `_member_health_line` helper）
- Test: `scripts/debug/ui_logic_test.gd`（新 `_test_member_health_line`）

- [ ] **Step 1: 寫失敗測試**

`ui_logic_test.gd` 加（沿用該檔既有測試風格）：

```gdscript
func _test_member_health_line() -> void:
	print("--- 成員健康一行 ---")
	var members: Array = [
		{ "name": "甲", "hp_status": "正常" },
		{ "name": "乙", "hp_status": "重傷" },
		{ "name": "丙", "hp_status": "輕傷" },
	]
	var line: String = TextUiMain._member_health_line(members)   # static helper
	assert("重傷" in line and "乙" in line, "應摘要傷員，實際=%s" % line)
	# 全正常 → 簡短
	var ok_line: String = TextUiMain._member_health_line([{ "name": "甲", "hp_status": "正常" }])
	assert(ok_line != "", "非空")
	print("member health line OK")
```

注意：`_member_health_line` 設為 **static**（純函數，吃 members array），方便單元測。`TextUiMain` = text_ui_main.gd 的 class_name（若無則加 `class_name TextUiMain`）。

- [ ] **Step 2: 跑確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/ui_logic_test.gd`
Expected: FAIL — helper 未定義。

- [ ] **Step 3: 實作**

`text_ui_main.gd`（檔頂若無 class_name 加 `class_name TextUiMain`）。新 static helper：

```gdscript
# 成員健康一行摘要：有傷列傷員，全正常則簡短「全員正常」
static func _member_health_line(members: Array) -> String:
	var hurt: Array = []
	for m in members:
		var s: String = str(m.get("hp_status", "正常"))
		if s != "正常":
			hurt.append("%s(%s)" % [m.get("name", "?"), s])
	if hurt.is_empty():
		return "成員: 全員正常"
	return "成員傷: " + "、".join(hurt)
```

`_build_state_str`：玩家區塊後加 food_days/starving（取 `ct`，P1 DTO）+ 成員健康行：

```gdscript
	var food_days: float = float(ct.get("food_days", 99.0))
	var starving: bool = bool(ct.get("starving", false))
	lines.append("糧: %.1f 天%s" % [food_days, "  ⚠斷糧" if starving else ""])
	lines.append(_member_health_line(ct.get("members", [])))
```

- [ ] **Step 4: 跑確認通過** — `member health line OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/ui/text_ui_main.gd scripts/debug/ui_logic_test.gd
git commit -m "feat(ui): status 增強 food_days/starving + 成員健康一行"
```

---

## Task 2: 資源趨勢箭頭（UI 端每日基準 delta）

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`（趨勢快取 + `_resource_trend` + `_build_state_str` 資源行）
- Test: `scripts/debug/ui_logic_test.gd`（新 `_test_resource_trend`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_resource_trend() -> void:
	print("--- 資源趨勢箭頭 ---")
	assert(TextUiMain._resource_trend(100.0, 120.0) == "↑", "增→↑")
	assert(TextUiMain._resource_trend(100.0, 80.0) == "↓", "減→↓")
	assert(TextUiMain._resource_trend(100.0, 100.0) == "", "平→無")
	print("resource trend OK")
```

- [ ] **Step 2: 跑確認失敗**

- [ ] **Step 3: 實作**

static helper：
```gdscript
static func _resource_trend(baseline: float, cur: float) -> String:
	if cur > baseline + 0.5: return "↑"
	if cur < baseline - 0.5: return "↓"
	return ""
```

`text_ui_main` 加每日基準快取（member var）：
```gdscript
var _res_baseline: Dictionary = {}   # 每日基準（日邊界更新）
var _res_baseline_day: int = -1
```

`_build_state_str` 資源行（食/幣/材…）每項附趨勢：每 refresh 比 `_res_baseline`；日邊界（`_bridge.get_current_tick() / TICKS_PER_DAY` 變化）刷新基準：

```gdscript
	var day: int = _bridge.get_current_tick() / WorldState.TICKS_PER_DAY
	if day != _res_baseline_day:
		_res_baseline_day = day
		_res_baseline = res.duplicate()   # res = ct.resources
	# 各資源顯示：「食:%d%s」% [val, _resource_trend(_res_baseline.get(k,val), val)]
```

（食/幣/材 三主項附趨勢即可，免每項。）

- [ ] **Step 4: 跑確認通過** — `resource trend OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/ui/text_ui_main.gd scripts/debug/ui_logic_test.gd
git commit -m "feat(ui): 資源趨勢箭頭（每日基準 delta）"
```

---

## Task 3: hint 行（當前模式可用鍵）

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`（`_ready` 建 HintLine + `_mode_keymap` + `_refresh` 設）
- Test: `scripts/debug/ui_logic_test.gd`（新 `_test_mode_keymap`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_mode_keymap() -> void:
	print("--- 模式 keymap ---")
	var main_km: String = TextUiMain._mode_keymap("main")
	assert(main_km != "", "主模式應有鍵表")
	var interact_km: String = TextUiMain._mode_keymap("interact")
	assert(interact_km != "", "互動模式應有鍵表")
	print("mode keymap OK")
```

- [ ] **Step 2: 跑確認失敗**

- [ ] **Step 3: 實作**

static keymap 表（依現有各 `_handle_*_mode` 實際鍵；實作者讀各 handler 對齊）：
```gdscript
const MODE_KEYMAP: Dictionary = {
	"main":     "[方向]移游標 [Enter]選 [I]物品 [M]成員 [F]勢力 [O]前哨 [T]互動 [Space]推進",
	"interact": "[1-9]選目標/行動 [Esc]返回",
	"member":   "[↑↓]選員 [Tab]切頁 [Esc]返回",
	"inv":      "[↑↓]選物 [E]裝備 [Esc]返回",
	# … 各 mode 一行；實作者照 _handle_*_mode 補齊
}
static func _mode_keymap(mode: String) -> String:
	return MODE_KEYMAP.get(mode, MODE_KEYMAP["main"])
```

`_ready` 建 HintLine（仿 _alert_bar，插於 _input_bar 前）：
```gdscript
	_hint_line = Label.new(); _hint_line.name = "HintLine"
	_hint_line.modulate = Color(0.6, 0.7, 0.9)
	vbox.add_child(_hint_line); vbox.move_child(_hint_line, _input_bar.get_index())
```
（宣告 `var _hint_line: Label`。）

`_refresh` 末設當前模式 keymap（依當前 mode flag 決定 mode 字串）：
```gdscript
	_hint_line.text = _mode_keymap(_current_mode_name())
```
新 helper `_current_mode_name()` 回傳當前模式字串（依 `_interact_mode`/`_member_mode`/… flags）。

- [ ] **Step 4: 跑確認通過** — `mode keymap OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/ui/text_ui_main.gd scripts/debug/ui_logic_test.gd
git commit -m "feat(ui): hint 行（當前模式可用鍵）"
```

---

## Task 4: feedback 行（指令成敗著色，持續）

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`（`_ready` 建 FeedbackLine + `_set_feedback` + 指令結果路由）
- Test: `scripts/debug/ui_logic_test.gd`（新 `_test_feedback_format`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_feedback_format() -> void:
	print("--- feedback 格式 ---")
	assert(TextUiMain._feedback_text(true, "獵得野味 +12") .contains("獵得"), "成功訊息")
	assert(TextUiMain._feedback_color(true) != TextUiMain._feedback_color(false), "成敗異色")
	print("feedback format OK")
```

- [ ] **Step 2: 跑確認失敗**

- [ ] **Step 3: 實作**

static helpers：
```gdscript
static func _feedback_text(ok: bool, msg: String) -> String:
	return ("✓ " if ok else "✗ ") + msg
static func _feedback_color(ok: bool) -> Color:
	return Color(0.5, 0.9, 0.5) if ok else Color(0.95, 0.5, 0.5)
```

`_ready` 建 FeedbackLine（仿上，插於 HintLine 前）。宣告 `var _feedback_line: Label`。

`_set_feedback(ok, msg)`：
```gdscript
func _set_feedback(ok: bool, msg: String) -> void:
	_feedback_line.text = _feedback_text(ok, msg)
	_feedback_line.modulate = _feedback_color(ok)
```

**路由**：所有指令結果處（現走 `_log_event("[X] %s" % r.message)` 的點）加呼 `_set_feedback(r.get("ok", true), r.get("message",""))`。最小：在 `execute_action`/dispatch 結果回來的共同點呼叫（實作者找指令回傳彙集處；text_ui 的 `_bridge.command_player` 回傳 result → 在該處 `_set_feedback`）。feedback 持續到下個指令（不清）。

- [ ] **Step 4: 跑確認通過** — `feedback format OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/ui/text_ui_main.gd scripts/debug/ui_logic_test.gd
git commit -m "feat(ui): feedback 行（指令成敗著色，持續顯示）"
```

---

## Task 5: event LogStrip（與 panel 共存）

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`（`_ready` 建 LogStrip + `_refresh` 常駐填）
- Test: `scripts/debug/ui_logic_test.gd`（新 `_test_log_strip`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_log_strip() -> void:
	print("--- event LogStrip 組字 ---")
	var events: Array = [
		{"type":"ui","msg":"A"}, {"type":"ui","msg":"B"}, {"type":"ui","msg":"C"}, {"type":"ui","msg":"D"}
	]
	var s: String = TextUiMain._log_strip_text(events, 3)
	assert("D" in s and "C" in s and "B" in s, "顯最新 3 條")
	assert(not ("A" in s), "舊的 A 不顯（只 3 條）")
	print("log strip OK")
```

- [ ] **Step 2: 跑確認失敗**

- [ ] **Step 3: 實作**

static helper：
```gdscript
static func _log_strip_text(events: Array, n: int) -> String:
	var out: Array = []
	var start: int = maxi(0, events.size() - n)
	for i in range(start, events.size()):
		out.append(str(events[i].get("msg", "")))
	return " | ".join(out)
```

`_ready` 建 LogStrip（仿上）。宣告 `var _log_strip: Label`。

`_refresh`：**無論是否在 panel 模式**，常駐設 LogStrip（取代「panel XOR log」的痛點 — panel 仍佔 _event_label，但 LogStrip 永遠顯最新 N 條）：
```gdscript
	_log_strip.text = _log_strip_text(_events, 3)
```
（放在 _refresh 不受 mode 分支影響的位置。）

- [ ] **Step 4: 跑確認通過** — `log strip OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/ui/text_ui_main.gd scripts/debug/ui_logic_test.gd
git commit -m "feat(ui): event LogStrip（與 panel 共存常駐）"
```

---

## Task 6: 註冊 + 驗證

**Files:**
- Modify: `scripts/debug/ui_logic_test.gd`（`_initialize`）

- [ ] **Step 1: 註冊** 5 新測試。

- [ ] **Step 2: 全測試** — `ui_logic_test` / `team_ui_test` / `headless_test` 全綠、無新增 SCRIPT ERROR。

- [ ] **Step 3: run-verify（視覺佈局）**

`.\tools\godot.ps1`（開遊戲，TextUI.tscn）→ 確認 4 chrome 區可見：
- status 區顯 糧 X 天 + 趨勢箭頭 + 成員傷摘要
- HintLine 顯當前模式鍵表（切模式時更新）
- 進 panel（如 O 前哨）時 LogStrip 仍顯最新事件（驗共存）
- 下指令後 FeedbackLine 顯成/敗著色
（互動式,需人工或截圖確認。子 session 若無法跑 GUI,記錄「需主 session/用戶 run-verify」。）

- [ ] **Step 4: handback** — `docs/superpowers/handbacks/2026-06-14-textui-p2-chrome.md`，附 helper 測試結果 + run-verify 狀態（或標待人工驗）。

---

## 注意事項（給實作者）

- **只動 `scripts/ui/` + ui_logic_test**，經既有 DTO（P1 已暴露 food_days 等）；不改 sim/API。
- **新 Label 動態建立**（仿 `_alert_bar`），不改 .tscn。插入順序：…EventLabel → LogStrip → FeedbackLine → HintLine → AlertBar → InputBar（feedback/hint 在 input 之上）。
- **新顯示邏輯抽 static helper**（trend/health/keymap/feedback/log_strip）供 ui_logic_test 單元測；視覺靠 run-verify。
- **keymap 對齊**：MODE_KEYMAP 各行須照實際 `_handle_*_mode` 鍵；實作者讀各 handler 補正。
- **邊界**：仍只經 `_bridge`（P1 invariant），勿直存 WorldState。
- **GUI run-verify**：headless 測不到視覺；子 session 跑不了 GUI 就標「待人工 run-verify」於 handback。
- 全動作覆蓋 / stage-1 互動渲染 = P3，不在本 plan。

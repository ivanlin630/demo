---
from: blueprint
to: systems
status: consumed
slice: 玩家實跑回饋 #1（用戶 2026-09-24 第一次開遊戲）
topic: ★真機 SCRIPT ERROR：text_ui_main.gd:213 把【結果句 String】append 進 _events，而所有讀者（:704 _log_strip_text、:1032 _build_debug_str、事件區）都用 e.get("msg")⇒「Nonexistent function 'get' in base 'String'」每幀噴｜★★票5 消費點回饋那一行帶進來的（8a43ed1d8 前後），80/80 電池沒抓到＝床沒有在「消費過一道指令之後」再 render 一次｜修法形狀清楚：包成 {"type":"cmd","msg":...}；並把「消費後 render」釘進 ui-flow 床當對照
---

# 一、用戶貼的原文（真機，非床）

```
SCRIPT ERROR: Invalid call. Nonexistent function 'get' in base 'String'.
          at: TextUiMain._build_debug_str (res://scripts/ui/text_ui_main.gd:1032)
SCRIPT ERROR: Invalid call. Nonexistent function 'get' in base 'String'.
          at: TextUiMain._log_strip_text (res://scripts/ui/text_ui_main.gd:704)
```

# 二、我讀到的（file:line，不下詮釋以外的斷言）

```
text_ui_main.gd:204  _events.append_array(result.get("events", []))     ← Dictionary 元素
text_ui_main.gd:213  _events.append("%s%s" % [...ok..., String(r.get("text",""))])   ← ★String 元素
text_ui_main.gd:1209 _events.append({ "type": "ui", "msg": msg })       ← Dictionary 元素
讀者：:704 events[i].get("msg")、:1032 e.get("type")/e.get("msg") ⇒ 混型陣列一碰到 String 就炸
```

# 三、要你派的

```
①implementer：:213 包成 {"type":"cmd","msg":...}（ok=false 保留「✗ 」前綴或改 type="cmd_reject"，HOW 你定）。
②★對照：ui-flow 床加一格「入列→推進一顆 tick→再 render 一次」——今天這格不存在，所以 80/80 綠而真機炸。
  陽性對照＝把修法還原這格必紅。
③交玩步驟第 8 步（主 dir --import + --check-only）抓不到這種【執行期】型別錯 ⇒ 第 8 步要加一段「玩家入口跑 N tick 含一道指令」。
```

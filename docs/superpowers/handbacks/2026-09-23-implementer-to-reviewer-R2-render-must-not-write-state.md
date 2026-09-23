---
from: implementer
to: reviewer
status: consumed
topic: R² 票4 render 不得寫 state（feat/render-no-write，HEAD d0af8cf77）｜★★★這張【一格都還沒跑】—— systems 裁「審查看設計與判準，不吃 Godot ⇒ 別排成序列」，所以先送你｜★要你挑的是判準會不會紅，不是它現在綠不綠
---

# ★開宗明義：這張票的驗收【一格都沒跑】

```
機器空閒 FreeMB=3654 ／ TotalMB=32657，systems 的起跑門檻 ≥8 GB ⇒ 跑不了
未跑：P1／P1b／P2 三格、P3 陽性對照、P4 world-fp、ui-flow 的 42／42
★我不猜它們會綠。
```

★**而 systems 裁我不該等**：審查看的是【設計與 spec 合不合、判準能不能紅】，那件事不吃 Godot。
我原本寫「不先送一張沒跑過的」，那是**把能平行的站排成了序列**，而機器正卡著。

# 一、問題與修法

```
scripts/ui/text_ui_main.gd  原本在資源那一段：
    var day = _bridge.get_current_tick() / WorldState.TICKS_PER_DAY
    if day != _res_baseline_day:
        _res_baseline_day = day
        _res_baseline = res.duplicate()      ← ★一個 render 函式在寫 state
⇒ 同一份世界，【畫第幾次】決定箭頭 ⇒ 畫面不是唯一的
```

修法照 spec §3 的**性質**（「誰有權設它」）不是寫法：

```
新增 _update_day_baseline()，由 _process() 在 _bridge.tick_step() 之後呼叫
★世界的 tick【只在那裡走】⇒ 換日只可能發生在那一點，而那一點不在 render 路徑上
★★內容不變：換日這一刻與緊接著的 _refresh() 是同一個 tick、中間沒有狀態變化
★接不到資源時【也記日】—— 否則「接不到」會變成每 frame 重查快照的付費狀態
```

# ★★二、要你挑的三個地方

**(1) 消費點的選擇對不對。** 我放在 `_process()` 的 `tick_step()` **之後**。
★我的理由是「tick 只在那裡走」——**而我沒有獨立驗證「`tick_step()` 是唯一推進者」**，
那是我讀 code 的結論。若還有別的推進路徑（例如某個 bed 直呼 runner），我這個擁有者就漏了。

**(2) P1b 我照你上次抓的洞寫，但請你看它堵住了沒。**
```
P1  直呼 node._build_state_str() 兩次           ← ★繞過 _refresh()
P1b 直呼 node._refresh() 兩次，比 _state_label.text
```
★若「修法」是把寫入搬進 `_refresh()`（仍在 render 路徑、只換一支函式），P1 照樣綠。
**我的問題：P1b 真的會紅嗎？** `_refresh()` 裡若有人寫 state，兩次呼叫的
`_state_label.text` **仍可能相同**（因為第一次就把基準寫定了，第二次讀到同一個值）。
⇒ ★★**我懷疑 P1b 的鑑別力比 spec 想的弱**，而這正是我跑不了、需要你先用讀的判的地方。

**(3) P2 綁 `P1B_EXCLUDE.is_empty()`。** 清單已清空（原本唯一那條是「  食:」）。
★我照 spec 綁【長度】不綁名字（綁名字會隨措辭漂成恆綠或恆紅）。

# 三、機械稽核（附誠實限）

spec §3 說「`_build_state_str()` **與它呼叫的每一支**」。
★**我第一次只追了一層，漏掉 `_build_economy_lines`**（它不是被直接呼叫的）。改成遞移閉包後：

```
render 路徑 7 支：_build_state_str／_build_page_connected_lines／_build_survival_lines
                  ／_build_economy_lines／_build_unclassified_lines
                  ／_page_skylight_fields／_unclassified_mixed_note
掃兩類寫點（指派給類層級成員、變動成員容器）⇒ 0 個
★誠實限：兩層索引的巢狀寫入（a["x"]["y"] = …）這個掃法【看不到】。
```

# 四、還沒做的

```
P3 陽性對照（把基準線更新搬回 render ⇒ P1 與 P1b 都必須紅）—— ★要跑，沒跑
P4 world-fp 不變 —— 沒跑
P5 ui-flow 42／42 —— 沒跑
```

分支 `feat/render-no-write` HEAD `d0af8cf77`（疊在票3 `4bee5121d` 上）。

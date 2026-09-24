---
from: implementer
to: systems
status: consumed
topic: ★票4（render 不得寫 state）code 已落地，★★而我把它拆到【自己的分支】——原本我疊在票3 上，那會讓已 CLEAN 的票3 被未審的票4 綁住｜★★★門檻仍未達（FreeMB=3654／32657）⇒ 票4 三格＋P3 陽性對照＋P4 全部【未跑】
---

# 一、分支現況（兩條都已 push）

```
feat/query-home       4bee5121d   票3 查詢面補「家」  ← reviewer verdict=CLEAN，只欠電池
feat/render-no-write  d0af8cf77   票4 render 不得寫 state（疊在票3 上）
```

★**我原本把票4 直接疊在 `feat/query-home` 上，那是錯的** ——
票3 已經 CLEAN、只等電池，而那樣做會讓它的 merge 拖著一張**沒審過**的票。
已拆：`feat/query-home` 退回 `4bee5121d`，票4 移到自己的分支。

# 二、票4 修法（照 spec §3 的【性質】不是寫法）

```
問題：_build_state_str() 在資源那一段寫 _res_baseline / _res_baseline_day
     ⇒ 同一份世界，【畫第幾次】決定箭頭 ⇒ 畫面不是唯一的
修法：新增 _update_day_baseline()，由 _process() 在 tick_step() 之後呼叫
     ★理由＝spec 的判準「誰有權設它」：世界的 tick【只在那裡走】
       ⇒ 換日只可能發生在那一點，而那一點【不在 render 路徑上】
     ★★內容不變：換日這一刻與緊接著的 _refresh() 是同一個 tick、中間沒有狀態變化
       ⇒ 玩家看到的箭頭一樣，改的只是它【何時被決定】
     ★接不到資源時【也記日】—— 否則「接不到」會變成一個每 frame 重查快照的付費狀態
```

# ★★三、機械稽核（不是「我會小心」）

spec §3 說的是「`_build_state_str()` **與它呼叫的每一支**」⇒ 我第一次只追了**一層**，
漏掉 `_build_economy_lines`（它不是被直接呼叫的）。改成**遞移閉包**後：

```
render 路徑 7 支：_build_state_str / _build_page_connected_lines / _build_survival_lines
                  / _build_economy_lines / _build_unclassified_lines
                  / _page_skylight_fields / _unclassified_mixed_note
掃兩類寫點（指派給類層級成員、變動成員容器）⇒ ★0 個
★誠實限：兩層索引的巢狀寫入（a["x"]["y"] = …）這個掃法看不到。
```

# 四、床（三格）與豁免清單

```
P1  連呼 _build_state_str() 兩次逐字相同（★母體地板：該輪必須真的有資源行）
P1b 連呼 node._refresh() 兩次、比 _state_label.text
    ★reviewer 那個漏洞我照堵：P1 繞過 _refresh()，只把寫入【搬到姊妹函式】的話 P1 照樣綠
P2  綁 P1B_EXCLUDE.is_empty()，不綁那一條的名字（綁名字會隨措辭漂成恆綠或恆紅）
P1B_EXCLUDE 已清空 —— 唯一那條「  食:」的債還掉了
ui-flow expect 39／39 → 42／42
```

# ★★★五、未跑（我不猜它們會綠）

```
我剛量：FreeMB=3654 ／ TotalMB=32657（從 1636 回升，仍低於你的 8 GB 門檻）
未跑：票4 的 P1／P1b／P2、P3 陽性對照（把基準線更新搬回 render ⇒ P1 與 P1b 都必須紅）、
     P4 world-fp、以及票3 的 P6 與 39／39
```

順序（我認的，照你排的）：
```
①≥8GB 後先單跑 ui-flow：驗票3 的 P6／39 與票4 的三格／42
②票4 的 P3 陽性對照（單跑，注射後還原）
③全新一輪釘死 HEAD 的電池 —— 不是續跑
★期間我不碰任何閘會讀的檔（known_issues／defers／hooks／註冊表）
```

★**票4 還沒送審** —— 等它跑過我再送 R² 給 reviewer，不先送一張沒跑過的。

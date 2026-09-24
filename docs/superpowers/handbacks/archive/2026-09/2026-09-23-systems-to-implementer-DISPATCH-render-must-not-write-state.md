---
from: systems
to: implementer
status: consumed
slice: render 不得寫 state
topic: ★DISPATCH（R² 補完視為 CLEAN）：`_build_state_str()` 算畫面的同時寫 `_res_baseline*` ⇒ 非冪等 ⇒ **同一個世界、不同的呼叫順序、不同的畫面**｜★★★reviewer 抓到我原本的判準有漏洞：P1／P2 都**直呼 `_build_state_str()`、完全繞過 `_refresh()`** ⇒ 你只要把寫入【搬進 `_refresh()`】就能兩格全綠而病還在 ⇒ 已補 P1b 直接呼 `node._refresh()` 兩次｜★P2 改綁 `P1B_EXCLUDE.is_empty()`（清單清空），不綁具名字串
---

# 一、票

spec：`docs/superpowers/specs/2026-09-23-render-must-not-write-state-HOW.md`（§4 已依 R² 補完）。
★**排在票B 電池與「查詢面補『家』」之後**，不要並行改同一棵樹。

# ★★★二、這張票真正要你做的事，以及一個【看起來像修好了】的陷阱

```
病：render 路徑上算畫面的同時【寫狀態】⇒ 非冪等 ⇒ 切分頁／開關 overlay／一個 frame 多跑一次
    ⇒ 同一個世界，不同的呼叫順序，不同的畫面
★陷阱（reviewer 抓的）：把 `_res_baseline` 的寫入從 `_build_state_str()` **搬進 `_refresh()`**
  —— 它仍然在 render 路徑上，病一點都沒好，★★而 P1／P2 會【照樣綠】，因為那兩格繞過 `_refresh()`
⇒ ★★★所以 P1b 存在：**直接呼 `node._refresh()` 兩次，驗 `_state_label.text` 逐字穩定**
⇒ 通則值得你記：**判準要打在【使用者真的會走的那條路】上，不是打在我方便呼叫的那個函式上。**
```

# 三、驗收（spec §4；三格互相咬）

```
P1  連呼 `_build_state_str()` 兩次逐字相同（★母體地板：那一輪要真的有資源行，否則恆真）
P1b 連呼 `node._refresh()` 兩次，`_state_label.text` 逐字相同   ← ★堵姊妹函式
P2  票B 的 `P1B_EXCLUDE.is_empty()`（★整張清單清空）而 P1／P1b 仍綠
    ⇒ ★★綁【清單長度】不綁【那一條的名字】：票B 還沒 merge，行號措辭會漂，綁名字會漂成恆綠或恆紅
P3  陽性對照：把基準線更新【搬回 render 裡】⇒ ★P1 與 P1b 都要紅
P4  world-fp 不變（本票不改模擬）｜P5 ui-flow 綠｜P6 merge 前全電池
```

# 四、不在本票

```
✘ 改箭頭的呈現（方向／門檻／顯不顯示）—— 那是 blueprint 的格
✘ 其他 render 函式的全面稽核 —— ★若要立「所有 render 都不得寫 state」的規則，
  那是另一張票，而它要先有母體（先數有幾處）
```

★做完送 R² 給 reviewer＝demo-60，並**立刻 SendMessage 敲他**。

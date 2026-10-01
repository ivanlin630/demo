---
from: implementer
to: systems
status: consumed
slice: 第二母體（自家隊動作全列＋原因）— 階段 1／2a
topic: ★★★你要的那個數有了：【哪一桶都不是】＝ **1 個 `confirm_trade`**（只出現在 `scripts/ui/main.gd` ＝ 整棵死樹 ⇒ 從活的玩家面進不去）⇒ 這一個要拿去問藍圖｜★階段 1／2a 全綠（available_actions 17／17）｜★★而這一格的三個母體各改過一次、第二桶的判準推翻了我自己寫的誠實限
---

# 一、★★★要拿去問藍圖的那一個（這是本信唯一需要上游動作的事）

```
【哪一桶都不是】＝ ["confirm_trade"]
  ·它的 `target=="none"`、`listed==false`（宣告在 `scripts/simulation/player_command_system.gd`
    的 `ACTION_SHAPE`）
  ·而它在 `scripts/ui/` 裡**只出現在 `main.gd`**（整棵死樹 —— 那件事由
    `scripts/debug/press_is_one_tick_bed.gd` 的 `SPEC_LIVE_UI_FILES` 那一段逐字記著）
  ⇒ ★**它從活的玩家面進不去** ⇒ 是一個**真正的新呈現決定（WHAT）**
★而它不是本票弄壞的：它本來就這樣，只是今天第一次被印在卷面上。
★★本票【不動它】（它是 WHAT，而且不在本票母體裡）。
```

三桶（相加 ＝ 母體 30，床自己斷言）：
```
某一屏的活 UI code 裡有字面            27
registry 之外還有第二條派發路徑         2  （`choose_heir`／`respond_aid_request`，
                                          兩個都是 `respond_to_forced()`）
★哪一桶都不是                          1  ＝ `confirm_trade`
```

# 二、已落地（未推）

```
79a62888f  階段 1：ACTION_SHAPE（54 列）＋反向掃（P16）＋異源交叉（P17）
c41ae641d  階段 2a：`listed` 欄（裁 (甲)）＋第三條反向掃（P18）＋expect 14／14 → 17／17
實測：available_actions errors 0｜到場點名 17／17
  registry key 51（無重複）｜ACTION_SHAPE 54 列（none 41／team 12／tile 1）｜listed 11
  P16 兩個方向都空＋「豁免清單裡的每一個都真的不在 registry」
  P17 兩個差集都空（12 vs 12 逐名相同）
```
★§4b 的誠實限**已寫進 code 檔頭**（不是只寫 spec）；`listed` 的語意也寫死在那裡
（「出現在自家隊動作區那一屏」≠「能不能做」）。

# 三、★★三個母體各改過一次，三次都是【實測逼出來的】

```
①動作母體太寬：第一版 ＝ 所有 `listed==false`（43）⇒ 名單 **19 個**，
  其中 8 個是**團隊目標動作**（從互動層**查表**進去 ⇒ handler 裡沒有那個字面）
  ⇒ ★一個「看起來像大工作的數字」⇒ 收窄成 `target=="none" and not listed`（30）
②掃描母體用錯了軸：第一版只掃 `_handle_*_mode`，而 `surrender_in_encounter` 走
  `scripts/ui/encounter_view.gd` 的按鍵處理（那裡沒有那種函式名）⇒ 被誤報成「進不去」
  ⇒ ★★判準：**掃描母體用【哪些檔】不要用【哪些函式名】** ——
    函式命名慣例是一個**會有例外**的東西，而例外會變成**假的 WHAT 殘餘物**
③掃描母體含死樹：`main.gd` 算進去 ⇒ `confirm_trade` 被判成「進得去」
  ⇒ ★★★這一個的失效方向是**假陰性**：名單少一個，而少的那個**正是要問藍圖的**
```

# 四、★★★第二桶的判準推翻了我自己寫的誠實限

```
第一版判準 ＝ `scripts/simulation/` 裡有 `"action": "<id>"` 字面
⇒ `respond_aid_request` 的路徑是 `respond_to_forced()`（`player_command_system.gd:1242`）
  **直呼 handler**（`:1281` 逐字 `result = _action_respond_aid_request(state, -1, …)`）
  ⇒ 沒有那個字面 ⇒ 被誤判成「哪一桶都不是」⇒ ★誤判方向是**多報**
⇒ ★★而我原本的誠實限寫「兩桶的失效方向都是【少算】」—— **那句話對第二桶是錯的**
⇒ ★★★判準：**誠實限要【逐桶】講** —— 一句話蓋兩桶會把方向講錯，
  而方向講錯之後「這份名單是下界」這句話會被下游當前提。
⇒ 判準換成**行為形狀**：handler 在 registry 之外**還有直接呼叫點**，並**指名那支函式**。
```

# 五、兩件儀器事故（都被床接住，而其中一件值得記）

```
①加 `listed` 時我用了命名群組，`m.group(2)` 因此回**空白** ⇒ `"target"` 被寫成一串空白
  ⇒ P16 母體地板 C ＋ P17 兩條當場紅並指名
  ⇒ ★★而**只讀 `listed` 的 P18 照樣綠** —— **一格可以在資料壞掉的另一個維度上保持綠**
    ⇒ 那不是 P18 的錯（它沒被問到那件事）；它是「一條斷言只回答一個問題」的另一面
②三桶的計數用 `forced.size()` ⇒ 有 id 同時落在兩桶 ⇒ **重複計**（27＋3＋1＝31）
  ⇒「三數相加 ＝ 母體」那條地板當場紅 ⇒ 改用**分類時的計數**
```

# 六、下一步（我手上）

§3②（11 支純查詢前置檢查，回 `{ok, reason}`，handler 改呼它、全列版也呼它）
＋ §3③（迴圈，母體 ＝ `target=="none" and listed`）⇒ 然後 P2／P2b／P3／P4／P5／P6（劃掉 `defers.tsv:305`）。

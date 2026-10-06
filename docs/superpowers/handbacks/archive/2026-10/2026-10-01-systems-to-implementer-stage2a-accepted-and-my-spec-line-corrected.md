---
from: systems
to: implementer
status: consumed
slice: 第二母體（自家隊動作全列）— 階段 1／2a 收件
topic: ★階段 2a 收，三個母體訂正全收 —— 其中②是**我 spec 寫錯的那一行**，已就地訂正（劃掉留理由）｜★`confirm_trade` 已上藍圖（path 在內），你不用等它｜★★我順手抓到一處與你今天同族的假註解，請在 §3 那一輪一併處理
---

# 一、收件：階段 1／2a

```
79a62888f（階段 1）＋ c41ae641d（階段 2a）收。
實測我對過：available_actions errors 0｜到場點名 17／17｜registry 51｜
  ACTION_SHAPE 54（none 41／team 12／tile 1）｜listed 11｜P16 兩方向空＋豁免清單有主詞｜P17 兩差集空
★`listed` 語意寫進 code 檔頭（不是只寫 spec）—— 這一點我特別記一筆：
  spec 會被讀一次，檔頭會被**每一個改那支函式的人**讀到。
```

# 二、★三個母體訂正全收，而②是我寫錯的

```
②【哪些函式名】→【哪些檔】：spec §8③ 原文逐字是
  「掃 `scripts/ui/` 的 `_handle_*_mode` 函式體裡有沒有那個 action_id」—— ★那一行是我寫的。
  `surrender_in_encounter` 走 encounter_view.gd 的按鍵處理 ⇒ 照我那一行做會生出
  **一個假的 WHAT 殘餘物** ⇒ 而假的殘餘物會讓藍圖去裁一件不存在的事。
⇒ 已**就地訂正**（`docs/superpowers/specs/2026-10-01-own-team-actions-full-list-HOW.md` §8③）：
  那一行劃掉留著（`~~…~~`）＋新增一節寫兩次推翻的理由，
  落地母體指名 `scripts/debug/press_is_one_tick_bed.gd` 的 `SPEC_LIVE_UI_FILES`
  （★用已存在的那一份，不新發明一份活樹清單 —— 這是你的做法，我照抄）。
  ★並補上「**空名單也要印**」：空名單是這一格最令人安心的形狀，所以它必須有主詞。
①動作母體 43 → 30：收。★「一個看起來像大工作的數字」那句我收進判準庫
  —— 它跟「母體太窄換成太寬，而寬的壞得更安靜」是同一條。
③含死樹 ⇒ 假陰性：收，且**少的那個正是要問藍圖的那一個** ⇒ 這是本輪最貴的一次訂正。
```

# 三、★`confirm_trade` 已上藍圖，你不用等它

```
`A:/GDS/demo/docs/superpowers/handbacks/2026-10-01-systems-to-blueprint-one-what-remnant-confirm-trade.md`
★我開檔補完了它的身世（你那封只需要給我名字，這部分是我的活）：
  `_action_confirm_trade`（player_command_system.gd:611-622）有兩半，
  ②沒有 `trade_offer` 時走 `resolve_trade_direct`（interaction_system.gd:1446）
  ⇒ **那是它唯一不重複的功能**，而那支全庫**只有這一個呼叫點**。
⇒ 給藍圖的是三個選項（補一鍵／退場／登 defer），★並明寫「沒有時限、沒有東西等它」。
```

# 四、★★我順手抓到一處與你今天同族的假註解（請在 §3 那一輪一併處理，不另開票）

```
`scripts/debug/ui_flow_test.gd:860-861` 註解逐字：
  「真路徑：`_build_trade_str` → `query_trade_direct_preview` → `InteractionSystem.preview_trade`」
★而實測：`_build_trade_str`（text_ui_main.gd:2777-2790）讀的是 `query_trade_session`；
  `text_ui_main.gd` 全檔 `trade_direct` 命中數 ＝ **0**
⇒ 那句註解今天是**假的**，而它危險的點正是你今天那一條的鏡像：
  **一個註解替一條路徑作證** —— 我差點拿它當「活 UI 有讀 direct preview」的證據寫進給藍圖的信。
⇒ 請順手：①註解改成它今天真的走的路徑
  ②★確認那一格**斷言的是哪一條**：若它本來就在驗 session 那條 ⇒ 改註解就好；
    若它確實要驗 direct preview 那條 ⇒ **它現在驗的是另一件事** ⇒ 回報我，我裁。
★我不自己改：那是床，不是我 owner 的檔。
```

# 五、下一步不變

§3②（11 支純查詢前置檢查，回 `{ok, reason}`）＋ §3③（迴圈，母體 ＝ `target=="none" and listed`）
⇒ P2／P2b／P3／P4／P5／P6（劃掉 `defers.tsv:305`）。
★交件時報數字不報狀態（哪一屏幾列、原因非空幾列、數法一行）。
★`confirm_trade` 繼續不動。

# 六、你那兩條判準我收進 memory（★單寫者是我，所以寫一句讓你知道收在哪）

```
①**誠實限要【逐桶】講** —— 一句話蓋兩桶會把方向講錯，
  而方向講錯之後「這份名單是下界」會被下游當前提。（收進「斷言範圍>證據範圍」）
②**掃描母體用【哪些檔】不要用【哪些函式名】** ——
  函式命名慣例是一個會有例外的東西。（收進「守衛輸入母體沒被驗證」）
★順帶你那句「一格可以在資料壞掉的另一個維度上保持綠」我也收了
  —— 它不是 P18 的錯（它沒被問到那件事），它是「一條斷言只回答一個問題」的另一面。
```

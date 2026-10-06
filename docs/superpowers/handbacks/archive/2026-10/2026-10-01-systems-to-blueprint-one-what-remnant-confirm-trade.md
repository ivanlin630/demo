---
from: systems
to: blueprint
status: consumed
slice: 第二母體（自家隊動作全列）— 機械掃出來的 WHAT 殘餘物
topic: ★一個要你裁的呈現決定：「照預覽價直接成交」這條貿易路線要不要有玩家入口（`confirm_trade`，全庫唯一的 WHAT 殘餘物，母體與數法都印在卷面上）｜★你不用為它停下來，實作端那張票不動它
---

# 一、問題一句話

**「不自己配對、照預覽價直接成交」這條貿易路線，要不要有玩家入口？**

# 二、它是什麼（逐處 file:line，我開檔核過）

```
registry 有 `confirm_trade`                      player_command_system.gd:201
handler `_action_confirm_trade`                  :611-622 —— ★它有兩半
  ①`player_state` 裡有 `trade_offer` ⇒ 轉給 `_action_submit_trade_offer`
    ＝ **活的文字介面已經有的那一條**（自己配對出價）
  ②沒有 ⇒ `resolve_trade_direct`（interaction_system.gd:1446）
    ＝ 不配對，雙向各結算一次（`_attempt_trade_direction` ×2），coin 有變就回「貿易成功」
⇒ ★②才是它唯一【不重複】的功能
⇒ ★★而 `resolve_trade_direct` 全庫**只有這一個呼叫點**（:619）
  ⇒ 這條路線在整個產品裡**只有玩家會走**，而玩家走不到。
```

# 三、為什麼它進不去（這一段是「現況」，不是我的判斷）

```
活的文字介面：`trade` 那一列 ⇒ 進 trade 子模式（text_ui_main.gd:1764-1768）
  ⇒ 數字鍵挑 ／ [Enter] 送出 `submit_trade_offer`（:2719）／ [C] 清 ／ [Esc] ⇒ `cancel_trade`（:2705）
  ★子模式鍵表（:878）逐字 ＝ `[數字]選項 [Enter]送出 [C]清 [,.]翻頁 [Esc]離開`
    ⇒ **沒有「直接成交」那一鍵**
唯一 emit `confirm_trade` 的地方 ＝ `scripts/ui/main.gd:103-106` 的彈窗確認鈕
  ★而 main.gd ＝ **整棵死樹**（活樹清單在 `scripts/debug/press_is_one_tick_bed.gd:60`
  的 `SPEC_LIVE_UI_FILES`，main.gd 不在其中）
連帶：`get_trade_direct_preview`（player_query_api.gd:200）也**只有床在讀**，活 UI 零呼叫點
```

# 四、★它怎麼被找出來的（不是我想起來的）

```
51 支 registry 動作逐一分三桶，★三數相加必須等於母體 30（床自己斷言，相加不等就紅）：
  某一屏的活 UI code 裡有字面            27
  registry 之外還有第二條派發路徑         2（choose_heir／respond_aid_request，走 respond_to_forced）
  ★哪一桶都不是                          1  ＝ confirm_trade
⇒ 這一格**會自己長出名單**：以後任何動作掉進第三桶，卷面上就會多一個名字。
★而這個母體被實測推翻過兩次（兩次都是**假的**答案）：
  ①第一版掃【函式名】(`_handle_*_mode`) ⇒ `surrender_in_encounter` 走 encounter_view.gd
    按鍵處理 ⇒ 被誤報成「進不去」（★假的 WHAT 殘餘物，會讓你裁一件不存在的事）
  ②第一版母體含死樹 main.gd ⇒ `confirm_trade` 被判成「進得去」
    ⇒ ★失效方向是**假陰性**，而少的那個**正是這一個** ⇒ 空名單是最令人安心的形狀。
```

# 五、要你裁的三個（成本我標了，取捨是你的）

```
(甲) 補一個鍵：trade 子模式加一鍵（例如 [T] 照預覽直接成交）＋鍵表那一行加字
  ⇒ HOW 成本小：一個 emit ＋ 一列鍵表 ＋ 一格床。
  ★但它是一個**新的呈現決定**：玩家會多一條「不用自己配對」的捷徑。
(乙) 判它是舊設計殘留 ⇒ 玩家入口不補，`confirm_trade` 從 registry 退場
  ⇒ ★要連帶處理 `resolve_trade_direct` ＋ `get_trade_direct_preview`（退場後兩者**零呼叫點**）
  ⇒ ★★而「直接成交」這個機制在 **NPC 側不存在**（NPC 走 `_attempt_trade_direction`／
    `_market_peer_trade`）⇒ 刪的是**一條只有玩家能走的路線**，不是刪一個世界機制。
(丙) 先不動，登 defer（錨：等「物物交換」那一屏有人重做時一起裁）
```

★**我的 HOW 意見**：(甲)(乙) 成本都小，差別純粹在**玩家要不要有一鍵成交**（＝WHAT，你的）。
(丙) 的代價：這一格會**一直印在卷面上**（它是機械掃出來的，不會自己消失）。

# 六、★你不用為它停下來

實作端那張票**不動它**（它不在票母體裡），第二母體階段 3 繼續跑。
★這一封**沒有時限** —— 你有空再裁，我這邊不排任何東西等它。

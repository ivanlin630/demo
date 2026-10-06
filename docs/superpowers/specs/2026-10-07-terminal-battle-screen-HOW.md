# 終端戰鬥區：GUI 戰鬥畫面的文字版＋戰鬥鍵送得進去（HOW）

```
票源 ＝ 藍圖裁 `bd245fc26`（內容＝GUI 既有六欄＋單位座標列表，不新設計；鍵從既有綁定導出不手抄；試玩等它；E2E 補遭遇戰兩步）
基準樹 ＝ `fe735b100`｜試玩觸發加一條：進遭遇戰（含被伏擊）能打完也能撤出
```

## §0 現況（file:line，樹 21cc377ff 實作端核過）

```
`text_ui_main.gd:225 _enter_encounter()` 藏主畫面、顯示 `encounter_view`；`:379 _input` 戰鬥中一律 return
終端畫面＝`TextUiView.compose`（六區）——沒有戰鬥區；`PlayerRepl.press_on` 只送主節點
GUI 戰鬥的唯一按鍵分派＝`encounter_view.gd:347 _handle_key(keycode)`：
  idle：QWEASD 移動（邊界外＝離場 `_do_exit:461`）／R 進瞄準／Space 待機／F 投降／Z 命令選單／J 收編
  attack_select：↑↓ 部位／QWEASD 移游標／Enter 攻擊／Esc 取消
  戰後：J 收編／K 拿戰利品／L 留下／其他鍵離開
GUI 戰鬥的六欄＝`encounter_view.gd:22-27` 六個 Label，內容由 `_refresh_ui:104` 寫（血量／裝備／可用動作／游標資訊／兵力／戰報）
推進＝`_advance_until_player_or_end:493`（每幀一步，直到 player_turn／encounter_ended）
```

## §1 做什麼

```
①【鍵送得進去】戰鬥中（encounter_view.visible）主節點把鍵轉給 `encounter_view._handle_key(kc)` —— ★唯一分派，不另寫一份
  ⇒ 改 `text_ui_main.gd:379`：從「return」改成「轉送」；press_on 不必改（它本來就呼主節點 _input）
②【畫面】compose 在戰鬥中加一區「── 戰鬥 ──」：
  ·六欄＝直接讀 `encounter_view` 那六個 Label 的 `.text`（★同一份字串，不重算、不手抄）
  ·單位座標列表：我方／敵方每個單位一行（名、座標、血量、★下一次行動的時間 —— 藍圖：遭遇戰時間尺 1:1、單位計時要看得到；欄位名先查 encounter state）
  ·鍵提示＝`_lbl_actions.text`（GUI 顯示的那一句就是綁定的說明，從同一處讀）
  ⇒ 戰鬥中其他區照常（頂列、事件區），主畫面的動作區不顯示（那些鍵現在不歸它）
③【畫面＝結算後】press_on 的等待條件加一條：戰鬥中等到 `_waiting_for_player` 或戰鬥結束（不只 is_advancing）
④【Z 命令選單】`_open_command_menu:532` 開的是 GUI 彈出選單 ⇒ 終端看不到 ⇒ 把選單項目印進戰鬥區（編號），數字鍵轉 `_on_command_selected(id)`
  ★若這一步改動超過「印出＋轉送」⇒ 回報、Z 先標「終端未支援」（不准靜默無反應）
⑤滑鼠功能（點格、縮放）不做：終端用 QWEASD 移游標已能瞄準
⑥介面修正票 U3 的「交戰中：終端尚無戰鬥畫面」那句，本票落地時拿掉；KNOWN K4／K5 刪
```

## §2 驗收

```
P1 [E2E 主動攻擊] 走法選「攻擊」⇒ 進戰鬥 ⇒ 用畫面上印的鍵打到戰鬥結束（勝／敗／投降任一）⇒ 回到主畫面；★每一鍵回來的畫面與 state 一致（戰鬥區有、兵力數＝state）
P2 [E2E 被伏擊] 佈置敵隊靠近並觸發伏擊 ⇒ 同上；★再一條：用 QWEASD 往邊界外走 ⇒ 撤出成功（_do_exit 路）
P3 [不手抄] 戰鬥區六欄的字串 ＝ 那六個 Label 的 .text（逐字比）；鍵提示同理
P4 [按鍵三態] 戰鬥中按一個無作用的鍵（例：主畫面的數字鍵）⇒ 印一句為什麼，不靜默
P5 [計時可見] 單位列表每行有下一次行動時間，且隨推進變化
P6 [反向] 非戰鬥時戰鬥區不出現；主畫面動作照舊（既有 E2E 走法全綠）
P7 KNOWN K4／K5 刪除後 E2E 綠、已知紅數下降；已知問題清單「遭遇戰卡住」那列標已修
P8 fp 量（應不變：只動 UI）；走整份電池
```

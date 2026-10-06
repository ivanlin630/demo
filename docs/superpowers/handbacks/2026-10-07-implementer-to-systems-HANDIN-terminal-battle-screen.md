---
from: implementer
to: systems
status: open
slice: 終端戰鬥區（GUI 戰鬥畫面的文字版＋戰鬥鍵送得進去）
topic: ★**交件｜已知紅 2**（P3／打聽情報、P3／確認打聽 —— 攻擊兩條已清）｜BATTERY_RC=0｜107 綠／0 紅（run-id `45156-20261007-064825`，HEAD `19e580056`）｜branch `feat/terminal-battle-screen` 遠端 tip **`11582aee7`**｜fp 不變（量的）｜另修一個 GUI 也有的卡死（投降之後每一鍵被吞）
---

# 一、改了什麼

```
scripts/ui/player_repl.gd   press_on：戰鬥中（encounter_view 可見）⇒ 呼 encounter_view.terminal_handle_key(kc)；否則照舊主節點 _input
                            等待：推進消化完 ＋ 戰鬥畫面 settled（輪到玩家／畫面已收／戰鬥已不在推進）；等完再 _refresh
scripts/ui/text_ui_main.gd  :379 戰鬥中照舊 return（GUI 那一鍵由引擎廣播給 encounter_view）；拿掉 K5 那一句與常數
                            build_regions 加 battle／battle_keys；_process 每推一步呼 encounter_view.sync_with_world()
scripts/ui/text_ui_view.gd  compose：battle 非空 ⇒ 中間框換成「─ 戰鬥（接管畫面）」、不印主畫面動作區、頁腳鍵列＝「戰鬥｜<_lbl_actions>」
scripts/ui/encounter_view.gd
  terminal_block()：兵力／主角狀態／裝備／游標／戰報 ＝ 那幾個 Label 的 .text 逐行（不重算）
                    ＋單位列表（我方／敵方、名、座標、可戰／倒下／離場、行動倒數＝action_timer）＋命令選單項目＋最後一句訊息
  terminal_keys() ＝ _lbl_actions.text｜is_waiting_for_player()（公開查詢，不讀私有欄）｜is_settled_for_terminal()
  Z 命令選單：彈窗照開（GUI），同一份項目記下來印進戰鬥區；數字選、Esc 收；沒有隊友 ⇒ 說「沒有可下令的隊友」
  無作用鍵說為什麼（idle：「此鍵在戰鬥中無作用（可用：…）」；瞄準中：瞄準的鍵說明）
  _log 記最後一句（GUI 照舊印 stdout）
★順手修（GUI 也有）：F 投降是排入佇列的令、在世界那一 tick 裡結算 ⇒ 舊版畫面還開著、玩家單位不在
  ⇒ `_handle_key` 那一行 `if player_unit.is_empty(): return` ⇒ **之後每一鍵被靜默吞掉**
  ⇒ 現在：_process 推進時 sync_with_world() 讓畫面轉進戰後（戰果＋按任意鍵離開）；_handle_key 也同樣兜底
```

# 二、E2E（seed 1337）

```
走法 step 15 攻擊：A ＝ t tab 1 6 f space esc（畫面印「F:投降」就投降、戰後「按任意鍵離開」就 Space）⇒ 回主畫面、差異含 encounter
  ★encounter 那一欄加讀 player_hostile_teams（攻擊 handler 寫它；打完之後 encounter_active 已回 false，不讀它就分不出打過沒）
BATTLE 格：
  ①按攻擊 ⇒ 戰鬥區（世界 tick 12）｜用畫面印的鍵打到結束 ⇒ 回主畫面、交戰中 false｜回主畫面後沒有戰鬥區（P6 反向）
  ②佈置伏擊（init_encounter 敵方攻、玩家守）＋x 推進 ⇒ 戰鬥區；用鍵列裡的方向鍵往邊界外走 ⇒「離開戰場」、戰鬥結束、回主畫面
  ③六欄每一行在畫面上逐字找得到（缺 0）；鍵列 ＝ _lbl_actions（去空白比：頁腳折行會改空白數）
  ④戰鬥中按「1」⇒ 戰鬥區印「無作用」
  ⑤行動倒數印出、逐單位 ＝ state 的 action_timer
  ⑥GUI 廣播一次按鍵（主節點 _input ＋ encounter_view _input）⇒ _handle_key 被呼 1 次
  ⑦Z ⇒ 選單項目印出（或說明沒有隊友）、Esc 收起
已知紅 4 → 2（P10／攻擊、STUCK／攻擊 刪；剩打聽兩條）｜已知問題清單「遭遇戰卡住」標已修
```

# 三、負對照（獨立 worktree）

```
h1 press_on 不分流（戰鬥中也送主節點）⇒ 8 紅：走法 ABORT（回不到主畫面）、④無作用、⑦Z 選單……
h2 主節點 :379 也轉送給 _handle_key（GUI 一鍵兩次）⇒ ⑥紅（被呼 2 次）
```

# 四、★要你知道的兩件

```
①spec P5「行動倒數會隨推進變化」在這一場**看不到**：全部單位同速 ⇒ 計時同步重置，每次輪到玩家都讀到「0／1／1／1」
  （encounter_system 的單位迴圈裡玩家排第一，一到 0 就回 player_turn，其他單位那一 tick 還沒減）
  ⇒ 我把格改成「印出來、而且逐單位 ＝ state」；「會變」要等一場有不同速度的戰鬥（受傷／負重）才看得到 —— 沒有硬造
②戰鬥區的主角狀態是 GUI Label 的原文 ⇒ 部位與狀態是英文（head: healthy、weapon_melee_low）
  ⇒ 照 spec「同一份字串、不重算」沒翻；玩家面的英文識別字是另一條規矩（終端自驗 (d) 只掃非戰鬥走法）⇒ 要不要翻、翻在哪一層，給你判
```

# 五、fp

```
本輪 world-fp ✓、world-fp-ctrl ✓ ⇒ 基準不動（只動 UI：送鍵分流、畫面區塊、戰鬥畫面跟上世界）
```

# 六、新列

```
沒有新列；terminal-e2e 的 expect 改成「=== terminal_e2e DONE === errors: 0｜已知紅排除: 2（P3／打聽情報、P3／確認打聽）」（從輸出抄）
```

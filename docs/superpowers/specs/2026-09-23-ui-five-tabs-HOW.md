# HOW spec：UI 五分頁 —— 票A（框）／票B（餵）

owner: systems ｜ 2026-09-23 ｜ **player_reachable: yes**
上游：blueprint `2026-09-23-...-freeze-line-exit-P7-retired-close-two-tickets-open-ui.md`（開票）
　　＋ `2026-09-23-...-launch-line-relayed-ui-split-approved.md`（切法收、驗收方向）
世代：8（`92349afb6` 之後）

---

## ★★★§0 前提盤點（★本節全部是 file:line，不是回憶）

### §0-1 玩家真的在玩的是哪一棵 UI 樹

```
project.godot:14   run/main_scene="res://scenes/TextUI.tscn"
⇒ ★我給用戶的那一行啟動指令打開的就是 TextUI ⇒ ★★五分頁必須長在這裡
   scripts/ui/text_ui_main.gd   2018 行（最後動 2026-08-27）＝ 玩家 UI 的全部
```

### §0-2 ★★★另外兩棵樹，以及一棵死的

```
ObserverMain.tscn / observer_main.gd（261 行，最後動 2026-07-09）
  ＝ 截圖 harness（`--obs-seed/--obs-shots/--obs-out`）的家
  ★observer_main.gd:2 自己寫著：「玩家路徑零 diff：main scene 不換」
  ⇒ ★★它【不是】玩家看到的畫面 —— 它是觀測 GUI

Main.tscn ＋ main.gd（205 行）＋ right_sidebar.gd（132 行）
  ＋ WorldMapView／TurnControls／BottomBar／PopupLayer／EncounterView／DebugBar 六個子場景
  ⇒ ★★★【死碼】：全庫 grep `Main\.tscn` 只命中 observer_main.gd:2 的一句註解
     （而那句講的是 ObserverMain），最後動 2026-05-31／06-04
```

★**訂正我自己**：我在 `2026-09-23-systems-to-blueprint-the-launch-line-...` 裡寫
「`right_sidebar.gd` 132 行、grep 分頁零命中 ⇒ 今天沒有分頁」。
**那句話字面為真但會誤導** —— 它不只是沒有分頁，**它根本不在玩家路徑上**。
★★**若照那句話派工，實作端會把五分頁蓋在死碼上，而它會【全綠】**
（沒有任何測試載入 `Main.tscn`）⇒ **用戶打開遊戲什麼都看不到**。
★★★**這正是「檢查管道 ≠ 失效管道」那一族**：分頁做對了、測試綠了、玩家看不到。

### §0-3 ★★分頁名單今天有【兩份】，而它們不一樣

```
(甲) docs/notes/2026-09-08-player-surface-and-agent-selfcheck.md:71
       團│據點│人│核心│事件          ← 副藍圖總案，也是 mechanism-intents.md:42 記的那份
(乙) scripts/debug/c1_walkthrough.gd:17
       const PAGE_ORDER := ["生存", "經濟", "威脅", "社交", "記憶"]
     來源＝blueprint 2026-09-10 裁定「頁＝該欄回答的問題」（archive/2026-09-10-...paging-method-and-117-phased.md）
```

★**(乙) 較新且已被實作**（走查 v2 印的就是這五頁）⇒ **本 spec 採 (乙)**。
★★**而 `mechanism-intents.md:42` 還寫著 (甲) ⇒ 它 stale**，已另信請 blueprint 訂正（意圖帳是 WHAT 權威，不是我的格）。
★★★**HOW 上我不賭哪一份會贏**：見 §2-1 —— 名單是**一個常數**，而且**與走查共用同一份**。

### §0-4 分頁語意**尚未被用戶簽**（★這改變票A 的形狀）

```
progress.md:1378 「C1 票② 走查 … ★它是【分頁暫定】與【看不看得懂】兩件事的批准閘」
blueprint 2026-09-22：walkthrough-v2 分支 keep，門票＝用戶完成「找出植入的錯」
⇒ ★★★所以票A 不得把五個頁名寫死在十幾處 —— 簽核回來時改名／改序必須是【一行】
```

---

## §1 票A／票B 的界線（blueprint 已收）

```
票A ＝ 五分頁的【框】：切得過去、每頁有標題、沒接的格子印【具名天窗】
票B ＝ 把欄位【餵進去】：走查印得出來的值，搬到對應分頁
★合成一張時，一個空格子有兩種解釋（框沒做好／沒接出）⇒ 紅燈沒有語意
```

---

## §2 票A：HOW

### ★★§2-1 名單是一個常數，且**與走查共用同一份**

```gdscript
# scripts/ui/ui_pages.gd（新檔，class_name UiPages）
class_name UiPages
const PAGE_ORDER: Array = ["生存", "經濟", "威脅", "社交", "記憶"]
```

```
★c1_walkthrough.gd:17 改成讀 UiPages.PAGE_ORDER（刪掉它自己那份）
⇒ ★★【結構保證】走查與畫面不可能是兩套五分頁
   —— 而那正是 §0-3 今天已經發生過一次的事（notes 一份、床一份）
★★★禁止：在 text_ui_main.gd 裡另寫一份頁名陣列，或把頁名寫進字串字面值
```

### ★★★§2-2 分頁狀態是【一個 enum】，不是第 12 個 bool

```
text_ui_main.gd 今天有 11 個互斥的模式旗標：
  _member_mode／_inv_mode／_interact_mode／_faction_mode／_outpost_mode／_subteam_mode
  ／_advisor_mode／_storage_mode／_intel_mode／_recruit_mode／_trade_mode／_pre_encounter_mode
  而 _current_mode_name()（:640-654）是一串 if 排序決定誰贏
⇒ ★分頁若做成第 12 個 bool，它會進那串 if，而【它不該互斥】
```

```
★★分頁與模式是【兩個軸】：
   模式 ＝ 疊在上面的 overlay（成員／物品／互動…），一次一個
   分頁 ＝ 右欄【常駐】的內容選擇，永遠有一個是選中的
⇒ 狀態：var _page_idx: int = 0   （0..UiPages.PAGE_ORDER.size()-1）
⇒ ★★★它【不進】_current_mode_name()，也【不加】MODE_KEYMAP 的第 13 列
```

### §2-3 分頁長在哪、怎麼切

```
位置：TextUI.tscn 的 StateLabel 欄（右欄，custom_minimum_size 220）
      ＝ text_ui_main.gd:667 `_build_state_str()` 的產物
切鍵：[<] [>]（或 [Tab]）循環 —— ★進 MODE_KEYMAP["main"] 的提示字串
      ★★在【任何 overlay 開著時】切鍵不吃（overlay 的鍵優先）⇒ 與 §2-2 的兩軸一致
頁首：每頁第一行 `── 生存 (2/5) ──` ⇒ ★★★「我現在在第幾頁」必須在畫面上，
      否則用戶按了鍵卻不確定有沒有切過去（而他會以為是壞的）
```

### ★§2-4 常駐狀態列不隨分頁換（票② §1 的四件事）

```
附身對象名／位置（格＋據點）／current_task（＋intent 摘要）／世界時間＋速度檔
⇒ ★這四件【在分頁上方，不屬於任何一頁】—— 放進某一頁＝每次要翻
★★它們今天已經有：_build_state_str() 前三行 ＋ DebugBar ⇒ 本票是【搬位置】不是【新接資料】
```

### §2-5 天窗

```
每一頁的每一個【預定但未接】的欄位，印：
  「<欄位名>：未接出（票B）」
★不得靜默略過 —— 沉默的空白會被讀成「這個世界沒有這個東西」（票② §2 硬規②，逐字沿用）
★★票A 交付時【絕大多數格子是天窗】，這是預期，不是缺陷
```

---

## §3 票B：HOW

```
①母體 ＝ 走查腳本今天印得出來的欄位（c1_walkthrough.gd:113 _ctx_fields ／:121 _page_map）
   ★★不是「119 欄」——那個數字是名字比對的產物（progress.md 2026-09-10 逐字警告）
②每一欄的讀點必須走【公開查詢面】（PlayerQueryApi／SimBridge 快照），
   ★不得直接讀 state，★★不得是常數／占位字串（blueprint 驗收方向 B，逐字）
③接上一欄 ⇒ 該欄的天窗消失；★沒接上的仍然印天窗（不許先拿掉天窗再說）
```

---

## ★★★§4 驗收（★儀器我改了，理由在 §4-0）

### §4-0 blueprint 指定「截圖 harness（ObserverMain --obs-*）」，而它**指向另一棵樹**

```
★截圖 harness 在 observer_main.gd ⇒ 它畫的是 ObserverMain，【不是 TextUI】
⇒ ★★拿它截五個分頁，截出來的畫面裡【沒有分頁】—— 而它會是綠的（它只是存了一張圖）
★★★而 TextUI 已經有一支【比截圖強】的儀器，且已在註冊表上：
   merge-gates.tsv:93  ui-flow
     powershell … --script scripts/debug/ui_flow_test.gd
     expect: `=== UI Flow Test DONE === errors: 0｜到場點名 26／26`
     它 load("res://scenes/TextUI.tscn").instantiate() ＋ 驅真鍵盤 handler ＋ 斷言 label 字串
```

★**所以本票的判準走 `ui-flow`，不走截圖**，而我把 blueprint 的兩格逐條翻譯：

| blueprint 的 WHAT | 本 spec 的機器判準 |
|---|---|
| A：五個分頁各一張截圖 | 逐頁斷言 `_build_state_str()` 含 `── <頁名> (i/5) ──`，★頁名來自 `UiPages.PAGE_ORDER` 不是字面值 |
| A：鍵盤切換可達 | 從第 1 頁連按切鍵 5 次 ⇒ 回到第 1 頁；★★每一步的頁首都對 |
| B：每欄有真世界來源 | ★★★**成對對照**：把某一欄從查詢面拿掉 ⇒ 畫面那一格必須變天窗（票② §4④ 同形） |
| B：世界變了畫面跟著變 | 同種子推進 N tick ⇒ `_build_state_str()` 的字串 **diff 非空**（★文字 diff，不是像素） |

★★**為什麼文字 diff 比截圖 diff 好**：截圖 diff 非空**也可能是時鐘走了一秒**，
而它**說不出是哪一格變了**；文字 diff 印得出哪一行變了。
★★★**但我不把截圖丟掉**：留一格 `--obs-*` 冒煙（見 P5），職責改成
**「畫面真的畫得出來、不是全黑／不是崩」**，而**不是**「內容對」。

### 驗收格（票A）

```
P1 [框] ui-flow：五個頁名都印得出來，且頁首帶 (i/5)
P2 [鍵] ui-flow：切鍵循環 5 次回原頁；★overlay 開著時切鍵不吃（開 _member_mode 再按切鍵 ⇒ 頁不變）
P3 [單一來源] ★grep 斷言：text_ui_main.gd 裡【沒有】頁名字面值；c1_walkthrough.gd 不再自帶 PAGE_ORDER
P4 [天窗] ui-flow：未接欄位印「未接出（票B）」；★任一頁【全空白】＝紅
P5 [畫得出來] ObserverMain 截圖冒煙照舊綠（★證明本票沒有弄壞另一棵樹）
P6 [fp] world-fp 不變 —— ★★本票只讀不寫；★★★fp 若動了，那不是 UI 票，是有人碰了模擬
P7 [電池] merge 前全部 merge-gates（`bash .claude/hooks/merge-gates.sh`）
```

### 驗收格（票B，接在票A 之後）

```
Q1 [來源] 逐欄 grep 讀點 ⇒ 指向 PlayerQueryApi／SimBridge 快照；★常數／占位＝紅
Q2 [成對對照] 拿掉一欄的查詢面 ⇒ 那一格變天窗（★不是整頁壞掉）
Q3 [會動] 同種子兩個 tick 的 _build_state_str() diff 非空，★並印出【哪一行】變了
Q4 [天窗遞減] 票B 每批之後，天窗清單【變短】且【印出來】——★★母體是票A 畫面上長出來的那張清單，不是我們列的
Q5 [fp] 不變（同 P6）
```

---

## §5 ★不在本票

```
✘ 換 main_scene（TextUI 仍是玩家路徑）
✘ 把 Main.tscn 那棵死樹刪掉或復活 ⇒ ★另開一張清理票，本票【不碰】
   （理由：刪除是不可逆的、而且它與本票的失敗模式無關；混在一起時紅燈分不開）
✘ ObserverMain 加分頁
✘ 「UI 讀路徑零直讀 live state」那格 —— blueprint 2026-09-23 裁：不做
   （分片死了，理由跟著消失；只留「畫面呈現上一顆完整 tick」語意，現行若已是幀末讀取就不動）
✘ 117 欄的接出總量（那是既有的分批票，票B 只搬【走查已經印得出來的】）
```

## §6 ★★誠實限

```
①本 spec 全程【沒有跑 Godot】（機器在 implementer 手上）⇒ 所有斷言都是靜態 file:line
   ★★沒有驗過的：TextUI 真的畫得出來、切鍵不與現有鍵衝突
   （★MODE_KEYMAP["main"] 已佔用 WASD/Enter/M/Space/G/I/P/F/O/K/U/V/T/Q
     ⇒ 切鍵選 [<][>] 或 [Tab] 是【看表挑的】，實作端請在第一次跑起來時確認）
②分頁名單未經用戶簽（§0-4）⇒ 票A 的價值【不依賴名單正確】：框對了，改名是一行
③「Main.tscn 是死碼」＝ grep 零引用；★它不能排除「某個人手動在編輯器裡開它」
```

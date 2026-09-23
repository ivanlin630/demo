---
from: reviewer
to: systems
status: open
slice: 三支恆真格修法 — R②裁定
topic: verdict=CLEAN,可merge｜Q1母體地板夠不夠:核過兩支修法用【不同預設值】(測試端-1 vs production端0/預設)當防撞——combat_power單獨缺席/controlled_team整個空,都會因預設值不同而讓數值比較本身就會紅,不靠母體地板單獨扛;你舉的(a)「兩邊都壞成同一個數」場景實際上out of scope(算錯值不是這張票的守備範圍,兩邊本來就讀同一份cached_snapshot,不是獨立量測,這張票守的是「畫面有沒有正確轉錄」不是「算法對不對」)｜Q2 player_status_label窄化沒有製造新空真:_line_with找不到回""+substr在空字串上安全不炸,"找得到那一行"與"冒號後有內容"各自獨立守住line缺席與line存在但空內容兩種情況｜零production改動、31/31核過、注射殘留grep=0核過
---

# 一、Q1：母體地板夠不夠——核過，夠，而且防線不只母體地板一層

```
你問的兩種「兩邊都壞」走法，逐一核：

(a) 查詢面回了 capabilities 但 combat_power 缺席（而非整個 dict 空）：
  scripts/ui/text_ui_main.gd:688  cap.get("combat_power", 0.0)   ← production 預設 0
  ui_flow_test.gd(新)            cap.get("combat_power", -1.0)   ← 測試端預設 -1
  ⇒ combat_power 缺席時：畫面印「戰力 0」，測試 want_cp 讀到 -1 ⇒ 0 != -1 ⇒ 直接紅
  ⇒ ★這不是靠母體地板擋，是靠【兩邊預設值刻意不同】擋——這條防線比你問的問題更早生效

  armed_count 同構：
  scripts/ui/text_ui_main.gd:680  ct.get("armed_count", 0)        ← production 預設 0
  ui_flow_test.gd(新)            ct.get("armed_count", -1)        ← 測試端預設 -1
  ⇒ 同一招，同樣在缺席時直接讓值比較本身變紅，不必等母體地板

(b) 畫面印了欄位名卻印錯數字而查詢面剛好壞成同一個數：
  ★這個場景我核過資料流：node._cached_snapshot 是【同一份】—— _build_state_str() 讀的
  ct/cap 跟測試讀的 node._cached_snapshot.get("controlled_team")...get("capabilities") 是
  同一個物件，不是兩條獨立管線。
  ⇒ 若 _team_capabilities() 本身算出一個錯的 combat_power（值錯但欄位在），畫面跟測試會
    讀到【同一個錯值】，比對永遠相等 —— ★但這不是這張票的守備範圍：這張票要抓的是
    「畫面有沒有正確轉錄已經算好的值」（P1-a／恆真格那條線），不是「_team_capabilities()
    算得對不對」（那是查詢面自己的正確性，屬於另一層測試）。
  ⇒ ★兩層測試混在一起會讓這一格背負它不該背的責任，我認為現在的切法對，不是漏洞。
```

```
controlled_team 整個空（ct.is_empty()）的情況：
  ★單獨核過：_build_state_str():671 if ct.is_empty(): return "（無玩家 team）"，整段跳過，
  "武裝: "不會出現在 s 裡 ⇒ got_armed 走 _kv_int 的 not-found 分支 = -1；
  而測試的 want_armed = ct.get("armed_count", -1) 在 ct 空的情況下同樣落到預設 -1
  ⇒ 值比較本身在這個特例會「巧合相等」（-1==-1）——
  ★★但這格已經被你加的母體地板單獨擋住：_check("查詢面有 controlled_team（★母體地板...)")
  在 ct.is_empty() 時直接紅，不依賴後面的值比較 ⇒ 這個特例確實【需要】母體地板，
  而它也確實【有】接住，是唯一真正依賴母體地板單獨防守的情況，其餘都有預設值當第二道防線。
```

⇒ **結論：母體地板 + 欄位名 + 刻意不同的預設值，三層一起看是夠的**，
沒有找到能同時繞過全部三層的第三種走法。

# ★★二、Q2：player_status_label 窄化沒有製造新空真

```
_line_with(text, key)：找不到含 key 的行 ⇒ 回 ""（明文標「空字串＝沒有那一行」）
line == "" 時：
  ①"找得到狀態列那一行"（line != ""）⇒ 直接紅
  ②line.find("狀態: ") 對空字串回 -1 ⇒ body = line.substr(-1+4) = line.substr(3)
    ★String.substr 在起點超出空字串長度時安全回傳 ""（不炸、不越界）
  ③"狀態列冒號後有內容"（body != ""）⇒ 空字串 != "" 為假 ⇒ 也紅
⇒ line 缺席時①②兩個判準各自獨立為真地報紅，不是共用同一個判準假裝守了兩件事，
  也沒有出現「line 缺席但因為某個中間值巧合非空而唯一的判準卻是綠」的情況。
line 存在但冒號後恰好無內容（例如格式被改成「狀態:」沒有空格接內容）：
  ①綠（找到那一行）②body 算出來是空字串 ⇒ 紅 ⇒ 正確標出「行在，內容空」這個更細的失效模式
```

⇒ 沒有反方向恆真（不是「什麼都沒有也算對」），窄化修法正確。

# 三、範圍與其餘核過

```
git diff --stat main...origin/feat/tautology-cells：只 scripts/debug/ui_flow_test.gd 一檔 —— 核過
grep ARMEDGONE / POSCTRL 於 origin/feat/tautology-cells 上：零命中 —— 注射殘留已清乾淨，核過
到場點名 31/31（EXPECTED_CELLS 陣列長度不變）——核過，是改判準不是加/減 cell
```

# 四、verdict

```
CLEAN。可 merge（併前跑全電池，同意這個順序）。
沒有找到新的恆真或空真，母體地板＋預設值防線經得起你點名的兩種繞法。
```

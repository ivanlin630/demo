---
from: reviewer
to: systems
status: open
slice: 票 A 第一階段（普查床）＋票 B §4（併入 tap，第二階段）
topic: R② ＝ **ISSUES，兩列**（`6718af005`）｜★★B2（下游有沒有換掉 scored[0]）我查到了，不是先查是已核：`faction_ai_system.gd` 的 `for e in ranked:` 迴圈對 delegate／收留／自救建田／無目標 都有「派失敗→continue 試次佳」的真實 code（:3779 delegate 分支逐字），Team11 的 16 筆**更可能是 rank.override（票A territory）不是 rank.flip**｜★A 的窗口規矩本身對，但沒接住一個從藍圖信裡就能算出來的事實：C1 的首例在 day 0.7-0.75、C2/C3 的首例在 day ~20/~22 ⇒ 任何短於 ~22 天的窗，C2/C3 **結構上**分母＝0，不是運氣｜B1 的 flipped_by「既有四欄」漏了兩層（SURVIVAL_BOOST／THREAT_BOOST，零_cmp記錄）
---

# 0 審了哪棵樹

`origin/main` ＝ `1284c5836`（含你這封信與派工）；spec sha `6718af005` 是它的祖先，兩顆都在遠端。

# 1 ★B2（你說請優先打的）—— 不是先查，我找到真實機制了

## 證據：`for e in ranked:` 迴圈本身就是「試下一個」的執行層（`faction_ai_system.gd:3714 起`）

```
3714  for e in ranked:
3715    var opt: String = e["opt"]
...
3732  if opt == "自救建田":
3733    if _ensure_rescue_build_started(...): ...; return
3738    continue   # 起建失敗（料被消耗/slot滿）→ 試次佳
...
3747  if opt == "收留":
3752    if _seek == null or ...: continue   # 對象走了/已登記 ⇒ 不可派，試次佳
...
3776  if td.get("delegate", false):          ★★★這就是 Team11 的 16 筆（*:location:delegate）
3777    if _dispatch_goal_delegate(state, team, td):
3778      team.current_option = String(e["opt"]); return
3780    continue   # 派失敗→試次佳
...
3786  if tgt == Vector2i(-1,-1) and td["task"] != TASK_FLEE:
3788    continue   # to_task 回 (-1,-1)＝找不到可徵的對象 → 不可派,試次佳
```

```
_dispatch_goal_delegate（:5703）依 td 內容分叉成 _dispatch_builder／_dispatch_facility_builder／
  _dispatch_convoy，每支都回 bool；:5720 自己的註解「afford/pop/advisor gate」
⇒ ★★這是一個會真的回 false 的函式，不是裝飾性的 if
```

## 判決

```
★★★這條鏈完全符合你 §4 自己寫的那句假設：「delegate 選項排第一、卻派不出人⇒換成別的」
  ——而它不是假設，是看得到、追得到的 code：reorder_same_need_first 之後、dispatch 迴圈裡，
  delegate 失敗就 continue，下一個候選（同需求層優先，因為 reorder 已經把同層排前面）變成
  team.current_option，也就是 QA 讀到的那個 winner（駐守）
⇒ ★你那段「我讀 code 得到的關鍵區分」判斷方向完全對（B 要先分辨 flip vs override），
  而現在有了機制名字：**override 的執行點 ＝ `:3776-3780` 的 delegate 分支**
⇒ ★★★Team11 16 筆**更可能落在 override**（票A territory：列的條件要等於做的條件）：
  如果 *:location:delegate 排第一卻沒有閒人可派，那不是「合成層把排序蓋過了」（flip），
  是「候選清單列了一個做不到的選項」（override／ineligible）
  —— 但我沒讀 specimen 逐筆驗證，這是**強烈的候選假設**，不是定論；B1/B2 還是要照寫好的
  去真的記錄，不要因為這條證據就跳過量，兩種都要能被記下來（PB2 的母體地板仍然成立）
```

## 建議落地

```
把 §4 的 B2「先查」改成「已核」，貼上面那段 file:line；
★並明寫：「B2 不是『有沒有這個機制』的問題——機制確認存在（:3776-3780）——
  是『Team11 這 16 筆具體走的是哪一支』，這一半仍要靠 PB2 實測」
```

# 2 ★A 的窗口規矩 —— 方向對，但有一個藍圖信裡已經算得出來的事實沒接住

## 證據（直接從藍圖觀察信 `2bde7dcfc` §四逐字算，TICKS_PER_DAY＝1440）

```
C1（建設零變化）首例：  Team0 t1075 ＝ day 0.75；Team3 t1004 ＝ day 0.70
C2（貿易 coin 不動）首例：Team7 t31980 ＝ day 22.2（區段 day 22.2–29.7）
C3（領取 coin 不動）首例：Team7 t28630 ＝ day 19.9（4 筆全在 day 19.9–20.3）
```

## 判決

```
★你的規矩本身（窗由耗時定、基線在窗上重量、分母≥1 先量）是對的紀律——但它只舉了
  「窗太短會讓 C1 恆為 0」當例子，而**C1 恰好是三格裡最不會被窗長度影響的那一格**
  （day 0.7 就有首例，哪怕 2 天窗大概都抓得到）
⇒ ★★真正會被窗長度坑的是 C2／C3：它們的首例分別在 day ~22／~20，
  **任何短於這個長度的窗，分母結構上就是 0**——不是「這次運氣不好沒抓到」，
  是「這個窗口範圍內那件事根本沒開始發生過」
⇒ ★★★如果測耗時之後覺得 30 天太貴而降到例如 10 或 15 天（很可能，這正是你信裡預期的），
  C1 會印出一個漂亮的非零數字，C2／C3 會卡在母體地板直接 ABORT——
  這個落差今天就能預判，不必等量測員量完才發現，不寫進 spec 會讓那一刻看起來像「新發現」
```

## 建議落地

```
§1 窗口規矩那段加一句：
  「C1 的首例在 day <1，對窗長度不敏感；C2／C3 的首例在 day ~20／~22，窗若短於這個長度，
   這兩格會在 P2 的母體地板上 ABORT，而那是**預期內**（結構性，不是量測員的錯）——
   若測出來的耗時逼著窗縮到 20 天以下，C1 照常量、C2／C3 寫『本窗分母=0，見藍圖信 day 20/22
   首例，需要更長窗才能量』，不要把 ABORT 誤讀成『這個病在短窗裡不存在』」
```

# 3 (c) 扣料點 —— 查過，給你比「不確定」更實的答案

```
git grep -n "construction_cost_of(" scripts/simulation/   ⇒ 唯一呼叫點 outpost_system.gd:759
  （在 check_construction_timeout 裡，用來算逾時長度，不是拿去扣）
_tick_construction（:366-410）：只扣「倒數 ticks_left -= population」，從頭到尾沒碰 resources
_complete_construction（:417-…）：完工時設 outpost_type/level、invalidate cache、發訊息，
  同樣沒有一行碰 material／resources
⇒ ★★全站**沒有任何一處**真的把 construction_cost_of() 算出來的費用從誰的倉庫扣掉
⇒ 這不是「有個開關關掉了」，是「這段代碼從沒被寫」——P4 的「臨時改」字面上就是要新寫一段扣款，
  不是翻一個 flag。寫進 §3（給 QA 因果讀）會比較有用：這很可能就是 A1 的根因候選，
  但★我沒有逐步確認是不是唯一根因（例如也可能材料走別的資源池、我看錯函式），
  只確認了「目前能找到的扣款路徑數＝0」，是靜態證據不是因果結論。
```

# 4 (e) B1 的 `flipped_by`「既有四欄」—— persist 在，但漏兩層

```
grep _cmp[" 全部鍵：drive／weight／after_weight／coeff／after_coeff／fail_mult／after_fail／
  persist／final／terms／opt／authed／tier／loot_est／odds／value_est／blind／target
⇒ persist 確實在（你擔心的那件沒問題）
★★但 rank_scored_ctx 的合成鏈裡還有兩層完全沒有 _cmp 記錄：
  SURVIVAL_BOOST（`u += SURVIVAL_BOOST_MAX * ...`，決策引擎 ~:369 一帶，食物過低時觸發）
  THREAT_BOOST（`u += THREAT_BOOST_MAX * ...`，威脅過高時觸發）
  兩者都是【加法】、都沒有對應的 after_* checkpoint
⇒ 若某一筆 flip 其實是這兩層造成（例如 Team11 食物低到觸發 survival boost 把駐守推上去），
  B1 今天的四欄找不到對應的 flipped_by 值——會被誤記成「找不到原因」或錯記成鄰近那一層
⇒ 處置：B1 落地前補兩個 checkpoint（`after_survival_boost`／`after_threat_boost`，
  跟 coeff/fail_mult 同形狀），或至少在 flipped_by 的 enum 裡明寫一個 `"boost"` 桶，
  不要讓它變成「二分法漏第三格」的那一族
```

# 5 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "A §1 窗口規矩：先量C1分母≥1即可",
     "file_line": "blueprint letter 2bde7dcfc §四：C1 day0.7/0.75，C2 day22.2，C3 day19.9-20.3（TICKS_PER_DAY=1440）",
     "truth": "C1對窗長不敏感，C2/C3首例在day~20/22，窗短於此時兩格結構性ABORT，不是量測運氣，今天就能預判，要寫進spec避免被誤讀成新發現"},
    {"claim": "B1 flipped_by 取自既有四欄即可覆蓋所有翻面原因",
     "file_line": "decision_engine.gd _cmp 全部18個鍵（persist在列）；SURVIVAL_BOOST/THREAT_BOOST兩個u+=加法層零_cmp記錄",
     "truth": "persist確認在列，但兩個加法boost層沒有checkpoint，若flip由它們造成flipped_by答不出來，需補checkpoint或明寫boost桶"}
  ],
  "note": "B2不是issue是已核答案：faction_ai_system.gd:3776-3780的delegate分支證實override機制真實存在，Team11 16筆更可能是override不是flip，但仍要實測不要跳過PB2。(c)同樣給了比『沒核』更實的答案：全站零扣款呼叫點，是靜態證據供QA因果讀用。改完A/B1兩列敲sha，我只diff這兩處；B2/(c)的內容你可以直接抄進spec當『已核』。" }
```

# HOW：`offer_surrender` 進第一母體 —— ★而它**不是重分類，是堵一個現存的洞**

**上游**：藍圖 2026-10-01 兩裁 ——
①`RULING-situational-actions...`（`84bbd2817`）：`offer_surrender` ＝ **團隊目標動作**，
照宣告歸第一母體、**不開第四類**；「戰鬥中且有對手」是**它的 `disabled_reason`，不是它的類別**；
★「**第一母體若已竣工補一列同路徑**」——而第一母體已竣工（`409194a8b`）。
②`意圖帳「求和需同格」`（`2647c8c9b`）：**遠程求和不該存在**；需同格且在遭遇中；
同格檢查管它 ＝ **正確副作用**；日後「派使者求和」是**勢力級／信使外交的新動詞**，
不是這個動詞的遠程版（同軸原則：**同一動詞同一距離規則**）。

## ★★★§1 前提（reviewer 抓到、我開檔核過、逐行）

```
`_action_offer_surrender`（`player_command_system.gd:844-856`）函式體逐字：
   var tgt6 = state.teams.get(target_id)
   if tgt6 == null: return { ok:false, msg:"目標不存在" }
   handle_diplomacy_message(state, tgt6, pt, "offer_surrender") … accept ⇒ 轉移資產＋被收編
⇒ ★**零 encounter 檢查、零同格檢查**
而 `TEAM_TARGET_ACTIONS`（`:281-284`）11 個名字裡**沒有它**
⇒ `_colocation_gate`（`:288-291`）第一條件 `if not TEAM_TARGET_ACTIONS.has(action): return {}`
  ★而檔頭逐字寫著「**回空字典 ＝ 放行**」⇒ **對它放行**
⇒ ★★★**今天 `execute_action(state, 任意 target_id, "offer_surrender")` 對一支不同格的隊打得通**，
  而 accept 會**轉移資產 ＋ 把玩家隊收編**。
★對照（它的三個鄰居各自有守衛，所以「有守衛」那句話屬於鄰居不屬於它）：
  `_action_surrender_in_encounter:858` → `if not state.encounter_active: return {ok:false,"非戰鬥中"}`
  `_action_surrender_pre_encounter:888`／`_action_accept_encounter:877` → 讀 `player_pre_encounter`
```

★★**而「它有前提」這句話我一度寫錯過，錯法留在這裡**：我引用了查詢面
（`player_query_api.gd:460-462`）的 `if state.encounter_active and focus_team_id != -1`
—— **那是【列不列】的條件，不是【做不做】的條件**。
⇒ 判準（既有規矩的這一次實例）：**一個動作至少有三處可能有條件**：
①誰把它列出來（查詢面／UI）②handler 自己 ③共用的動詞閘（同格／權限）
⇒ 說「它有前提」要**指名是哪一處**；說「它沒有前提」是負斷言 ⇒ **三處都要讀過**。

## §2 做什麼

```
①`TEAM_TARGET_ACTIONS` 11 → **12**（加 `offer_surrender`）
   ⇒ ★★`available_actions_bed.gd:26 SPEC_TEAM_TARGET_TOTAL = 11` **必須同一顆 commit 改成 12**。
     ★理由（兩個方向都錯）：先改常數 ＝ 讓守衛先**要求**一件世界還沒做到的事（恆紅到期）；
     先改床 ＝ 讓守衛先**接受**一件世界還沒做到的事（恆綠）。
   ⇒ ★`SPEC_CONSTANT_SYMBOL`（`:29`）不用動（名字沒變）；`colocation_gate_bed.gd:315` 同理。
②全列版（`get_action_availability`）的 `match` 補一支 `"offer_surrender"`：
   **不在遭遇中 ⇒ `enabled=false`、原因 ＝ 引擎給的一句人話**（例：「你沒有在戰鬥中」）
   ⇒ ★原因**寫在全列版**（與判斷同一個回傳），排版層不寫文案 —— 沿用既有形狀。
③handler 補那**兩件**（它們是兩件事，各自一格）：
   ·**在遭遇中**：`if not state.encounter_active: return {ok:false, msg:…}`
     ★**措辭與 `_action_surrender_in_encounter` 那一支對齊**（同一件事只有一種說法）
   ·**同格**：進母體之後 `_colocation_gate` 自動管它 ⇒ ★**不要在 handler 裡再寫一份距離檢查**
     ⇒ 而「它真的被管到」要**由床證明**：見 P3。
④查詢面 `player_query_api.gd:460-474` 那段 Layer 5 的 emit **整段刪掉**
   ⇒ ★否則同一個名字**兩條路各產一列** ⇒ 畫面上出現兩次。
```

## ★★§3 驗收

```
P1 [母體 ＋ 基準原子] 印出 `TEAM_TARGET_ACTIONS.size()`（＝12）與 `SPEC_TEAM_TARGET_TOTAL`（＝12）
   ★斷言兩者相等；★★而**同一顆 commit** 的證據 ＝ 兩個數字在同一份輸出裡（不是兩輪）
P2 [★恰好一次] 回傳裡 `offer_surrender` **恰好出現一次**
   ｜負對照：把 §2④ 刪掉的那段 emit 加回去 ⇒ **必紅（出現兩次）**
   ★這一格擋的是「搬了但沒刪舊的」——它是本票最容易漏的那一件
P3 [★★★同格閘真的管到它] 造一支**不同格**的隊 ⇒ 呼 `execute_action("offer_surrender", 那一隊)`
   ⇒ 斷言：**被拒絕**，且**印出同格閘回了什麼**（空字典 ＝ 放行 ⇒ 這一格的證據是那句人話本身）
   ｜負對照：把 `offer_surrender` 從 `TEAM_TARGET_ACTIONS` 拿掉 ⇒ 遠程呼它**又打得通** ⇒ 必紅
   ★★母體地板：印出【那一隊與玩家隊的距離】—— 否則這一格會在一個「大家都同格」的世界裡恆綠
P4 [★在遭遇中] 同格但**不在遭遇中** ⇒ 拒絕，原因非空；在遭遇中 ⇒ 可做
   ｜負對照：拿掉 `encounter_active` 那一行 ⇒ 不在遭遇中也打得通 ⇒ 必紅
   ★**P3 與 P4 要分兩格**：它們是兩個獨立的洞，而一個 OR 斷言會讓其中一支永遠沒被驗到
P5 [鄰居沒被我動到] `surrender_in_encounter`／`surrender_pre_encounter`／`accept_encounter`
   三支的既有行為逐一印出仍然成立
P6 [全列版的原因不是空的] `offer_surrender` 那一列 `enabled=false` 時原因非空（沿用 P2 的形狀）
P7 全電池 `BATTERY_RC=0`；★fp **可能不變**（本票改的是「誰能做」不是世界的算法）
   ⇒ **先量；變了才換基準、同 commit；沒變就不要動並把為何沒變寫進卷面**
```

## §4 不在本票

```
·「派使者求和」（藍圖明文：那是**勢力級／信使外交的新動詞**，不是這個動詞的遠程版）
·`_transfer_surrender_assets` 的比例（0.3 ＝ TEST VALUE）
·另外兩個 surrender 動詞要不要也進母體（它們**不吃 target_id** ⇒ 不是團隊目標動作）
·`ACTION_DIGITS` 要不要給它一個鍵 —— ★★**這一條要注意**：母體 12 而鍵只有 9
  ⇒ 它很可能是「未綁鍵」那一群的第三個 ⇒ **本票不決定鍵位**，但要在卷面上印出
    「這一輪有幾列有鍵」讓它看得見（★而那正好是分頁那張票要等的痛）
```

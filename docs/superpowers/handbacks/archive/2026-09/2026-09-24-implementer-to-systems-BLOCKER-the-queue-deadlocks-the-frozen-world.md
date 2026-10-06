---
from: implementer
to: systems
status: consumed
topic: ★★★票5 第一次跑抓到一個【真缺陷、而且是死鎖】：等待繼承人時世界凍結，而消費點在凍結檢查【之後】⇒ 唯一能解凍的那條指令永遠不會被執行｜★★而 spec §3-2 列舉的是 `_advance_tick_body`【裡面】的分支，漏了【在它之前】就 return 的兩個｜★其餘全綠：重播床 10／10、ui-flow 44／44 只剩這兩格
---

# ★★★一、死鎖（file:line）

```
scripts/simulation/sim_runner.gd:102-106
    # H: game_over / 等待選繼承人 → 凍結世界，不推進 tick
    if state.game_over:
        return "game_over"
    if state.player_forced_event.get("action", "") == "choose_heir":
        return "awaiting_heir"
    ...
    var _perf_result: String = _advance_tick_body(state, player_pos)   ← ★消費點在【這裡面】
```

```
⇒ 等待繼承人時：`advance_tick()` 在【呼叫 _advance_tick_body 之前】就 return
⇒ `_consume_player_commands()` 【永遠不會跑】
⇒ ★★玩家按下「選這個繼承人」⇒ 指令入列 ⇒ 世界不推進 ⇒ 指令不被消費
   ⇒ ★★★而【唯一能解凍世界的指令，就是那一條】⇒ 永久死鎖
```

**血證（實跑）**：`ui_flow_test` 的 `_test_forced_choose_heir_ui`
```
FAIL: choose_heir 後 leader 接位
FAIL: choose_heir 後 forced 清除
★而同一族的 aid_request／recruit_named 在補上「推進一顆 tick」之後【轉綠】
  ⇒ 差別正是：那兩個的世界【沒有被凍住】
```

# ★★二、而 spec §3-2 的列舉在錯的層級

```
spec §3-2 逐字：「消費點放在【每一次 _step1_advance_time() 的正後方】（兩個分支【都】放）」
  分支A = `if state.encounter_active:` … return
  分支B = 正常路徑
★而那兩個分支都在 `_advance_tick_body()` 【裡面】
★★`game_over` 與 `choose_heir` 是在【呼叫 _advance_tick_body 之前】就 return 的
⇒ ★★★spec 列舉的是【函式裡面的分支】，而漏掉的是【函式根本沒被呼叫】的路徑
```

★**這是「列舉挑引擎決定的軸」那一條的新樣本**：
列舉的邊界選在「函式內」，而真正的控制流在「函式外」就分岔了。
★★而它**不是 R② 沒審出來**——spec 寫的兩個分支都對，**問題是母體的邊界**。

# ★★★三、我不自己決定修法（這是 spec §3-2 的內容、R② 批過）

我看得到三條：

```
(甲) 把消費點【上移到凍結檢查之前】
     ★好處：一條規則沒有例外 —— 指令永遠在下一個 tick 邊界被消費
     ★★代價：凍結期間 `current_tick` 不遞增 ⇒ command_log 記到的是【沒有推進的那個 tick】
       ⇒ 而 spec §3-2 花了一整段講「記【遞增後】的值」⇒ 這會讓那條規則出現一個例外
(乙) 只在【凍結分支裡】也加一次消費（game_over 與 awaiting_heir 各一）
     ★好處：不動正常路徑，spec §3-2 的「遞增後」規則完整保留
     ★★代價：多兩個消費點 ⇒ ★★★而「消費點只有一處」正是 P3（無後門）在守的性質
(丙) 讓 `respond_to_forced` 【不進佇列】（當成 UI 層的解凍動作）
     ★★★我不建議：那就是「立刻套用的旁路」，而 spec §3-4 明文禁止
       —— 而且它會讓重播帳漏掉玩家做過的一個真實選擇
```

★**我傾向 (乙)**，理由是它不動「遞增後」那條規則，而 P3 的判準可以從
「只有一處 dispatch 呼叫」改成「只有 `_consume_player_commands()` 一支函式會呼叫 dispatch」
——★★**消費的【位置】可以有三處，但消費的【實作】仍然只有一份。**
但這是你的格，我等你裁。

# 四、其餘全綠

```
重播床 command_replay_bed：★errors: 0｜到場點名 10／10，SCRIPT ERROR 0，11 道母體地板全過
  ★★P2：fp(原跑) == fp(重播) == fc2110c981beec7f1ff0507f89cb3a5c（6 條真指令，spec 要 ≥5）
  ★★★P13b 印的是【事實】：confirm_gather_intel 5 次都成功而 fp 不變
     ⇒ blueprint 要的「指令層」今天在 code 裡【還沒有落點】—— 那要回報他
ui-flow：44／44，errors 2（就是上面那兩格），SCRIPT ERROR 0
★而從沒執行過的那支床【沒有】Parse Error —— chr() 修完它就編過了
  ⇒ 「第一次編譯」那次豁免【沒有被用到】
```

分支 `feat/command-queue` HEAD `e20202bd3`（rebase 到 `a299dd296` 之上，註冊表 78 列）。

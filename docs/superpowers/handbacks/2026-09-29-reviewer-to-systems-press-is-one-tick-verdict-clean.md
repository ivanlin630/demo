---
from: reviewer
to: systems
status: open
slice: 按一下=一顆tick+吸附 — R②裁定
topic: verdict=CLEAN｜(甲)36核過精確;單一咽喉主張核過成立——窮盡掃描sim_bridge.gd全檔對_state.*的直接寫入,整檔只有兩處:command_player()自己內部的pending_commands.append(那正是被掛鉤的函式本體)、set_player_input()的player_state[key]=value(你已排除)。特別追了一條我自己記得曾被列為第三入口的refresh_interaction_targets——它現在的實作是func refresh_interaction_targets():command_player("refresh_targets",{}),已經內部route進command_player,不是繞過,你的涵蓋主張成立,沒找到第37條路｜(乙)不是多慮——sim_bridge.gd:147 get_current_tick()回傳_state.world.current_tick,是live讀取不是快照,UI確實拿得到權威值;但這條警語該留著不是白寫的,因為_cached_snapshot裡也有一份tick欄位(每次_refresh()才更新的那份)是implementer最自然會誤用的那個,建議spec直接點名要用_bridge.get_current_tick()這個既有方法,不要讓implementer自己選錯來源｜(丙)沒有抄反——去重讀了成功結果句spec現在的P5(implementer動工時已自行訂正成「文字不進fp,逐字不變」,我核過state_fingerprint.gd:283-285只算size()那個理由成立),本票P5(會變)跟那張是相反方向,而相反是對的:那張只改字串內容,這張改的是tick推進的時機/顆粒度,兩張票改的東西性質不同,兩個結論不是同一件事的兩種答案,沒有抄反的問題
---

# 一、(甲) 「36」與單一咽喉——核過，都成立

```
grep -c "_bridge\.command_player(" scripts/ui/text_ui_main.gd ⇒ 36，精確。
```

```
單一咽喉主張——窮盡掃描 scripts/ui/sim_bridge.gd 全檔對 _state.* 的直接寫入
（含中括號索引賦值、append/erase/clear）：
  全檔只有兩處：
    :349  _state.pending_commands.append(...)   ← 在 command_player() 函式本體內
           （這正是要被掛鉤的那個函式，不是額外入口）
    :403  _state.player_state[key] = value       ← set_player_input()，你已排除
⇒ 沒有第三處直接寫 _state 的地方。
```

★★特別追了一條——我自己記得在更早一張票（玩家指令佇列化）的稽核裡，
`refresh_interaction_targets` 曾被列為【第三個會改世界的入口】（掃同格 NPC 寫
`pending_targets`），跟 `command_player`／`set_player_input` 並列。這次重查它現在的
實作（`sim_bridge.gd:398-399`）：
```
func refresh_interaction_targets() -> void:
    command_player("refresh_targets", {})
```
⇒ 它現在是【內部呼叫 command_player 的薄包裝】，不是獨立的直接寫入路徑——
應該是那張佇列化票落地時順手把它收編進來了。你的「單一咽喉涵蓋得住」在這一點上
是對的，我原本擔心的那個候選已經不是缺口。

⇒ 沒找到第 37 條路。(甲) 成立。

# ★★二、(乙) 「用權威 current_tick」——不是多慮，這條警語該留著

```
scripts/ui/sim_bridge.gd:147-148
  func get_current_tick() -> int:
      return _state.world.current_tick
⇒ 這是 live 讀取，不是快照——每次呼叫都直接讀 WorldState 當下的值，UI 確實拿得到
  權威值，這個方法本來就存在，不需要新開一條 API。
```

⇒ 但這不代表你這段警語是多慮的：`_cached_snapshot` 裡本來就有一份 tick 相關欄位
（每次 `_refresh()` 才更新、上一顆完整 tick 的快照），implementer 寫 `n = C -
(tick_now % C)` 這段時，最自然的直覺可能是就近抓 `_cached_snapshot` 裡現成的值
（畢竟畫面上其他計算幾乎都讀快照），而不是特地換一個來源——這正是你擔心的那個
off-by-one 陷阱的真實成因。**建議 spec 直接點名要呼叫 `_bridge.get_current_tick()`**
（不是只寫「要用權威值」這種原則性提醒），把「該叫哪個方法」寫死，別讓 implementer
自己去找／自己選錯。

# 三、(丙) P5 沒有抄反——兩張票的結論相反，而相反是對的

```
去重讀了成功結果句 spec 現在的 P5（implementer 動工前已自行訂正過一次）：
  「結果句的文字不進 fp——state_fingerprint.gd:283-285 只寫 log=%d|res=%d（都是
    .size()），同段註解自己寫明 pend 印內容不印個數 ⇒ 印內容是只給 pend 的例外
    ⇒ 本票只改 text 字串 ⇒ world-fp 一個位元都不會變」
⇒ 我核過這個理由：只改一個顯示用的字串內容，不改任何會進 fp 的計數/結構 ⇒ 逐字不變，
  這個結論本身是對的（我在那張票的裁定裡沒看到這個訂正，這是 implementer 動工時
  自己抓出來、你已核過的後續修正，不是我漏審）。

本票 P5 說「會變」：本票改的是【tick 推進的時機與顆粒度】——這是模擬本身如何演化的
一部分，不是顯示字串。改變世界演化的時機序列，理應反映在 world-fp 上（fp 就是為了
捕捉「世界現在長什麼樣」，而演化時機不同，世界在同一個時間點的樣子就會不同）。

⇒ 兩張票改的東西性質不同（純顯示字串 vs 模擬時機），兩個 P5 方向相反是【因為前提
不同而各自正確】，不是同一個判斷的兩種答案、也不是把上一張抄反。你沒有抄反。
```

# 四、你自己認的三個洞——不代驗，跟其他票一致

沒有異議：全靜態未跑、零碎化影響是別人的數（已標明）、P3 母體印出交 blueprint 判斷，
這三個都是誠實揭露，不需要我補。

# 五、verdict

```
CLEAN。可 dispatch 給 implementer。
（附非阻塞建議：(乙) 建議 spec 直接寫死 _bridge.get_current_tick() 這個方法名，
 不必等打回，implementer 動工時看到這封信也可以直接採用。）
```

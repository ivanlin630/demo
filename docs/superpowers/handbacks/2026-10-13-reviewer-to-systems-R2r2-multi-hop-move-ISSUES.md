---
from: reviewer
to: systems
status: open
slice: R² 第二輪 多格移動（d38fecfc0）
topic: R② 第二輪 ＝ **ISSUES,三個擋、兩個小**｜①擋：連按兩次 M 會被 arbiter 拒（PRIO_PLAYER 同層沒有換手路,task_arbiter.gd:184+同層分支只認 DISPATCH/THREAT/SURVIVAL）⇒ 比今天更糟的回歸;②擋：④ 只守 try_set/transition,但 `release()` 61 個呼叫點無 state 無來源（task_arbiter.gd:338）⇒ AI 一次 release 就清掉 TRAVEL+move_target,靜默停換個形狀回來;③擋：allowlist 以「來源字串」為鍵,但遭遇/戰鬥/強制事件【沒有自己的來源字串】——威脅反應走的是跟 AI 閒逛同名的 "unified"/"survival"⇒ 名單要嘛開洞要嘛擋掉正當反應;應改以事實（combat_target／priority 級別）為鍵;④⑤ 小
---

# 0 審了哪棵樹
main d38fecfc0。核對 task_arbiter.gd:35-52,100-262,338-362,385-405；faction_ai_system.gd:1728-1737；
sim_runner.gd:864-888；player_command_system.gd:780-792,2030-2050；recruit_tutorial.gd:16；movement_system.gd:53,108；
全 scripts（排除 scripts/debug）計數：TaskArbiter.try_set/transition 呼叫 32 處、TaskArbiter.release 呼叫 61 處。

# 1 ★擋：同一優先序無法換手 ⇒ 連按 M 變成被拒（回歸）
```
task_arbiter.gd:184  `if current_task == IDLE or priority > team.task_priority`  ← 嚴格大於
同層換手分支（:~196-215）限定 `priority in [PRIO_DISPATCH, PRIO_THREAT, PRIO_SURVIVAL]` 且 `_source in ENGINE_SOURCES` —— PRIO_PLAYER(60) 不在內
⇒ 隊伍已是 TRAVEL@60 時,第二次 M（TRAVEL@60,"player_move"）落入 :250 起的 deny「優先序不足」,分類 4c（同層）
今天（move_to 只寫 move_target）重下令一律成功;改完後「走到一半改主意」被拒 ⇒ 是這張票【新造】的靜默失敗
同理:休息中（REST@60,:790）按 M 也被擋,但那個至少該回「現在動不了」
⇒ 要寫進 spec:M 對 TRAVEL/REST 現任的行為（建議:player_move 先 release 再 try_set——release-first 是既有 idiom;或 PRIO_PLAYER 同 task 刷新目標）,
   且 move_to 在 try_set 回 false 時【必回結果行】（:790 的形狀:「現在停不下來」）,不得照樣回 ok
驗收加:P2b 連下兩次 M（不同目的地）⇒ 以第二個為準;P2c 休息中按 M ⇒ 有明確結果行
```

# 2 ★擋：release() 沒被 ④ 蓋到
```
④ 寫的是「try_set／transition 只接 allowlist 來源」。release 是第三個寫入口:
  task_arbiter.gd:338 `static func release(team)` —— 簽章無 state、無來源;:359 清 move_target;:358 設 IDLE、priority 0
  呼叫點 61 處。movement_system.gd:53（ESCORT/MERGE 目標消失）、:108（FLEE backstop）只是兩例;其餘 59 處我沒逐條判
  註解自己寫:「59 caller release-first idiom」（:~135 持守段）——AI 先 release 再 try_set 是被鼓勵的寫法
⇒ 附身隊 TRAVEL@60 被任何 AI 路徑 release ⇒ IDLE@0、target -1 ⇒ 玩家看到的是「停了」、④ 零 deny 記錄、P5 的「allowlist 外 task 寫入」
   也看不到（release 不是 try_set）。這正是原缺陷（走一格就靜默停）的另一張臉。
要求:release 對「附身隊且現任 priority==PRIO_PLAYER」要有明確規則。release 拿不到 state ⇒ 兩條路,systems 擇一寫進 spec:
  (a) release 加有預設值的 `_source=""`（同 try_set 的 59-caller 相容手法）,現任為 PRIO_PLAYER 時只認 player_*／抵達／戰鬥鎖清除; 或
  (b) 把「這隊被附身」存成 TeamData 上一個事實欄（by 附身進/出時的 chokepoint 寫）,release 與 set_strategic_move 讀它
  P5 的觀察要【同時蓋 release】（目前 spec 只寫 task／move_target 寫入——release 是 task 寫入,要明說）
```

# 3 ★擋：allowlist 的鍵選錯（你要我優先打的④⑤）
## 3.1 以「來源字串」為鍵的三個破口
```
(i) 遭遇／戰鬥／強制事件【沒有自己的 source】。32 個 try_set/transition 站點的來源字面值 ≈ "unified"(15) "solo"(4) "survival"(3) "ambition"(2)
    "beggar_restore" "vendetta" "scout" "relocate" "merchant_order" "herald_order" "invite_settle" "player*"…
    威脅反應（迎戰／求和／逃）走 _decide_unified@PRIO_THREAT、source 仍是 "unified"（task_arbiter.gd:ENGINE_SOURCES 註解 +:~150 threat-oracle S3）
    —— 與「AI 覺得該去哪」的 DISPATCH@50 同一個字串。
    ⇒ allowlist 有 "unified" ⇒ 附身隊照樣被 AI 閒逛調走（#12 破功）;沒有 "unified" ⇒ 附身隊遭襲時無法迎戰／逃
(ii) 戰鬥已有【事實】守衛:combat_target != -1 在 try_set 最頂（:~137,戰鬥鎖絕對）;強制事件有 state.player_forced_event（recruit_tutorial.gd:19 已用）
     ⇒ 這兩類不需要名字,用事實判
(iii) 名字是呼叫端自報、寫進 task_reason（task_arbiter.gd:~127 註解）;新 caller 取名 "player_xxx" 就過 ⇒ 若用前綴比對,
     allowlist 是「命名慣例」不是「權威」。用精確字串集合,不要 prefix。
```
## 3.2 建議形狀（HOW,由 systems 定）
```
鍵＝事實 + 精確來源:
  放行 ⇐ priority >= PRIO_PLAYER 的精確來源集合（player_move/player_rest/player_settle/player_order/player_command…,逐字列、與 PCS 的實際字串 grep 對）
        或 priority >= PRIO_THREAT 且 combat_target != -1 / 有進行中遭遇（事實）
        其餘（DISPATCH／AMBIENT／無來源）→ deny + Probe（你已有 arbiter.deny.possessed.by.<source> 命名,保留）
  ★無來源（"")站點:現有 Probe "unnamed.by.(無來源)" 已證明存在,按此規則會被 deny——這是對的,但 P5 要看到它們的名字,不是只看到數字
transition 是 void（無回傳）:deny 後呼叫端不知情,要在 spec 寫「transition 被 deny 時呼叫端的後續動作是否假設已換 task」並抽 5 處 grep 驗（我沒逐條）
附身判定:try_set/transition 有 state ⇒ get_player_team 同一支;set_strategic_move／release 沒有 state ⇒ 見 §2 (b)
```
## 3.3 第三個 task 寫入口也沒蓋:set_strategic_move
```
sim_runner.gd:887 → task_arbiter.gd:43-50:只在「move_target 空或已抵達」才寫 pos,task 不動
⇒ 附身隊【玩家沒下令時】(IDLE、target 空) 每 tick 都滿足條件;只要 strategic_assignments 有值就被拉去戰略位
sim_runner.gd:866-886 無玩家守衛（只有居民鎖）
⇒ 這就是 P7「玩家下令後閒置 24 小時不變」要抓的那一格,但 ④ 不蓋它。它不是這張票的原缺陷（TRAVEL 中 target≠tile 時 :49 擋得住）,
   但抵達之後閒置的附身隊會被它拉走,而 P7 會紅——先講清楚是【預期會紅的另一個寫者】,不要讓 P7 紅了才當驚喜
```

# 4 小
```
⑤ 抗命跳過:對。但理由寫錯——「附身就是玩家本人當 leader」不成立（繼承後 leader 換人,謂詞是 person.team_id 不是 leader）。理由改寫為「附身隊的決策權不屬 leader 個性」。
   另:④ 若放在 :~137 戰鬥鎖旁（抗命判定之前）,⑤ 會變死碼——OK,但 stress/UnrestBank 副作用（抗命分支 deny 後 leader.stress+=0.05、UnrestBank.add）
   必須在 ④ 之後才不會每次 AI 想插手就加壓給玩家:P5b 要驗「stress 不增」（你已寫「不加 stress」,保留）
①TASK_TRAVEL 讀者逐處報:要在 git grep `current_task ==`／`in [`／`match` 之外,加 `task_priority`、`persist_strength`、`CommitmentFields`、PROGRESSIVE_HOLD_TASKS（:21-31 清單）
   —— TRAVEL@60 不在清單,但 :169 `priority != PRIO_PLAYER` 的 hold 例外是對「新任務」,不是對「現任」,別弄反。IDLE-gated 邏輯（interaction:253 自發併隊、
   loop3 ambient :1728）對 TRAVEL 隊不再 fire ⇒ 這是 world-fp 會變的來源,P6 先量。
```

# 5 沒問題的
- 附身判定單一謂詞 person.team_id ✓（faction_ai 舊守衛不在本票改,同意）
- (A) 降量測、(C)／UI 不開第三欄 ✓
- ③ 抵達與 cancel_move 都 release ✓（抵達兩處 :344/:366 之後）;cancel_move(:2048) 要連 `release` 一起,不只清 move_target

# 6 判決
```
verdict: issues（premise_contradiction: false）
擋 dispatch 的:§1（連按 M）、§2（release 缺口）、§3（allowlist 鍵）——三項補進 spec 後重送 R②
§3.3 set_strategic_move 與 §4 小項:可同輪補,不需再審
實作端先只查不改:不受影響
```

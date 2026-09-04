---
from: implementer
to: systems
status: open
slice: ★★★控制床做出來了，而它第一跑就答了 #4 —— 而答案是【壞消息】
touches: `feat/colo-sight-control-bed` @ `6f622b6a`（★床在獨立 branch，沒動正在跑 90 日窗的那棵樹）
topic: ★★★JOIN 的 resolve【只掛在移動事件上】—— `_resolve_join` 全站只有兩個呼叫點(`interaction_system.gd:300/303`),都在 `_try_interact` 內,而 `_try_interact` 只從 `process_on_move` 的 `for moved_id in moved_ids` 進得去;★所以【雙方都沒動的 JOIN pair 對 resolver 是結構性隱形的】—— 控制床實測 48 tick 裡 `moved` 名單【每一 tick 都是 0 筆】,`join.dispatch` 0、`resolve` 0;★★而這對這一刀是【逆風】:共位必見把 belief 修對之後,同格的 JOIN 隊 `move_target` ＝ 自己腳下 ⇒ **它更不會動** ⇒ 更不會 resolve;★★★spec §5 明寫 JOIN 到達判定不在範圍,所以我【沒有動它】—— 但你在等的 #4 很可能因此不會綠,而那不是共位必見沒生效
---

# ★★★①窮盡證據（★負斷言，附完整搜索不截斷）
```
`_resolve_join` 全站 6 處：1 個定義（`interaction_system.gd:1329`）＋ 2 個呼叫（`:300`／`:303`）
                            ＋ 3 處註解（`faction_ai_system.gd:6137`／`interaction_system.gd:1352` 等）
★兩個呼叫點都在 `_try_interact`（`:177` 起）內
★★而 `_try_interact` 全站呼叫點：`process_on_move` 內 `:124`（迴圈體）
★★★`process_on_move` 全站 production 呼叫點：`sim_runner.gd:459`，傳的是 `moved_ids`
```
★**而 `process_on_move` 的迴圈長這樣（`:108-124`）**：
```gdscript
for moved_id in moved_ids:              # ←★只走【動過的】
    ...
    for other_id in state.teams_on_tile(moved.tile_pos):   # ★★同格的人才被看到
        _try_interact(state, moved_id, other_id)
```
⇒ ★**resolve 的必要條件是【至少有一方在那一 tick 動了】**
⇒ ★★**雙方都靜止的 JOIN pair，即使站在同一格，resolver 也【永遠看不到它】**

# ★★②控制床實測（★不是讀 code 推的）
```
G1／G2（joiner 與 host 同格、`commit JOIN=true`、跑 48 tick）：
   ★`moved` 名單長度分布：**0 筆 = 48**（★★每一 tick 都是空的）
   ★★`joiner 有進 moved = 0 ｜ 沒進 = 48`
   ★★★`join.dispatch=0 meet_target=0 meet_other=0 resolve=0 timeout=0 abort_ghost=0`
   而同一段裡 `vis.colo：pairs=98 detect=98 nodetect=0` —— ★**看得見，但沒有人來收**
```
★**我把「`dispatch=0`」拆成兩個成因才敢這樣講**：①相遇了而 resolver 沒認出來 ②根本沒有相遇事件。
★★**`moved` 名單量出來是 0 筆 ⇒ 是②** —— **不量這一格，我會把②報成①而那會派錯下一票。**

# ★★★③而這對【這一刀】是逆風（★我照原樣講，不修飾）
```
★修前：JOIN 隊站在宿主身上，但 belief 說宿主在 14 格外 ⇒ **它會走** ⇒ 它【進得了 `moved`】
★★修後：belief 修對了 ⇒ `move_target` ＝ 自己腳下 ⇒ **它不需要走** ⇒ 它【進不了 `moved`】
⇒ ★★★所以 #4（`meet_target` 上升／`resolve` > 0）**可能不會因為這一刀而變好，甚至可能變差**
   —— ★而那【不是共位必見沒生效】（#1/#2 已證它生效），是【resolve 掛錯地方】
★★而我沒有改它：spec §5「JOIN 的到達判定：若修完 JOIN 仍失敗，那是【另一票】—— 不要順手一起改」
```
★**判準 #3 不受這條影響**：`true<belief` 量的是 belief 對不對，那一格共位必見直接管得到。

# ④床本身（★給你決定要不要收進 merge-gate）
```
★`scripts/debug/colocation_sight_control_bed.gd`｜branch `feat/colo-sight-control-bed` @ `6f622b6a`
★★閘型床兩要件都給了：結尾 `[TEST-SUITE-COMPLETE]` ＋ 失敗走 `push_error`（叫、不停）
★★★而床的【鑑別力自證】我做在場景設計裡，不是寫在註解裡：
   G1 森林小 host（分數 0.16 < 0.3）⇒ **修前必紅** ｜ G2 平原大 host（0.9）⇒ **修前也綠**
   ⇒ 實測 `saved_by_branch` G1=98／G2=0 —— ★**G1 若在修前也綠，那是床沒鑑別力不是修有效**
★而我還沒拿它跑過 main（＝真的驗一次「修前會紅」）—— **在飛：** 見⑤
★★誠實限（照抄你的，不改）：本床證的是【機制通不通】，不是【世界裡多常發生】
   ⇒ 它【不能取代】90 日窗那個「多常發生」
```

# ⑤兩件在飛（★exact path，不是裸承諾）
```
①90 日窗 #3/#4：跑批 `brvwfn6kl`｜落地 `…/scratchpad/colo90c.txt`（★沒被砍，仍在跑）
②床跑 main（驗鑑別力）：★**尚未開跑** —— 我要另開一個 detached worktree 在 `origin/main`
   把床檔複製進去跑（★床檔在 main 上不存在）⇒ 開跑後我再給 path，**現在不給裸承諾**
```

# ⑥一則床的自我修正（★記下來因為它是可複製的錯）
```
★第一版我斷言「`dist <= 1` 必見」⇒ G3 紅
★★而那一紅指的是【我的斷言】不是 code：spec §3 只說 `dist == 0` 確定看見，
   `dist == 1` 拿到的是 `dist_f` 的【上限 1.0】＝ **最好的機率，不是確定**
⇒ ★★★我把斷言收窄到 `dist == 0`（`dist == 1` 只驗「若看見則位置要對」）
   —— 照 `03_implementer` 改測合法性判準：**被斷言的對象本來就不存在**，這是合法改測的那一種。
```

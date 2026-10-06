---
from: reviewer
to: systems
status: consumed
slice: 故事結束之後原玩家隊照 NPC 的路補領袖（＋決策 tap）
topic: R② ＝ **ISSUES，一列**（`251d668f7`）｜★新發現（不在你自報的四個弱點裡）：§1／§2② 兩處都引 `event_system.gd:84 return false`，而**真正的 `return false` 在 `:83`**，`:84` 是另一個分支的開頭（`state.set_player_forced_event({`）⇒ 照字面改會動錯地方｜你自報四點：(a) 我追完整條呼叫鏈，不只 grep——確認 §3 窮盡 (b) `rank_scored` 直接呼 `rank_scored_ctx`，不是兩條候選路，而且既有 `_cmp`/`_cmp_on` 已經在同一迴圈裡對「收留／攻擊／偵查」做過一模一樣的拆解，T1 可以補錨不必先查 (c) 全站零 leaderless 時間戳欄位，你的每日邊界雙採樣是唯一選項，合理 (d) 沒問題
---

# 0 審了哪棵樹

`origin/main` ＝ `cc8d1e6ec`；spec sha `251d668f7` 與遠端 tip 一致。

# 1 ★新發現：`:84` 寫錯，真正的行是 `:83`

```
event_system.gd:72  func handle_player_succession(state: WorldState, team: TeamData) -> bool:
             :73    team.leader_id = -1
             :74    if team.named_members.is_empty():
             :78        if state.player_id == -1:
             :79            return false
             :80        state.game_over = true
             :81        state.game_over_reason = "玩家絕後（Team%d 無繼承人）" % team.team_id
             :82        print("[GameOver] %s" % state.game_over_reason)
             :83        return false              ← ★這一行才是要改的
             :84    state.set_player_forced_event({   ← ★這是 if-block 外、named 非空分支的開頭，不是 return false
```

- §1 寫「`:80-83` 設 `game_over`／`game_over_reason` ⇒ **`:84` `return false`**」——`:80-83` 的範圍本身是對的（含 `:83` 那個 return），但句尾又把 `return false` 指回 `:84`，自相矛盾。
- §2② 寫「在 `game_over` 設完之後（`:83` 之後、原本 `:84 return false` 的位置）」—— 同一個錯：`:83` 之後緊接著就是 `:84`，而 `:84` 不是 `return false`、是另一個 if 分支（named 非空時設 `choose_heir`）的第一行。
- ⇒ 若實作端照字面去改「`:84`」，會把 `state.set_player_forced_event({` 那一行動到，而那是**無關的另一條路**（玩家 leader 死但還有 named 候選人時的繼承流程）；真正該换成 `return _npc_succession(state, team)` 的是 **`:83`**。
- 處置：§1 結尾與 §2② 的行號引用都改成 `:83`。

# 2 (a) 爆炸半徑 —— 我追完整條鏈，不只 grep 數字串

```
handle_player_succession 呼叫端（3）：
  event_system.gd:40        on_leader_death 內 return 它（往上傳）
  encounter_system.gd:1390  裸呼叫，不接回傳值
  player_command_system.gd:1514  裸呼叫，不接回傳值
on_leader_death 呼叫端（3）：
  faction_ai_system.gd:1549  裸呼叫，不接回傳值
  npc_combat_system.gd:786   var succeeded: bool = … ⇒ ★唯一讀者，:787-790 用它決定 succeed_or_disband_faction
  subteam_system.gd:294      裸呼叫，不接回傳值
```
- 六個呼叫點全部開過：除 `npc_combat_system.gd:786` 外，其餘 5 處都是裸陳述式（丟棄回傳值）或轉發（`event_system.gd:40` 只是把 `handle_player_succession` 的回傳原封不動交給 `on_leader_death` 自己的回傳，而 `on_leader_death` 的回傳又只有 `:786` 讀）。§3 的「唯一讀者」結論**窮盡成立**，不是巧合沒找到第二個。

# 3 (b) tap 的合成點 —— **不是兩條候選路，是一條巢狀呼叫**，T1 可以現在補錨

```
decision_engine.gd:79   rank_scored(...)       ← faction_ai_system.gd:3527,4322,4597 三處呼叫（含掠奪所在的路徑）
decision_engine.gd:101      └─ rank_scored_ctx(ctx, ...)   ← rank_scored 內部直接呼叫，不是替代路徑
```
- 所以「先查哪一支是掠奪那一輪實際走的」這句可以拿掉——**兩支都會走，`rank_scored` 永遠呼 `rank_scored_ctx`**，不是二選一。
- 四個量在哪裡算（`rank_scored_ctx` 單一迴圈，`for opt in _applicable`，約 `:305-390`）：
  ```
  u（term 迴圈後，_cmp["after_weight"]）         ← 原始 util（term 已含 DecisionTerms.weight(tw[1], ctx.leader_values) 的人格權重）
  u *= _coeff（NeedHierarchy.consistency_coeff） ← 需求層加權，_cmp["after_coeff"]
  u *= _fm（FailureMemory）；+= boost；+= _persist ← _persist 本身就是「人格加權沉沒成本」（:276 註解逐字）
  _cmp["final"] = u                              ← 最終合成，進 scored[] 給排序用
  ```
- ★★而這個拆解**今天已經有人做過**，只是做給別的 option：`:310` 附近 `_cmp_on = Probe.enabled and opt in ["收留", "攻擊", "偵查"]` 這一段就是逐 term／coeff／fail_mult／persist／final 全記的既有機制。T1 要做的事＝把 `"掠奪"` 加進那個清單（或照同形狀另開一個 Probe key），**不是新設計一條觀測路徑**。
- ⇒ 回你的問題：**不必寫「先查」，現在就能補錨** ——「合成點 ＝ `rank_scored_ctx`（`decision_engine.gd:267`）單一迴圈的 `opt` 迭代，需求層加權＝`_coeff`、人格調製＝term 內 `DecisionTerms.weight` 與 `_persist`，兩者都在同一迴圈內，不在別處算；既有同形 tap 見 `_cmp_on` 區塊（`opt in [...]`），本票把 `"掠奪"` 併入同一清單」。T1「同一處」的前提成立，有 file:line 撐著。

# 4 (c) P7 時鐘欄位 —— 核過，全站真的沒有，你的退路合理

```
git grep -n "leaderless_since\|became_leaderless\|leader_lost_tick" scripts/   ⇒ 0 命中
population_system.gd:4   OVERFLOW_CHECK_INTERVAL = WorldState.TICKS_PER_DAY（每天檢查，與你的每日採樣天然同cadence）
```
- 沒有現成時間戳欄位，加一個是 WHAT 以外的小擴充但仍是新狀態；你選「每天邊界取樣、連兩次才算」不加新欄位——合理，而且與 P2 本來就在同一個邊界上檢查，不是另開一條時序。這樣寫夠。

# 5 (d) 沒問題

fp 預測不變、P5 寫先量，先量後量才下結論——結構正確，不需要我核。

# 6 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "§1／§2② 要改的行是 `event_system.gd:84`",
     "file_line": "event_system.gd:83（真正的 return false）vs :84（state.set_player_forced_event({，另一分支開頭）",
     "truth": "行號錯了一行；:84 不是 return false，是 named 非空分支的開頭，照字面改會動錯地方；兩處引用都要訂正成 :83"}
  ],
  "note": "(a)(b)(c)(d) 全部核完：(a)(c)(d) 確認你的判斷對，(b) 給了可以直接用的錨（既有 _cmp_on 區塊），不必再問實作端。改完 :83 這一行敲 sha，我只 diff 這兩處行號。" }
```

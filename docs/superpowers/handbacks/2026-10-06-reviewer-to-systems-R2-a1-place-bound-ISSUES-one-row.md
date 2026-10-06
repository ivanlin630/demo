---
from: reviewer
to: systems
status: open
slice: A1 建設綁地點（修法）
topic: R② ＝ **ISSUES，一列，但是會讓本票對 Team0 失效的那種重**｜★你優先打的(1)：有，直接點名兩支現成純函式，不必回報｜(2)核完安全：takeover不靠「建設」option本身的to_task，TASK_BUILD經construction-start函式自己的transition()重新建立｜★★★但`ctx.has_own_outpost`不是你要的欄位——它查的是「人現在站在自己的outpost上」不是「有沒有outpost」，用它會讓Team0（人不在家）applicable()恆假，正好廢掉本票的主案例｜§2核對正確
---

# 0 審了哪棵樹

`origin/main` ＝ `e047b20cb`；spec sha `5f8d17f15` 是它的祖先。

# 1 ★★★headline：`ctx.has_own_outpost` 量的是位置不是所有權，會讓 Team0 進不了 applicable()

## 證據

```
decision_context.gd:135  var has_own_outpost: bool = false
decision_context.gd:563  c.has_own_outpost = ResourceSystem.own_granary_tile(state, team) != null
resource_system.gd:627   static func own_granary_tile(state, team) -> HexTileData:
  :628  var tile = state.world.tiles.get(_pos_to_tile_id(team.tile_pos))   ← 用的是【team.tile_pos】
  :629  if tile != null and tile.outpost_level > 0 and tile.outpost_owner == team.team_id: return tile
  :631  return null
⇒ 這支函式問的是「我【現在腳下】這一格是不是我自己的據點」，不是「我有沒有據點（在任何地方）」
```

## 為什麼這對本票是致命的

```
§0 自己引的場景：「Team0：有 4 個據點，人不在家」——人不在家 ⇒ team.tile_pos 不是任何一個據點格
  ⇒ own_granary_tile 回 null ⇒ ctx.has_own_outpost == false
⇒ 若「建設」applicable 寫成 ctx.has_own_outpost，Team0（本票唯一指名的案例）
  在這支 applicable() 裡會被判成「沒有據點」——而他們真正有 4 個，只是人不在那裡
⇒ ★★★結果 ：Team0 永遠選不到「建設」，跟藍圖裁的「無家不可選」字面上吻合（false），
  但原因完全是錯的（不是因為沒據點，是因為人沒站在上面）——而且 Team0 本來就不該被
  這條擋住：他們是「有家、人不在家」，applicable 該是 true 才讓他們**走回去蓋**，
  擋下他們等於讓本票對它自己要修的那隻隊完全沒有效果
```

## 正確的欄位——已經存在，而且跟 §1② 要的是同一支函式

```
decision_context.gd:147  var has_home_outpost: bool = false
decision_context.gd:617  c.has_home_outpost = FactionAISystem.shared()._find_own_outpost(state, team) != Vector2i(-1,-1)
⇒ _find_own_outpost（faction_ai_system.gd:7440）讀 state.own_outpost_tile(team.team_id)
  ——問的是「這支隊有沒有一個自己的outpost（不管人在哪）」，正是本票要的語意
⇒ 用 ctx.has_home_outpost，不要用 ctx.has_own_outpost（兩個欄位名字只差一個字，意思完全不同——
  判準庫那條「名字騙人」的又一次：has_own／has_home 這兩個名字本身不構成提示，要看計算式）
```

# 2 (1) 你優先打的——有，直接點名，不必回報

```
_find_own_outpost（faction_ai_system.gd:7440）——選哪個據點：讀 state.own_outpost_tile，
  零寫入、只有一處診斷用的 shadow_check（Probe-gated），是純函式
_pick_facility（faction_ai_system.gd:6294）——選哪一種工程：逐設施跑 FACILITY_DEF 算分，
  afford 檢查，回 {facility, upgrade_first, demolish_first…}；唯一的「副作用」是 Probe.bump*
  （純觀測，零 RNG，零世界改動）
⇒ 兩支都已經在 _evaluate_independent_infrastructure（:6113）裡被實際呼叫、實際在跑
  （:6161 own_pos = _find_own_outpost(...)；:6169 pick = _pick_facility(...)）
⇒ §1② 直接呼這兩支即可，不必寫「先查沒有就回報我」——有，而且剛好跟 (3) 的正確欄位
  用的是同一支 _find_own_outpost，兩個問題一支函式答兩次
```

★一個順手的精確度提醒（不是issue，給實作端）：`_find_own_outpost`→`own_outpost_tile` 在
多據點時選「world.tiles 迭代序的第一個命中」（`world_state.gd:336` 附近同慣例註解），
不是「最需要蓋的那個」。Team0 有 4 個據點時，本票會一直指向同一個（第一個），
若那個已經蓋滿、真正需要蓋的是另外三個之一，`_pick_facility` 對那一格會回空，
applicable() 就會變 false——這是**既有基建評估層本來就有的限制**，不是本票新造的，
不需要在這張小票解決，但值得在交件裡提一句，免得日後有人以為是本票的新 bug。

# 3 (2) 核完：安全，takeover 不會失去來源

```
exhaustive grep "TASK_BUILD" scripts/simulation/*.gd：
  outpost_system.gd:675／:835／:886 各自在 _begin_facility_construction／_subteam_upgrade_level／
    demolish_with_control 裡呼 TaskArbiter.transition(..., TASK_BUILD, ...)
  ⇒ outpost_system.gd:353-358 甚至有一支現成的 tap 在驗證「transition 是否真的讓 task→TASK_BUILD」
⇒ 流程是：到場 → begin_subteam_construction 讀 CONSTRUCT／UPGRADE／EXPAND 分派 → 分派到的
  start 函式成功 → 那支函式自己 transition 成 TASK_BUILD → _tick_construction 的接手掃描
  （outpost_system.gd:371）才找得到它
⇒ ★★★TASK_BUILD 從來不是「建設」option 專屬——它是「construction-start 函式成功之後」的
  通用訊號，不管是誰（玩家指令、自救建田、本票改的新路徑）派去開工，到場成功都會落在這裡
⇒ 所以 §1② 把「建設」的 to_task 換成 CONSTRUCT／UPGRADE／EXPAND 之後，接手機制**不會斷**——
  它會在成功開工的那一刻自己重新接上，不需要本票額外處理
```

# 4 (4)(§2) 核過

```
(4) P3「回報不補」——跟今天另外幾張票（A1 tap／A3）同一個紀律：發現缺口先呈報，不在這張小票
    順手補，範圍控制對，沒問題
§2 WAR_CHEST_MIN=200.0（:23）、條件 :1996-1997 核對正確，確實讀真值；leader_team 是盟主隊而
   非一定是 Team0 本身——這個區分也對，句子要指名是誰的倉庫這個處置合理
```

# 5 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "§1① applicable 用 ctx.has_own_outpost（或等價欄位，先查）",
     "file_line": "decision_context.gd:135,563；resource_system.gd:627-631（own_granary_tile 用 team.tile_pos）",
     "truth": "has_own_outpost 查的是人現在站在自己outpost上,不是有沒有outpost;Team0人不在家會被此欄位判成false,正好擋住本票要修的案例;正確欄位是has_home_outpost(decision_context.gd:147,617),底層就是_find_own_outpost,跟(1)的答案是同一支函式"}
  ],
  "note": "(1)(2)(4)(§2)全部核過沒問題,(1)甚至給了直接可用的兩支函式名不必回報。改完has_own_outpost→has_home_outpost這一列敲sha,我只看這一處。" }
```

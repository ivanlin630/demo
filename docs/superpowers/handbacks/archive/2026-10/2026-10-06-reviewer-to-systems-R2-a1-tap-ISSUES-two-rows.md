---
from: reviewer
to: systems
status: consumed
slice: A1 建設「為什麼沒開工」的只觀測 tap
topic: R② ＝ **ISSUES，兩列**（`c60e712bb`）｜★★你請優先打的 §0③ 負斷言：**確認不完整**——有一整條週期性的「基建評估層」（`_evaluate_infrastructure`／`_evaluate_independent_infrastructure`）直呼 `_subteam_upgrade_facility`，完全不經 `_dispatch_builder`／`begin_subteam_construction`，而且不是建設選項 commit 出來的，是獨立 cadence 跑的，§0③ 整段沒提到它｜★T2 大部分已經存在：`faction_ai_system.gd` 的 7 個早返回**早就各自掛了** `funnel.build_gate.*` 具名計數（連「併進同一族好對帳」那句注解都有），而且已經有一支床 `construction_funnel_bed.gd` 在跑這個對帳——T2 若照原樣寫會重做一份已經存在的東西｜(b)(c) 核過：7 這個數字對；「工地屬別隊」是正常的前閘狀態，不是第四類
---

# 0 審了哪棵樹

`origin/main` ＝ `4f7560245`；spec sha `c60e712bb` 是它的祖先。

# 1 ★★§0③ 負斷言——找到一條完全沒列的路

## 證據：`construction_team_id` 的全部正值寫入點（排除 `==-1`／`!=-1` 的讀取比較）

```
已被 §0③ 列到：outpost_system.gd:401（換手）／start_build（經 begin_subteam_construction :799）／
  faction_ai_system.gd:7155（_commit_settle_site，紮根 commit-hook）
我多找到（git grep "construction_team_id\s*=" -- scripts/simulation/，排除比較）：
  outpost_system.gd:578  start_build（本身，跟 :799 那條路同一支函式，不是新路）
  outpost_system.gd:601  start_upgrade_level  ← 只被 player_command_system.gd:992 呼叫，玩家專用，跟 NPC 無關
  outpost_system.gd:670  _begin_facility_construction（_subteam_upgrade_facility 的內層）
  outpost_system.gd:690  start_demolish        ← 只被 player_command_system.gd:1038 呼叫，玩家專用
  outpost_system.gd:830  _subteam_upgrade_level ← 經 begin_subteam_construction :802，已在既有路徑內，不是新路
  outpost_system.gd:883  demolish_with_control  ← 玩家專用
⇒ 上面大部分不是新發現（同一支函式內部、或玩家專用、跟 NPC「建設」選項無關），
  但 `_subteam_upgrade_facility`（:841）本身還有**另外三個完全不同的呼叫者**，都在 faction_ai_system.gd：
  :6174  _evaluate_independent_infrastructure（:1482 呼它，受 team.indep_infra_next_tick cadence 閘）
  :6246,:6253  _evaluate_infrastructure（:1361 呼它，受 f.infra_eval_next_tick cadence 閘）
  :6570  _ensure_rescue_build_started（"自救建田" 選項專用，跟「建設」是不同 option）
⇒ ★★前兩個（INFRA／INDEP_INFRA）是**完全獨立的週期性評估層**：
  有自己的 cadence 欄位（`infra_eval_next_tick`／`indep_infra_next_tick`）、自己的 `DecisionTier` 標記，
  **不經過 `rank_scored`／不是任何 option 被 commit 出來的結果**——
  它直接呼 `_subteam_upgrade_facility(state, team, tile, pick["facility"])`，完全繞過
  `_dispatch_builder`（T2 要 tap 的那支函式）
```

## 判決

```
★你問的是「我沒核這個負斷言對不對」——核完：**不對，不完整**。
  §0③ 宣稱的「開工地的路徑」只列了跟「建設」option 直接相關的三條，
  而 INFRA／INDEP_INFRA 這條完全沒被提到，它也會讓 construction_team_id 被設成某隊
⇒ ★但這不直接等於「A1 的根因在這裡」——INFRA 層呼的是 `_subteam_upgrade_facility`
  （**升級既有設施**），而 Team0／Team3 的符合「宣稱建設連續29天」聽起來更像是
  **從無到有起一座新據點**（bootstrap，`start_build`／`begin_subteam_construction` 那條）；
  若他們今天 home_count＝0（沒有任何據點），INFRA 層大概摸不到他們——
  ★但我沒有查到 Team0／Team3 的 home_count，這句是推論不是查到的事實
⇒ 處置：§0③ 的措辭要改——不能再寫成「開工地的路徑只有這幾條」（那是我和你都查過還漏一條的負斷言），
  要改成「本票鎖定的路徑是這幾條（給理由：bootstrap 相關）；INFRA／INDEP_INFRA 那條獨立評估層
  今天不在本票範圍，★但要先確認 Team0／Team3 不是走那條（印他們的 home_count／最近一次
  infra_eval 的 tick），否則 T2 可能 tap 錯函式」
```

# 2 ★T2 大部分已經存在——先讀既有床，別重做

## 證據：7 個早返回**已經各自掛了**具名計數，而且已經有床在對帳

```
`_dispatch_builder` 的 7 處 return false（:5379/:5384/:5411/:5416/:5431/:5449/:5455），
  每一處旁邊都已經有：
  :5378 funnel.build_gate.busy_subteam／:5383 tile_occupied／:5409-5410 cost(+cost.<res>)／
  :5415 no_advisor／:5430 pop／:5448 food_bridge（註解逐字「併進同一族，讓六道閘可以直接相加對帳」）／
  :5454 subteam_dispatch
  成功：:5510 funnel.build_gate.dispatched
`scripts/debug/construction_funnel_bed.gd`（`@bed-kind: diagnostic`，★既有床，不是我新找的名字）：
  GATES 常數（:17-19）逐字列出上面全部 8 個鍵；床頭註解逐字：
  「判準三條：①每段都要有分母②fp不變③每顆counter至少非零過一次，恆0的要講明是掛錯位置還是不可達」
  ⇒ ★★這正是 T2／P3 想做的事，已經存在、已經在跑
```

## 判決

```
★★★T2 原樣寫會是重做一份已經存在、命名體系還不一樣的東西（你的 build.not_dispatched.<名>
  vs 既有的 funnel.build_gate.<名>）——兩套名字並存正是判準庫那條「兩份會漂，漂掉的那份是靜默的」
⇒ 處置（二選一，不是我裁 WHAT，給你技術選項）：
  ①T2 整段改成「先跑 construction_funnel_bed.gd（配 Team0/Team3 的條件：無據點、資源充足、
    committed 建設），讀它的輸出——若某道閘恆 0 且其餘閘加成功 < 分母，那就是答案，不必新建 tap」
  ②若既有床跑完之後仍答不出來（例如它的 config 從來沒讓 Team0/Team3 類型的隊落進這支函式），
    T2 縮小成「只確認 Team0/Team3 真的有進入 _dispatch_builder（分母 tap 命中 ≥1 次）」，
    不必重複 7 個已經存在的具名計數
⇒ ★不管哪一條，T1（每日四分類）仍然是全新的、沒有重複，正常送審
```

# 3 (b)(c) 核過

```
(b) 7 這個數字我逐行讀過（不是信 awk）：:5379/:5384/:5411/:5416/:5431/:5449/:5455 每一處都是
    真正的頂層 return false，各自緊鄰一個既有 Probe.bump，沒有巢狀函式、沒有註解裡的 return
    ⇒ 數字對，而且比你猜的更好：這 7 個不只是「真的早返回」，還已經各自有名字
(c)「工地屬別隊」我判是**正常的前閘狀態**，不是該獨立成第三類「異常」：
    一支隊選了「建設」、target=自己腳下，而腳下已經有別隊的工地 ⇒ 下次牌到 `_dispatch_builder`
    時應該會被 :5383 的 tile_occupied 擋下 ⇒ T1 的 (ii) 與 T2 的 tile_occupied 計數
    在健康系統裡應該大致同向變化——這給你一個順手的交叉核對：(ii) 多但 tile_occupied 很少，
    代表那些隊根本沒被派去嘗試（卡在更上游），不是被 tile_occupied 擋下
```

# 4 判決

```json
{ "verdict": "issues",
  "premise_contradiction": true,
  "scope_of_contradiction": "§0③『開工地的路徑只有這幾條』——INFRA/INDEP_INFRA 兩個獨立 cadence 層直呼 _subteam_upgrade_facility，完全不在列表裡",
  "issues": [
    {"claim": "§0③ 窮盡列出開工地的路徑",
     "file_line": "faction_ai_system.gd:1361(_evaluate_infrastructure)／:1482(_evaluate_independent_infrastructure)／:6174,6246,6253,6570(_subteam_upgrade_facility 呼叫點)",
     "truth": "有一條完全獨立、不經 rank_scored／_dispatch_builder 的 cadence 層會設 construction_team_id；是否影響 A1 診斷取決於 Team0/Team3 的 home_count，需先查"},
    {"claim": "T2 要新建 7 個具名早返回計數並對帳",
     "file_line": "faction_ai_system.gd:5378-5510（funnel.build_gate.* 共8個既有計數）；scripts/debug/construction_funnel_bed.gd（既有對帳床）",
     "truth": "7個計數與對帳邏輯已存在並已有專床，T2應改成先讀那支床而非重新命名重建"}
  ],
  "note": "(b)(c)核過沒問題。這兩列都不是推翻T1或整張票的立意，是指出§0③的負斷言要補一句、T2要先查既有床再決定要不要寫新碼。改完敲sha，我優先看這兩處。" }
```

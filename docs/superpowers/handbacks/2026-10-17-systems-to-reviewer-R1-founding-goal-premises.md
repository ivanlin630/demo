---
from: systems
to: reviewer
status: open
slice: 開點登進既有長程目標表（結構輪之後第一張；藍圖 RULING 2026-10-16-blueprint-to-systems-RULING-founding-is-a-goal-in-the-existing-means-end-registry-not-a-new-desire＋2026-10-17 RULING-merge-structure-round-…）
topic: R① 寫 HOW 前請 factcheck 下列前提（main f83a6edc2，結構輪已合）；其中 P2 我讀到的跟藍圖信不一樣，P7 兩道舊門是藍圖點名要查的
---

# 為什麼走 R①
新概念大框（開點變成目標表一列、四條當場開點的路收斂成它的執行端），而且前提含未驗的 code 斷言。下列每條請給 ✓／✗＋file:line；✗ 的話，請寫出實際是什麼。

# 前提
**P1 表上登了什麼**
- `scripts/simulation/decision/goal_registry.gd:14-19` 維持類 4 個（food／material／tools／weapons；`maintain_coin` 已拆）。
- `:24-33` 設施 8 座。
- 沒有任何開點列。
- 藍圖信寫「5 種資源維持」，我讀到 4 種。

**P2 沒據點的隊跑不跑目標迴圈**（★我讀到的與藍圖信不同）
- 藍圖信：「`goal_resolver.gd:88` 早返回 ⇒ 沒自家據點的隊整個目標迴圈不跑」。
- 我讀到的：
  - `decision_engine.gd:102` `ensure_maintain_goals` 對每支隊都呼；
  - `:498` `frontier_candidates` 也對每支隊都呼（只擋 `state／team == null`）；
  - `goal_resolver.gd:46-91` 裡跟據點有關的，只有設施列：`otile == null` ⇒ 設施列移除（:70 `no_otile`），也不重掛（:87-91 只數 `readd_blocked_no_otile`）；
  - 維持列與它們的前置候選照跑。
- ⇒ 我的判斷：沒有要退場的早返回；新的開點列只要掛／退不讀 `otile`，沒據點的隊自然會跑。請驗這一條。若成立，藍圖 WHAT 第 3 條在 code 上已經是真的，HOW 不必拆任何東西。

**P3 四條當場開點的路**（行號在結構輪合併後）
- ① 紮根：`options.gd:330` 起，`TASK_BUILD` 自己蓋；applicable 讀 `can_settle_here`／`settle_resume_site`／`own_camp_pos`。commit 端是 `faction_ai_system.gd:7402 _commit_settle_site` → `OutpostSystem.start_build`。
- ② 擴點：`options.gd:360` 起，delegate `build_type`。applicable 要「有家」⇒ 沒據點的隊走不到。
- ③ 採料遠端開點：`goal_resolver.gd` `_resolve_resource_prereq` 內，約 :1174 `_mk_delegate_candidate(... PREREQ_LOCATION ..., {"build_type":"civilian"})`。
- ④ infra 段 (3)：`faction_ai_system.gd` 約 :6554-6558，呼到 `_dispatch_builder`。
- 請驗：還有沒有第五條（例如子隊抵達後開工 `outpost_system.gd` 約 :1052、子隊紮根 `faction_ai_system.gd` 約 :7436）？哪些在同一 tick 就出發或開工？

**P4 既有前置種類能不能直接承接**
- `PREREQ_RESOURCE` 走 `_resource_prereq_candidates`（買／採／守），qty 走 `need_keep`。
- `PREREQ_LOCATION` 走 `_resolve_location_prereq`（:1462-1481），產 `TASK_MIGRATE` 到最近可達的格，是把隊移過去，不是選址。
- `MANPOWER／FACILITY／SUBGOAL` 是 stub（:315-317 註解），不出候選。
- 請驗：開點的「地點」前置若要讀選址秤（結構輪 §三之二的採料天數項），是不是只能新寫一種 location 解法，不能直接用 :1462？

**P5 payoff**
- `derived_payoff`（:194-221）：設施列讀 `FACILITY_DEFICIT_DEF.outputs` 的缺口×價；沒有資源前置的列退回表值（gate-ok 註）。
- 請驗：開點列若掛資源前置（material），會掉進 :213-221 那支「維持類」公式（pop×TARGET_PER_POP − stock），而不是開點自己的價值。若是，payoff 要另寫一支，不能沿用。

**P6 需求帳接點**
- `NeedOracle._new_outpost_need`（結構輪 §三之三）今天只讀「已承諾」兩種：在路上的 `TASK_BUILD`、採段工地。
- 請驗它的位置與呼叫者：`need_keep` 的建造加數、`trade_valuation` reserve、`coin_treasury.gd:54`。要擴成「掛上的開點目標」，是不是只改這一支？

**P7 兩道舊門（藍圖 2026-10-17 點名：量擋下多少、被擋的本來會去哪；12 人該翻成秤，與 MIN_PARENT_POP_AFTER_DISPATCH 同源禁兩份；沒帶隊人先分物理還是門）**
- 人數：
  - `_dispatch_builder`（`faction_ai_system.gd:5510` 起）的 `pop = maxi(6, level*4)`，擋 `leader_team.population < pop*2`（TEST VALUE，L1 ⇒ 12）。
  - 同一件事另有兩處用另一套：
    - `faction_ai_system.gd:899-900`：`settler = clampi(pop/4,2,5)`，擋 `pop − settler < MIN_PARENT_POP_AFTER_DISPATCH(10, :187)`；
    - `goal_resolver.gd:568-569`：同式。
  - 而實際派出的人數是 `pop`＝6，不是 settler。
  - ⇒ 我讀到同一個「派了之後母隊剩多少」有兩份規則、派出人數也有兩份（6 對 2–5）。請驗。
- 帶隊人：`_pick_or_promote_advisor`（:5860-5868）只在 `_pick_advisor == -1` 且 `PersonGenerator.generate_for_team` 回 null 時回 -1。
  - 請驗 `generate_for_team` 什麼條件會回 null：是真的沒人可升（物理，例如 anon 0），還是條件卡住（門）？
  - 戰國世界修後擋下 257 次（交件信 `docs/superpowers/handbacks/2026-10-17-implementer-to-systems-DONE-structure-round-probes-v8-not-passed-worldfp.md` 六道閘表）。

**P8 承諾生命週期**
- 藍圖 WHAT 2：跨日持有＝既有 `goal_state`，承諾照「唯二出口」。
- 請驗：`goal_state` 的元素今天有沒有 `target` 欄可以放選定的格（:37 寫 `"target": null`）？有沒有任何讀者假設 `target` 恆為 null？

# 我先不寫 HOW
等 R① 回來。P2 若 ✓，我會回藍圖更正那一句（不改 WHAT）。

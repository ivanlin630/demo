---
from: reviewer
to: systems
status: consumed
topic: "[R② 異質框外審 ISSUES] means-end HOW spec — 2 must-fix(util-scale 護欄/tile-resolver belief-source)+4 次要，別逕 dispatch"
---

# R② 判決：means-end HOW 架構 spec — **issues**（用不同模型/Sonnet 代跑，明確 refute prompt）

先讀完整份 HOW spec + 你指定 8 審點，再獨立核你的 code citation（非只信 agent，我自己複驗兩條最重的）。判決：**issues，2 項 must-fix，4 項次要（可 plan 階段補）**。

## ★must-fix ①（HIGH，你的審點1）：goal candidate util 對 static option util **零架構護欄**
我自己已讀過 `decision_engine.gd:48-141`（GATE-A/extraction 審查時已核），可獨立確認 agent 這條數學：static option util = 小量 term 和（大致 [0,2]）× `NeedHierarchy.consistency_coeff`(∈[0,1]) + 條件式 boost（SURVIVAL_BOOST_MAX 2.5 / THREAT_BOOST_MAX 0.5，皆 floor-gated）+ COMMITMENT_BONUS(0.3)。**每個 static option 都先被 coeff 壓過才可能碰 boost。**

HOW spec §8 把 goal candidate 併入同一 `scored` 陣列，**完全不經 `consistency_coeff`、不吃 boost**（因為它們不在 `DecisionOptions.applicable(ctx)` 集合裡）——這點結構上為真。但 spec 給的安全論證「發展型 candidate 會被折現自然壓低，絕境時贏不了 survival boost」**不是架構保證，是假設**：`payoff` 估法 + 折現函數形（§7）明文留給 plan 階段 TEST VALUE，**HOW 文件本身沒有給 candidate.util 任何上界宣告**。若之後隨便挑的 payoff 數字夠大、折現不夠陡，一個未被 coeff 壓過、未被排除在 boost 外的 candidate util 理論上就能蓋過 `static_u + SURVIVAL_BOOST(2.5)`——直接打破全引擎仰賴的「survival 恆贏」不變量（`THREAT_BOOST_MAX < SURVIVAL_BOOST_MAX` 那條硬約束背後的精神）。因為紀律是 whole-system-first（S1-S7 建完才 measure），這個洞可能一路潛伏到 S7 才被人玩出來。

**要求**：HOW 層級（非留 plan）明確二選一：(a) 給 `cand.util` 明文上界宣告，或 (b) 讓 goal candidate 也過 `consistency_coeff`（或等效壓制機制）——非「相信折現會救我們」。此外建議 S2（資源型 candidate 首次產生非零 util）+ S6（折現首次接上）各加一個**合成 unit-level range/invariant 檢查**（非 gameplay measurement，不違反 whole-system-first 紀律）：斷言「絕境合成 ctx 下，goal candidate 永遠贏不過 survival-boosted static option」。

## ★must-fix ②（MEDIUM-HIGH，你的審點3）：`find_nearest_tile` 通用 tile-resolver **搜尋來源未定案**，含混過 constitution_gate
我自己複驗兩條 citation（非只信 agent）：
- `invariants.md:192`：**★★市集＝零豁免、必經 belief**（2026-07-19 用戶定，否決舊「公開地標豁免」）——`_nearest_market_outpost` 曾被判「全 `state.world.tiles` 掃無 discovery gate = god-view 後門」，強制建 `team_market_known` belief store 才過關。
- `constitution_gate.gd:12,22,41`：`GV_FILE_RE` 含 `decision/` 路徑（若 GoalResolver 放這裡，機制看得到）；`gv_mapscan` 偵測器對「全圖 tile 迭代」標記——**但 :41 註解「地理=公共知識 legit → gate-ok」**，即**純地形類全圖掃有先例可判合法**（非一律違憲）。

**★我的訂正/補充（比 agent 原判更精準）**：這不是「全圖掃一律違憲」，是**分情況**——地形本身（forest terrain）屬公共地理，或可比照既有 gate-ok 先例；但 WHAT spec §3 給的 location 前置範例明寫 `{kind:"location", terrain:"forest", control:true}`——**`control` 是「我方是否控制此地」，這是會變動的所有權狀態，正是市集判例打的那類「需傳播非全知」資訊**（誰控制哪塊地，非固定地理）。∴ `find_nearest_tile` 若真通用到能查「control/ownership」類條件，就踩到市集同款地雷；若只查純地形類條件，可能有 gate-ok 先例可循。

**要求**：HOW spec 明確拆開——「純地形/物理地理」查詢 vs 「所有權/動態狀態」查詢，不能用同一個未分流的 generic resolver 含混過去。若後者需要，§12 應明列「建通用 known-tiles belief store（鏡射 `team_market_known`）」為**明確 in-scope 交付項**，非留白；且新模組檔案路徑應釘在 `GV_FILE_RE` 涵蓋範圍內（`decision/` 底下即可），否則憲法閘看不到、會悄悄溜過。

## 次要（4 項，plan 階段補即可，不擋 dispatch）
3. **`GoalInstance.target` 語意模糊**：§2 標「跨 tick 持久」但沒說是「resolver 每 tick 重算覆寫」還是「一次鎖定不再變」——後者等於偷渡 plan-state（違 §9「無 plan-state」自述），需明文定案非留implicit。
4. **facility/subgoal 遞迴子目標的 discount 歸屬未定**：往下遞迴時新合成的中繼子目標，`created_tick`(折現用)算誰的、resolver 是唯讀卻要合出新實體，深度隨 tick 變動時 label 穩定性只靠既有 COMMITMENT_BONUS（為小固定集設計，非為組合爆炸的合成 label 空間設計）——需講清楚。
5. **兩個獨立 re-entrancy guard（`goal_type` keyed 的 registry visiting set + `res` keyed 的既有 `_construction_visiting`）耦合後不自動保證聯集無環**——各自健全不代表交叉圖安全，需一個橫跨兩張圖的協調機制或明確論證。
6. **委派 peer option（組件D）**：風險較低——有 applicable 硬閘（pop-guard）擋「委派恆贏」，util 校準可留 plan 階段。

## 判決
`issues` → 回你修（must-fix ①②在 HOW 層級補，非丟給 plan TEST VALUE）；修完再 R②複核。次要 4 項可與 must-fix 一起補或明記留 plan，你判斷。別逕 dispatch S1 給 implementer。

# SLICE B — 領主分配政策 HOW spec（2026-08-01）

**arc**：後勤統一 §②分配政策（[[project_logistics_unification]]）。WHAT 定案（blueprint）：領主拿到供給後怎麼分給居民＝**人格 WEIGH 非腳本福利**（義氣→發、貪婪→囤/賣外賺、忽視→不管），餵現有 unrest/defection 管線。

**★約束1（用戶硬定，統一搬運脊椎）**：分配走**同一 convoy 原件**（`_tick_convoy` FETCH→OUTBOUND→DELIVER→RETURN），DELIVER 終點＝居民隊（≠market_order）。禁另刻平行搬運。

---

## §0 現況（premise 坐實 file:line）

| 事實 | file:line |
|---|---|
| 居民現況＝**純機械水管**：每日 auto-consume `team+own_granary_tile.public_storage["food"]` merged pool、**無領主政策層** | resource_system:126-141 |
| UnrestBank `add(team,n,reason)`/`reduce`/`reset`→`team.unrest_turns`；`unrest_turns≥20`→defection fire | unrest_bank:5-16 / event_faction_defect:9 |
| persona：`greed=leader.values.get("貪婪",0.5)`、`honor=leader_p.values.get("義氣",0.5)`（[0,1]、義氣＝anti-greed、無獨立慷慨欄） | faction_ai:196/1026/1141 |
| convoy DELIVER 現終點：`_tick_convoy`(faction_ai:1774)→`_resolve_market_at_outpost`(interaction:731)→`_market_visitor_sell(deliver_cargo)`(interaction:815)；`deliver_cargo>=0` bypass reserve。**現只 貨主 outpost `tile.market_orders`**（interaction:758） | — |

**病**：占領村居民（獨立隊、自產可能 < 消耗＝deficit）跨距靠自己 local granary、領主 capital vault 的 surplus 不會流過去。無政策＝無戲（領主人格不影響居民死活）。

---

## §1 核心 seam（機會成本模型、零新市場）

**剝削≠新內部 coin 市場**。領主 surplus 有兩條既有出路競爭同一 argmax：
- **賣外面賺**（現成 trade/deliver convoy util，goal_resolver `_deliver_candidates`）。
- **餵缺料居民**（★新 `_distribute_candidates`）。

**persona WEIGH（憲法非 GATE）**：
- **義氣高**→ distribute util 放大 → 餵居民贏 argmax → 居民 fed → `UnrestBank.reduce`。
- **貪婪高**→ distribute util 壓低（surplus 寧賣外賺）→ 居民持續 deficit → `UnrestBank.add` → unrest↑ → defection。
- 非硬鎖：貪婪領主 loyalty 崩在即（unrest 逼 defection）仍**可**發（util 動態、survival-like 反制），義氣領主自己斷糧時也讓位求生。

∴ 剝削＝**withhold 的機會成本**（賣外賺而不發），非居民付錢。零新定價/支付機制。

**感知鐵律 note**：分配決策讀**本勢力自己**居民 deficit（intra-faction 自有後勤狀態＝合法知情、非 god-view 讀敵隱藏態）。不涉隔空/敵情 belief。✅

---

## §2 元件（新增/擴充，implementer 做）

### A. deficit 偵測（trigger）
- 領主（faction 有 capital vault surplus）掃**自有 resident-teams**，投影 food runway＝`(team_food + local_granary_food) / (pop × FOOD_PER_PERSON_PER_DAY)`（複用 resource_system:126 算式）。
- runway < `DISTRIB_DEFICIT_DAYS`（新常數、初值 e.g. 4 天）＝deficit 候選。

### B. `_distribute_candidates`（新，goal_resolver.gd，仿 `_deliver_candidates`:125）
- 對每個 deficit resident-team，生成 candidate：
  `{task:TASK_CONVOY, target:resident_team_tile, cargo:"food", qty:補到 runway 目標的量, kind:"distribute", terminus_team_id:resident.id}`。
- **util**（`_candidate_util` 家族）：`deficit_severity × HONOR_WEIGHT(honor)`，其中 `HONOR_WEIGHT = f(honor,greed)`（義氣放大、貪婪衰減，e.g. `base × (0.3 + honor) / (0.3 + greed)`）。競 argmax 對 trade-util（`_deliver_candidates`）。**GOAL_UTIL_CAP=1.5 沿用**。
- source vault＝領主 capital granary surplus（FETCH 階段既有 `_load_convoy_cargo` faction_ai:2964 取源）。

### C. DELIVER 終點擴充（interaction_system.gd）
- `_resolve_market_at_outpost`(731)：加 **resident-DELIVER 分支**——若 `task_extra_data.kind=="distribute"` 且抵達 tile 有 `terminus_team_id` 對應 resident-team → **直注 food 入 resident team pool**（`resident.resources["food"] += deliver_cargo` 或注 local granary），**無 market_order、無支付、無 reserve**（純施捨轉移）。
- 沿用 `deliver_cargo>=0` bypass-reserve 路（interaction:815），但終點是 team pool 非 sell-settle。
- convoy RETURN 照舊（faction_ai:1774 尾）歸建釋 pop。

### D. unrest 耦合（新回饋，resource_system 或 faction_ai per-tick）
- resident-team per-tick（或 per-cadence）：
  - 持續 deficit（runway < `UNREST_STARVE_DAYS` e.g. 2、且本 cadence 未受 distribution 補）→ `UnrestBank.add(resident, 1, "領主斷糧/剝削")`。
  - 受補 fed（runway 回升 > 安全線）→ `UnrestBank.reduce(resident, 1, "領主施捨")`。
- 餵**現成** `unrest_turns≥20→event_faction_defect`（零新 defection 機制）。

**★全量暫態可觀測性（憲法）**：新 decision（distribute util per-option）、新 resource move（distribute DELIVER 量）、新 state（resident deficit runway、unrest 增減源）**必接 tap**（telemetry），否則 QA 故事性判官盲。distribute candidate 的 util 分項（deficit×persona）入 per-option dump。

---

## §3 dev-time 便宜驗（★約束3，非跳過）

`scripts/debug/` 新 bed（仿 `peaceful_economy_bed`）：
- fixture：1 領主（capital vault food surplus）+ N resident-teams（deficit：pop×burn > local food），兩型領主（義氣高 / 貪婪高）各一 run。
- **硬斷**：
  1. **distribute 真 fire**：義氣領主 → distribute convoy dispatch>0、DELIVER 真注 food 入 resident pool、resident runway 回升。
  2. **剝削真餵 unrest**：貪婪領主 → distribute 讓位 trade（util 輸）→ resident 持續 deficit → `unrest_turns` 逐 cadence ↑ → 逼近/觸 defection≥20。
  3. **persona 分岔**：同 fixture 只換 leader.values 貪婪/義氣 → distribute 決策翻轉（WEIGH 非 GATE 證據）。
  4. determinism（seeded、3 跑 byte-identical）、observe 路徑零 RNG（[[feedback_observer_no_global_rng]]）、gates 綠。

## §4 隔離（★約束2）
- branch `feat/logistics-sliceB-distribution`（獨立、防 floor 式誤 merge、[[feedback_held_work_isolate_worktree]]）。

## §5 一次合量（★約束4）
- 甲乙各 dev-verify 綠後，**一次**整世界 warring 合量 + tap 分帳（分配 fire? unrest 餵? + 乙 join.resolve↑? + 全貌活/大小/政治）。非多跑昂貴 run。

---

## §6 ★WHAT-fork 呈 blueprint（剝削模型，你裁）

「貪婪囤+**高價賣居民**」HOW 有二解：
- **(A) 內部定價/居民付 coin**：居民有購買力、內部 coin 市場、領主定價剝削 → 大（需居民 coin 經濟 + 定價層 + 支付結算）。
- **(B) 機會成本扣留（本 spec 採）**：領主 surplus 賣外賺 vs 發居民＝同 argmax persona weigh；貪婪扣留→居民餓→unrest；無內部支付/定價。小且戲足（貪婪領主餓死子民→謀反）。

**我推 B**（最小、複用脊椎、零新市場、戲一樣）。若你 WHAT 要 A（居民真付錢的剝削經濟）則 SLICE B 擴（+內部 coin 層）。**你裁 A/B** → 我定稿 spec → R² → dispatch。

## §7 工序
甲 HOW spec（此檔，B 模型）→ **blueprint WHAT-confirm 剝削模型** ‖ **R² 設計審** → CLEAN+confirm → dispatch implementer（隔離 branch）→ dev-verify → 乙合量。

# Spec — Consolidation S-A 併決策統一（技術 / systems HOW）

> 願景 = `2026-07-10-consolidation-unified-decision-design.md`（blueprint，已收 reviewer 框①三靶）。本檔 = S-A 技術 HOW（term/context/seam）。屬決策統一 program [[project_unified_decision_framework]]。**S-B 降服/附庸另 slice**。

## 目標（S-A，★blueprint 重定 2026-07-10）
**＝食壓驅併＝有機政體湧現 + S-B 政治層地基。非殲滅修復**（因果鏈反向已證、pop-% 已 S1 絕對解、殲滅已裁接受不可見）。價值判準 = **gate#1 餵養真解生存非搬餓**（S-A 成敗核心）。
技術：退役 `consolidate_drive` **雙 flat**（eval flat + weight flat 1.0）+ `join_drive` weight/gate 補齊 → **收進 rank_scored 真生存/人格 term 秤**；`_find_absorber` 納**餵養能力**（gate#1 防搬餓）；接受方也 rank 秤（雙邊握手，靶C 薄層邊界誠實寫）。

## 現況錨點（characterize，★異質框外審修正 2026-07-10）
- `terms.gd:89-91 join_drive`：gate `投靠 + has_strong_neighbor`，**eval 已食壓 scaled**＝`DESPERATION_SCALE * maxf(0, DESPERATION_DAYS - food_days)`（與 camp/beg/buyfood 共 pattern）。weight `join`=義氣/信義/求生欲(`:222`)。**∴ join 真 delta 僅 weight 側（+野心負向）+ gate 降 applicable，eval 別重造（原 spec 誤稱「無食壓」=異質審抓的 premise_contradiction）**。
- `terms.gd:158-161 consolidate_drive`：**雙 flat**＝eval flat `CONSOLIDATE_DRIVE` const(`:161`，非食壓 scaled) **+** weight flat 1.0(`:229`)。**= 真 flat 病靶**（join 不是）。S-A 主修＝consolidate eval→食壓 scaled（mirror join `:91`）+ weight→人格。
- `faction_ai:1562 _find_absorber`：選 absorber，**零 food 檢查**（靶A 靶）。`consolidate_target_of`→ 餵 `ctx.consolidate_target_id`(`decision_context:266`)。
- context 已有：`food_days:9`（=ef/(pop×FOOD_PER_PERSON_PER_DAY)）、`home_food:54`、`survival_pressure` term、`has_strong_neighbor:40`。
- 投靠 contact resolver 已存在（`_try_join_target`，join.resolve 活）——**靶C 薄層復用點**。

## HOW-1：term 退 flat → 生存×人格秤（地板1：真 term 非補償閘）
**驅力 = 食壓（eval magnitude）× 人格（weight）**，argmax 湧現（地板2：無 `pop<N` 硬寫）。

### `join_drive`（投靠=弱方求生 push，走 subteam join）
- **eval 別動**（已食壓 scaled `:91`，異質審修正）。唯一 eval 改＝`has_strong_neighbor` 硬 gate → **applicable 前提**（`options.gd` 側，非 eval）＝食壓驅 join 不再限「有強鄰」才 fire。
- weight `join` 保（義氣/信義/求生欲）+ **野心負向**：野心高者不甘投靠 → weight 疊 `_low_ambition_factor = clampf(1 - 野心, ...)`（design：野心低+餓→投靠 util 高）。
- 威脅加碼（可選）：`+ THREAT_JOIN_W * threat_norm(ctx)`。

### `consolidate_drive`（整併=全池化合併，弱方主動選）＝S-A 主修（真 flat 病）
- **eval `:161` 退 flat `CONSOLIDATE_DRIVE`** → 食壓 scaled（mirror join `:91`：`DESPERATION_SCALE * maxf(0, DESPERATION_DAYS - food_days)`），gate 保 `consolidate_target_id!=-1`。
- **weight `:229` 退 flat 1.0** → `consolidate` weight = f(求生欲, 1-野心)（餓+不稱霸傾向併大）。

### 吸附側 pull（強方收弱隊）＝接受方 rank（見 HOW-3）
- 野心/統領力高者 weight 高（願當吸附方）——由**接受方**的 accept-util 表達（非發起方 term），見 HOW-3 握手。

## HOW-2：`_find_absorber` 餵養能力 gate（★靶A 硬 gate，防搬餓）
`_find_absorber`（`faction_ai:1562`）選 absorber 時**必過餵養能力**：
- 新 context/helper：`absorber_food_surplus = absorber.food_days`（併前餘命）；`combined_food_days = combined_ef / ((absorber.pop + absorbed.pop) × FOOD_PER_PERSON_PER_DAY)`（併後合隊餘命，ef=兩隊 food 存量和）。
- **gate**：`combined_food_days >= ABSORBER_MIN_SURVIVE_DAYS`（併後合隊須真能撐；吸附者併前有 surplus 才吸）。不過 → 該 absorber 不選（非把餓稀釋進更大隊）。
- = design「餵養真解生存非搬餓」的 code 面。`consolidate_target_of` 同步過此 gate（context target 一致）。
- **同 faction 限制**：S-A 保守**維持同 faction**（跨勢力投靠=脅迫語境，歸 S-B 降服）。註記放寬待 S-B。

## HOW-3：雙邊握手（★靶C 薄層，誠實邊界）
**承諾＝驅力統一（雙方 util 皆 rank_scored 出），非「跨隊時序協調零 bespoke」。** 單隊 per-cadence argmax 無法原子做雙邊同意 → **薄層 = contact-time resolver**（復用既有 `_try_join_target`/interaction resolver 骨架，非新概念）：
1. **發起方**（弱隊）argmax 選 `投靠`/`整併` → `to_task` dispatch 走向 absorber（move_target=absorber，既有）。
2. **接受方**（absorber）在**接觸時** resolver 查其 **accept-util**：absorber 側 rank 一個輕量 accept 判斷（野心/統領力 weight × 有餘裕收 → 願收；食壓自身太重 → 拒）。**這是薄層**：非 absorber 每 cadence 主動秤全 option，而是被動 on-contact 秤「收不收這隊」。
3. accept → `merge_teams`（整併）/ subteam attach（投靠）；reject → 發起方回退（下 cadence 重 argmax，可能轉別 absorber 或別 option）。
- **邊界誠實聲明**：此 resolver = bespoke 薄層（contact 觸發），**不假裝零框外**。**accept-util 邊界公式仿 `_resolve_aid_request`(BEG) 節制原則＝單一 util 比較非全 rank**（reviewer 顯式點名前例：judge 盤點確認 accept-util 與 BEG resolver 結構近但非同 judge/不同 option 域，不違 01 鐵律）。**★量級但書（異質審抓）**：同構的 `_resolve_aid_request`(BEG) 實測 ~75 行完整次要評分系統——「薄層」史上守不住，**別承諾「~1 函數」**；accept-util 若滾成 absorber 側完整 rank 就是第二決策引擎（違統一）。設計約束：accept-util **限單一 util 比較（收/不收）非全 option rank**，超出即回報 blueprint 重估「薄層是否撐得住」。復用 interaction-resolver seam（judge 盤點：非重造，同 BEG/JOIN/aid 模式）。

## HOW-4：consolidate cadence gate（★perf，S-A merge 前置；blueprint churn 假設 systems profile 確認）
**根因確認（file:line）**：`decision_context.gd:262-266` 每 faction 成員（非子隊非 leader）**每 tick** call `consolidate_target_of`→`_find_absorber`（`faction_ai:1562`）O(N) 掃全 faction 成員，**無 cadence gate**（`subteam_eval_next_tick`/`threat_eval_next_tick:357` 有、成員整併塊漏）。S-A `consolidate_drive` 食壓 scaled → 餓隊 argmax 選整併 → dispatch → 餵養 gate#1 拒 → re-dispatch **churn**（dispatch:accept≈281:1），疊每-tick O(N) = 2x 慢 + 抖動走位。
**修 = cadence gate（鏡射 `SUBTEAM_CADENCE`，1 日級）**：
- `TeamData` +`consolidate_target_cache: int`(-1) + `consolidate_eval_next_tick: int`。
- `decision_context.gd:266` 前 gate：`if current_tick >= team.consolidate_eval_next_tick: cache = consolidate_target_of(...); next_tick = current_tick + CONSOLIDATE_CADENCE`；否則 `c.consolidate_target_id = cache`（用快取，不重掃）。
- `CONSOLIDATE_CADENCE = TimeScale.TICK_PER_DAY * 1`（TEST VALUE）。
- = 砍 O(N) 掃頻率（每 tick→每日）+ churn（餓隊不每 tick 重派）→ perf 解 + 行為更穩。determinism 保（cache 純節流，同 seed 同軌）。
- **S-A merge 前置**：大窗現 churn 跑不動（60min timeout），cadence 修好 measurer 才拿得到 gate 樣本。

## HOW-5：整隊合併可達性 de-patch（★S-A merge-blocker，18-seed 揭 TASK_MERGE 0/8333）
**根因確認（code 邏輯確定非假設）**：`options.gd:247` 整併 to_task 回 `{"task": TASK_MERGE, "order_target": ctid}`，但 **`_decide_unified` 成員 dispatch 尾巴（`faction_ai:1508-1512`）只處理 `combat_target`+`social_target`，漏 `order_target`** → `team.order_target_id` 從沒被寫（留 -1）→ resolver `interaction_system:261`（`order_target_id==id_b`）+ `_try_merge:464`（`order_target_id!=target_id: return`）**恆 false** → `_try_merge` 永不執行 → **0/8333**。leader 路（`faction_ai:403`）有接 order_target，成員路漏 = BEG/JOIN social_target 同型 seam bug（target 欄沒接進 dispatch）。**可修可達性 bug 非結構本罕**（solo-join 走 social_target 通、整併走 order_target 斷）。
**修 = de-patch 補接 order_target**（鏡射 `:403`）→ **★parity audit 擴大**：`order_target`/`order_task` 只 leader 路（`:403-404`）接，**成員/子隊/solo 三路全漏** → 補三路（`:1509`/`:1703`/`:1776` 旁各加 order_target+order_task，鏡射 leader）。解鎖整併（整隊吸收）+ **求和（`:234` order_target+order_task）第二潛在 never-fire** 一併修。詳工單 `dispatch-parity-fix`。
- 次要（非本修，觀察）：`interaction:214` combat_target 早退可能仍擋部分（absorber 戰鬥中）→ 降頻非歸零；先修 order_target 看實際 accept 率，再判是否需第二修。

## ★S-A 硬驗收 gate（reviewer 靶A，spec 寫成 measurer 先驗項，非事後量）
1. **餵養真解非搬餓**：measurer 量併事件**前後合隊** `food_days/餘命`——須**實質改善**（`combined_food_days > 兩隊併前 min`，且吸附者併前 surplus>0）。搬餓（合隊更餓）=FAIL 打回。
   - **★空真守衛（reviewer R② 抓，pursuit 截斷病同型）**：本 gate 須先驗**併事件次數 >0**（organic full_probe 內）才有效判定；**=0 則標 `INCONCLUSIVE` 非 PASS**（「沒一次搬餓」空真≠通過），並回報**門檻 `ABSORBER_MIN_SURVIVE_DAYS` 可能過嚴致機制啞**（同 gate 太嚴=機制不 fire 的截斷病），systems 調門檻重跑。
   - **★★調門檻的 WHAT 邊界（blueprint 守則 2026-07-10，不可破）**：`ABSORBER_MIN_SURVIVE_DAYS` 可調（HOW），但**方向 = 讓真有餘裕 absorber 更易匹配，非讓餓 absorber 也能吸**。**禁為湊 `accept_n>0` 放寬到餓 absorber 可吸 = 重新引入搬餓 = 破 gate#1 存在理由**。非搬餓=不可退地板：調後 measurer 仍須驗每個 accept 事件 `combined_days ≫ joiner 原餘命` 且 absorber 併後不跌破生存線。**若 cadence 修後 accept 仍≈0 且非門檻問題（餓世界結構性無 surplus absorber）= WHAT 發現（consolidation 純飢荒世界救不了誰），回報 blueprint 重估意義，非硬調參湊數**。稀 accept+每次真救 > 多 accept+搬餓。
2. ~~**隊變大真觸殲滅可見**~~ **★砍為 side-observe（blueprint 裁 2026-07-10）**：異質審證因果鏈反向（大隊跳絕境判、rout 每 round 先於 annihilation → 隊變大更易先 rout 逃非撐到殲滅；殲滅=雙勇均等 1v1 窄縫，隊變大更難湊）。**殲滅可見非 S-A 目標**（敗北逃已裁接受不可見、pop-% 已 S1 絕對解）。measurer **只 side-observe 隊規模分布/annih**（記數不判 pass/fail、不為它調任何東西）。
3. **併=湧現非腳本**：grep 確認**無** `pop<N 就併` 硬寫；食壓 term 驅 argmax。三端/戰鬥不退化、determinism/融合閘/憲法綠。

## 觸及檔（S-A）
| 檔 | 改點 |
|---|---|
| `decision/terms.gd` | `join_drive`/`consolidate_drive` eval 退 gate→食壓 scaled；weight 退 flat→人格（求生欲/1-野心/威脅）|
| `decision/decision_context.gd` | +餵養能力 context（absorber surplus/combined 餘命）；威脅量化 norm |
| `faction_ai_system.gd` | `_find_absorber`/`consolidate_target_of` +餵養 gate（靶A）|
| interaction/resolver | 接受方 accept-util 薄層（靶C，復用 `_try_join_target`）|
| `decision/options.gd` | 投靠/整併 applicable：`has_strong_neighbor` 降 applicable 前提（非驅力）|
| `warring_harness.gd` | +併事件前後 food_days/隊規模分布/殲滅 探針（3 gate）|

## 常數（TEST VALUE，measurer 校準）
`JOIN_SAFE_DAYS`(餘命門檻~5)、`THREAT_JOIN_W`(0.4)、`ABSORBER_MIN_SURVIVE_DAYS`(併後合隊最低餘命~7)、`accept-util` 人格權重。

## 流程
spec-lock 前 **reviewer 對抗②（審本 spec）**——**★大架構 call（新 option-set 語意 + redirect 大工 + 動決策腦核心）三對齊 → 升異質 refute 框外審**（別 Opus 代）。CLEAN → implementer → measurer 3 硬 gate → 數字 to:blueprint 判因果鏈（尤其靶A 搬餓/隊變大見殲滅）。**S-B risk 清單（靶B subteam 骨架硬假設）留 S-B 動工前**。

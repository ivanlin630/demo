# HOW spec：決策狀態「推進」與「讀取」解耦（EWMA advance 出 gather）

date: 2026-08-20 ／ owner: systems ／ 溯源：specimen 非中立性 investigation③ 根定案（implementer 2026-08-20）
狀態：待 R② → dispatch。**12mo 大考 blocker#1 的根修**。

## §0 一句話
`DecisionContext.gather` 目前**每被呼叫一次就推進一次持久 EWMA**（`decision_context:565` `team.need_urgency` + `:569` 由它導出的 `team.plan_phase`）。把「推進」從「讀取」裡拔出來：`gather` 預設**唯讀**，只有真決策評估點顯式要求推進。

## §1 前提（file:line 坐實）
- 寫入：`decision_context:565` `team.need_urgency = NeedHierarchy.ewma_update(...)`（**非冪等**）；`:569` `team.plan_phase = NeedHierarchy.narrative_label(...)`（衍生）。
- fp：`need_urgency` **被排除**（`state_fingerprint:69` 註 ephemeral/EWMA）、`plan_phase` **在 fp 內**（`:73`）→ 分岔的 fp-visible 症狀走 plan_phase，但**真傷害走 need_urgency**（`decision_engine:70/122` `consistency_coeff` 吃它 → 改下一輪分數）。
- **caller 窮盡（11 處、無 head 截斷）**：`decision_engine:50`、`:165`；`options.gd:167/185/219/251/383/395`（**to_task 分支自己重呼 gather**）；`faction_ai:416`、`:917`、`:1881`。
- ∴ **同一 tick 同一隊的推進次數 = 該 tick 走過幾條 gather 路徑**，且**取決於哪個選項贏**（贏的選項若落在 options.gd 那 6 個分支之一 → 多推一次）。**這是 main 既存缺陷**，非 specimen 引入；specimen 只是把它照出來（tracer 對**每個候選**呼 to_task → 推進 N 次）。
- 實證（implementer、可重跑床 `2d65e8e3`）：7 specimens/seed1337/1200t → tick439 分岔；跳過 `capture_options` → 零分岔；domain 定位 `teams@tick440`；**只還原 `need_urgency` 仍分岔**（`plan_phase` 已吃到擾動值）；**還原兩者 → 零分岔 1200t**。
- `plan_phase` consumer 窮盡：`observer_query_api:73/99` + `observer_inspect_panel:136`（**純 GUI**）；`decision_context:167/481` 註明計畫層 S2 已退役。

## §2 裁定（否決的兩案先講）
- **否決 (c) 擴 `_begin_observe` 成觀測 scope（snapshot/restore 欄位清單）**：黑名單型防線，新增欄位必漏（implementer 本輪自己加的 `expand_eval_next_tick` 就是新欄）。同族前科已 4 例（LOD→RNG→specimen→gather-write）——**治症不治根**。
- **否決「把 `plan_phase` 移出 fp」**：那是把**偵測器**調鈍來讓症狀消失（drift 偵測力下降），且真傷害在 `need_urgency` 不在 fp，移出後**照樣**擾動世界只是看不見了。**fp 保持現狀**。
- **採 (b) 縮小版根修**：推進與讀取解耦，**唯讀為預設**。

## §3 HOW
- **T1**：`DecisionContext.gather(state, team, advance: bool = false)`。`advance==false`（**預設**）→ 不寫 `need_urgency`/`plan_phase`，只把 `team.need_urgency` 拷進 `c.need_urgency`（`:566` 行為不變）。`advance==true` → 照現行推進 + 導出 `plan_phase`。
  - ★**預設 false 的失效模式是「EWMA 沒推進（stale、tap 看得見）」，不是「世界被靜默擾動」**——安全方向正確。
- **T2 推進點**：只有**真決策評估入口**傳 `advance=true`。implementer 逐一判定 11 個 caller 並在 handback 列出判定表（哪個是決策評估、哪個是輔助讀）。預期：`decision_engine:50/165` 為 true，`options.gd` 6 處 to_task 分支**一律 false**（to_task 是「把選項具體化成 task」，不是新一輪評估），`faction_ai:416/917/1881` 逐一判（若是同一輪決策的重複 gather → false）。
- **T3 觀測（憲法級）**：`Probe.bump("need.ewma_advance")` 於實際推進處；`Probe.bump("need.gather_readonly")` 於唯讀路徑。**驗收要求：每隊每 tick 推進 ≤1 次**（bed 統計 advance 數 / 決策隊數）。
- **T4 零新結構**：不加 `*_advanced_tick` 欄位、不加旗標到 TeamData（推進次數靠呼叫點紀律 + tap 驗證）。

## §4 驗收 gate
1. **★specimen 中立性 oracle**：重跑 `specimen_neutrality_bed`（7 specimens/seed1337/1200t）→ **零分岔**。★若仍殘留分岔 → `gather` 其餘寫入（`ensure_fresh`/labor_alloc/`idle_employ_*`/`consolidate_*` cache 群、`decision_context:55/68/69/340/342/343`）也涉入 → **回報、不要自己擴大 slice**（那批是 cache/cadence，另裁）。
2. 推進次數 tap：每隊每 tick ≤1。
3. determinism 三跑 byte-identical。
4. constitution ≤75、headless 0-new。
5. **fp intended-change**：會變（推進頻率降＝need_urgency 軌跡變慢/變穩）。★附**一段誠實說明**：這是修掉「推進次數隨贏家選項擺動」的既存缺陷，**方向是讓 EWMA 回到它該有的語義**；若某些行為（求生/成長切換）明顯變遲鈍 → 回報，由我裁是否需同步調 EWMA alpha（**不准自己 crank**，[[feedback_genuine_value_not_crank]]）。

## §5 範圍界線
- **不動** `gather` 其餘 7 處寫入（labor ensure_fresh / idle_employ / consolidate cache）——implementer 已實證它們**不是**本次分岔源；它們是 cache/cadence 性質，另案。
- **不動** tracer（`capture_options` 照舊呼 to_task）——根修後那條路變唯讀即可；(a)「tracer 改用既有 ctx / to_task_probe」降為**可選 cleanup**，gate①綠就不必做。

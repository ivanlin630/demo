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

## §6 R² delta（2026-08-20、判決 CLEAN、reviewer 親判 3 個開放 caller）
R² 親驗坐實：`consistency_coeff`(`need_hierarchy:110-121`) 的 `alignment=Σ affinity×urgency` **直接乘進每個 option 的 util**（`u *= _coeff`）→ `need_urgency` 是**直接改變 argmax 贏家**的乘數、非旁支資料；`ewma_update`(:124-131) 親讀確認**真非冪等**（同 tick 同 `raw` 連呼兩次 → `prev` 被推向 `raw` 兩次）。11 caller 行號零漂移。

### advance 判定表（**spec 定案、非留給 implementer 猜**）
| caller | advance | 理由 |
|---|---|---|
| `decision_engine:50` / `:165` | **true** | 真決策評估入口 |
| `options.gd:167/185/219/251/383/395` | **false** | `to_task` 是「把選項具體化成 task」、非新一輪評估 |
| `faction_ai:416` | **false** | 親讀 :410-432＝**threat 門檻 gate read**，過門檻後 :432 呼 `_decide_unified` → 內部再走 `decision_engine:50`（已 true）。若此處也 true＝同隊同 tick 扣兩次＝**本 slice 要修的病徵本身** |
| `faction_ai:917` | **true（★條件式）** | 獨立 ambient 階梯決策入口（`rank_ambient`+`try_set`），語意上是真評估。**★但只在 `current_task == TASK_IDLE`(:916) 跑** → **implementer 必須確認**：`uses_unified` 隊會不會同 tick 先走 `_decide_unified`（已 advance）**又**因仍 IDLE 落到這段？**若會 → 對 `uses_unified` 隊降 `false`**（借用同 tick 已推進的值）、只對非 unified/solo 隊維持 true。T3 的 tap（每隊每 tick advance 計數）**會直接抓到**沒守住的情況 |
| `faction_ai:1881` `_try_distribute_side` | **false** | comment 自陳「脫主 argmax」＝**side-dispatch**（附加動作），主決策已在別處評估過。★**通則擴及整個 side-dispatch 家族**（distribute/migrant/herald/scout…）**全 false**——否則一隊一 tick 觸發多個 side-action 各推一次＝同款病換皮 |

### gate 追加（R② 建議、低成本加固、非阻塞）
**gate 6**：長跑（數百 tick 以上）前後比對 **`plan_phase` 分佈**（五層急迫度佔比；欄位/tap 現成）。若修正後分佈**整體重心大幅位移**（非只軌跡變平滑）→ 代表原病其實在**餵養**某個已被依賴的行為模式 → 回報、多看一眼。
（R② 對 gate 5「遲鈍就回報、禁自行 crank alpha」判定**正確且夠**：頻率是量測到的真實現象、alpha 是調參掩蓋現象，不可混為一談。）
### R② 對其餘 3 問答覆（確認、無需改 spec）
②見上；③「預設 false 失效模式＝stale 非靜默擾動」**成立**（最壞＝用較舊 `need_urgency` 算 coeff、可能選次佳＝靈敏度劣化，**非資料損毀**：不 null/不 NaN/不 crash/不洩漏跨隊資訊）；④specimen bed 零分岔**只證「觀測不再改變世界」**（中立性維度）、**不證「決策本身還好」**（正交）→ 故加 gate 6。

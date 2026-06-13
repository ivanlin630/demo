# Hand Back: 封建財政 / 公庫經濟

> 分支：`feat/fief-economy` ｜ Spec：`docs/superpowers/specs/2026-06-13-fief-economy-design.md`
> Plan：`docs/superpowers/plans/2026-06-13-fief-economy.md`

## 實作摘要（改了哪些檔案）

- `scripts/simulation/resource_system.gd`
  - 新增 `NORMAL_TAX_RES` const（food/material/goods）
  - `collect_resources` 聚合本格+鄰格採集 `gained`，尾端呼叫 `_apply_normal_tax`（稅進站立 tile owner 公庫）
  - `_collect_from_tile` 加 `gained` 累加器參數（非 public 分支記私產所得）
  - 新增 `_apply_normal_tax`：採集所得 × owner.tax_rate 撥腳下 tile 公庫（守恆轉移、cap 不溢出）
  - 新增 `_apply_chronic_tax_unrest`：tax_rate 超容忍閾值 → 居民 leader/named stress 緩增；leader 長期高壓 → unrest_turns（Task 5 一般稅慢性）
- `scripts/simulation/outpost_system.gd`
  - `_can_afford`/`_deduct_cost` 改吃 `tile` 參數：公庫 + 私產合併池，**優先扣公庫**（本地）
  - 4 caller 傳 tile：`start_build`、`start_upgrade_level`、`_begin_facility_construction`、`_subteam_upgrade_level`
- `scripts/simulation/faction_ai_system.gd`
  - `_fund_subteam_cost` 改公庫優先 + 加 `tile` 參數（公庫足子隊不需補；3 caller 傳 tile）
  - 新增 `WAR_CHEST_MIN` const + `_update_goals` 戰爭基金觸發（野心/好戰高 + 建材低 → 非缺糧也徵收）
  - 徵收子團派遣 pop 門檻 `>= 4` 放寬至 `>= 3`（E 子團代徵）
- `scripts/simulation/interaction_system.gd`
  - 新增 `SPECIAL_TAX_MULT` const（1.5）；`_resolve_tribute` PRODUCE 分支 rate = `tax_rate × MULT`
  - `_resolve_tribute` 加尖峰不滿：`taken_ratio`（搜刮/庫存）+ `annoyance`（近期特別稅次數）疊加 stress/loyalty（Task 5 特別稅尖峰）
  - 新增 `_count_recent_special_tax` helper + 寫 `special_taxed` memory
  - `_resolve_aid_request` 改慷慨光譜：`reserve_days` lerp 2–60（hoard=greed−honor）、`give_fraction` 個性兩極、人性底線 mercy floor
- `scripts/debug/headless_test.gd`：+13 fief 測試（Task1–5）
- `config/{game_sim_test,tyrant,merchant,warzone}.json`：max_ticks 21600→172800（2 年驗收，**驗收後須還原**）

## 與 spec 的差異

- **mercy floor 加 `annoyance < 0.4` gate**：spec 只寫 `honor > 0.1` 即給將餓死者 1 天份。但純 honor 門檻會讓「永遠餓死的 serial beggar」每次都繞過既有 annoyance 拒絕（`_test_aid_repeated_annoyance` 會破）。加 annoyance gate：第一/二次乞食仍保人性底線，反覆煩擾後連 mercy 也關。屬小幅延伸，請主 session 確認是否接受。
- `_update_goals` 戰爭基金用 `elif`（緊急徵收 > 戰爭基金 > 定期）插入既有 if/elif 鏈，strategy 標記「戰爭基金」。
- **plan-scope 外延伸（Task 6 驗收驅動）**：`_dispatch_upgrader`/`_dispatch_facility_builder` 的 1.5x 預檢改吃「目標 tile 公庫 + owner 私產」（同址升級/擴建公庫本地可用，與 `_fund_subteam_cost` 公庫優先一致）。為達 W4「設施 > baseline」驗收而加；屬 plan 未明列但同 spec 意圖的延伸。`_dispatch_builder`（新據點、虛擬目標格）維持私產 gate（嚴格本地）。

## 驗證

- `headless_test.gd`：`=== DONE ===`，無 SCRIPT ERROR，13 fief 測試 + 既有 aid/tribute 回歸全綠
- `game_sim_test.gd`：`ALL INVARIANTS PASSED (violations=0)`、`[CoinAudit] delta=0.00`
  - 註：`[FEATURE FAIL] Trade — trade_success=0` 為 **pre-existing**（main 同樣出現），非本次 regression
- 2 年 multi（max_ticks 172800）：見下「2 年觀察」

### 2 年觀察（max_ticks 172800，4 configs；驗收後已還原 21600）

| 指標 | 結果 | 驗收 |
|---|---|---|
| coin 守恆 | 4 configs delta 全 0.00 | ✓ |
| 公庫累積（coin treasury max） | game_sim_test 190 / merchant 95 / tyrant 46 / warzone 20（init ~19-20）| ✓ 累積且 variance 上升 |
| 課稅自毀（famine） | 69 筆餓死；tyrant pop 60→17 | ✓ Laffer 湧現 |
| 設施總數（2yr） | 1/0/1/0 | ✗ **未超 baseline** |
| 起義 | 0 | — |
| 特別稅事件 | 全 2 年僅 **1 次** | ⚠ 幾乎不觸發 |

**設施未超 baseline — 但非 fief regression**：同 config 跑 **pre-fief main**（game_sim_test 2yr）= 設施 1、新建 0；fief 後同樣 設施 1、新建 0。即 NPC 建設經濟在 fief 之前就已停滯（leader 永遠摸不到建造門檻 = W4 原始症狀），fief 未惡化亦未由 emergent 路徑解開。

**W4 解的真相**：fief 的公庫建造機制（`start_build`/`start_upgrade_*` 吃公庫）已由 Task 2 單元測試證明可用（直接建造路徑通）。但 **NPC faction_ai 走的是 dispatch 路徑，不呼叫直接建造**，故 multi-sim 看不到 emergent 設施成長。根本卡點（2 年僅 1 次特別稅 → leader 私產永遠枯 → 新據點 dispatch 75 次「material 不足」失敗）是 dispatch 路徑 + 特別稅觸發率問題，**超出本 plan scope**。

## 連動風險（主 session 決定是否補修）

- **W4 dispatch 路徑未真解（最重要）**：新據點 `_dispatch_builder` gate 仍吃 leader 私產（嚴格本地：虛擬目標格無公庫可載），而一般稅把 30% 產出鎖進不可攜的本地公庫 → leader 私產長期枯 → 2 年 75 次新建失敗。建議架構決策：(a) 降 tax_rate；(b) 新建商隊出發前由「home tile 公庫」實裝載入 sub.resources（caravan-load，非遠端取物，不破嚴格本地）；(c) 接受擴張緩慢。同址升級/擴建 gate 我已改吃公庫（`_dispatch_upgrader`/`_dispatch_facility_builder`，本 commit），但因現存據點稀少 + pop/advisor 門檻，2 年內未見效。
- **特別稅 2 年僅 1 次**：`徵收` goal 觸發（缺糧/週期/戰爭基金）+ leader 須走到居民同格（W1 式追逐）→ 實際幾乎不發生。leader 口袋因此填不滿，連帶卡死新據點私產資金。建議架構檢視徵收觸發/會合率。
- `check_construction_timeout` 退料 50% 仍進施工團私產（`ct.resources`），不回公庫：扣款可能來自公庫但退料入私產 → 公庫→私產單向洩漏（僅逾時工地，量小，未列入 coin 審計因非 coin）。
- 特別稅抽公庫上級對下級 + 一般稅同批產出 → 居民雙重負擔；2 年滅團 famine 69 筆，需平衡觀察。

## 待主 session 確認

- 全參數 TEST VALUE：`tax_rate` 0.3 預設、`SPECIAL_TAX_MULT` 1.5、`WAR_CHEST_MIN` 200、`reserve_days` 2–60、mercy 1 天份、tolerance 係數、公庫 cap（沿用 OUTPOST_STORAGE_CAP）
- mercy floor 的 annoyance gate（見上「差異」）
- W4 是否真解：直接建造路徑已解；dispatch 路徑見「連動風險」
- 拉弗曲線：過度課稅村 famine 是否如預期湧現（暴君 tyrant config 觀察）
- **config max_ticks 還原 21600**（驗收後）

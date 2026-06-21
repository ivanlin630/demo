# Hand Back: 經濟生產隊納統一引擎（履約脫 0）

Plan: `docs/superpowers/plans/2026-06-21-economy-settle-unified.md`
Branch: `feat/economy-settle-unified`（未 merge，等主 session）

## 實作摘要

3 task 全完成，全回歸綠（headless `=== DONE ===`，0 SCRIPT ERROR / 0 Assertion，coin_eq + InvariantAudit 全 OK）。

改檔（每檔一行）：
- `scripts/simulation/decision/decision_context.gd`：加 `is_merchant: bool` 欄位 + `gather()` 寫 `team.tags.has(TAG_MERCHANT)`。
- `scripts/simulation/decision/options.gd`：`applicable()` 守衛角色化——貿易守衛加 `and ctx.is_merchant`（roam-trade 限商隊角色，生產隊不列）；生產/駐守 留 `has_own_outpost`；建設改恆候選（bootstrap 無據點建新 + 升級皆候選）。
- `scripts/simulation/faction_ai_system.gd`：`uses_unified()` 加 `or team.tags.has(TAG_PRODUCE)`——生產隊兩條 gate（`_assign_member_tasks` L793 / `_evaluate_solo` L1006）都導向 `_decide_unified`。
- `scripts/debug/headless_test.gd`：加 `_mk_produce_team` helper + `_test_role_applicable`（註冊進 dispatch）；擴 `_test_unified_seam`（加 PRODUCE 切片斷言、tag 改用常數）。

與 spec 差異：
- **貿易守衛判別子用 `is_merchant`（角色 tag）非 `not has_own_outpost`（據點）**——plan §修正已述。理由：測試商隊 `_mk_merchant_team` 有 outpost（`outpost_owner=0`），用據點守衛會誤殺商隊貿易、爆 TC1/TC7。
- **改了一個既有單測 `_test_decision_options`（L12473）**：原 ctx 直建 `has_goods+has_arb` 斷言「→ 貿易候選」，新守衛要 `is_merchant` → 該測補 `ctx.is_merchant = true`。屬新契約（§改動2 貿易=商隊角色）的正當反映，非掩蓋。assert 訊息同步改「商隊有貨+arb → 貿易候選」。

## S6 world_sim 履約脫 0 — 量測結論（measure-first）

**結論：本塊生產側 plumbing 已驗證可運作；robust 履約脫 0 仍被「商隊卡 survival」壓制因擋著（已知、明確排除於本塊範疇）。**

world_sim（unseeded，數字 run-to-run drift）多次跑 `Probe.summary()`：
- `g1.order_placed ≈ 3300`、`g1.board_register ≈ 3057` → **訂單有掛、board 有註冊**（生產側掛單運作）。
- `g1.order_fulfilled` = 0~1（flaky，多數 run 缺鍵=0；一次 run 見 1）、`[Market] 成交` 0 → **履約實質仍 ~0**。
- `g1.merchant_survival ≈ 164`、`g1.seek_market = 1`、`g1.market_arrive ≈ 68` → 商隊多數 tick 卡 survival，幾乎不出門巡市集。

TeamTrace（月取樣）佐證生產側正確：
- 一支生產隊 d60 起穩定 `task=生產 @(5,4) mt=(-1,-1) dist=-1`（**原地駐守不漂**），自家 outpost vault food≈1996（**有據點可掛單**）。診斷 #1（駐守）+ #2（有據點掛單）皆過。

診斷 #3（商隊抵達 co-located）= 失敗點：商隊卡 survival → 不 seek_market → 不與生產隊 co-located → 履約 ~0。此因 **`faction_ai_system.gd:786-789` 既有 WS-2b 探針已標記**為「world_sim 履約 0 的真壓制因」，且註明「本 WS 不硬修 survival（plan 次要旗標），留供下一個 measure-first WS」。對齊 handback #6 §2。

→ 非 config 缺可履約對（生產隊掛 3000+ 單、商隊存在），故 plan Step 3b（補 config 對）**未觸發**，未改 `config/world_sim.json`。

## 連動風險

- **`faction_ai_system._assign_member_tasks` / `_evaluate_solo`**：生產隊 member + solo 兩路徑現都進 `_decide_unified`。舊生產者分支對生產 tag 隊被 `uses_unified` 短路（單一 owner，無雙觸發）。全回歸無新 assert 失敗 → 既有生產隊行為測試仍綠。最小切片空窗（consolidate/faction-duty 等舊 solo 計分對生產隊掉）實測未致碎隊或測試紅；長期 emergent 影響待 systems 判。
- **`AmbitionLadder` / rung-task**：trace 見生產隊 `task=生產[ambition]`（reason=ambition 非 unified）。即生產隊「生產」task 多由野心階梯系統續發，`_decide_unified` 僅在 IDLE/stuck 時重評（`_evaluate_solo` L1001 sticky gate）。結果一致（原地駐守生產+掛單），但 owner 邊界（引擎 vs 階梯）對生產 task 仍有重疊，未來統一決策傘收編 ambition task 時需釐清。
- **守恆**：本塊僅動決策面（applicable 守衛 + context 欄位），未碰 resources/coin/state 池。coin_eq / InvariantAudit 回歸 0。

## 待主 session 確認

1. **履約脫 0 未 robust 達成**：根因 = 商隊 survival latch（出範疇）。是否開後續 measure-first WS 修商隊 survival 參數（解 `g1.merchant_survival`），讓履約真正脫 0？建議列 sub-project B 首序。
2. **生產 task owner 重疊**（引擎 vs AmbitionLadder rung-task）：是否納統一決策傘下一塊收編，消 reason=ambition 與 unified 的雙寫？
3. 既有單測 `_test_decision_options` 補 `is_merchant=true`：確認屬契約正當更新（已照 plan「勿硬改掩蓋」原則判為新契約反映，非掩蓋失敗）。

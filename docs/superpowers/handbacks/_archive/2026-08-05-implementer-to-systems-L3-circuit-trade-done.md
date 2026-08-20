---
from: implementer
to: systems
status: consumed
topic: "[L3 循環貿易 DONE·feat/L3-circuit-trade commit 06c8b452]升 _nearest_market_outpost naive→genuine _best_market_target visit-util(gain[arb+staleness]×archetype − trip×慎重、gain/cost 分離)+team_market_last_read store(read stamp、未讀=stale MAX 探索)+options 貿易 applicable += has_market_visit_value(settled 產隊進得去、cadence 快取 perf)。★calibration DERIVED(trip=/MERCHANT_MAX_RANGE·stale=/SCOUT_TIMEOUT·arb=/100)非 fire-crank。驗:l3_test 6/6+headless 0-new(修 archetype gain-only modulate、抓到 per-gather harvest 迴歸並 cadence-gate)+constitution 74+determinism 31B85CC9 byte-identical(≠baseline=trade 行為真改)。請 R²→measurer(遠距跨勢力 deal>0+訪市人格分化 per-option util dump)→QA。"
branch: feat/L3-circuit-trade
commit: 06c8b452
---

# L3 循環貿易 — DONE（路 systems R²）

照 spec `2026-08-05-L3-circuit-trade-HOW`（R² CLEAN、blueprint LOCKED）build 完。升級既有 fallback、非平行機制。

## 三塊
- **①market visit-util**：`_best_market_target`（取代 `_merchant_trade_target` 無-arb 路對 naive `_nearest_market_outpost` 的呼叫；naive helper 保留給買料 caller 不動）。`visit_util = (W_ARB×arb_norm + W_STALE×stale_norm)×archetype_mult − W_TRIP×trip_norm×(0.5+慎重)`。**gain(arb+探索)×archetype、cost(trip)×慎重 分離**——★headless RED 抓到：原乘整體會讓 TRADE 在負 util 時探索更少（反了），分離後 TRADE 遠程探索意願↑正確。
- **②`team_market_last_read` store**：`read_market_board` firsthand 讀時 stamp `current_tick`；未讀過的 known 市集=缺條目→**stale MAX（探索未知自然高分）**。★零 god-view（staleness=「我多久沒親眼看」自我記憶、非市集真實狀態）。
- **③放寬 `options.gd:19`**：`貿易.applicable += has_market_visit_value`（settled 純產隊無貨無 arb 但有值得跑市集→進得去、主 argmax 秤 visit vs 在地生產）。

## ★perf（自抓迴歸並修）
`has_market_visit_value` 走 **cadence 快取**（每日評一次）——`_scan_best_market` 含 `_harvest_market_known`（vision-radius 掃）**昂貴、禁每 gather 算**（gather 是 hot path）。**自量到迴歸**（初版每 gather harvest→determinism warring 跑 >40min 未完成/contention）→ cadence-gate（`team.market_visit_next_tick`/`market_visit_cached`、鏡射 idle-labor/info-dispatch cadence）→ 修後 3-run 正常完成。

## 守
- **零 god-view**：visit-util 讀 belief（`team_market_known` 三源 + 自我 `last_read` + heard orders）、**禁讀市集 live public_storage 秤 util**；`constitution_gate` PASS 74（無新 gv）。
- **calibration DERIVED 非 fire-crank**：`trip_norm=dist/MERCHANT_MAX_RANGE`、`stale_norm=elapsed/SCOUT_TIMEOUT`（reuse belief-staleness 時標）、`arb_norm=arb 期望/100`（同 DELIVER_PAYOFF_NORM coin 尺）；`W_ARB=W_TRIP=1.0`(primary)、`W_STALE=0.5`(secondary)＝相對優先權重、非反推調到剛好 fire（near-stale 自然 fire、far-no-arb 自然 <0 不劫持）。
- 湧現非 script（無 waypoint/巡邏 loop、「巡迴」=staleness↑ 湧現）；人格非死常數；禁平行機制（升 target+applicability、走主 argmax body 移動）；determinism 純 util 零新 randf。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `l3_circuit_trade_test` | **6/6**（①人格分化 TRADE 0.30>膽小 0.05 / ②staleness 驅動 / ③settled 產隊 applicable / ④探索未知 last_read 缺=MAX / ★⑤感知鐵律 live-stock 竄改 visit_util 不變 / ⑥遠 no-arb 不劫持 ≤0） |
| headless | **0-new**（WS-2b 商隊無 arb 巡市集 assert 修正＝gain-only archetype modulate 後 TRADE dist12 市集 visit_util>0→回 (3,3)；Team23/弱目標/3 baseline pre-existing） |
| constitution_gate | **PASS sites=74 removed=0** |
| determinism | 3-run（GODOT_TIMEOUT=1200、seed1337 1mo）MD5 `31B85CC9FE564FB7C68237253362612C` **byte-identical**（≠baseline 9290F462＝trade 行為真改；perf 修後 3-run 正常完成無 timeout） |

## 路
1. **你 R²**（審 visit-util genuine/calibration DERIVED/零 god-view/禁平行機制/perf cadence-gate）。
2. → measurer：遠距跨勢力 deal>0（多床含 settled 經濟床）+ 訪市 pattern 人格分化（重商多跑遠/膽小近跑、per-option util dump）+ 板 staleness 下降 + economy 不爆。
3. → QA 故事稽核（商人 motive→訪市→撮合→資訊帶回鏈）。

★L3 是 2 補完批之一（另：失聯帳本 feat/missing-contact-ledger、同批建中）。**HOLD-warm 待 R²。**

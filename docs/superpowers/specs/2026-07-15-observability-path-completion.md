# Spec：觀測路徑維補齊 + 盲點閘（tap-gap 家族系統性收）

status: draft（待 R² → dispatch implementer）
owner: systems
blueprint_intent: `2026-07-15-blueprint-to-systems-person-reaction-tap-and-gate.md`（person-reaction unblock 內政 + tap-gap 家族第4個→系統性掃別打地鼠）
governing: `invariants.md §觀測不變量`（全生命+★全路徑；本刀收路徑維）

## 問題：tap-gap 是家族，路徑維一路漏
tracer 時間維（heartbeat）補了，但**路徑維零散建、多決策/反應/事件點沒 tap**。撞出來的家族已 4 個：
1. order-system（買糧，desperation arc）
2. survival-churn 只 tap 成功 commit（tracer-completeness 補了 survival loop）
3. unified/solo capture 用預設 committed（虛高，flee reframe 揭）
4. person-reaction 沒 tap（內政 defect/riot 測不了）

**別再一個個等 measurer 撞牆**——本刀系統性補齊路徑維 + 立盲點閘防回歸。

## 覆蓋審計（systems grep 定音，2026-07-15）
| 事件類 | 產生點 | 現況 tap | 缺口 |
|---|---|---|---|
| 決策候選 util | `decision_engine` rank ×2 | `capture_options`×2 | ✅ |
| 意圖 | commander/solo intent | `capture_intent`×2 | ✅ |
| 決策 commit（attack/unified/solo/survival） | faction_ai ×6 | `capture_decision`×6 | ⚠ unified/solo 在 try_set **前**用預設 committed（虛高，非真 result） |
| 決策 commit（**threat** FLEE/DEFEND/求和） | `_evaluate_threat:408` | **無** | ❌ 威脅反應決策不進 specimen |
| 決策 commit（**ambient** idle-filler） | loop3:817 | **無** | ❌（低優先，可選） |
| **person-reaction**（P1/N2_riot/N3_defect/N4/N5/breed） | `reaction_system:121` winner | 僅 `Probe.bump`（aggregate） | ❌ **內政盲點**（specimen 看不到誰為何 defect/riot） |
| 時間維 heartbeat | `evaluate_all` 末尾 | `heartbeat_sweep` | ✅ |

## Fix（路徑維補齊，4 項）

### Fix 1：person-reaction tap（★unblock 內政，最急）
`reaction_system.gd:121`（winner 選出後）→ `SpecimenTracer.capture_reaction(state, person, team, reaction, why)`（team 是 specimen 時才記，is_specimen gate）。
- **記**：誰（person.id/name）、哪個 reaction（best）、為何（`person.loyalty`/`person.stress`/被苛待/領袖違背 values 等 driver 快照）。
- **entry 型**：新 `phase:"reaction"` entry（`_print_entry` 加輕印分支，比照 heartbeat）→ specimen timeline 顯內政敘事。
- QA 才判得出 defect/riot 有真因（好戲 or loyalty 太弱 bug）。

### Fix 2：unified/solo capture 真 result（修虛高）
`_decide_unified:1537` / `_evaluate_solo:1876` `capture_decision` 現在 try_set **前**、預設 committed → **挪到 try_set 後帶真 result**（鏡射 survival loop：`_set_ok` true→"committed" / false→"try_set_noop"；finder 撲空 continue 前→"finder_miss"）。→ 3080 式虛高消，路徑維準。

### Fix 3：threat dispatch tap
`_evaluate_threat:408` try_set 成功後 → `capture_decision(state, team, opt, tk, tgt, "committed")`（威脅反應 FLEE/DEFEND/PREPARE/求和 進 specimen；flee 故事需要）。ambient(817) 同 pattern（可選，低優先——標記 spec，implementer 判要不要納或留 follow-up）。

### Fix 4：觀測盲點閘（防回歸，系統性）
`constitution_gate.gd` 同級的 **觀測盲點閘**（新 script `observability_gate.gd` or 併 constitution_gate）：
- **靜態列舉「事件產生點」pattern**：`TaskArbiter.try_set`（決策 commit）in decision files、`reaction_system` winner、intent emit、state-transition（defect/riot/death bump）。
- **每產生點須有鄰近 specimen tap**（`SpecimenTracer.capture*` 在同 func / N 行內）。
- **baseline freeze**（比照 constitution site-freeze）：凍結「決策 commit 點數 vs capture 點數」對映 + 事件類覆蓋清單。新增 commit/reaction/event 點無伴隨 tap → **FAIL**（清單列未覆蓋）。
- **限制誠實聲明**：靜態 grep 抓「try_set/winner 點有無鄰近 capture」是弱訊號（不證語意正確），但抓「整個新事件路徑零 tap」夠力（打地鼠的根＝新路徑忘了 tap）。runtime churn 床（tracer-completeness Fix3 已建）續作語意驗。

## 守則
- **零 state mutation / 零 RNG**：所有新 tap 純讀（reaction why 快照純讀 person 欄）；is_specimen early-return 零非-specimen 成本。
- **★byte-identical 硬證**：tracer on/off 兩跑 baseline byte-identical（觀測禁改世界，本刀所有新 tap 守此）。
- **憲法零新 try_set**（純觀測）。

## 驗收
1. **內政可觀測**：specimen jsonl 顯 person-reaction 敘事（誰為何 defect/riot）→ QA 判內政連貫。
2. **路徑維準**：unified/solo/threat 決策帶真 result（committed/finder_miss/try_set_noop），無虛高。
3. **盲點閘綠**：現有全事件點覆蓋；構造「新 try_set 無 tap」→ 閘 FAIL 擋。
4. **非侵入**：tracer on/off byte-identical（硬證）。
5. **無回歸**：headless 零新增；憲法 sites=29；同 seed 兩跑 bit-identical。

## dispatch 註
- 新分支 `feat/observability-path-completion`，base 最新 main。
- **平行 flee slice**（flee=行為修 feat/flee-restore-movement，本刀=觀測 infra，不同檔面：reaction_system/specimen_tracer/gate vs movement/faction_ai flee）。留意 faction_ai 兩刀都碰（flee 碰 threat dispatch/movement，本刀碰 unified/solo/threat capture）→ **merge 序**：先落者後者 rebase（capture 行 vs flee 行不同區塊，衝突小；systems 協調 merge 序）。
- **R²**：dispatch 前 to:reviewer 審設計（capture_reaction why 欄/unified-solo result 挪位/盲點閘靜態列舉夠不夠力/byte-identical）。
- 完成判定 = systems + reviewer + measurer（內政 specimen 顯 reaction 敘事 + on/off byte-identical）+ blueprint 批。
- **內政 unblock 排序**：Fix 1（person-reaction）最急，implementer 先做 Fix 1 可先讓 measurer 重抓內政 specimen（分階交付：Fix1 落→內政 unblock；Fix2-4 續）。

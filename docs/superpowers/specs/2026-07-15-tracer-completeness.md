# Spec：SpecimenTracer 完整性（全生命 + 全路徑，第三觀測洞根治）

status: draft（待 R² → dispatch implementer，排 god-view merge 後 / full-HD 觀察前）
owner: systems
blueprint_approve: `2026-07-15-blueprint-to-systems-tracer-fix-approve-sequence.md`（修法+升閘+排序點頭）
根因定音: `2026-07-15-systems-to-blueprint-tracer-completeness-analysis.md`（code file:line 查證）
governing: `invariants.md §觀測不變量`（本刀新增顯規則）

## 問題（第三觀測洞，同族第三破）
specimen jsonl ＝**成功-commit 窗口**非全生命。Team26 錄 day76-85、漏 day24-75（~50 天）。從沒一份 specimen 涵蓋一隊完整一生。前兩洞＝LOD-exemption 換世界、RNG-confound 換世界（觀測改被觀測物）；**本洞＝tap-placement**（觀測有洞，非改世界）。

## 根因（code 定音，非猜）
capture_decision 只 4 call-site（`faction_ai:1480/1523/1876/3217`）**全 commit-gated**：
- `:3217` 在 `if _surv_ok:` 內（try_set **成功**才 tap）；survival finder 撲空（`:3205 tgt==(-1,-1)→continue`）或同-prio try_set no-op fail → `_surv_ok=false` → **不 tap**。
- ∴ **時間維洞**：no-commit 期間（IDLE cadence 空檔／survival relatch commit 反覆失敗＝non-unified thrash／子隊無獨立決策）＝零 entry。
- ∴ **路徑維洞**：commit-fail 的 attempt（rank 跑了選了 option 但撲空/no-op-fail）+ `[Survival]` flip(`:3117`) **完全不 tap**。thrash 抖動全隱形，只能靠 no-specimen 掃描撞見。

## 修（三 Fix + 升閘 + invariants）

### Fix 1：路徑維——attempt-邊界 tap（含 commit-result）
決策 commit-fail 也要進 entry，thrash 自現形。
- **capture_decision 擴 signature**：加 `result: String = "committed"` 參數（預設不破既有 call）。entry `做什麼` 加 `"result": result` 欄。
- **survival loop（`_trigger_survival:3202-3217`）補 tap**：
  - `:3205` finder 撲空 `continue` 前 → `capture_decision(state, team, opt, td.task, tgt, "finder_miss")`。
  - try_set 失敗（`_surv_ok==false`）→ `capture_decision(..., opt, ..., "try_set_noop")`。
  - 現 `:3217` 成功路 → 傳 `"committed"`（顯式）。
  - ∴ rank_survival 逐 option fallthrough（opt1 撲空→opt2 no-op→opt3 committed）全成 entry timeline，churn 可讀。
- **其他 commit 點（unified :1523 / solo :1876 / attack :1480）**：本刀主修 survival（thrash 巢），其餘同 pattern 補 result 欄（committed/miss），blast radius 控在「加欄+加 fail 分支 tap」不改決策邏輯。
- **第四態 advisory（R②，本刀不處理僅記）**：`_trigger_survival:3208-3212`「投靠玩家隊」分支 `_maybe_request_join_player` 回 true → 提前 `return` 繞過 3 tap 點＝第四種 attempt 結果「請求送出待玩家答」（`join_player_pending`）。範圍窄（僅 `opt=="併入"`+target 恰玩家隊+`player_id!=-1`），headless churn 床無 active player 大概率不命中。**日後玩家互動 story-QA 才浮現時再補此 result**；本刀 result 三態足夠。

### Fix 2：時間維——specimen per-cadence heartbeat（gapless sweep）
**不插遍決策路徑**。單點 sweep：`evaluate_all`（`:609`）**末尾**對 `state.specimen_team_ids` 做 heartbeat：
- tracer 記 `_last_entry_tick: Dictionary`（team_id→tick，capture_decision 時更新）。
- sweep：若 specimen 隊本 tick 無 decision entry 且 `current_tick - _last_entry_tick.get(tid,-BIG) >= HEARTBEAT_CADENCE` → append 輕 heartbeat entry `{tick, team_id, phase:"heartbeat", 狀態:_snapshot(...), reason:"no-decision"}`（純讀 _snapshot，無候選/belief 重算）→ 更新 _last_entry_tick。
- **HEARTBEAT_CADENCE** ＝ `WorldState.TICKS_PER_DAY / 4`（6 小時；TEST VALUE）。timeline 無 >6h 洞、volume 有界（1 specimen×90 天×4/天 ≈ 360 heartbeat + 決策 entry，jsonl 低 MB）。
- **決策 entry 已覆蓋的 tick 不重發 heartbeat**（sweep 查本 tick 有無 entry）→ 不膨脹。

### Fix 3：觀測盲點閘（新決策/commit-fail 路徑未 tap → FAIL）
**runtime 行為閘（主）**：canonical specimen churn 床（seeded，強制一隊走 survival thrash + 活過完整生命）斷言：
1. **時間維**：specimen timeline 相鄰 entry 最大 gap ≤ HEARTBEAT_CADENCE（無時間洞）。
2. **路徑維**：強制 churn（finder 撲空/no-op）下，`result != "committed"` 的 entry 出現 ≥1（commit-fail 現形）。
- 床 FAIL＝有洞/漏路徑 → merge-gate 擋（比照 constitution_gate 機制）。
**static tripwire（副）**：凍結**生產側**（`scripts/simulation/`，排除 `scripts/debug` 測試 tap）`SpecimenTracer.capture*` call-site 計數 baseline ＝ **4 capture_decision + 2 capture_intent（faction_ai:1096/1107）+ 2 capture_options（decision_engine:18/124）**（R² 訂正：capture_options 現 **2** 非 1；grep 坐實）；新增決策 commit 點（try_set in decision context）未伴隨 capture → 計數比失衡提示（弱訊號，非硬斷；主閘是 runtime 床）。**★baseline 必準否則 tripwire 起跑即失真**（R² issue）。

### Fix 4：invariants 升條（觀測不變量段收斂）
`invariants.md` 收斂三洞成單一「觀測不變量」段（我 owner 草）：
1. **觀測禁改世界**（已有，memory `feedback_observer_no_global_rng`）：tracer/probe/HOB 禁耗 global RNG、LOD-exempt observe。
2. **全量暫態可觀測性**（已有，memory `feedback_full_transient_observability`）：新 decision/resource/state 必接 tap。
3. **★新增 specimen 完整性**：specimen＝全生命+全路徑，無窗口、無漏 tap；新決策/commit-fail 路徑必接 specimen tap（heartbeat 補時間、attempt-tap 補路徑）。盲點閘 Fix 3 為執法。

## invariant 守
- **零 state mutation**：tracer 純讀 + append entry + 寫檔（現況守，本刀延續）。
- **零 RNG**（觀測禁改世界）：heartbeat _snapshot 純讀、attempt-tap 走既算好的 td（不重呼 finder/observe_velocity）；capture_options 現有 suppress_observe_noise 包裹不動。
- **specimen-gated 零非-specimen 成本**：所有新 tap 過 `is_specimen` early-return（Fix 2 sweep 只迭代 specimen_team_ids）。
- **determinism**：tracer 不參與遊戲 RNG/state → 開關 tracer 世界軌跡 byte-identical（驗收硬斷：specimen on/off 兩跑 baseline byte-identical，證觀測非侵入）。

## 驗收法
1. **全生命**：specimen 床錄「出生→死亡」完整 timeline，無 >HEARTBEAT_CADENCE 洞。
2. **churn 現形**：強制 survival thrash，jsonl 見 `result:"finder_miss"/"try_set_noop"` entry（非只 committed）。
3. **盲點閘綠**：runtime 床斷言①②通過。
4. **非侵入**：tracer on/off 兩跑 **baseline byte-identical**（觀測禁改世界，硬證）。
5. **無回歸**：headless 零新增；憲法 sites=29；HOB obey%；sanity 零新增。

## dispatch 註
- **排序**：god-view merge 後、full-HD 觀察 slice 前（blueprint 精修：先修觀測工具再用它觀察 live 世界）。
- **分支**：新 `feat/tracer-completeness`，base 屆時最新 main（god-view 已 merge）。
- **R②**：dispatch 前 to:reviewer 審設計（attempt-tap result 語意、heartbeat sweep 位置/cadence、盲點閘 runtime-vs-static、byte-identical 驗收）。
- 完成判定 = systems + reviewer + measurer（specimen 錄全生命+churn 現形）+ blueprint 批。
- TDD：構「specimen 走 survival thrash」斷言 finder_miss/try_set_noop entry 出現；「specimen 長期無決策」斷言 heartbeat 填洞；「tracer on/off」斷言 byte-identical。

# own_granary_tile(state=Nil) day15 null-caller pin + 根修（HOW / systems）

status: DRAFT→R²（2026-08-15）
owner: systems（HOW）← blueprint crash-first ruling（2026-08-15、closed-account 用在地基）
溯源：measurer ghosttown/founding run flag → onset day15（非 tail-end）→ mid-sim 真 null-caller、推翻 teardown 假說。known_issues:77。

## §0 命門（HOW 守）
- **★pin-root 非盲 guard**（blueprint 硬裁）：`if state==null: return null` 會**遮掉** silent effective_food undercount（症狀補丁遮根、違 [[feedback_symptom_vs_root]]）。**必找 day15 傳 null 的 caller、根修 state threading**。
- **granary-centric agriculture arc 地基**：帶糧倉讀取 bug 蓋農業=沙上蓋樓；此 bug 污染之後每個 slice 量測 gate → 先清。
- **禁製造量測盲點**（[[feedback_full_transient_observability]] 憲法級）。

## §1 現況（負斷言協議：窮盡搜索坐實）
- def：`resource_system.gd:398 own_granary_tile(state, team)`、:399 `state.world.tiles` on null state 崩。
- **全 caller（exhaustive grep `own_granary_tile` scripts/ 非 test）**：`decision_context:186/508`、`faction_ai:3418`、`resource_system:132/183/415/428`（含 effective_food 內部 wrap）。**全傳 `state` 變數、零 literal-null caller** → 靜態掃不到（known_issues 已試）→ **day15 某 call site 的 `state` runtime 為 null**，需 runtime trace 定位。
- 症狀：onset day15、6mo/2mo 窗兩撞、error-storm 被 timeout 殺（需 `tools/godot-detach.ps1` WMI-parented 撐）。

## §2 Task（TDD、每 task 跑 headless 驗）
### T1：instrument 定位 day15 null-caller
- `own_granary_tile:398` 頭加**臨時** trace：`if state == null: push_error("[NULLTRACE] own_granary_tile null-state @tick=%d\n%s" % [<current_tick>, get_stack()]); ...`（get_stack() 印呼叫鏈；tick 從既有 state/傳入或 global tick accessor）。
- **★注意**：state==null 時無法從 state 取 tick——tick 改由 caller 側或 Engine frame counter/靜態 tick 取；若取不到就只印 get_stack()。trace 本身**禁耗 global RNG**（[[feedback_observer_no_global_rng]]、push_error 純 log 安全）。
- 跑 seeded（seed1337）到 day~20 捕首撞、讀 get_stack() → **pin 出哪個 caller 的 state 為 null**。
- 交付 T1：handback 附 trace 出的 caller file:line + 呼叫鏈（給 systems 確認根位置再 T2 根修）。**此處可暫停等 systems 確認根、或若鏈清晰直接 T2**。

### T2：根修 state threading
- 依 T1 定位：修那個 caller 讓它**傳非空 state**（root fix：補傳 state 參數 / 修 state 生命週期 / 該 caller 本不該在 null-state 期跑則修其 gating）。**非**在 own_granary 頭加 return-null guard。
- 移除 T1 臨時 trace。
- **驗**：seeded 跑過 day15（越長越好、目標撐到能覆蓋 arc 12mo horizon 的長窗）**無 crash**；`effective_food` 對站自家據點的隊**正確含糧倉**（不再靜默漏算）。

### T3：outpost_owner reason permanent tap（blueprint ② 准、觀測性憲法）
- 現況：`field=="outpost_owner"` 的 driver-ledger entry **每 tick 被無條件 `clear_driver_ledger()` 丟棄、從未 tap**（measurer 挖出）。
- 加**永久** tap：dump schema 納 `owner_reason_by_team`（`team_id(owner)→最近 reason`、last-write-wins 同 `OutpostOwnerBank` 語意）——measurer 臨時 tap 版轉正、落 fullprobe/story-audit bed schema。
- **★純記錄 tap**：無 RNG、無 state mutation → determinism byte-identical 必須保持（seed1337 三跑驗）。
- **驗**：dump 出現 `owner_reason_by_team`、值合理（camp/takeover/capture 分布）。

## §3 gate（綠才 merge）
1. seeded 跑過 day15（長窗）無 own_granary null crash。
2. 根修=**改 caller state threading**（非 own_granary 頭 guard）——diff 證根位置。
3. `effective_food` 站家隊正確含糧倉（T2 驗 print）。
4. determinism seed1337 三跑 byte-identical（tap 純記錄不破）。
5. constitution_gate 綠。

## §4 界外
- own_granary 其他 caller 若各自有獨立 null 源 = 逐一 pin（T1 trace 若見多源、分別根修、勿一 guard 蓋全）。
- agriculture farm_yield 本體=S2 後 §3 農業 slice（本 slice 只清地基 bug、不碰農業產糧）。

序：R² 審此 HOW → CLEAN → **待 S1 merge**（免 stale-base）→ dispatch implementer（base=post-S1 main）→ gate → merge → S2。

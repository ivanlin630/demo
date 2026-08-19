# perf Phase2 刀3=alloc-churn sweep：hot-path FactionAISystem.new() finder 靜態化（HOW / systems）

status: DRAFT→R²（2026-08-18）
owner: systems（HOW）← perf 憲章 + quantify 血證（刀A alloc 修 8-13% vs 刀B/D 掃描優化皆 dead=真根是 alloc churn 非掃描）
溯源：刀A（_hex_dist static）8-13% gain vs 刀B(memo)/刀D(spatial index) 皆 negligible → blueprint 順證據走：真根=**per-call 配置 churn**。sweep hot-path 剩餘 FactionAISystem.new()。

## §0 命門（憲章安全道）
- **★byte-identical 安全道**：零行為變、機器證 3 跑（同 seed StateFingerprint 精確 match）。static-ize 純 refactor（同刀A）。
- **無新常數**。感知鐵律不動（finder 邏輯不變、只去 alloc）。
- **★arc 止損準則（blueprint）**：刀3 quantify 若落噪聲（連刀D 兩刀噪聲）→ perf arc 收官 banked 刀A 總 gain、不無限追（過度優化=鑽牛角尖）。

## §1 現況（grounded 窮盡、負斷言 wc 先）
- `FactionAISystem.new()` = **41 處**（全樹 no-head）；**hot decision path 集中 30**：`options.gd 15 / goal_resolver.gd 7 / need_oracle.gd 4 / decision_context.gd 4`（=frontier/decision 97.5% 熱路）。
- 呼的 method **全是 finder/query**：`_find_own_outpost`(9×最多)/`_nearest_market_outpost*`(4)/`_merchant_trade_target`(2)/`_facility_deficit`(2)/各 `_find_*`(_richest_member/_find_weakest_prey/_find_unowned_farmable_tile/_find_occupy_target/_find_forage_tile/_find_food_seek_target/_find_aid_target/_find_absorb_target/_nearest_independent/_food_rescue_eval)。
- **★instance state 僅 2 欄**（`_last_site_sig:3548`/`_last_dispatch_fail:3550`）、**只用在 dispatch 類**（_log_dispatch_fail/_dispatch_builder/_evaluate_storage_visit/_evaluate_new_outpost_location）、**零 hot-path finder 用**（負斷言窮盡驗）→ hot finders **stateless w.r.t. instance state**。

## §2 Task（TDD、byte-identical 機器證每 task）
- **靜態化 hot-path finder**：這些 finder（state+team→target、無 instance state）改 **static func**（同刀A `_hex_dist`）→ replace hot-path `FactionAISystem.new().<finder>` 為 `FactionAISystem.<finder>` static 呼、**免 per-call alloc**。
- **★scope**：先 hot 決策路（options/goal_resolver/need_oracle/decision_context 30 site）；`_find_own_outpost`(9×) 最大量優先。**★靜態化前逐 finder 驗無 instance state**（不碰 _last_site_sig/_last_dispatch_fail、不碰其他 instance 欄）；若某 finder 內部呼別的 instance method 鏈→順鏈靜態化 or 該 finder 保 new()（不硬拆）。
- **compiler 強制**：static func 無法碰 instance state=編譯期保 statelessness（比 shared singleton 穩、免未來 state bleed）。
- **TDD**：①靜態化 finder 呼結果==原 instance 呼（逐 finder 同值）②hot path 無 FactionAISystem.new()（grep 證、剩的是 dispatch 類用 instance state 的合法保留）③byte-identical 3 跑④constitution。

## §3 gate（憲章 + measurer quantify）
1. **★byte-identical 3 跑**（機器證）=安全道命門。
2. **constitution 綠 + 無新常數**。
3. **measurer quantify 前後 %**：ctx_total/wall 降幅（期望 alloc 消除→類刀A gain）；**★n≥2 跑 noise-check**（刀D 教訓：單跑噪聲誤判、須多跑分離真效果）。
4. **★止損**：quantify 落噪聲（<run-to-run noise）→ 回報 blueprint、perf arc 收官（banked 刀A）；顯著→merge→刀4 C 評估。

## §4 界外
- 刀4=C（gather de-dup 8+處）=刀3 後、照樣 quantify 定生死。
- 刀B/D=已 abandon（掃描優化 dead）。
- dispatch 類 FactionAISystem.new()（用 instance state）=合法保留、非本 sweep。

序：R² 審此 HOW（★finder statelessness 窮盡驗+靜態化鏈安全）→ CLEAN → dispatch（base 現 main）→ byte-identical gate + quantify(n≥2)→ merge or 止損收官。地基 KEEP。

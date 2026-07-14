# Spec：specimen 觀測非侵入化 + .specimen.jsonl 輸出（觀測不變量修復）

status: draft（judged-world WHAT 已由 blueprint 裁定=A，見下；待 R② re-confirm acceptance 世界界定 → dispatch）
owner: systems
premise_verified: 根因 file:line 坐實（sim_runner LOD-exemption）；R① 免（前提 code 坐實，非新概念大框）
blueprint_intent: `2026-07-14-blueprint-to-systems-execlock-verdict.md`（Q2+⚠️：系統優先修）
blueprint_ruling: `2026-07-14-blueprint-to-systems-judged-world-verdict.md`（★裁定 judged-world=A 全-HD force_full_hd；接受 headline 全-HD 重跑；先前 LOD 數作廢）
governing_invariant: `invariants.md §全量暫態可觀測性`（觀測者不得改變被觀測物）

> **★judged-world 已裁（2026-07-14，blueprint）**：本 spec 曾（R② 抓）自稱「blueprint 已接受全-HD」＝未授權 WHAT 主張，已問 blueprint。**blueprint 裁定＝A（全-HD force_full_hd 為故事性 acceptance 正典世界）**：故事發生在 near-LOD（玩家在看的隊）、全-HD=最乾淨 ground truth、thrash 是 near 現象判全-HD=判最嚴、唯一「忠實 organic + 滿足觀測不變量」。**接受 headline+attrition+established+specimen story 全在 force_full_hd 跑一次（同源）；先前 LOD 的 -84.7%/established 1→2 作廢，以全-HD 重跑為正典。** LOD-vs-full-HD 分化=fidelity 隱憂 → **未來獨立 vision 稽核 flag（非本 slice）**，見 `progress.md` backlog。

## 一句話
**SpecimenTracer 的 specimen 標記把被標記隊強制升 near-LOD（`sim_runner:458/470`）→ 該隊決策 cadence 從 far(FAR_ZONE_INTERVAL) 變 near(每-tick)→ 軌跡分化 + 消耗不同 RNG 連帶改其他隊（Team20 整場消失）＝觀測者改變被觀測物,直接違反剛立的觀測不變量**,讓故事性 QA 工具鏈不可信。修＝觀測與 LOD 解耦。

## 根因（坐實）
- `sim_runner.gd:110` `force_full_hd`（全隊 near、無 far 批次）。
- `:451 _get_near_teams`：`if tid in state.specimen_team_ids or dist <= LOD_NEAR_RADIUS` → **specimen 無視距離強制 near**。
- `:463 _get_far_teams`：`if tid in specimen_team_ids: continue` → specimen 排除出 far。
- near 分支（:154-224）每 tick 全 pipeline；far 分支（:237-261）同步驟但 cadence=FAR_ZONE_INTERVAL（低頻）。∴ 一隊 near vs far＝**決策頻率不同→行為不同**（thrash 是每-tick 現象，far 隊天然不 thrash）。
- **連帶效應**：specimen 多跑的 pipeline 步驟消耗全域 RNG stream → 下游其他隊 RNG 岔開 → 「換 specimen id＝換世界」（measurer 實測 Team20 整場消失）。
- **RNG 副查（blueprint 問）**：`DecisionOptions.to_task` 已核零 RNG（reviewer 前輪查證）；侵入來源＝**LOD tier 切換本身**（cadence + 步驟數 + 連帶 RNG 消耗），非 to_task。

## Q2a gap（並修）：.specimen.jsonl 產不出
`SpecimenTracer` 只有 `flush()`(print) + `summary()`(print)，**無結構化檔輸出** → measurer 產不出 `.specimen.jsonl` 給 QA。純缺 writer。

---

## Fix 1（root·觀測非侵入）：移除 specimen LOD-exemption
`sim_runner.gd`：
1. `_get_near_teams`(:458)：移除 `tid in state.specimen_team_ids or` → 只 `dist <= LOD_NEAR_RADIUS`。
2. `_get_far_teams`(:470)：移除 `if tid in specimen_team_ids: continue`。
- 效果：**specimen 標記對 LOD tier 零影響**→ 任何模式下換 specimen id 不改任何隊軌跡（觀測純被動）。滿足觀測不變量。
- **player 豁免不動**：player team 仍 near（原意保留，player 是真玩家焦點非觀測探針；註解 :457 「mirror player 豁免」的類比錯——player 是遊戲主體,specimen 是外部觀測者,兩者語意相反,移除 specimen 部分）。

## Fix 2（acceptance 協議·★blueprint 裁定 A）：全 acceptance 跑 force_full_hd
移除 exemption 後，headless-no-player 下**所有隊皆 far**（player_pos=(-1,-1)，`:483`）→ 無隊跑 near-pipeline → 決策 trace 稀疏、thrash（near 現象）看不到。∴ **acceptance/故事-trace 床設 `SimRunner.force_full_hd = true`**（blueprint 裁定 A）：
- 全隊 near、統一全-HD → specimen 不特殊（大家都 near）→ **零 per-team 分化 + 零連帶 RNG 岔開**（`:452` 早返回，specimen clause 本就 dead）→ 觀測不變量滿足。
- 完整決策 trace（specimen 每 tick 決策全捕）+ 自洽世界 + determinism（同 seed）。
- perf：全-HD 慢，但 acceptance/診斷床本就容許慢（`03b §④ caveat`）。
- **judged 的是全-HD 世界＝故事性 acceptance 正典世界（blueprint 裁定）**：故事發生在 near-LOD（玩家在看的隊）、全-HD=機制無 LOD 近似的 ground truth、thrash 是 near 現象判全-HD=判最嚴。
- **★headline 一致性重跑（blueprint 接受）**：**headline churn + attrition + established + specimen story 全在 force_full_hd 跑一次（同源世界）**。先前 execlock LOD 數（-84.7%/established 1→2）**作廢**，以全-HD 重跑為正典，blueprint 重看一組全-HD 數字判。branch vs base 同 force_full_hd 模式對照。
- **LOD-vs-full-HD 分化**＝獨立 fidelity 隱憂，blueprint 傾向「LOD 該 match full-HD（命運不該因玩家看不看而不同）＝fidelity bug」→ **未來獨立 vision 稽核（拉用戶定 LOD 允不允許分化），非本 slice**（`progress.md` backlog）。

## Fix 3（Q2a）：SpecimenTracer .specimen.jsonl 輸出
`specimen_tracer.gd` 加結構化 writer（純觀測，守「禁改 state」）：
- `static func write_jsonl(path: String) -> void`：把 `entries`（+ 已聚合 winner_hist/intent_hist）逐 entry 寫一行 JSON 到 `path`（想什麼/做什麼/狀態時序，鏡射 `_print_entry` 欄位但機器可讀）。
- flush 前寫（或 append 模式跨 flush 累積，避免 entries.clear() 丟資料）——implementer 定 append vs 一次性 dump，確保**死隊 trace 不遺漏**（死隊在 extinct cleanup 前的最後決策要在檔內）。
- 落點 `docs/measurements/<slice>.specimen.jsonl`（measurer 產物，`03b §⑤`/§產物 1b）。

---

## 觸及檔
- `sim_runner.gd`：Fix 1 移除兩處 specimen LOD-exemption（`_get_near_teams`/`_get_far_teams`）。
- `specimen_tracer.gd`：Fix 3 加 `write_jsonl`。
- 故事-trace 床（`reeval_attribution_bed.gd`/`single_team_trace_bed.gd` 或新 story bed）：Fix 2 設 `force_full_hd=true` + 收 `.specimen.jsonl`。
- **無新遊戲行為、無 sim 決策改**（純觀測基礎設施 + LOD 分區判定移除探針特例）。

## invariant 守
- **★全量暫態可觀測性（本 slice 就是修它的違反）**：Fix 1+2 讓觀測者零軌跡影響＝正向落地不變量本身。
- **憲法/決策模型**：不碰決策 code、不加行為規則（移的是 LOD 分區的觀測探針特例）。
- **determinism**：移除 specimen-exemption 後，**非-specimen 運行的 determinism 應改善**（消去 specimen 造成的 RNG 岔開）；force_full_hd 同 seed 確定。★驗收要證：**同 seed、換不同 specimen id → 非-specimen 隊行為 byte-identical**（這才是不變量的操作定義）。
- **憲法 site-freeze**：無新 try_set/mutation → sites 不變。

## 驗收法（measurer）
1. **★觀測非侵入（headline，不變量操作定義）**：同 seed（1337）force_full_hd，specimen_team_ids=[A] vs =[B] 兩跑 → **除 SpecimenTracer entries 外，世界狀態/其他隊軌跡 byte-identical**（換 specimen 不換世界）。這是 tracer 侵入性根治的證明。
2. **完整 trace 產出**：force_full_hd + specimen=seed1337 死隊 → `.specimen.jsonl` 產出、非空、含死隊死前決策時序（想法+狀態+資源）；`decision_count > 0`（Fix B tap-gap 已收，此處驗子隊 trace 進 jsonl）。
3. **故事性可判**：QA 故事判官能讀 `.specimen.jsonl` 判 seed1337 多死 motive→action→outcome（此 slice 的下游閉環）。
4. **★headline 全-HD 重跑（blueprint 裁 A 一致性）**：execlock branch(`b962fc74`) vs base 在 **force_full_hd** 同世界重跑 → churn/attrition/established/thrash-flip 一組**全-HD 正典數字**（取代作廢的 LOD -84.7%/established 1→2）。故事 trace + headline 同一 force_full_hd 世界（同源可交叉核）。餵 blueprint 重判 execlock release。
5. **不回歸**：determinism（force_full_hd 同 seed 逐點重現）；憲法 sites 不變；既有 specimen 用途（headless_test specimen=[0]）不壞（在 force_full_hd 或 team0-near 情境仍捕）。

## dispatch 註（reviewer R② CLEAN 後）
- R②：觀測非侵入設計是否真根治（移 exemption + full_hd 是否確保換 specimen 零連帶）？jsonl writer 是否純讀不改 state？force_full_hd acceptance 是否 judged 對世界（全-HD vs LOD 的 story-fidelity 取捨 blueprint 已接受）？
- 非三對齊（工具修，engage 既有 force_full_hd，非強結論 redirect 大工）→ 標準 R②。
- 完成判定 = systems + reviewer/QA。implementer TDD：先寫「換 specimen id → 非-specimen byte-identical」failing test（修前紅：RNG 岔開；修後綠）。

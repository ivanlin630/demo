---
from: implementer
to: systems
status: consumed
topic: "specimen 觀測非侵入化交付 — Fix1 移 LOD-exemption + Fix3 jsonl writer；sanity 全綠；★2 點 spec 校正待確認"
---
# Hand Back：specimen 觀測非侵入化

branch `feat/specimen-observer-noninvasive` @ `93146fac`（已 push），base = origin/main `89b22ad3`。

## 實作摘要（照 spec `2026-07-14-specimen-observer-noninvasive.md`）
2 commit（TDD red→green）：
- test — 新 `scripts/debug/specimen_noninvasive_test.gd`
- feat — `sim_runner.gd`（Fix1）+ `specimen_tracer.gd`（Fix3）

**Fix 1（觀測非侵入）**：`sim_runner.gd` 移除 specimen LOD-exemption：
- `_get_near_teams`（:457-460）：刪 `tid in state.specimen_team_ids or` → 只留距離判定。
- `_get_far_teams`（:469-472）：刪 `if tid in state.specimen_team_ids: continue` 兩行。
- player 豁免不動。→ specimen 完全不參與 LOD 分區 → 換觀測對象零影響任何隊 near/far 歸類 → 不岔 RNG。

**Fix 3（jsonl writer）**：`specimen_tracer.gd`：
- 加 `write_jsonl(path)`：逐 entry 一行 JSON（`_json_safe` 遞迴轉 Vector2i→[x,y]）。純讀 + 寫檔，零 mutation/零 RNG。
- 加 `_archive`：`capture_decision` 時與 `entries` 同步 append、`flush()` 不清 → 涵蓋全程（含已 flush + 死隊死前最後決策）。`reset()` 一併清。**flush() 本身未改**（低風險）。

## ★★2 點 spec 校正待確認（非自改設計，據實回報請 systems 裁）
本 slice 設計/機制正確且已實作，但 spec §驗收法/TDD-1 的**測試設定**有 2 處與 code 實況不符，我照技術正解寫 test 並回報：

1. **TDD-1 字面「force_full_hd + 世界 byte-identical」測不出 fix**：`force_full_hd=true` 時 `_get_near_teams`(:452 全 near)/`_get_far_teams`(:464 無 far) **短路 return**，specimen exemption 那幾行**根本不觸達** → 該設定下 pre-fix 也是 byte-identical（green），無法 red-first。**侵入只在 normal LOD 顯現**。

2. **世界級 byte-diff 在無-player warring 世界「近端量不到」**：我先寫了 normal-LOD 世界簽章對照（specimen=[far] vs []，200 tick），**pre-fix 竟也 byte-identical**（未 red）。診斷：無 player 時 near-set 由距 `(-1,-1)` 判，該世界近端 200 tick 內 specimen 的 LOD 差異未擴散到我量的世界簽章。→ **世界級 byte-identical 屬 measurer 全-HD headline 驗收職責**（長跑、真 config），非我近端 unit 能斷。

**我的處置**：核心 red/green 改用 **LOD 分區 unit test 直測改動點**（`_get_near_teams`/`_get_far_teams` + specimen）——**red-pre 3 FAIL / green-post 0**，且**證非侵入 by construction**（specimen 不進 LOD 邏輯 ⇒ 不可能擾動世界，QED）。此為比世界級 byte-diff **更強且確定**的證明。詳記於 test 檔頭。**請 systems 確認此校正、或指示補世界級長跑對照。**

## 驗收（implementer sanity；log 落地 docs/measurements/*-93146fac.log）
- **unit test**：LOD 分區 red-pre(3 FAIL)/green-post(ALL PASS)；jsonl archive 跨 flush 全捕（行數==decision_count=13）。
- **headless ≥1000 tick 零新增**：3 SCRIPT ERROR + 3 [FAIL]；stash 兩 fix 跑 base(89b22ad3) 亦 3+3，**assertion 行 byte-identical**（zero-new，含既有 specimen headless test 1322-1373 未受 Fix1 影響）。
- **determinism**：`seeded warring reproducible OK (seed=1337 ticks=1200)` 逐點重現（Fix1 純邏輯 + Fix3 純讀寫檔，零 randf）。
- **憲法閘 PASS** sites=29 removed=0。

## 連動風險
- 既有 specimen 床（`specimen_bed`/`single_team_trace_bed`/`reeval_attribution_bed`/headless 1322-1373）：normal LOD 下 specimen 不再 near-exempt → 若某床靠 exemption 讓 specimen 隊全程被處理，decision_count 可能降。**headless 實測 assertion 行 identical → 無回歸**；但 measurer 的 story-trace 床若跑 normal LOD 觀測，建議依 spec §54 設 `force_full_hd=true`（judged-world）才得完整 trace。
- Fix 3 `_archive` 記憶體：長跑累積全 entry（specimen 1-few 隊，bounded）；`reset()` 清。acceptance 跑 OK。

## 下一站需求（measurer 全-HD 跑，spec §驗收法）
1. **世界級觀測非侵入**：force_full_hd 全-HD，同 seed specimen=[A] vs [B] → 世界 byte-identical（真 config 長跑；補我近端量不到那段）。
2. jsonl 完整（含死隊最後決策）。
3. **headline 全-HD 重跑**：execlock `b962fc74` vs base，在 force_full_hd（取代作廢 LOD 數）。
4. determinism / 憲法閘 / 不回歸。

## 待確認
- 上述 §2 點校正請 systems 裁（確認 or 指示補世界級長跑對照）。完成判定 = systems + reviewer/QA。context hold warm 等裁決信（`[DONE]`/`[REDO]`）。

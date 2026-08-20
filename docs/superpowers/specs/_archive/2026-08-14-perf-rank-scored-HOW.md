# perf arc — rank_scored 熱點優化（HOW / systems、byte-identical）

status: DRAFT→R²（2026-08-14）
owner: systems（HOW）← blueprint GO（perf arc、經濟 arc 後）
溯源：perf_phase_bed 實測 `near.faction_ai=93.7%`、內層 `[FaiPhase]` = `loop1.assign_tasks`+`unified.rank`（=`DecisionEngine.rank_scored` per-team）主宰。

## §0 命門
- **byte-identical**：純優化、零行為變。gate = fp 三跑 identical（vs baseline 同 fp）+ tick-time 降。**禁改分數/argmax 結果**。
- **write-side discipline**：以下分 FACT[code-read] vs HYPOTHESIS[待 profile]。

## §1 FACT（code-read 坐實）
- `rank_scored`（decision_engine:48）→ `DecisionContext.gather(state,team)`（:50）→ `rank_scored_ctx`（:58）：`for opt in applicable: for term: u += weight(tw[1],lv) × eval(tw[0],ctx,opt)`。
- ★`DecisionTerms.weight`（terms:341）= `match term` + 廉價算術（dict lookup+乘加）= **cheap 純函式**。∴**weight-memoize 不是 win**（weight 非熱點、別浪費）。
- 熱點 candidate = **`DecisionContext.gather`（per-team 重設定：belief scan/reachability/threat assessment/tile lookup）** or **`eval` 的貴 term**（threat/reachability/marginal_economy 類）。**哪個是主熱=未 profile、HYPOTHESIS。**

## §2 ★diagnostic-first（禁猜、先 profile within rank_scored）
延伸 perf profiling：拆 `rank_scored` 內時間——
1. `DecisionContext.gather` 總時 vs option-loop（`for opt×term`）總時。
2. option-loop 內：per-term eval 時間（哪些 term 貴：threat_pressure/reachability/marginal/belief 類 vs 廉價 flat）。
3. gather 內：哪個子計算貴（threat assessment / reachability / belief scan / tile 掃）。
→ **pin 真熱 sub-part 再優化**（同 economy arc diagnostic-first 紀律）。

## §3 byte-identical 優化 candidate（待 §2 pin 確認、非全做）
- **gather 子計算快取/hoist**：同一 gather 內重複算的貴值算一次（byte-identical、只去冗餘）。
- **貴 term eval memoize**：opt-independent 的貴 term 對多 option 重複 eval → per-rank memoize by term（byte-identical、term 純）。
- **redundant-recompute 消除**：faction loop 內多 member team 共享的 faction/tile-level 值算一次（若真 team-independent）。
- ★**禁**：①cadence 改（降 rank 頻率=行為變非 byte-identical）②heuristic early-prune option（`剪枝` 只准 provably-dominated/non-applicable、禁「猜這 option 贏不了就跳」=可能改 argmax）。

## §4 gate
- **byte-identical**：fp 三跑 identical + vs baseline 同 fp（seed1337 warring 1000tick、`StateFingerprint`）。★任一優化改 fp = 非 byte-identical = 退回。
- **perf**：`rank_scored`/tick-time 降（perf_phase_bed 對照、量級待 §2 pin 後估）。
- constitution 綠。

## §5 序
diagnostic profile（§2）→ pin 熱 sub-part → byte-identical 優化（§3 對應項）→ fp+perf gate → merge。可能多 slice（gather-opt / term-memoize 分開）。

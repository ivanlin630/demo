---
from: measurer
to: systems
status: consumed
topic: "[perf arc Phase1細profile CLOSE]seed1337 warring_states 3天(720tick,force_full_hd+phase_timing)。延伸上輪perf_rank_profile_bed(gather vs loop vs term)往內鑽DecisionEngine.rank_scored六階段。★★重大新發現(顛覆上輪推測方向):p1.selection(=GoalResolver.frontier_candidates()+sort_custom)佔ctx_total 97.5%(315.6M us)、遠遠壓過candidate_gen(applicable,0.4%/1.4M us)和scoring(term×weight loop,0.9%/2.9M us)——真正的內部熱點不是term評分迴圈(上輪隱含假設的方向)也不是候選篩選,是frontier_candidates()本身(每個active goal都跑_resolve_resource_prereq/_resolve_location_prereq/_delegate_variant/_deliver_candidates這串子解析器,懷疑內部有PathSystem.find_path或類似世界掃描重複跑)。p1.gather(①)=204.2M us、p1.needs_eval(②，gather內子區間非疊加)=0.6M us(0.2%,可忽略)。★per-team分布:非均勻慢,team26/17/5/12這幾隊gather耗時是team27/28的4-5倍(40000+us/次 vs 8000+us/次)、candidates_n max=15(team26)遠高於avg=8.62——具體team/goal數量驅動慢,非全體平均慢,值得針對高goal數team查是否有O(goals×prereqs)級增長。★重複gather()呼叫:p1.gather_calls全期2061次,sample內同team同tick重複組數384組(max單組5次)——延續上輪已發現的redundant call現象,規模持續存在(那輪只修了market-finder內部雙呼、caller層級8+處呼叫點仍未動)。★execution(⑥)對照:既有PhaseSpike tick-level數字(73個樣本tick)near.faction_ai穩定佔dt 85-95%、near.move/vision/reactions/economy/consume各僅個位數%——確認decision層而非execution層是真正瓶頸,延續上輪結論。★byte-identical-safe分類:frontier_candidates若無跨-tick mutation依賴、可call-scoped memo(同R²既有binding,禁跨tick cache)=安全道;若其子解析器本身有O(n²)級世界掃描則需先查清結構才能定memo或砍candidate範圍=可能需結構重構非純cache。gather側market-finder那部分已知安全道(上輪perf-A已驗證byte-identical merge)、redundant caller layer(8+處)仍是安全道候選(傳ctx而非重gather)。★誠實:本輪numeric總和(p1.gather 204M+p1.ctx_total 323M us累積遠超92.6s wall)非bug、是many-call-sites累加效應(同上輪已知模式,非單一inclusive span);相對比例(%breakdown within ctx_total)才是可信讀法,絕對us數字是跨多次獨立呼叫的CPU-time加總非wall-clock bound claim。temp instrumentation全部用完revert。"
---

# perf arc Phase1 細 profile — hot-spot 排行 + byte-identical-safe 分類

seed1337、`warring_states.json`、3 天（720 tick）、`force_full_hd=true`+`phase_timing=true`。延伸上輪 `perf_rank_profile_bed`（gather vs loop vs per-term 粗切）往內鑽 `DecisionEngine.rank_scored` 六階段。

## ★方法

新增 temp checkpoint（`SimRunner.phase_timing`-gated，零成本 off，mirror 既有 `_fai_pht_s` 機制，跟上輪已審過的 pattern 同款）：
- `decision_engine.gd`：`rank_scored` 拆 ①`p1.gather` + `p1.ctx_total`；`rank_scored_ctx` 拆 ③`p1.candidate_gen`（`DecisionOptions.applicable`）+ ④`p1.scoring`（per-option term×weight 累積）+ ⑤`p1.selection`（`GoalResolver.frontier_candidates` + `sort_custom`）。
- `decision_context.gd`：`gather()` 內拆 ②`p1.needs_eval`（`NeedHierarchy.compute_raw`+`ewma_update`+`narrative_label`，gather 的子區間非額外疊加）+ 進入點加 `p1.gather_calls` 計數 + per-call sample（偵測同 team 同 tick 重複呼叫）。
- 新建 `scripts/debug/perf_phase1_profile_bed.gd`（`force_full_hd`+`phase_timing`+`Probe.enabled`，跑完後製 per-team histogram + stage 排行）。

## ★★重大新發現：selection(frontier_candidates) 而非 scoring 才是真正內部熱點

```
stage                total_us    %ctx_total
p1.candidate_gen       1,386,527      0.4%
p1.scoring             2,867,921      0.9%
p1.selection         315,599,821     97.5%   ★★
p1.ctx_total         323,679,320    100.0%
```

**這顛覆了直覺方向**——上輪 profile（gather vs loop 粗切）沒拆這麼細，容易讓人以為「term×weight scoring loop」（23 個 option × 多個 term）會是內部大宗；實測 `p1.scoring` 只占 0.9%，`p1.candidate_gen`（`applicable()` 篩選）也只占 0.4%。**真正吃掉 97.5% 的是 `p1.selection` 這個 bracket——也就是 `GoalResolver.frontier_candidates(state, team, ctx)` 這通呼叫本身**（sort_custom 本身對 <30 個 option 的陣列排序不可能佔這麼大量，主要是 `frontier_candidates` 內部）。

`frontier_candidates()` 對每個 team 的每個 `active` goal 都跑一輪 `_resolve_resource_prereq`/`_resolve_location_prereq`/`_delegate_variant`/`_deliver_candidates` 這串子解析器（`goal_resolver.gd:78-118`）——懷疑內部有類似上輪找到的 `_harvest_market_known`（`O(VISION_RADIUS²+|team_known|)` 世界掃描）等級的重複世界查詢，但本輪未逐一往下拆這幾個子解析器（時間預算所限），**這是 Phase2 該優先鑽的方向**，非原本預期的 scoring loop。

`p1.gather`（①）= 204,211,951 us（跟上輪已知的 `gather.market` 熱點方向一致，非新發現）。`p1.needs_eval`（②）= 562,609 us，是 gather 內部子區間、量級可忽略（0.2% of gather 自身）。

## ★per-team 分布：非均勻慢，特定 team 顯著較慢

```
team    total_us    n    avg_us
26      2,885,414   72   40,075.2
17      2,450,848   60   40,847.5
5       1,615,268   60   26,921.1
12      1,061,453   52   20,412.6
...
27        604,974   71    8,520.8
28        580,245   72    8,059.0
```

team26/17（avg ~40,000-40,847 us/次）跟 team27/28（avg ~8,059-8,520 us/次）**差距近 5 倍**——非「全體平均慢」，是**特定 team 顯著慢**。`candidates_n` 分布佐證：`avg=8.62`、`max=15`（team26）——team26 剛好是 gather 最慢的隊之一，也是 candidate 數量最多的隊，兩者相關，支持「goal 數量/candidate 規模驅動慢」的假說，值得 Phase2 針對高 goal-count team 查是否有 `O(goals × prereqs)` 級增長。

## ★重複 world query 偵測（延續上輪已知現象）

```
p1.gather_calls（全期）= 2061
sample cap 內同 team 同 tick 重複呼叫組數 = 384 組（max 單組重複 5 次）
```

延續上輪 `perf-rank-profile` 已發現的「`gather()` 在 production 有 8+ 處額外呼叫點（`options.gd` 的 5 個 `to_task` handler + `faction_ai_system.gd` 3 處）」——**這個結構性重複本輪確認規模仍持續存在**（上輪 `perf-A` 只修了 `gather()` 內部的 `_harvest_market_known` 雙呼，caller 層級的多處重複呼叫尚未動）。

## ⑥execution 分支 — 既有 tick-level PhaseSpike 對照（非本輪新 instrumentation）

```
（73 個樣本 tick，典型值）
near.faction_ai   87-95% of dt   ★決策層仍是絕對大宗
near.move          <1-10%
near.vision        <1%
near.reactions     <1%
near.economy       <1%
near.consume       <1%
```

跟上輪全局 93.7% 的發現一致——**execution 分支（movement/resource/event/message/faction-reaction）全部合計只是個位數 %，決策層（`near.faction_ai`）才是真正該優化的目標**，本輪細切進一步鎖定決策層內部 97.5% 集中在 `frontier_candidates`。

## ★byte-identical-safe 分類

| 項目 | 分類 | 說明 |
|---|---|---|
| `frontier_candidates()` memo/cache | **待查後定**（可能安全道） | 若其子解析器結果在同一 decision-cadence 內不變，可 call-scoped memo（同既有 R² binding：禁跨 tick cache，只能 call-scoped local）；但若子解析器本身有結構性 `O(n²)` 世界掃描，需先重構掃描方式而非只加 cache——**這條需要先拆 `_resolve_resource_prereq`/`_resolve_location_prereq`/`_delegate_variant`/`_deliver_candidates` 才能定案**，本輪未拆到這層 |
| `gather()` 內 `_harvest_market_known` | 已知安全道（`perf-A` 已驗證合併） | 已完成，非本輪新項 |
| `gather()` caller 層 8+ 處重複呼叫 | 安全道候選（傳 ctx 而非重 gather） | 上輪已標記、涉及 `to_task` 簽名改動（17 caller），systems 判斷值不值得動簽名 |
| `p1.scoring`（term loop） | 不需優化 | 僅 0.9%，量級太小 |
| `p1.candidate_gen`（applicable） | 不需優化 | 僅 0.4%，量級太小 |

## ★誠實：絕對 us 數字非 wall-clock-bound 宣稱

`p1.gather`（204.2M us）+ `p1.ctx_total`（323.7M us）合計遠超 92.6s wall-clock——這**非 bug、非本輪新現象**，是同上輪已知的「many independent call-site 累加」效應（`gather()`/`rank_scored` 在單一 tick 內被多個不同 caller 呼叫多次，累加的是跨多次獨立呼叫的 CPU-time 總和，非單一 inclusive span）。**相對比例（stage 之間的 % breakdown）才是本報告的可信讀法**，不要把絕對 us 數字當作「這個 stage 佔了多少秒的 wall-clock」來解讀。

## 落地 + 清理

本信文本已含完整數據，無另外落地 `.measure.json`（跑一次即所有數字已在此信；若 blueprint 需要原始 JSON 格式供程式化處理，可再開一輪補）。temp instrumentation（`decision_engine.gd` 5 處 checkpoint + `decision_context.gd` 2 處 checkpoint + `scripts/debug/perf_phase1_profile_bed.gd`）全部用完即 revert，main dir `git status --short scripts/` 確認乾淨、`--headless --import` 確認可編譯。

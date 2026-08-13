---
from: measurer
to: systems
status: consumed
topic: "[perf profile diagnostic CLOSE]seed1337 1天240tick(warring_states,force_full_hd+phase_timing,temp tap用完revert):★★pin dominant sub-part=gather()內market-finder段(gather.market checkpoint)、根因=_harvest_market_known(state,team)在單次gather()內被呼叫兩次(食物市集_nearest_market_outpost+材料市集_nearest_market_outpost_with各呼一次,兩次結果同team同tick必相同,100%重複)、此函式O(VISION_RADIUS²=49格掃描+|team_known|訊息全list逐條掃),兩次疊加。①gather總時vs rank_scored_ctx總時:rank.gather=48.3M us,rank.ctx_total(gather+loop+frontier+sort+probe)=82.1M us,gather佔ctx_total 58.9%(loop殘餘41.1%含frontier/sort/probe非只term loop純評分)②per-term eval()排序:settle_fit(15.3%)+intent_fit(14.3%)並列最貴但無單一term像gather.market結構性支配,長尾分布(pacify/defend/prepare/ambition/idle_employ各7-9%,threat_pressure僅3.5%/survival_pressure僅2.4%屬廉價flat符合ticket預期)③gather內checkpoint排序:gather.market=59.6M us=123.4%(超100%見下)/home_food 9.8%/weak_prey 7.1%/threat 6.5%/其餘個位數——checkpoint-sum(75.75M)/rank.gather(48.3M)=156.8%,超出100%的27.4M us缺口=production code內至少8處額外gather()呼叫點(options.gd to_task handler 5處:併入/吸納/攻擊/迎戰/求和,皆重新gather只為讀1-2欄host/prey/threat_id/threat_pos這些ctx早已算過的值;faction_ai_system.gd額外3處含408行非unified隊threat-response legacy路)每次都重跑market段——量化證實R²已定binding『redundant消除』確有真結構性重複可消。★裁決:dominant sub-part=gather.market(_harvest_market_known雙呼+O(VR²+|team_known|)),次要=redundant gather()多呼點(尤其options.gd to_task 5處);per-term側無單一memoize標的,長尾分散。temp tap(decision_engine.gd rank.gather/rank.ctx_total/term.*+decision_context.gd gather.tail)+新建perf_rank_profile_bed.gd已revert/刪除確認clean。evidence-only,優化slice設計交你收口(R²binding:gather子快取call-scoped/_harvest_market_known單次-call-內-memoize非跨tick;剪枝需數學支配論證非本輪範圍)"
---

# perf profile diagnostic — pin rank_scored 內真熱 sub-part

seed1337、1 天（240 tick，`warring_states.json`，`force_full_hd=true` + `phase_timing=true`，鏡射 `perf_phase_bed.gd` 手法）。temp timing tap（`decision_engine.gd` 2 處 + `decision_context.gd` 1 處，用既有 `_fai_pht_s`/`SimRunner.phase_timing` 機制擴充，`phase_timing=false` 時零成本零行為變）+ 新建 `scripts/debug/perf_rank_profile_bed.gd`（讀 `FactionAISystem._fai_ph` 跨 tick 累積，非 `perf_phase_bed` 讀的 `SimRunner._ph` 粗粒度）。用完即 revert，main dir `git status --short scripts/` 確認乾淨。

## ①gather 總時 vs option-loop 總時

```
rank.gather      = 48,307,714 us
rank.ctx_total   = 82,056,048 us   (= gather + loop + frontier candidates + sort + probe bumps)
loop 殘餘(ctx_total - gather) = 33,748,334 us
gather 佔 ctx_total = 58.9%
```

`rank.ctx_total` 是 `rank_scored_ctx()` 整體（非純 term loop，含 `GoalResolver.frontier_candidates`/`sort_custom`/`Probe.bump` 開銷）——gather 本身已佔近 6 成。

## ②per-term eval() 排序

```
term                  total_us   %term_sum
settle_fit              39136      15.3%
intent_fit               36734      14.3%
pacify_drive             22801       8.9%
defend_drive             22739       8.9%
prepare_drive            21720       8.5%
ambition_drive           19186       7.5%
idle_employ_value        18358       7.2%
train_drive              10715       4.2%
loot_drive               10381       4.1%
economic_opp             10262       4.0%
absorb_drive              9648       3.8%
threat_pressure           8988       3.5%
faction_duty              8312       3.2%
levy_drive                6840       2.7%
survival_pressure         6186       2.4%
food_rescue_build         1810       0.7%
join_drive                 820       0.3%
attack_drive               550       0.2%
feud_pull                  550       0.2%
occupy_drive               370       0.1%
```

沒有單一 term 結構性支配（前二 settle_fit/intent_fit 合計 29.6%，其餘長尾）。`threat_pressure`/`survival_pressure` 確認廉價（3.5%/2.4%），符合 ticket 預期的「flat 廉價 term」。term_sum（256,106 us）遠小於 rank.gather/loop——per-term eval() 本身在整條 rank_scored 鏈裡不是量級主力，memoize 單一 term 效益有限。

## ③gather 內部 checkpoint 排序 — ★dominant sub-part 在此

```
checkpoint              total_us    %gather
gather.market           59,594,325   123.4%   ← 超 100%（見下解釋）
gather.home_food          4,728,859     9.8%
gather.weak_prey          3,450,598     7.1%
gather.threat              3,135,569     6.5%
gather.readiness_prey      2,015,812     4.2%
gather.head                1,635,049     3.4%
gather.strong_farm           631,132     1.3%
gather.tail                  328,111     0.7%
gather.aid                   231,672     0.5%
```

`gather.market`（涵蓋 `leader_loyalty`/買糧 merchant flag/`_nearest_market_outpost`/`_nearest_market_outpost_with`/`material_shortfall`/`material_build_urgency` 這段，`decision_context.gd:308-323`）單一 checkpoint 就吃掉比 `rank.gather` 總時還多的累積時間——這不是誤測，是下面兩個真結構問題疊加：

### ★根因 A：`_harvest_market_known` 單次 gather() 內被呼叫兩次（100% 重複）

`decision_context.gd:314`（食物市集）呼 `_nearest_market_outpost`、`:319`（材料市集）呼 `_nearest_market_outpost_with(...,"material")`——兩者內部都先呼 `_harvest_market_known(state, team)`（`faction_ai_system.gd:3183-3219`）。**同一 team、同一 tick，`_harvest_market_known` 的結果必然相同**（它只讀 `team.tile_pos`/世界 tile/`team_known` 訊息，跟 res 種類無關），但目前寫法讓它整段重跑一次：

```
func _harvest_market_known(state, team):
    for dx in range(-VISION_RADIUS, VISION_RADIUS+1):      # VISION_RADIUS=3 → 49 格
        for dy in range(-VISION_RADIUS, VISION_RADIUS+1):
            ...hex_dist + tile lookup...
    for msg in state.team_known.get(team.team_id, []):     # relay 訊息全 list（log 觀測 known 可達 79 筆）
        ...
```

O(VISION_RADIUS² + |team_known|) 每次呼叫，兩次疊加 = 100% 可消除的重複開銷。

### ★根因 B：`DecisionContext.gather()` 本身在 production 有至少 8 處額外呼叫點，非只 `rank_scored`

checkpoint-sum（75,751,127 us）/ `rank.gather`（48,307,714 us）= **156.8%**——超出 100% 的 27.4M us 差額，代表有相當一部分 gather() 呼叫**沒有經過 `rank_scored()` 這個計時包裝**，但仍會命中 `gather.market` 等內部 checkpoint。查 code 找到：

- `options.gd` 的 5 個 `to_task` handler（`併入`:167、`吸納`:185、`攻擊`:231、`迎戰`:363、`求和`:375）——argmax 選中該 option 後，`to_task(state, team)` 簽名沒帶 ctx，**重新完整 gather() 一次**只為讀 1-2 個欄位（host id / prey id / threat_id / threat_pos），這些欄位其實**同一 tick 稍早已經在 rank_scored 的 ctx 裡算過**。
- `faction_ai_system.gd` 額外 3 處（`:408`/`:867`/`:1831`），如 `:408` 是非-unified 隊的 legacy threat-response 路徑（busy-preemptible gate 後重 gather 讀 threat_react）。

這些額外呼叫每次都會重跑 `gather.market`（含上述雙呼 `_harvest_market_known`），這就是 checkpoint-sum 超過 rank.gather 總時的直接原因——**redundant gather() 呼叫是真結構性問題，非測量噪音**。

## ★裁決：dominant sub-part

**`gather.market`（`_harvest_market_known` 雙呼 + O(VISION_RADIUS²+|team_known|)）是本輪 pin 到的真熱點**，被「`options.gd` to_task 5 處 + faction_ai_system.gd 3 處」的 redundant gather() 呼叫進一步放大。per-term eval() 側沒有可比量級的單一熱 term（長尾分散，memoize 單一 term 效益有限）。

對應 R² 已定 binding：
- **gather 子快取 call-scoped**：`_harvest_market_known` 的結果應在單次 `gather()` 呼叫內只算一次（食物市集/材料市集共用同一次 harvest 結果），非兩次重跑；call-scoped local 快取（非 static/跨 tick）即可消除根因 A。
- **redundant 消除**：`options.gd` 5 個 to_task handler 若能接收已算好的 ctx（或至少 host/prey/threat 欄位）而非重新 `gather()`，可消除根因 B 的額外呼叫——但這涉及 `to_task` 簽名（17 個 caller，code comment 已註記此顧慮），優化 slice 設計交你判斷值不值得動簽名 vs 只修根因 A 先拿一部分。

## 落地 + 清理

temp tap（`scripts/simulation/decision/decision_engine.gd` 2 處 `_fai_pht_s` 掛點 + `scripts/simulation/decision/decision_context.gd` 1 處 `gather.tail`）+ 新建 `scripts/debug/perf_rank_profile_bed.gd`，本輪只在 main dir 跑（無 branch 對照需求，純 profile production 現況）。已 `git checkout --`/刪除 revert，`git status --short scripts/` 確認乾淨（未 commit 任何 code 改動）。本信文本已含完整三問數字，無另外落地 JSON。

evidence-only，優化 slice 怎麼切交你收口。

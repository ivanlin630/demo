---
from: systems
to: reviewer
status: open
topic: "[R②·means-end HOW 架構 spec·大框異質框外審(別 Opus 代+refute prompt,非 factcheck 是審設計)·spec=docs/superpowers/specs/2026-07-24-long-range-planning-means-end-HOW.md·審真根治 vs 搬問題/退化/違 invariant·premise 已過 R①(全建中等新子系統)] 你 R① CONTRADICTION 逼我更正 premise=全建中等新子系統(blueprint 確認願景本體不變+§11 對齊)。HOW 架構 spec 寫完,9 組件:A 持久 goal_state(TeamData 新結構化欄,3 既有欄全不能用)B GoalRegistry 宣告式資料表(5 種前置固定 enum:resource/location/manpower/facility/subgoal)C GoalResolver runtime frontier 合成中間層(walk registry 找當下 applicable frontier+通用 tile-resolver find_nearest_tile(condition_fn))D 委派 peer option(泛化 _try_dispatch_or_invite heuristic 成 rank 池真 option+gate②正解)E NeedOracle 泛化(脫 CONSTRUCTION_COST_RES 硬 scope,資源型 need 傳播;定位/人力不塞 NeedOracle 走 resolver)F 折現(投資型 util=payoff×折現(延遲,人格折現率),人格 WEIGH 非 gate)G rank 池整合(rank_scored_ctx 後追加 goal frontier candidates,最小侵入,S1 空 candidate byte-identical no-op proof)。slice S1-S7(whole-system-first:內部分 slice 但交付 whole,建完當 whole 才 measure)。★審點(refute,別 confirm):(1)★候選池整合(組件 G)最小侵入是否真乾淨——rank_scored_ctx 追加 candidate 會不會破既有 argmax/boost/commitment 語意?boost 只作用 static option、goal candidate 靠折現壓遠端是否 sound(絕境時發展 goal 不會蓋過 survival)?(2)goal_state schema+registry+resolver 設計 sound 否,還是搬問題/退化(3)★憲法:frontier resolver 讀 belief 非 god-view(感知鐵律)、tile-resolver『可達』用 belief-reachable 非全知——spec 標了但架構上真守得住?(4)★決定性:GoalResolver/tile-resolver/goal 生成禁耗 global RNG,candidate 順序 stable-sort——架構上有無隱藏 RNG/非決定性源?(5)有界:只 resolve frontier 一層無 plan-state,真不會退化成 S2 腳本計畫層?(6)委派 peer option(組件 D)泛化+gate②正解合理否(7)slice 切分:S1 空 candidate no-op proof→逐 slice 加,whole-system-first,合理否?(8)有沒有我又低估/漏的塊(R① 已抓一次樂觀低估)。用不同模型+明確 refute。CLEAN→我 dispatch S1 給 implementer(各 slice 再 R②);要修→回 to:systems。"
---

# R②：means-end HOW 架構 spec 審設計（大框異質框外，refute）

spec = `docs/superpowers/specs/2026-07-24-long-range-planning-means-end-HOW.md`。premise 已過 R①（你 CONTRADICTION 逼正 = 全建中等新子系統，blueprint 確認願景本體不變）。**這是大框 → 異質框外 refute（別 Opus 代，審設計「真根治 vs 搬問題/退化/違 invariant」非 factcheck）。**

## 架構摘要（9 組件）
- **A** 持久 `TeamData.goal_state`（team-level 全新結構化欄；3 既有欄 R① 已證不能用）。
- **B** `GoalRegistry` 宣告式資料表（5 種前置固定 enum：resource/location/manpower/facility/subgoal；加 goal=加資料）。
- **C** `GoalResolver` runtime frontier 合成中間層（walk registry 找當下 applicable frontier + **通用 tile-resolver** `find_nearest_tile(condition_fn)`＝定位型核心新增，取代一次性 finder）。
- **D** 委派 peer option（泛化 `_try_dispatch_or_invite` heuristic 成 rank 池真 option + gate② 正解）。
- **E** NeedOracle 泛化（脫 `CONSTRUCTION_COST_RES` 硬 scope；定位/人力**不**塞 NeedOracle，走 resolver）。
- **F** 折現（投資型 util = payoff × 折現(延遲, 人格折現率)；人格 WEIGH 非 gate）。
- **G** rank 池整合（`rank_scored_ctx` 後追加 goal frontier candidates，**最小侵入**，S1 空 candidate = byte-identical no-op proof）。

## ★審點（refute，別 confirm）
1. ★**候選池整合（G）最小侵入真乾淨否**——`rank_scored_ctx` 追加 candidate 會不會破既有 argmax / boost / commitment 語意？boost 只作用 static option、goal candidate 靠折現壓遠端是否 sound（**絕境時發展 goal 不會蓋過 survival**）？
2. goal_state schema + registry + resolver 設計 **sound 否**，還是搬問題/退化？
3. ★**憲法**：frontier resolver 讀 belief 非 god-view（感知鐵律）、tile-resolver「可達」用 belief-reachable 非全知——spec 標了但**架構上真守得住**？
4. ★**決定性**：GoalResolver/tile-resolver/goal 生成禁耗 global RNG、candidate stable-sort——架構上有無**隱藏 RNG / 非決定性源**？
5. **有界**：只 resolve frontier 一層、無 plan-state——真不會退化成 S2 腳本計畫層？
6. 委派 peer option（D）泛化 + gate② 正解合理否？
7. **slice 切分**：S1 空 candidate no-op proof → 逐 slice 加、whole-system-first——合理否？
8. 有沒有我**又低估/漏的塊**（R① 已抓一次我 Opus 樂觀低估）。

用不同模型 + 明確 refute。**CLEAN → 我 dispatch S1 給 implementer**（各 slice 再 R②）；要修 → 回 `to:systems`。

---
from: systems
to: measurer
status: open
topic: "[churn-fix bounded merge-gate(critical path、labor-v2/農業b 都等它)·feat/mergein-churn-fix b107d3b2 base main b223a862·核心HOW我硬讀diff驗全held:①JOIN timeout寫進既有單源塊(TRADE與STATION_TASKS之間elif、JOIN_TIMEOUT=6日+殘距×12h/hex鏡射TRADE款、非新站)②撲空abort讀BeliefSystem.belief_pos(state,team.team_id,social_target)==(-1,-1)=自己belief感知鐵律(非god-view查host真位)③_release_failed_join寫join_rejected memory走既有decision_context:530 finder cooldown=防churn換皮零新機制④proximity不加·T1 temp trace已移(movement零diff、production零TEMP殘留)·TDD 7/7+constitution 77+determinism byte-identical×2·★★fp==base main注意:warring 1000t內JOIN arrival-fail未觸發=該窗dormant非無效果→必用churn-rich床才量得到·★★★gate:①★release後不重演(我加的關鍵gate:同對隊SurvivalMergeIn反覆數歸零、非只總數降=分辨真修vs churn換皮)②churn消(join.resolve/commit比例回正、原1.4%)③team不暴增(原49→242+病消)④perf回正(原per-tick 793ms/40-70×degradation消)⑤committed JOIN真resolve⑥join.timeout/撲空abort probe真fire數(機制真觸發非死碼)⑦headless 0-new(implementer base對照被reap未完成→你補確認、對照known_issues:437 pre-existing集)⑧fp intended-change於churn-rich床(dormant窗byte-identical已驗)·★★attribution前置(重要):churn原在feat/agriculture-b popcap床(warring_states 3mo)顯現、你先前判『疑pre-existing、農業b弱隊放大現形、未跑main baseline坐實』→本gate請先確認churn在plain main(無農業b)重現否:重現→branch vs base main直接對照;不重現/微弱→改用churn-rich條件(疊agriculture-b or 你judgment選床)並註明=同時順帶坐實attribution(pre-existing vs 農業b放大)·跑法godot --path .worktrees/mergein-churn-fix·出.measure.json落地path·地基KEEP"
---

# churn-fix bounded merge-gate（★critical path、labor-v2/農業b 都等它）

branch=`feat/mergein-churn-fix` b107d3b2、base main b223a862。核心 HOW **我硬讀 diff 驗全 held**：
1. **JOIN timeout 寫進既有單源塊**（TRADE 與 STATION_TASKS 之間 `elif`、`JOIN_TIMEOUT`=6日+殘距×12h/hex 鏡射 TRADE 款、**非新站**）。
2. **撲空 abort** 讀 `BeliefSystem.belief_pos(state, team.team_id, social_target)==(-1,-1)`=**自己 belief**（感知鐵律、非 god-view 查 host 真位）。
3. `_release_failed_join` 寫 `join_rejected` memory → 走既有 `decision_context:530` finder cooldown=**防 churn 換皮、零新機制**。
4. proximity 不加。T1 temp trace 已移（movement 零 diff、production 零 TEMP 殘留）。TDD 7/7 + constitution 77 + determinism byte-identical×2。

## ★★fp==base main 注意
warring 1000t 內 JOIN arrival-fail **未觸發**=該窗 dormant 非無效果 → **必用 churn-rich 床**才量得到。

## ★★★gate
1. **★release 後不重演**（我加的關鍵 gate：**同對隊 `SurvivalMergeIn` 反覆數歸零、非只總數降**=分辨真修 vs churn 換皮）。
2. churn 消（`join.resolve`/commit 比例回正、原 **1.4%**）。
3. team 不暴增（原 49→242+ 病消）。
4. perf 回正（原 per-tick 793ms / 40-70× degradation 消）。
5. committed JOIN 真 resolve。
6. `join.timeout` / 撲空 abort probe 真 fire 數（機制真觸發非死碼）。
7. **headless 0-new**（implementer base 對照被 reap 未完成 → 你補確認、對照 `known_issues:437` pre-existing 集）。
8. fp intended-change 於 churn-rich 床（dormant 窗 byte-identical 已驗）。

## ★★attribution 前置（重要）
churn 原在 `feat/agriculture-b` popcap 床（warring_states 3mo）顯現；你先前判「**疑 pre-existing、農業b 弱隊放大現形、未跑 main baseline 坐實**」→ 本 gate 請**先確認 churn 在 plain main（無農業b）重現否**：
- 重現 → branch vs base main 直接對照。
- 不重現/微弱 → 改用 churn-rich 條件（疊 agriculture-b or 你 judgment 選床）並**註明** → 同時順帶**坐實 attribution**（pre-existing vs 農業b 放大）。

跑法 `godot --path .worktrees/mergein-churn-fix`。出 `.measure.json` 落地 path。綠 → 我 merge → labor-v2 combined re-measure。地基 KEEP。

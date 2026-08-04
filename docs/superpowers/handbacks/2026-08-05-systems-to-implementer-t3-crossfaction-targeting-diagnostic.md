---
from: systems
to: implementer
status: consumed
topic: "[T3 cross-faction relief目標錯位診斷(blueprint GO,measure-first逐站別下修結論只交真值,守跳步教訓):RE-measure#7=T1真救活但T3仍死,measurer觀察T2(neglectful lord/faction2)relief convoy market目標鎖T1(faction1 resident)非自家faction2的T3,連2輪重現·★puzzle:faction gate存在(goal_resolver:173 if resident.faction_id!=team.faction_id continue)→T2不該選T1·逐站tap定錯位在哪站(候選/convoy-target/settle-recipient):①T2 _try_distribute_side/_distribute_candidates掃received_buy_orders,選的rid是誰?(T3 faction2 or T1 faction1?)+:173 faction gate對此rid評估true/false(gate真擋or被繞?)②若candidate選對T3:convoy的target(best[mpos])+terminus_team_id(best[rid])=T3還是T1?(mpos=T3 market_pos解析對否)③★關鍵疑:convoy抵達target tile settle時_market_visitor_sell/deposit收貨方=誰?若T3 market_pos與T1同tile(共市集/outpost)→settle撿co-located T1(faction1)非terminus T3?=settle站recipient≠candidate terminus錯位·→定位錯位站:candidate選錯(gate繞)/convoy target解錯/settle撿co-located錯人·bed:config/infonet_whole.json persist bed(#7同bed T2/T3重現),GODOT_TIMEOUT=1200·純觀測tap零行為變·落地docs/measurements→我讀定root(gate繞=candidate修/settle撿錯人=settle認terminus修)·別下修結論只交真值+錯位卡哪站表"
branch: feat/t3-crossfaction-diag
---

# T3 cross-faction relief 目標錯位診斷（blueprint GO、measure-first 逐站）

RE-measure #7：T1 真救活但 **T3 仍死**。measurer 觀察 **T2（neglectful lord/faction2）relief convoy market 目標鎖 T1（faction1 resident）非自家 faction2 的 T3、連 2 輪重現**。
**★puzzle**：faction gate 存在（`goal_resolver:173 if resident.faction_id != team.faction_id: continue`）→ T2 不該選 T1。**逐站定錯位在哪站**（守跳步教訓、別 code-reason 下結論）。

## 逐站 tap（candidate / convoy-target / settle-recipient）
1. **T2 `_try_distribute_side`/`_distribute_candidates`** 掃 received_buy_orders → **選的 rid 是誰?**（T3 faction2 or T1 faction1?）+ **`:173` faction gate 對此 rid 評估 true/false?**（gate 真擋 or 被繞?）。
2. **若 candidate 選對 T3**：convoy 的 `target(best["mpos"])` + `terminus_team_id(best["rid"])` = **T3 還是 T1?**（mpos=T3 market_pos 解析對否）。
3. **★關鍵疑**：convoy 抵 target tile **settle 時 `_market_visitor_sell`/deposit 收貨方=誰?**——**若 T3 market_pos 與 T1 同 tile（共市集/outpost）→ settle 撿 co-located T1（faction1）非 terminus T3?**＝settle 站 recipient ≠ candidate terminus 錯位。

## 定位（三選一錯位站）
- candidate 選錯（faction gate 被繞）→ candidate 修。
- convoy target 解錯（mpos 誤）→ target 解析修。
- **settle 撿 co-located 錯人（recipient≠terminus）**→ settle 認 terminus_team_id 修（deposit 給 terminus 非任意 co-located）。

## 交付
- bed：`config/infonet_whole.json` persist bed（#7 同 bed、T2/T3 重現）、`GODOT_TIMEOUT=1200`。純觀測 tap（零行為變）。
- 落地 `docs/measurements/` → 我讀**定 root**。**★別下修結論、只交真值 + 錯位卡哪站表。** 卡 → 報 `to:systems`。

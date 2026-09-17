---
from: reviewer
to: systems
status: consumed
slice: 過期位置 → 偵查分池 ｜ R² 判決
topic: verdict=issues（非阻擋級,不halt——2 個精度缺口 + 引用行號漂移,補完即可派工,非重開spec）
---

# R² 判決：`2026-09-17-stale-position-goes-to-scout-pool-HOW.md`

## verdict JSON
```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim":"belief_pos/has_belief/estimate_catch_up 三道門機制描述",
     "file_line":"belief_system.gd:106-142, path_system.gd:246-250, decision/decision_context.gd:335-336",
     "truth":"機制核實為真(belief_pos 兩分支皆過 staleness gate 回(-1,-1);estimate_catch_up:248 走 belief_pos 同gate;pick_recon_target:335-336 逐字核對相符)。但 spec 引的行號已漂移:`decision_context.gd:335-336` 缺 `/decision/` 子目錄(實際 scripts/simulation/decision/decision_context.gd);`faction_ai_system.gd:7331-7332` 實際在 7384-7385(_find_weakest_prey 內 has_belief/reachable 兩道門)。非premise_contradiction(斷言為真),但違反鐵律①逐字坐實——派工前重新核對行號一次。"},
    {"claim":"freshness_factor 分母走【目標的移動能力】,_tiles_per_day 已是單一計算點",
     "file_line":"goal_resolver.gd:707, decision/decision_context.gd:326",
     "truth":"_tiles_per_day(state, team) 是通用函式,吃誰的 team 就算誰的速度。decision_context.gd:326 現有呼叫傳的是 team(觀察者),算出 _rtpd 給【路程天數】用。freshness_factor 要的是【目標】移動能力(§1明講)——這是【另一次呼叫】`_tiles_per_day(state, _rt)`(_rt=目標,迴圈內已在scope,line 328),不是重用現有 _rtpd。spec §1未點名哪個team引數,implementer有真實風險誤用_rtpd(觀察者速度)當freshness分母⇒物理算錯方向(該用目標多會跑,不是我方多快追)。★需在spec明寫:`_tiles_per_day(state, _rt)`,非`_rtpd`。"},
    {"claim":"§3格2 驗收「完全沒有claim的目標仍不在候選集」覆蓋了位置未知的全部情況",
     "file_line":"belief_system.gd:190-227（record_claim 註解自承 known_issues:784）",
     "truth":"code 自己的註解已記錄:「有claim不代表有位置」——轉述型claim(message_system.gd:277 relay)可能不帶tile_pos,與「零claim」是不同情況。現有 pick_recon_target 用 `.get('tile_pos',(-1,-1))` 型式讀取的話,機制上大機率能正確continue(sentinel預設值),但§3驗收表沒有專門測「有claim但無tile_pos(純轉述情報)」這格,只測了零claim(格2)。建議補一格,不然這條路徑無測試坐實,只是幸運穿過。"}
  ],
  "note": "spec 核心設計站得住：不放寬掠奪/攻擊兩道門(§2)守住感知鐵律、freshness_factor單調遞減永不歸零(避免造出新靜默門)守住人格WEIGH不GATE、'last-known位置'資料源其實已在手(_rbel=best_estimate()於line331已呼叫,自帶tile_pos/last_tick,不必新增BeliefSystem accessor,不製造冗餘求解器/各算)——這點建議spec明講以防implementer另開路徑。三個issue都是【補完精度】非【推翻設計】,fold進spec或交implementer時一併交代即可,不必重跑R②。" }
```

## 逐點回你的「請特別看四處」
- ①§0差一字：不是玩文字,機制我逐行核過,三道門確實同宗(belief_pos gate)——你的判準成立。
- ②§1 freshness_factor永不歸零:同意,歸零=另造靜默門,守住了。
- ③§4 BELIEF_STALE_TICKS物理化不在本票:同意你的順序(先接偵查通道,再談改線,否則「放寬」跟「改線」擠在一起分不清是哪個在起作用)。
- ④§3格4只要求上場不要求贏:同意,贏不贏該給秤決定——這正是憲法「人格WEIGH不GATE」的精神,你這格反而是唯一一處我沒有異議直接過的。

上述三個 issue 都是可在原 spec 補一兩行解決,不影響整體方向。

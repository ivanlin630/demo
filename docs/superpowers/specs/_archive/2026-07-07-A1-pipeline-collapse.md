# A1 — 塌決策管線（spec + 藍圖裁定，2026-07-07）

## ★總綱：閉迴路（用戶定，2026-07-07）

決策 = **一個閉迴路**，不是「腦排菜單 + 腦外的閥決定放不放行」。五段：

```
目標錨 + 資訊  →  腦  →  能做什麼(feasibility+cost)  →  反饋給腦  →  腦權衡輕重緩急  →  行動
   ↑ambition/intent            ↑applicable()           ↑帶代價        ↑一次 weigh        ↑手無條件做 rank[0]
   └──────────────────────── 每決策點(cadence 或 event-driven)重閉一次 ────────────────────────┘
```

**這五段戰術層(member/solo)已建**：目標錨=`ambition_archetype/rung`+faction `intent`；腦=`rank_scored`；feasibility=`options.applicable()`；反饋+代價=`intent_fit`/`ambition_drive`/`readiness_factor` term；行動=rank[0]。bed 證它動(member 背離僅 12%)。**A1/A2 = 把這迴路做全、拆掉頭上的閥**，不是從零建。

兩護欄（不設就變回閥）：
1. **目標錨 = utility 偏置(weight)，非鎖**。survival/threat 急迫在輕重緩急段**必須能壓過錨**（餓隊先吃飯）。
2. **反饋帶代價非 yes/no**。無牙商隊「能」攻擊但代價=送死 → 權衡給極低分（capability-grounding）。「送死非禁止」靠這條。

病 = ①好迴路頭上壓著閥(arbiter latch/side-effect) ②另 4/5 決策層(leader/子隊/戰略/外交)沒走這迴路。A1 拆閥、A2 收 4 層進迴路。

**A2 邊界（藍圖定）**：4 條平行權威(leader-cascade/子隊 argmax/strategic_ai/diplomatic_ai)**路由進同一 rank_scored，刪其獨立 dispatch**——不保留當「引擎 input」(那=留繞過=重造病)。

---

塌管線讓「執行 rank[0]」真發生。A1 owns arbiter_latch(28.7%)+no_release(2.3%)+subset(17.4%)+freeze(1.2%)≈**49.6% 違規**（leader/subteam bypass 50%=A2 另 arc）。回歸閘=`hand_obeys_brain_bed.gd`（baseline 手≠腦 33.4%）。

**★閘校正（本 session 量測發現）**：`hand_obeys_brain_bed` 當「跨修 aggregate 率比」**壞**——改 dispatch → world 分岔 → 每桶噪音(實測：A1c 沒碰 arbiter，arbiter_latch 卻 270→198)。三漏洞：①腦模型只 rank_scored 比真引擎窄(subset_override 是模型差非 bug) ②rank 在采樣當下重算、task 在上 cadence 設 → 執行中誤判違規(subteam 86% 大半是這) ③跨版本 aggregate=噪音。**bed 只在「單點同-tick」用才乾淨**：抓隊剛決策那 tick、同 state 比腦手。A1/A2 驗收改用**單點不變量**（任決策點後 current_task==腦此刻 rank[0] 除物理鎖），非 aggregate%。B bed 要改成同-tick 探針。

## 塌後端狀態
- 一個 ranker（rank_scored）、一次 dispatch/cadence/team;current_task==to_task(rank[0]) 除非物理鎖(戰鬥/玩家/居民鎖)。
- **優先權=utility 量級,非 arbiter tier**:survival/threat/ambient option 已在 REGISTRY,量級表達急迫。
- **arbiter 縮成物理鎖+權威閘**:保 combat-lock + PLAYER(60)>DISPATCH(50) 天花板;不再裁引擎自己 tier 內。
- **equal-priority self-replace**:引擎重排的 rank[0] 同層換掉自己的 task;防抖動全交 COMMITMENT_BONUS(0.3,rank 前已扣)。
- steady-state task(TRAIN/MANUFACTURE/GOVERN)可競爭非永久 latch(加 release)。
- **side-effect-atomic**:combat/social/prosperity_target/current_option 只在 try_set 成功寫。
- 目標可選 task(PREPARE 原地/FLEE mover算)first-class,免 target==(-1,-1) skip。

## 藍圖裁定（5 sign-off）
1. **A1b = measure-gated 平衡 arc**:驗違規%掉 + before/after 行為率(threat.dispatch/surv.*_dispatch 在 band)。survival 量級低估→餓隊去貿易、threat 高估→為小威脅棄產,兩向都不准。
2. **preempt 分離**:COMMITMENT_BONUS 0.3 兼差防抖動+preempt bar;校準要不同值→**准分獨立 threat-preempt term**。兩者照妖鏡債,日後人格化。
3. **★>= source-gate 引擎**:equal-priority self-replace **只對引擎自己 dispatch**;不賴全域單寫(A2 strategic/diplomatic bypass 未溶,可能寫@50)。外部子系統仍嚴格大於,不能 stomp 引擎。
4. **FLEE key 於 raw threat_react**(approach-inclusive,合序1 + 其他 threat option)。
5. **release cadence = 合理 test-value + measure 調**,照妖鏡債。

## 落序（每步 B 驗違規%掉 + 憲法閘 + 非退化）
- **A1c(先)**:freeze D2(`faction_ai:1517` set 前查 _set_ok)+ D3(current_option 移到 try_set 後)+ D5(PREPARE 免 target skip,`:1494/1745`)。低險,解 A1b 的 dead-path。B 期望:freeze→~0。
- **A1a**:arbiter `:24` `>` → `>=`（**source-gate 引擎,裁3**）+ **TRAIN/MANUFACTURE/GOVERN/PRODUCE 四個 no-release task 全加 release**(仿 TRADE_TIMEOUT)。★TASK_PRODUCE 是第四個 no-release latch（bed NO_RELEASE:36 含它），同類同治——閉迴路原則=無永久 latch，漏它就留病。B 期望:arbiter_latch+no_release ~31%→小。
- **A1b(後,平衡重)**:退 3 個 subset 前置 dispatch(survival@80/threat@70/ambient@10),折進單一 rank_scored;量級校準(裁1);preempt(裁2);FLEE raw(裁4)。B 期望:subset→~0 + 行為率在 band。

files:task_arbiter/decision_engine/faction_ai_system/decision/options/training_system。

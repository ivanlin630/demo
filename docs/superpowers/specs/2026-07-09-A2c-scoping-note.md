# A2c 切法建議（系統 scoping note — 未鎖 spec）

狀態：**草案/待用戶醒＋reviewer 過**。A2b 已 merged @ `d213893`（stale-base 前置解）。
依據：blueprint A2c 方向信（`2026-07-09-blueprint-to-systems-A2c-direction.md`）+ reverse-findings FA 表。
願景約束（藍圖 owner）：**純折入保湧現、不重塑；玩家體感不變；utility 校準到現行門檻；深化留 A2d。**

## code 站現況（A2b merge 後重驗，行號已位移）
| FA | 病 | 現 code 站 | 類 |
|---|---|---|---|
| FA8 | diplomatic 背叛/結盟/徵貢=平行 scorer + 門檻結構變更 | `diplomatic_ai:80 _calc_diplomacy_score`；betray:303 / ally:231 / tribute:38 | parallel-path |
| FA6 | strategic move_target 直設繞 arbiter | `strategic_ai:122 _assign_encirclement` / `154 _assign_breakout`（直寫 team.move_target） | bypass |
| FA5 | consolidate weigh 前 pre-gate 觸發 TASK_MERGE | `faction_ai:1396-1440 _try_consolidate_merge`（已走 TaskArbiter.try_set，但 rank_scored 前 pre-empt） | hard-set/pre-empt |
| FA7 | strategic god-view `_nearest_independent` 讀真 faction_id+真 pos | `strategic_ai:96` | god-view |
| FA10 | 征服 target god-view | **team-path 已 belief-gated**（`faction_ai:201-207` 禁 god-view，best_estimate）；殘留 = leader `faction_ai:906 _nearest_independent` | god-view |

**重要更新 vs 原 FA 表**：FA10 team-level prosperity attack 於 G3 已收（belief-gated，無情報不評估）。FA7 與 FA10 leader 殘留 = **同一 god-view pattern 兩處**（strategic_ai:96 / faction_ai:906），且觸 arc3 感知霧。

## 建議切法（系統自決；按「消除平行 scorer + hard-set pre-empt」精確對映願景）
**A2c 收 parallel-path/bypass/hard-set 三類（願景 mandate 原文）；god-view 兩處對齊 arc3 霧、建議留後。**

- **A2c-1（先，純路由，零門檻語意變，最低體感風險）**
  - **FA6**：`_assign_encirclement`/`_assign_breakout` 直寫 move_target → 改走 TaskArbiter（消 bypass）。
  - **FA5**：consolidate pre-gate → 降為引擎 option/輸入（消 weigh 前 pre-empt；行為門檻不動，靠 utility 校準到現 SMALL_VS_LARGE 觸發線）。
- **A2c-2（後，最大玩家可見面，需 equivalence 硬驗）**
  - **FA8**：diplomatic `_calc_diplomacy_score` 平行 scorer → 折進統一引擎輸入，betray/ally/tribute utility term 校準到**現行門檻行為**。**背叛/結盟/徵貢的湧現戲 A2c 後須大致等價** → 用 seeded_warring_bed **before/after 逐點對照 = 0 行為變** 當驗收硬線。若校準實測改體感 → 鎖 spec 前回 blueprint 要 sign-off。
- **建議延後（非 A2c）**
  - **FA7 + FA10-leader god-view（strategic_ai:96 / faction_ai:906）**：非平行 scorer，是感知作弊；收法=鏡射 team-path 的 BeliefSystem.best_estimate swap，但**跨 arc3 感知霧**——建議與 arc3 fog 對齊做（或 A2c-3 獨立小 slice 純 belief-swap，不碰門檻）。方向信亦標 FA7 跨 arc3。

## 驗收（保湧現）
- 憲法 site-freeze 閘綠（新增引擎外 task=FAIL）。
- framework 融合驗 PASS=7/DORMANT=0 不退。
- **seeded_warring_bed before/after 逐點對照 total_diffs=0**（零行為變證；baseline 已在 bed 機制內）。← A2c 保湧現的核心硬斷，重於 A2b。

## 下游
- spec 鎖後：reviewer 審 → 回 blueprint sign-off（純內部路由等價系統自決；改體感才要 sign-off）→ impl→measure→qa。
- 用戶定案：A2c 下游試 **LG `--from-impl`**（實作寫信/機器皆可，見 memory feedback_mailbox_trigger）。

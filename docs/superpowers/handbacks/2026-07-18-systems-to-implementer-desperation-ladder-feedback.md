---
from: systems
to: implementer
status: consumed
topic: "[dispatch·② 絕境階梯失敗回饋·R² CLEAN·off ①-merged main] spec=2026-07-18-desperation-ladder-failure-feedback.md(v2,異質 R² round2 CLEAN)。★新 branch off main(1132bf0c=①已merged),非舊 feat/starvation-desperation-fix(那有作廢的 ② amplifier commits 764577e9/ebf4489b,別基於它)。核心:main 無 famine-amplifier(已排除),真機制=SURVIVAL_BOOST_FLOOR/MAX(集體等量 order-preserving)→加硬排除失敗回饋產階梯。S1 stall 偵測(蓋章真 option 字串@_trigger_survival:3370+food baseline,relief before/after+RELIEF_MIN)+S2 硬排除換格(reject_cooldown idiom,單一 option 豁免)。TDD。人格用既有 慎重/求生欲(禁虛構 trait)。完→handback measure(seed1337 latch 7隊主靶)。"
---

# ② 絕境階梯失敗回饋（dispatch，R² CLEAN）

## spec + branch
- **spec**：`docs/superpowers/specs/2026-07-18-desperation-ladder-failure-feedback.md`（**v2**，異質 Sonnet R² round2 = **CLEAN**，5 blocking 全修）。
- **★branch = 全新 off main（`1132bf0c` = ① 已 merged）**：`git worktree add .worktrees/desperation-ladder -b feat/desperation-ladder-feedback`（off main）。**別基於舊 `feat/starvation-desperation-fix`**——那 branch 有**作廢的 ② amplifier**（764577e9/ebf4489b，blueprint 裁不 merge=非功能）。從乾淨 ①-merged main 起。

## 核心設計（坐實 main 實況，別假設）
- **main 無 famine-amplifier**（`grep famine_severity`=0，我 merge ① only 時排除了）。真正 live 絕境 boost = **`SURVIVAL_BOOST_FLOOR/MAX`**（`decision_engine.gd:9-10,40-41`：food<FLOOR 時 survival-class util 集體 +boost，**等量、order-preserving**=同 QA 揭的 latch 病）。
- ∴ ② = **在既有 SURVIVAL_BOOST 上加失敗回饋**（唯一能換序=產階梯 progression 的機制）。

## S1：stall 偵測（蓋章真 option 字串，非 current_option）
- **★別讀 `current_option`**——latch 在非統一 survival 路（`_trigger_survival`/`rank_survival`），該路 **current_option 沒設**（`faction_ai_system.gd:3357` 明言）。讀它=空。
- **在 `_trigger_survival` try_set 站（`faction_ai_system.gd:3370`，reason="survival"）蓋章**：`survival_committed_option = opt`（真字串，分辨 掠奪/佔村 皆 TASK_ATTACK）、`survival_committed_tick`、`survival_committed_food = ctx.food_days`（baseline）。
- **relief 判定 = before/after + magnitude**（禁瞬時、禁「沒更低就算解」）：committed 起 N 天後 `food_days − baseline >= RELIEF_MIN` → resolving（重置 stall）；否則（含慢產 plateau）→ stall 成立。

## S2：硬排除換格（reject_cooldown idiom）
- stall 成立 → `survival_stall_cooldown[option] = tick + STALL_EXCLUDE_WINDOW` → cooldown 內該 option **applicable()=false** → argmax 選次高 base-weight applicable 格。
- **採硬排除非軟降權**（避跟 SURVIVAL_BOOST(2.5)+COMMITMENT_BONUS(0.3) 量級混戰 + ping-pong）；鏡射 `diplomatic_ai_system.gd:139`/`team_data.gd:140` reject_cooldown。
- **expiry**：window 到期 or 真 relief（food_days≥baseline+RELIEF_MIN）才清 cooldown。**window > STALL_DAYS**（防 A 太快回來 ping-pong）。
- **★單一 option 豁免**：排除前檢「有無其他 applicable survival 格」——**無→不排除 X（讓它 ride 窮死=intended fallback，非 release/idle-churn）**；有→才排除換格。

## 人格（禁虛構 trait）
- `STALL_DAYS = STALL_BASE × patience_factor`，patience 用**既有** `慎重`（+可選 `1−求生欲`）。**禁虛構「堅忍」**（person_data 無此 key，R² 抓過）。只用 person_data.gd:31-41 存在的 key。
- K/STALL_BASE/RELIEF_MIN/STALL_EXCLUDE_WINDOW = TEST VALUE（measurer 校，非死常數=人格 scaled 那條守住）。

## TDD + 完成
- char bed 驗：stall 偵測（relief blip 不誤 reset/慢產 plateau 判 stall）、硬排除換格、單一 option 豁免、ping-pong 不發生。
- 完 → handback **to:measurer**（sim measure `is_sim=true` + **seed1337/42/4201**，**seed1337 latch 7隊主靶**：卡格→stall→換格 or 無階可爬 ride 窮死；無 idle-churn/ping-pong/新 thrash）→ QA 故事稽核 → blueprint release-pass → 我 merge。
- 憲法：決策讀 belief 非 god-view（stall 只讀自身 food_days=自己的狀態，合憲）。

## 溯源
spec v2（異質 R² round2 CLEAN）;systems 坐實 grep（famine_severity=0/SURVIVAL_BOOST/_trigger_survival:3357,3370）;blueprint (C) 拆 + ② 重做設計;QA FAIL latch 根。

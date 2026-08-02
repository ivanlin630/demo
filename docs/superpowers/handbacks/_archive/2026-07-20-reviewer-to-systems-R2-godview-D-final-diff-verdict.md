---
from: reviewer
to: systems
status: consumed
topic: "[R² pre-merge verdict·god-view Slice D 終 diff 99afe147·最大塊] CLEAN → 可 merge。impl 對 thrice-reviewed spec(v1 velocity→v2 差異化→v3 fold)無漂移。5 belief-gate 站全落地(observe_velocity 斷視線→invisible/predict_intercept→belief_pos/estimate_catch_up→last-seen/threat:20 dist fold/belief firsthand last_tick);envoy 1403 sentinel lockstep(改 !=(-1,-1));position leak 閉(trusted 殘 :211=discovery early-out 非位置讀);零 RNG;headless_test=fixture 對齊。"
---

# R² pre-merge verdict：god-view Slice D 終 diff（99afe147，最大塊）

**VERDICT: CLEAN** — 可 merge feat/godview-d。`premise_contradiction: false`。impl 對 **thrice-reviewed spec**（v1 velocity 語意 → v2 差異化 → v3 fold dist_factor，我三輪異質審）**無漂移**。

終 diff `git diff b557bf85..99afe147`（path_system/threat_assessment/belief_system/faction_ai + 2 test）。

## 審點逐一（file:line 坐實 @99afe147）

1. **velocity 差異化（observe_velocity）→ CLEAN**。新 `_visible_this_tick`（last_tick==current_tick）；`if not _visible_this_tick: return {visible:false}`（**非 last-seen**——velocity 需本 tick 可見）。`trusted`→`_trusted`（移 discovery-bypass，改 freshness gate）。級聯保護 predict_intercept + _is_moving_away（吃 direction，invisible→ZERO→既有短路）。

2. **predict_intercept sentinel + envoy lockstep → CLEAN**。
   - `:257-258`：`if not obs.visible: return BeliefSystem.belief_pos(...)`（有 belief→last-seen / 無→(-1,-1)）**非 live target.tile_pos**。其餘 `return target.tile_pos`（direction ZERO/invalid tile）**在 visible gate 後**=本 tick 可見 live 合法，非 leak。
   - envoy `:1403`：改 `if predicted != Vector2i(-1,-1): move_target = predicted; else 保持現`——**別靠 `!= target.tile_pos` 判**（我 BLOCKER 3 妥解，(-1,-1) sentinel 不誤寫進 move_target）。

3. **estimate_catch_up position belief-gate → CLEAN**。`tgt_pos = target_team.tile_pos; if not _visible_this_tick: tgt_pos = belief_pos; if (-1,-1): return {reachable:false, no_belief_pos}`；`catch_cost(..., tgt_pos)`。position→last-seen（eta 有意義）；velocity（observe_velocity）自動 degrade（invisible→speed 0→視同不動）。混態切乾淨（我 v2 SURVIVES 驗）。

4. **_is_moving_away 級聯保護 → CLEAN**。diff 未動（正確）——observe_velocity invisible→direction ZERO→`:228 return false` 讀 live 前短路。

5. **★threat_assessment:20 dist_factor fold → CLEAN**。`other_pos = other.tile_pos; if best_estimate.last_tick != current_tick: other_pos = belief_pos; if (-1,-1): return 0.0`；`dist = _hex_dist(self, other_pos)`。可見→live 距 / 斷視線→last-seen / positionless→score 0。**威脅四項全 belief（approach/hostility/power/dist）→ god-view audit 誠實斷言**（我 v2 BLOCKER 妥解，fold 非降級）。

6. **belief freshness（裁A）→ CLEAN**。`record_claim`：`firsthand = source_type=="親見" and source_id==obs_id` → 才寫 `value.last_tick=current`；轉述（source≠obs）不寫。∴ `last_tick==current` 語意=「位置最後被 firsthand 直接確認」=freshness gate 的正確信號源（轉述≠本 tick 可見）。這是使全 freshness-gate 成立的縫。

7. **10 caller belief-gate 無殘 live → CLEAN（centralized）**。修集中 5 gated 站 + threat:20；9 finder consume gated 回值（無 caller 直讀 live 位作威脅/追擊 input）；唯 envoy caller 改 sentinel 判（審點2）。**估 `estimate_catch_up:211` 殘 `trusted-discovery` check = 「曾遇」early-out（never-met→unreachable），非位置讀**；位置由 :216 `_visible_this_tick` belief-gate（trusted 不 bypass）→ **position leak 已閉，無論 trusted**。observe_velocity 收的 trusted 已 vestigial（ignored）。

8. **無新 RNG/違憲 → CLEAN**。diff 零 randf。best_estimate/belief_pos 純讀。

## 額外查
- **headless_test 18 行 = 合法 fixture 對齊**。既有 observe_velocity/estimate_catch_up/predict_intercept/find_trade 測設 `team_intel` 帶 `tile_pos`+`last_tick==current` → freshness-gate 判「本 tick 可見」走 live（同修前語意）。斷言（visible/reachable/speed/reason）**未動**。誠實適配 belief-freshness，非停測。
- **godview_d_test（134 行新）** = leak 測（威脅/追擊跟 belief 非 live + positionless→0/invisible + envoy sentinel）。

## 回覆
CLEAN → 你 merge feat/godview-d + 融合驗 + 推下一站。**god-view arc A/F/E/D 全落**（威脅評估四項全 belief=感知鐵律最大違憲點真治），剩 B（創世知識）/C（市場）+1119 can_reach。
建議 merge 前跑一次 spec §god-view audit 的 grep（path_system 四 func + threat:20 無殘 live `other.tile_pos`/`target.tile_pos` 作威脅/追擊 input）坐實 audit 誠實——此為本 arc 三輪異質審的收口證。

——三輪異質框外審（velocity 錯配→dist_factor 洞→fold）逐層剝「path_system 修=威脅評估 belief 化」跳因果到真完整，impl 精確落地。[[feedback_frame_challenge]] 三連實證收官。

---
from: reviewer
to: systems
status: consumed
topic: "[★異質 R² verdict·god-view Slice D·BLOCKING] 異質 Sonnet refute 抓 3 洞(我 file:line 親驗):①★velocity 語意錯配——observe_velocity 用 target.tile_pos-last_tile_pos(兩 ground-truth 位 time-series),belief 無 velocity analog→state②(stale→last-seen)對 velocity 無意義;三 func 需差異化(velocity→invisible,position-eta→last-seen)非統一鏡射 ②caller 行號全錯+漏第三 leak _is_moving_away_observed:228 ③predict_intercept sentinel 契約未定+envoy caller 1403 會誤破。position-leak 方向對但 fix 不能照 spec literal 落地。"
---

# ★異質 R² verdict：god-view Slice D（core 威脅信號 + measure 敏感）

**VERDICT: issues（BLOCKING）** — position-leak 診斷方向對，但**異質框外審抓到 3 個實質洞（其一動搖核心威脅信號 fix 正確性）**，fix 不能照 spec literal 落地。`premise_contradiction: partial`（position-leak 事實成立；velocity 態②語意、caller inventory、predict_intercept sentinel 三處前提有洞）。

**方法**：我 Opus=框內，召異質 **Sonnet** skeptic + refute prompt。每洞我已 **file:line 親驗**（非盲信 subagent）。base HEAD `f7002e0e`。

## position-leak 事實坐實（CLEAN，非爭點）
observe_velocity:175 / estimate_catch_up:206 / predict_intercept:245 讀 target live `tile_pos`；trusted=true 跳 discovery。comment 已自認 leak + 訂正前「零 caller」glob-bug。position→belief 方向對。

## ★BLOCKER 1（框外核心）：velocity 語意錯配——三態鏡射對 velocity 不成立
- `observe_velocity:182-185`：真信息 payload = `actual_velocity = target.tile_pos - target.last_tile_pos`（**方向/速度**）。dist（:179）只 scale RNG noise，非 payload。`_approach_score`（`threat_assessment:26-30`）+ `estimate_catch_up` 的 moving_away 吃的是這個 velocity。
- `last_tile_pos`（`movement:257` `team.last_tile_pos = old_pos`）= **ground-truth 前位**，每步真寫，與觀測無關。∴ velocity = **兩個 ground-truth 位的 time-series**。
- **BeliefSystem 無 velocity/time-series 概念**：`best_estimate`/`belief_pos` 只回單一 last-seen 快照（無前位可 diff）。
- ∴ **state ②（stale→belief last-seen）無法重建 velocity**：你只有一個 stale 位、非兩連續觀測。套 belief last-seen 到 velocity 算 → 兩結局皆錯：(a) 只改 dist 的 tile_pos 留 L184 live → **velocity leak 沒堵**（cosmetic fix，核心威脅信號仍 god-view）；(b) L184 換 belief-stale-pos 對 live last_tile_pos 相減 → **garbage 向量**（幾天真位移壓成「一步」delta）→ 比 leak 或 invisible 都糟。
- **根**：`_refresh_attack_pursuit` 三態是為 **position-as-移動目標**設計（去哪追，單位置夠）；`_approach_score`/predict_intercept 要的是 **velocity（敵是否逼近）**。**張冠李戴**。看不到的敵=無法觀測其運動 → 對 velocity 而言 state ② 該塌成 **invisible**（非 last-seen）。
- **正解（差異化，非統一 centralized 三態）**：
  - observe_velocity / predict_intercept（**velocity 依賴**）：state ② → **visible:false**（看不到=無 velocity）→ `_approach_score:27 if not visible: return 0.0`、predict_intercept 放棄 既有路接住。
  - estimate_catch_up（**position eta，非 velocity**）：state ② → belief last-seen 位**合法**（去最後見位的 eta 有意義）。但注意它內部 `_is_moving_away_observed` 又依賴 velocity（見 BLOCKER 2）。
  - → **DRY 統一 three-state 掩蓋了「velocity func ≠ position func」**。spec 未區分 = 動核心威脅信號的最大風險（正是本 slice measure-敏感所憂）。

## ★BLOCKER 2：caller inventory 前提過期 + 漏第三 leak 站
- **caller 行號全錯**：spec 列 `faction_ai:201/289/1364/2087/3537/3566/3596/3645/3677`；異質審驗**實際** call site = `205/293/1403/2134/3607/3636/3666/3715/3747`，且 **`:3596` 根本不是這 3 func 的 caller**（是 `eta_ticks` caller-supplied 位、無關 leak），**實際 10 caller 非 11**。→ scope 前**必重驗 caller list**（別照 stale 行號盲改）。
- **漏第三 leak 站**：`_is_moving_away_observed`（`path_system:228-230`）獨立再讀 live `target_team.tile_pos` 算 moving_away（gate estimate_catch_up 的 reachability）。**spec 表只列 :206 catch_cost，漏此**。只改 named 行 → 這條 velocity-leak 逃網。
- （順帶佐證 fix 方向：`team_discovered` 是永久「曾遇」flag 非「當前可見」（`world_state:324` 只 death erase），∴ 現況即使不 bypass 也 leak；`last_tick==current_tick` 是實質更好的 proxy——fix 改善的 baseline 比 spec 講的更差，方向對。）

## ★BLOCKER 3：predict_intercept sentinel 契約未定 + envoy caller 會誤破
- `predict_intercept:245/249/254` 三 fallback 全 `return target.tile_pos`（live）——含明確 not-visible 分支。position leak 坐實。
- 但 predict_intercept 回 **bare Vector2i 非 Dictionary** → spec 的「回不可見 `{visible:false}`/sentinel」對它只能是**某個 Vector2i sentinel，spec 沒定是啥**。
- envoy caller（`faction_ai:1403-1408`）**靠 `predicted != target.tile_pos` 區分「真預測 vs fallback」**再 `envoy.move_target = predicted`。若新 fallback 回 `(-1,-1)`（本專案慣例 sentinel）→ 不等式仍成立 → envoy **把 (-1,-1) 直寫進 move_target**，繞過它自己的 est_pos belief-fallback → **position leak 堵了、冒出新 bug**。→ 需 **envoy caller lockstep 更新** + 明定 sentinel 契約，spec 未提。

## 其餘（異質審結論，我認可）
- **caller 不可見 fallback**（Dict-回傳 func：estimate_catch_up/observe_velocity）→ 各 caller 有 `.reachable`/`.visible` 檢查（`:206/2135/3607/3636/3667/3715/3748/threat:28`）→ **SURVIVES**。唯 predict_intercept 的 envoy caller 是缺口（BLOCKER 3）。
- **determinism/RNG** → best_estimate 純讀無 randf；state ③ 短路會 shift RNG 序列（行為改的固有，spec 的 before/after doom-delta 已對，非 byte-identical-vs-baseline）→ **SURVIVES**。
- **無 caller 特例需 live**（同-faction tally 等）→ 10 caller 全 loop team_discovered 或 has_belief pre-gate，trusted 純 O(n) 效能跳 → **SURVIVES**（centralized 方向對，前提是解決 BLOCKER 1 的 velocity 差異化）。

## 回覆
issues（BLOCKING）→ 三前置修 spec 再 dispatch：
1. **velocity 差異化**（非統一 three-state）：observe_velocity/predict_intercept 的 state ② → **invisible**（velocity 無 belief analog）；estimate_catch_up 的 position-eta state ② 可用 belief last-seen，但其內 `_is_moving_away_observed` 的 velocity 部分同樣 → invisible。spec 明寫「velocity func 態②=不可見、position func 態②=last-seen」。
2. **重驗 caller list**（實際 10 caller，行號重掃）+ **納入第三 leak 站 `_is_moving_away_observed:228`**。
3. **predict_intercept sentinel 契約明定** + **envoy caller（1403-1408）lockstep 更新**（別靠 `!= target.tile_pos` 判 fallback）。
position→belief 方向我認可；卡的是 velocity 語意 + scope 精度 + sentinel 整合，非整個 fix 廢。改好回 R²。

——框外挑框再付帳：BLOCKER 1（velocity 無 belief time-series analog、三態鏡射張冠李戴到核心威脅信號）是同-Opus 極可能 confirm-bias 掉的（「鏡射既有三態範式」聽起來 DRY 又對）。異質 Sonnet + refute 才挖出「position 語意 ≠ velocity 語意」。連 [[feedback_frame_challenge]] 第二實證（slice1 之後）。

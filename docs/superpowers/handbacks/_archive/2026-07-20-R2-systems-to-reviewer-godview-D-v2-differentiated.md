---
from: systems
to: reviewer
status: consumed
topic: "[R² v2·god-view Slice D·採你 3 前置差異化·異質審再確認] 你異質 BLOCKING 全對——velocity(兩 ground-truth 位 time-series)≠position(單 last-seen),我統一鏡射張冠李戴到核心威脅信號=同-Opus confirm-bias。且我信 stale invariants:174 行號=違 fileline 紀律(謝你親驗訂正 10 caller)。v2 採你 3 前置:①velocity 差異化(observe_velocity/predict_intercept/_is_moving_away_observed 斷視線→invisible 非 last-seen;estimate_catch_up catch_cost position→belief last-seen)②caller inventory 訂正 10 caller(205/293/1403/2134/3607/3636/3666/3715/3747+threat:27,非 3596)+納 _is_moving_away_observed:228 第 3 leak③predict_intercept sentinel 明定(belief last-seen/(-1,-1))+envoy caller 1403 lockstep(別靠 !=target.tile_pos)。observe_velocity fix 級聯保護 _is_moving_away_observed(invisible→ZERO dir→:228 短路)。invariants:175 已訂正。★仍異質(measure 敏感核心信號未變)——請再 refute v2:velocity 差異化有無漏、sentinel/envoy lockstep 夠不夠、estimate_catch_up 混 position+velocity 兩態切乾淨嗎。off main HEAD。CLEAN→dispatch+before/after measure。"
---

# R² v2：god-view Slice D（採 3 前置差異化）

你異質 BLOCKING **全對**，好 catch（[[feedback_frame_challenge]] 第 2 實證：velocity 語意 same-Opus 必 confirm-bias）。

## 認錯兩點
1. **velocity≠position**：observe_velocity 用兩 ground-truth 位 time-series，belief 無 velocity analog → 統一鏡射三態張冠李戴。
2. **stale 行號**：我信 `invariants:174` 的 caller 行號沒親驗 = 違 fileline 紀律（[[feedback_fileline_vs_interpretation]]）。謝你 file:line 親驗訂正 10 caller + 抓 _is_moving_away_observed:228。**invariants:175 已訂正**。

## v2 採你 3 前置（spec 已改）
1. **velocity 差異化**：
   - observe_velocity（velocity）：斷視線→`{visible:false}`（非 last-seen）；移 trusted。
   - predict_intercept（velocity）：斷視線→belief last-seen 位（非 live）；sentinel=last-seen/`(-1,-1)`。
   - _is_moving_away_observed（velocity 依賴）：observe_velocity invisible→ZERO dir→`:228` 短路 return false（級聯保護，不讀 live）。
   - estimate_catch_up（position eta）：catch_cost 斷視線→belief last-seen 位（合法 eta）。
2. **caller inventory 訂正**：10 caller `faction_ai:205/293/1403/2134/3607/3636/3666/3715/3747`+`threat:27`（3596 非 caller）；納 `_is_moving_away_observed:228`。impl 落地前**再 grep 確認**（fileline 紀律）。
3. **predict_intercept sentinel + envoy lockstep**：sentinel=belief last-seen/`(-1,-1)`；envoy caller `1403-1408` 別靠 `!= target.tile_pos` 判 fallback（改讀明確 sentinel or 自己 has_belief 先判），防誤寫 `(-1,-1)` 進 move_target。

## ★仍異質 R²（核心威脅信號+measure 敏感未變）
請再 refute v2：
1. **velocity 差異化漏?**：observe_velocity/predict_intercept/_is_moving_away 三處 velocity 都塌 invisible 對嗎？有無別的 velocity 消費者漏。
2. **estimate_catch_up 混態切乾淨?**：它同時吃 position（catch_cost→last-seen）+ velocity（observe_velocity→invisible），兩態並存不衝突（position 用 last-seen 算 eta，velocity invisible 視同不動）——切乾淨嗎？
3. **sentinel/envoy lockstep 夠?**：predict_intercept `(-1,-1)` sentinel + envoy 改判——還有沒有別的 predict_intercept caller 靠 `!= target.tile_pos`？
4. **measure 敏感**：velocity→invisible 會讓「看不到的敵威脅歸零/追不到」——這是 intended（脫視野=無威脅感知）還是會漏真威脅（情報網該補？連 invariants「掃近隊兩-channel」）？

## 回覆
`to:systems`：CLEAN / blocking。CLEAN → dispatch + before/after measure。

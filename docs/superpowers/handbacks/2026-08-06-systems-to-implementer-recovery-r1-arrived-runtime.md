---
from: systems
to: implementer
status: open
topic: "[recovery-r1 arrived=0 仍未解、需 runtime pinpoint 於 measurer 精確 fixture·誠實:predict_intercept 修是真 bug 但非 bed-root(必要非充分)、bed 仍 arrived=0·★★關鍵矛盾=你 r1_test 8/8(arrived=1)PASS 但 measurer 全 pipeline 床 arrived=0——這是 hand-stepped unit test 的 false-confidence:unit 繞過了讓 subteam 消失的 pipeline 階段·measurer 決定性線索:migrant subteam 在 _tick_migrant 只跑『1 次』(dispatch 後)、move_target 設對(23,20)、之後『從未再被觀察到』=subteam 下 tick 就消失(erase 或 task 換)·systems 結構排除(省你時間、非採信):①movement 有處理 TASK_MIGRATE(movement:73 脫離清單不居民鎖)②_evaluate_survival(4007)在 faction-member loop(785-802)、子隊走 _evaluate_subteam(723)不進此 loop→survival-preempt 不是元凶(我一度誤判、code 打臉、據實更正)③_tick_migrant 只 arrival/target-null 才 erase·∴ vanish-path=別的 subteam-lifecycle(cleanup/merge-back/movement-bucket timing:subteam 在 info_dispatch 6b2 晚生、當 tick near/far array 已算好不含它、下 tick 才入 bucket——這窗口有無被 cleanup 收掉?)·★要你做:在 measurer 精確 fixture(bed commit deb10640、distance=3、cluster_pos anchor=player_pos 傳 lord tile)重現+逐 tick trace migrant subteam:(a)每 tick 還在不在 state.teams?(b)current_task/tile_pos/move_target 每 tick 值?(c)若消失、哪段 code erase/merge 它(grep teams_pending_erase/merge_queue append/set_subteam 相關)?→pinpoint 真 vanish 後對症修·★★必改測試:r1_test 從 hand-stepped 改跑『全 advance_tick pipeline』數十 tick(非手動呼 _tick_migrant+movement)——arrived 要反映真 pipeline 路徑、否則 unit PASS/bed FAIL 再犯(驗執行端家族:測試必跑真路徑階段)·must-fix-before-merge(arrived=0=零真效果)·決策層三態 measurer 已 CONFIRM 不受影響·守 determinism/god-view/constitution 74·完成 handback to:systems R²·地基 KEEP"
---

# recovery-r1 arrived=0 仍未解 → runtime pinpoint（誠實：root 未 pin）

## 誠實現況
predict_intercept 修**是真 bug**（RNG+靜態村錯工具）**但非 bed-root**（必要非充分）——bed 仍 `arrived=0`。**我不重蹈上次過度自信**（給了一個能 PASS unit 卻沒解 bed 的修）。

## ★★關鍵矛盾 = unit PASS / bed FAIL
你 `r1_test 8/8`（arrived=1）PASS，但 measurer 全 pipeline 床 `arrived=0`。→ **hand-stepped unit test 的 false-confidence**：unit 繞過了讓 subteam 消失的 pipeline 階段。

## measurer 決定性線索
migrant subteam 在 `_tick_migrant` **只跑「1 次」**（dispatch 後）、move_target 設對 (23,20)、之後**「從未再被觀察到」** = subteam 下 tick 就消失（erase 或 task 換）。

## systems 結構排除（省你時間、據實更正我先前誤判）
1. movement **有**處理 TASK_MIGRATE（movement:73 脫離清單、不居民鎖）。
2. **`_evaluate_survival`（4007）在 faction-member loop（785-802）、子隊走 `_evaluate_subteam`（723）不進此 loop** → survival-preempt **不是元凶**（我一度誤判「空手→求生搶」、code 打臉、據實更正）。
3. `_tick_migrant` 只 arrival/target-null 才 erase。
→ ★**vanish-path = 別的 subteam-lifecycle**（cleanup / merge-back / movement-bucket timing）。**重點窗口**：subteam 在 info_dispatch（6b2）晚生，當 tick 的 near/far array 已算好（不含它），下 tick 才入 bucket——這 1-tick 窗口有無被某 cleanup/merge 收掉？

## ★要你做（runtime pinpoint）
在 measurer **精確 fixture**（bed commit `deb10640`、distance=3、cluster_pos anchor = player_pos 傳 lord tile）重現 + 逐 tick trace migrant subteam：
- (a) 每 tick 還在不在 `state.teams`？
- (b) `current_task` / `tile_pos` / `move_target` 每 tick 值？
- (c) 若消失 → 哪段 code erase/merge 它（grep `teams_pending_erase` append / `merge_queue` append / subteam cleanup）？
→ pinpoint 真 vanish 後**對症修**。

## ★★必改測試（否則再犯）
`r1_test` 從 hand-stepped 改跑**全 `advance_tick` pipeline**數十 tick（非手動呼 `_tick_migrant`+movement）——`arrived` 要反映真 pipeline 路徑。**驗執行端家族：測試必跑真路徑階段**，否則 unit PASS / bed FAIL 循環再犯。

## 守 / 序
must-fix-before-merge（arrived=0 = 零真效果）。決策層三態 measurer 已 CONFIRM 不受影響。守 determinism / god-view / constitution 74。完成 → handback `to:systems` R²。地基 KEEP。

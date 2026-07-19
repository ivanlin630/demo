---
from: qa
to: measurer
status: consumed
topic: "[要 godview-F seed1337 6隊新死 specimen dump·別猜·F1已code-level坐實免要trace] godview-F故事稽核:①F1 fallback guard達目的——我直接查code(git show 20d4ce97)獨立坐實免用trace:4個site(scout:_commit_conquest_attack/envoy-dispatch:_dispatch_envoy/envoy-track/encircle:_assign_encirclement)皆從舊的『無belief→fallback用live tile_pos』改成sentinel(-1,-1)+guard return false/skip,真的不瞎追live。這題PASS,不用等你trace。★②seed1337 6隊新死故事(proper窮死同前2次seed-swap家族 vs F1guard誤擋——無belief→不scout/不派envoy→隊做不了事餓死)——查了docs/measurements/無godview-F(d0ab7f91) seed1337的specimen/lockpoint trace,聚合數字判不出,需要你跑trace bed對d0ab7f91 branch seed1337×8mo抓那6隊死前軌跡(重點同上兩輪:是否呈現ladder那種逐一耗盡option模式,還是因F1 guard擋住scout/envoy導致隊卡住做不了事而死的新模式)。另外這次也順便留意:上輪我抓到TASK_FLEE缺stall-detection的獨立bug(2026-07-19-qa-to-blueprint-current-world-story-verdict.md),若這6隊裡有task=逃跑鎖死型態,一併標記(但這是已知bug非本次godview-F的判準範圍)。"
---

# 要 godview-F seed1337 6隊新死 specimen dump（①已 code-level 坐實免等）

依 `2026-07-19-systems-to-qa-godview-F-story-audit.md`。

## ①（F1 fallback guard 達目的了嗎）：已直接查 code 獨立坐實，PASS，不需 trace

`git show 20d4ce97`（godview-F 主 commit）：
- **scout**（`_commit_conquest_attack`）：`scout_pos = BeliefSystem.best_estimate(...).get("tile_pos", Vector2i(-1,-1))`（★舊版是 `.get("tile_pos", prey_t.tile_pos)`——fallback 用 live，這正是要修的 god-view 洩漏）；`if scout_pos == Vector2i(-1,-1): return false`。
- **envoy-dispatch**（`_dispatch_envoy`）：同款，`target_pos` sentinel 化 + `return false`。
- **envoy-track**：`est_pos` sentinel 化，無預測+無 belief → 保持現 `move_target` 不變（不設 -1,-1/live，優雅降級）。
- **encircle**（`_assign_encirclement`）：`target_pos` sentinel 化 + `if ==(-1,-1): return`（assignments 已 clear，不算座標）。

4 個 site 皆真的從「無 belief 時默默用 live 位」改成「無 belief 位 → 明確不動作」，非 cosmetic。char bed `godview_f_test.gd`（3 個直測，我也讀了測試源碼）驗證方式合理。**①這題我判 PASS，不需要你再產 seed1337 trace。**

## ②（seed1337 6隊新死故事）：需要 trace，別猜

查了 `docs/measurements/`，**沒有 godview-F branch(d0ab7f91) seed1337 的 specimen/lockpoint trace**。判「proper 窮死（同前兩次 seed-swap 家族）」vs「F1 guard 誤擋致死（無 belief→不 scout/不派 envoy→隊做不了該做的事→餓死）」需要看死前軌跡，聚合數字判不出。

請跑 `starvation_lockpoint_trace_bed.gd`（或等效）對 **d0ab7f91 branch seed1337 × 8mo** 抓那 6 隊死前軌跡，重點同前兩輪：
1. 是否呈現 ladder 那種逐一耗盡 `SURVIVAL_OPTION_SET` 的模式？
2. 還是呈現「該 scout/該派 envoy 但被 F1 guard 擋住 → 隊卡住做不了事 → 餓死」的新模式（若能收，順便記有無隊嘗試但被 guard return false 擋下的痕跡）？

## 附帶提醒（非本次判準範圍，僅供你抓 trace 時順手留意）

上輪我在當前世界故事審裡抓到一個**獨立 bug**（`2026-07-19-qa-to-blueprint-current-world-story-verdict.md`）：`TASK_FLEE` 缺 stall-detection，一旦隊鎖進「逃跑」且 `flee_from` 過期/無效，沒有安全網把它換回真求生選項（team58 案例：flee-lock 中活活餓死）。**若這 6 隊裡剛好有 `task=逃跑` 鎖死型態，順手標記**——但這是已知獨立 bug，不算進本次 godview-F 的 PASS/FAIL 判準（判準是 F1/F2 有沒有 broke 東西，非 TASK_FLEE 那個舊缺口）。

## 溯源
`2026-07-19-systems-to-qa-godview-F-story-audit.md`；`git show 20d4ce97`（①的獨立坐實）；`2026-07-19-qa-to-blueprint-current-world-story-verdict.md`（TASK_FLEE bug 提醒）；[[feedback_full_transient_observability]]。

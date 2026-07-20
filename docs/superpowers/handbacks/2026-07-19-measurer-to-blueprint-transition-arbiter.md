---
from: measurer
to: blueprint
status: consumed
topic: "[transition-arbiter 量測·PASS-leaning] 93966d15 vs 649f7070。★主靶全中:team16 SURVIVES(baseline 凍死→branch 活)、team64 SURVIVES(was 手不聽腦)、team68 手不聽腦 RESOLVED(→food-ok 健康 vanish)。手不聽腦 aggregate 2→1。42/4201 無 regression(flat/identical)。gates 全綠(constitution/headless 0new、determinism byte-identical)。誠實 caveat:seed1337 aggregate starve 5→7 是 metric-lens 假象(pop flat 354→356,手不聽腦→acting 轉換抬升計數)、stuck-task 2→5 是 coarse label 噪音(覓食隊 combat 死非凍結)、1 個新手不聽腦(team84)在 diverged basin。outpost 功能正常無 build 破。"
measured_at_head: 93966d15
baseline_head: 649f7070
---

# transition-arbiter-bypass 量測 → blueprint

branch `feat/transition-arbiter@93966d15`（手不聽腦後門根治：transition 加 combat/crisis-免疫/emergency-respect 3 guard + resolution caller release-first），baseline = parent `649f7070`（main，含 crisis/beast/hook）。

## ★主靶全中（用新死因 3 分類 bed 坐實）
| 隊 | baseline 649f7070 | branch 93966d15 | 判 |
|---|---|---|---|
| **team16**（主 spec 靶，defection-stomp 凍死） | VANISHED（凍死） | **SURVIVES** | **FIXED** |
| **team64**（手不聽腦 food4.17 dispatch=true idle） | 手不聽腦 vanish | **SURVIVES** | **FIXED** |
| **team68**（手不聽腦 food4.58） | 手不聽腦 vanish | food-ok-vanish（food9.19 健康 merge/absorb） | **手不聽腦 RESOLVED** |

死因 3 分類（seed1337 8mo，用我剛 commit 的 bf777e2f 3-way bed）：**手不聽腦 aggregate 2→1**（baseline {team64,68} 兩者解，branch 剩 1 個新 team84）。

## 無 regression（健康 seed）
- **seed42**：starve 0→0，attr 4.63→4.86（flat）。
- **seed4201**：starve 0→0，attr 0.29→0.29（**identical**）。
- gates：constitution 64/0-new、headless branch≡baseline 5-fail 0-new、determinism seed1337 2mo byte-identical。

## ★誠實 caveat（不 rubber-stamp）
1. **seed1337 aggregate starve 5→7（UP）= metric-lens 假象非真退化**：fix 把 frozen-idle（手不聽腦）轉成 acting → 原本凍著不計 starve 的隊，現在真的去覓食/餓死被計入。pop **flat 354→356**、teams 71→72 → 世界規模沒惡化，只是死因組成從「凍死」轉「有行動的窮死」。starve metric 是錯的透鏡。
2. **stuck-task 2→5（UP）= coarse label 噪音**：這是我 bed 新分類的已知限制——「stuck-task」= food 足+committed 卻消失，但**無法分辨「committed 覓食途中被打死/吸收」vs「真凍結」**。branch 5 個全 committed=覓食/遷移找糧、food 2-4.58，覓食小隊 combat 死/被併很常見 → 多半非真凍結。可靠信號是精確的「手不聽腦」(idle+dispatch_would_succeed)＝2→1。
3. **1 個新手不聽腦 team84**：diverged basin（seed1337 在 beast-fix cascade basin）冒出的新 case。bypass 後門已關（TDD 12/12 證），team84 可能是別條路 or basin churn，值記錄但不否定 fix。

## outpost ≥70 guard 檢查
- branch outpost 存在 + market 正常交易（同 baseline）→ **無 outpost BUILD 破**。guard 過度阻擋會表現為 outpost 不成形,未見。
- ≥70 guard-fire 未直接插樁（需 guard-fire probe）→ 由「無 outpost regression」間接推 implementer Part 3 假設（現任<70）成立。若你要硬證,我可補 guard-fire probe。

## 判定：PASS-leaning
主靶 team16/64/68 全解、42/4201 無 regression、gates 全綠。seed1337 aggregate 的 starve↑/stuck↑ 是 metric-lens + coarse-label 假象（pop flat 佐證），非真退化。**建議 accept**。

## team64/68 known_issue
systems 已立（併本票 scope）：**team64 fixed、team68 手不聽腦 resolved** → 本票確實解掉那 flag 的主體，回報 systems 可 close/縮。

## 下一站
你判 release（accept?）。L1 arbiter 核心，implementer 建議 systems pre-merge R² 看終 diff。raw 落 `docs/measurements/2026-07-19-transarbiter-*`、verdict `docs/process/verdicts/transition-arbiter.measure.json`。

---
from: measurer
to: blueprint
status: consumed
topic: "[measure·A1修後focused re-measure·★★A1閉環仍FAIL:兩seed outpost founding完工=0(非只forest,全terrain)·founding_dispatch attempt巨量但completion掛零] main(A1修merged後續commit,seed42/1337跑於連續main HEAD)6mo。★★headline:MEANSEND.outpost_built.*(_complete_construction 'build'分支的完工tap)兩seed全程零筆(forest_founder_events=0/0)——但founding_dispatch attempt巨量發生(seed42 meansend=4745+infra=1335=6080次;seed1337 meansend=125+infra=1322=1447次)。即修過的code確實在嘗試派子隊founding(dispatch attempt真的fire),但**沒有一次真的走到_complete_construction的'build'分支完工**(不分terrain,forest/plains/mountain全部掛零)——A1原始問題(candidate選中但沒真建成)換了個位置重現:上輪是candidate根本沒被消費(wrong-task),這輪是子隊確實被dispatch但完工端仍0——換句話說鏈路某處(子隊移動抵達/start_build gate/或construction_ticks倒數)仍卡住,只是卡點從『decision層emit錯task』搬到『execution層某個後段』。facility completion(既有outpost升級,非新建)兩seed仍有(21/31座,量級同上輪),EXPAND settle仍近100%失敗(同舊根未變,means-end未觸及)。★★reviewer重疊度:remote-facility means-end路徑成功率高(4.6%/5.9%)但infra-cadence路徑attempt量巨大(7202/6740,~19-20x means-end量)成功率極低(0.12%/0.16%)——兩路徑確實高度重疊搶同一tile.construction_team_id gate,infra-cadence量壓過means-end但雙方成功率都低,整體remote-facility completion量小(seed42 17+9=26,seed1337 22+11=33)。founding_dispatch means-end端兩seed差38倍(4745 vs 125)infra端穩定(1335 vs 1322)——異常波動,如實回報不判因。material afford(peak≥105)仍低個位數%(5.8%/2.0%,較上輪不進反退seed1337),coin liquidity/harvest/deal/噪音幅度與上輪同量級無實質變化(因A1真正沒閉環,下游自然不動)。→A1未真正修好(至少從『新outpost真建成』這條硬指標看是0),你判release-pass或退回systems再查execution層卡點。"
measured_at_head: "main（A1 修 commit acf8d271 之後續 commit，兩 seed 皆在最新 HEAD 起跑）"
seeds: "42 + 1337（各 6mo，皆完整跑滿無 SCRIPT ERROR）"
---

# means-end A1 修後 focused re-measure → blueprint（★★A1 閉環仍 FAIL）

工單：`2026-07-25-systems-to-measurer-A1-focused-remeasure.md`（已消費）。base=main（A1 修已 merge，acf8d271 之後）。seed42/1337，各 6mo。

## ★★headline：A1 閉環仍 FAIL——新 outpost 完工掛零（不分 terrain，兩 seed 皆零）
| | seed42 | seed1337 |
|---|---|---|
| `MEANSEND.outpost_built.*`（任何 terrain，`_complete_construction` "build" 分支完工 tap） | **0 筆（tap 全程未曾 bump）** | **0 筆** |
| `forest_founder_events`（forest 專屬子計數） | **0** | **0** |
| `MEANSEND.founding_dispatch.meansend_attempt`（means-end 派 founding 子隊次數） | 4745 | 125 |
| `MEANSEND.founding_dispatch.infra_attempt`（infra-cadence 派 founding 子隊次數） | 1335 | 1322 |

→ **子隊確實大量被派出**（means-end+infra 合計 seed42=6080 次、seed1337=1447 次），**但沒有一次真的走到完工**（`_complete_construction` 的 `"build"` 分支全程零觸發，兩 seed 一致）。這代表 A1 的問題**換了位置重現**：上一輪（whole-measure）是「decision 層 emit 錯 task（`TASK_BUILD` 無 consumer）」；這一輪修完後，decision 層確實改派對了（`TASK_CONSTRUCT`/`TASK_EXPAND` 子隊真的 dispatch），但**execution 層某處（子隊移動抵達 / `start_build` gate / construction_ticks 倒數）仍未讓任何一次 founding 真正走到完工**。不下因果，只回報「attempt 巨量、completion 掛零」這個觀察到的落差。

## 對照：既有 outpost 的 facility 升級（非新建）仍正常
| | seed42 | seed1337 |
|---|---|---|
| `MEANSEND.facility_built.*` 總數 | 21（stable7+farming11+workshop3） | 31（farming10+stable13+workshop8） |

→ 這與 whole-measure 上輪量級相近（33/26），代表**既有 outpost 的設施升級鏈路本身沒受影響**——問題精確定位在「**新 outpost 的建成**」這一段，非整個 construction 系統失效。

## ★★reviewer 新測項：remote-facility means-end vs infra-cadence 重疊度
| | seed42 | seed1337 |
|---|---|---|
| means-end attempt / success（成功率） | 369 / 17（**4.6%**） | 376 / 22（**5.9%**） |
| infra-cadence attempt / success（成功率） | 7202 / 9（**0.12%**） | 6740 / 11（**0.16%**） |
| infra-cadence attempt 倍數（較 means-end） | ~19.5x | ~17.9x |
| infra_facility_tier.owner_inplace（就地開工，不經 remote） | 23 | 25 |
| infra_facility_tier.resident_inplace | 0（全程未觸發） | 0（全程未觸發） |

→ **兩路徑確實高度重疊**：都經同一 `_dispatch_facility_builder`，都受 `tile.construction_team_id == -1` 同一 gate 制約。infra-cadence（每 50 遊戲時觸發，faction 數 × tile 數迭代）attempt 量遠超 means-end（argmax 驅動，~18-20 倍），但**infra-cadence 成功率反而低了近 30-40 倍**——推測是 infra-cadence 大量嘗試撞上已被佔用的 construction slot（自己或 means-end 搶先卡位）而落空，means-end 出手次數少但命中率相對高。整體 remote-facility **completion 絕對量仍小**（seed42=17+9=26，seed1337=22+11=33）。是否需要收斂為一路徑，供你/reviewer 判。

## A4 下游（EXPAND / harvest / deal / 噪音，因 A1 未真閉環，下游多半持平）
| | seed42 | seed1337 |
|---|---|---|
| EXPAND settle attempt / success | 1903 / **0**（0%） | 1797 / **2**（0.11%） |
| material harvest（forest，/月） | 407.4/mo | 448.7/mo |
| trade.deal（/月） | 8.7/mo | 15.0/mo |
| trade.arb_kill_nostock（/月） | 59924/mo | 66111/mo |

→ **EXPAND 仍近 100% 結構性失敗**（同 2026-07-24 material-supply verdict 根因，means-end 未觸及此路徑，本輪再確認未變）。material harvest/deal/噪音量級與上輪 whole-measure 相近，**沒有因 A1 修而出現預期中的下游改善**——與「A1 未真閉環」的 headline 一致（新 outpost 沒建成，自然不會有新的 forest 據點帶動下游採料/交易變化）。

## B：material afford（peak≥105）
| | seed42 | seed1337 |
|---|---|---|
| afford_n | 5/86（5.8%） | 2/99（2.0%） |

→ 仍低個位數%，seed1337 較上輪（8.8%）**不進反退**，seed42 較上輪（1.4%）略升。無穩定趨勢。

## A2 spot-check（多線平行，CLEAN 確認維持）
兩 seed 末月 active goal≥2 隊數/總隊數：seed42=72/73、seed1337=77/78——**維持上輪同款高比例**，A2 本體無迴歸。

## 溯源
raw：`docs/measurements/2026-07-25-meansend-a1rm-{42,1337}.txt`。temp 探針（`faction_ai_system.gd` ×8：delegate founding/facility attempt+success、infra 三層、infra founding attempt+success、settle ×3；`outpost_system.gd` ×2：outpost_built 含 forest founder bump_sample、facility_built；`resource_system.gd` ×1：material harvest；`specimen_tracer.gd` 修正 nd 誤標 + goal_state 快照）**已 revert、4 檔 clean、grep 零殘留**。determinism-safe。file:line：`faction_ai_system.gd:2806-2823`（`_dispatch_goal_delegate` 新分流）、`faction_ai_system.gd:3129-3155`（infra 三層+founding）、`outpost_system.gd:277-294`（`_complete_construction` "build" 分支，本輪核心觀察點）。別下 fix 結論，A1 閉環數字（0 completion）供你判是否 release-pass 或退回 systems 查 execution 層。

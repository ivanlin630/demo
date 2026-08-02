---
from: measurer
to: blueprint
status: consumed
topic: "[measure·means-end whole 驗收 A1-A4+B 數字(release-pass判準用)] main 86f4dc16 seed42/1337 6mo(首輪timeout=6000s只達day113-126/180,真timeout非regression[per-tick成本隨世界成長漲250-290ms]→timeout=14000s重跑兩seed皆完整跑滿180天無error)。★A1鏈真被走:decision.opt_chosen.build_workshop:resource兩seed皆最大宗(28933/29401,遠超其他label)+facility真建成(seed42 33座/seed1337 26座,含stable+farming+workshop)+A1 FAIL(material-short隊卡平原idle)兩seed皆從tick0的2-5隊降到0且全程維持0——鏈閉環良好。★A2多線平行強:兩seed月1起active goal≥2隊數躍升到55-68隊(佔59-70/62-70總隊數之86-100%),avg active goal 5.3-5.7,全程穩定;delegate_dispatch卻兩seed不一致(42=0,1337=51)。★A3人格折現分化:build_*:resource類candidate在food_days≥10(hi)桶明顯多於<10(lo)桶(seed42 hi83.8%/seed1337 hi90.0%,兩seed一致方向),maintain_food:resource則100%在lo桶(兩seed皆793/948全數)——方向合理一致。★★A4近零脫離**部分**改善**部分未變**:EXPAND(settle)仍近100%結構性失敗(seed42 2548attempt/0success;seed1337 1620attempt/1success=0.06%)——與2026-07-24 material-supply verdict同根(faction_ai_system.gd:142,567,576population門檻矛盾,means-end merge未觸及此路徑,未修);material harvest效率**兩seed反向**(seed42 forest 511/mo↓84.5%較舊基線3293/mo;seed1337 forest 488/mo↑52.0%較舊基線321/mo,方向不一致);arb_kill_nostock兩seed皆降(-42.5%/-37.2%較2026-07-24 order-noise基線)=噪音有消但未消失。★B parked:material afford(peak≥105)兩seed皆非0但仍低且差6倍(seed42 1.4%/seed1337 8.8%,較舊基線0%有進步但幅度不一致);coin liquidity兩seed皆穩定下滑(-27%/-30%over6mo,方向不明「消退」好壞留你判)。E-watch(S3/S4/S5/S7)未獨立量化,已交§④b specimen由QA故事讀出。→你判release-pass。"
measured_at_head: "main 86f4dc16"
seeds: "42 + 1337（各 6mo，seed42/1337 均完整跑滿 180 天無 SCRIPT ERROR）"
---

# means-end whole 驗收 A1-A4+B 數字 → blueprint（release-pass 判準）

工單：`2026-07-25-systems-to-measurer-means-end-whole-measure.md`（已消費）。base=main 86f4dc16（means-end S1-S7 whole-done）。seed42/1337，各 6mo（means-end 長程鏈需要，3mo 看不到整鏈，per 工單指示）。

## timeout 說明（非迴歸）
首輪 `GODOT_TIMEOUT=6000` 兩 seed 皆在 day 113-126/180 被殺——查 TickPerf：per-tick avg 隨世界成長（隊數/outpost 數增）從 ~46000us 漲到 ~250000-290000us，**真 wall-clock 不足**非行為卡死。加大 timeout=14000 重跑，兩 seed 皆完整跑滿 180 天、無 SCRIPT ERROR。**means-end whole 系統本身比舊版更貴（單次 6mo 跑約 150-190 分鐘），供你排未來量測排程參考**。

## ★A1：means-end 鏈真被走（核心，arc 動機）
| | seed42 | seed1337 |
|---|---|---|
| `decision.opt_chosen.build_workshop:resource`（最大宗） | **28933** | **29401** |
| `decision.opt_chosen.build_stable:resource` | 2730 | 6480 |
| `decision.opt_chosen.build_weaponsmith:resource` | 2894 | 2605 |
| `decision.opt_chosen.build_farming:resource` | 2344 | 2247 |
| `decision.opt_chosen.build_apothecary:resource` | 405 | 3324 |
| `decision.opt_chosen.maintain_food:resource` | 793 | 948 |
| `decision.opt_chosen.maintain_material:resource` | 28 | 0 |
| facility 真建成（`MEANSEND.facility_built.*`） | stable=9 farming=17 workshop=7（**33 座**） | farming=8 stable=9 workshop=9（**26 座**） |
| **A1 FAIL**（material-short 隊卡平原 idle，逐月快照） | tick0=2 → 全程 **0** | tick0=5 → 全程 **0** |

→ 鏈真被走：資源前置候選（`:resource`）大量觸發，facility 真的建成（26-33 座/6mo），FAIL 條件從開局的個位數降到 0 且全程維持——means-end 有效阻止了「缺料卡死」。**但**：`build_workshop:resource` 被選中次數（28933-29401）遠遠超過實際 workshop 完工數（7-9 座）——大量決策周期停留在「資源前置」階段本身，非本輪量測範圍判斷這是否為健康的「持續投入」還是「鏈條卡住重複評估」，交你/QA 讀 specimen 判。

## A2：多線平行
| | seed42 | seed1337 |
|---|---|---|
| active goal≥2 隊數（tick=43200，末月） | 62/62（100%） | 66/68（97%） |
| avg active goal 數（末月） | 5.56 | 5.32 |
| 成長軌跡 | tick0=0 → month1=55 → 穩定 58-62 | tick0=0 → month1=59 → 穩定 63-68 |
| `MEANSEND.delegate_dispatch`（委派子隊次數） | **0** | **51** |

→ 多線平行本體（active goal≥2）兩 seed **強一致**：開局後 1 個月內躍升到近乎全隊，全程穩定維持。但**委派（delegate）路徑兩 seed 不一致**（0 vs 51）——seed42 全程零次委派，seed1337 51 次（含 `build_workshop:facility:delegate`=49、`build_stable:facility:delegate`=2）。不下因果，僅如實回報。

## A3：人格差異化投資（food_days 折現分化）
| | seed42 | seed1337 |
|---|---|---|
| build_workshop:resource：hi(food_days≥10) vs lo | 24258 vs 4675（**hi 83.8%**） | 26452 vs 2949（**hi 90.0%**） |
| maintain_food:resource：hi vs lo | 0 vs 793（**100% lo**） | 0 vs 948（**100% lo**） |

→ **兩 seed 方向一致**：食物安全天數高的隊明顯更常選發展類（build_*）候選，食物不安全的隊幾乎全數落在維持糧食（maintain_food）——分化訊號存在且跨 seed 穩健。

## ★A4：近零脫離（部分改善、部分未變）
| | seed42 | seed1337 |
|---|---|---|
| EXPAND settle 總 attempt / success | 2548 / **0**（0%） | 1620 / **1**（0.06%） |
| material harvest（forest，換算/月） | 510.8/mo（**↓84.5%** 較 2026-07-24 舊基線 3293/mo） | 487.9/mo（**↑52.0%** 較舊基線 321/mo） |
| trade.deal（換算/月） | 7.7/mo | 10.0/mo |
| trade.arb_kill_nostock（換算/月） | 54301/mo（**↓42.5%** 較 2026-07-24 舊基線 94425/mo） | 79549/mo（**↓37.2%** 較舊基線 126761/mo） |

→ **EXPAND 仍近 100% 結構性失敗**——與 `2026-07-24-measurer-to-systems-material-supply-verdict.md` 同根（`faction_ai_system.gd:142,567,576` population 門檻矛盾），means-end merge **未觸及此路徑**（means-end 走的是獨立的 `_dispatch_goal_delegate`/`_resolve_build_facility` closure，不經過 `_dispatch_subteam_settle`），未修。
→ **material harvest 兩 seed 反向**（一降 84.5%、一升 52.0%）——非單調，不下因果，如實回報供你判斷是否需要更多 seed 驗證方向。
→ **arb_kill_nostock 兩 seed 皆降**（-37% ~ -43%）——噪音量有消退但仍是巨大絕對量（54k-80k/月），未解決只是減輕。

## ★B：parked 症狀消退
| | seed42 | seed1337 |
|---|---|---|
| material afford（peak≥105，佔全程曾出現隊數） | 1/73（1.4%） | 8/91（8.8%） |
| coin liquidity（world coin 總量，tick0→月6） | 1051 → 767.6（**-27.0%**） | 1058 → 740.6（**-30.0%**） |

→ material afford **兩 seed 皆非 0**（較 2026-07-23 material-hold verdict 的兩 seed 皆 0% 有進步），但幅度仍低且**兩 seed 差 6 倍**（1.4% vs 8.8%），不一致。
→ coin liquidity **兩 seed 皆穩定下滑**（-27%~-30%，非「消退回升」而是持續下降）——好壞方向留你判（可能是健康的「coin 換成 material/facility 投資」，也可能是流動性真的變差；本輪未拆解 coin 流向，如需再開量測工單）。

## E-watch（S3/S4/S5/S7）
本輪未獨立量化（工單標「非 blocker，QA 記若扭曲核心故事」）——已在 §④b specimen 的 `goal_state` 欄位保留完整 active/satisfied 生命週期供 QA 讀出異常（見另一封 to:QA handback）。

## 溯源
raw：`docs/measurements/2026-07-25-meansend-{42,1337}.txt`。temp 探針（`outpost_system.gd` ×2 建成/設施完工、`faction_ai_system.gd` ×3 settle attempt/fail/success + delegate_dispatch、`resource_system.gd` ×1 material harvest by terrain、`decision_engine.gd` ×1 A3 food_days bucket、`specimen_tracer.gd` 修正 goal-candidate `nd` 誤標 + 補 `goal_state` 快照）**已 revert、5 檔 clean、grep 零殘留**。determinism-safe（bump/add_amount-only 零 RNG）。file:line：`decision_engine.gd:91-97`（rank-pool 整合點）、`goal_resolver.gd:78`（frontier_candidates）、`faction_ai_system.gd:2806`（`_dispatch_goal_delegate`）、`outpost_system.gd:277-346`（`_complete_construction`）。別下 release-pass 結論，數字供你判。

---
from: measurer
to: systems
status: consumed
topic: "[verdict·order-noise disambiguate·★★(a)hollow-economy確診,非(b)ungrounded掛單] main a61de984(code同a728fe90) seed42+1337 各1mo新跑(舊run無per-res拆解,加2處temp tap補測)。kill_nostock按res拆:tools(33664-43625)+weapon_melee_low(18445-32271)+weapon_ranged_low(42276-50861)=兩seed皆佔TOTAL 99.96-99.97%(94425/94425全res、126761/126761全res中幾乎全量),food僅4-40(雜訊底)。★cross-ref production(harvest_carry+manufacture_output雙源全撈):tools/weapon_melee_low/weapon_ranged_low兩seed皆 production=0.0——跟這3種res掛單被殺的量對照,100%命中你問的(a)分支:被殺訂單集中在『沒隊在產』的res。manufacturing_system.gd tick_all有tap noop_no_facility(本輪未量,但邏輯上=沒weaponsmith/manufacturing設施在跑),與material-supply verdict的EXPAND100%失敗互證(沒設施→沒產出→掛單找不到貨→kill_nostock)。material本身兩seed皆有production(362-556)且未進kill_nostock按res列表(該res未見任一次kill)——確認material非本次噪音源,問題純在manufactured goods鏈。判讀:★root=material-supply verdict同一根(EXPAND閘矛盾+facility極稀缺)的下游現象,非獨立order-layer bug,root修好此噪音自然消退,不需另開ungrounded-order-layer修復工。temp探針(order_system.gd 1處+resource_system.gd 1處+manufacturing_system.gd 1處)已revert,3檔clean。→回to:systems。"
measured_at_head: "main a61de984（code 同 a728fe90，本輪僅新增 doc handback commit，無 code diff）"
seeds: "42 + 1337（各 1mo，低優先故縮短非 3mo）"
---

# order-noise disambiguate verdict → systems（★★(a) hollow-economy 確診）

工單：`2026-07-24-systems-to-measurer-order-noise-disambiguate-hollow-vs-ungrounded.md`（已消費）。舊 material-supply run 的 `trade.arb_kill_nostock` 只有全域聚合，無 per-res 拆解——**確實需要新跑**（工單猜的「可能不用新 run」不成立），故加 2 處 temp tap（`order_system.gd` per-res kill + `resource_system.gd`/`manufacturing_system.gd` per-res production）跑 1mo×2seed（低優先，縮短非 3mo）。已 revert，3 檔 clean。

## 答①：killed-nostock 按 res 拆
| res | seed42 | seed1337 |
|---|---|---|
| **tools** | 33664 | 43625 |
| **weapon_melee_low** | 18445 | 32271 |
| **weapon_ranged_low** | 42276 | 50861 |
| food | 40 | 4 |
| **TOTAL** | 94425 | 126761 |

→ **tools+weapon_melee_low+weapon_ranged_low 佔 94385/94425（99.96%）/ 126757/126761（99.97%）**，跨 seed 一致。**material 完全不在列表中**（本輪兩 seed 皆零次 material kill_nostock）。food 僅個位數，雜訊底。

## 答②：那些 res 有沒有隊在產（cross-ref production）
| res | seed42 production | seed1337 production |
|---|---|---|
| **tools** | **0.0** | **0.0** |
| **weapon_melee_low** | **0.0** | **0.0** |
| **weapon_ranged_low** | **0.0** | **0.0** |
| food | 894.6 | 1360.8 |
| material | 362.0 | 555.8 |
| herb | 5.1 | 4.9 |
| ore_iron | 3.9 | 17.0 |

→ **兩 seed 皆一致**：被殺最多的 3 個 res（tools/weapon_melee_low/weapon_ranged_low）**production 恰好都是 0.0**——完全命中你問的 **(a) hollow-economy** 分支：訂單找的是「沒隊在產」的貨，非「有貨但掛單沒對到」。material 兩 seed 皆有 production（362-556）且**從未出現在 kill_nostock 列表**，確認 material 不是這次噪音來源，噪音**純集中在 manufactured goods 鏈**（tools/weapon_melee_low/weapon_ranged_low，皆走 `manufacturing_system.gd` 的 `weaponsmith_level`/`manufacturing_level` 配方組）。

## ★判讀：(a) hollow-economy 確診，非 (b) ungrounded
- production 恰好=0（不是低，是**完全掛零**），代表全程沒有一次 `_run_recipe_group` 成功產出這 3 種 res——即沒有隊在跑對應設施（weaponsmith/manufacturing_level）。
- 這與同批 material-supply verdict（`2026-07-24-measurer-to-systems-material-supply-verdict.md`）的核心發現**同根**：EXPAND（settle）100% 結構性失敗 + forest harvest 效率僅 0.5-4.8% → 設施（含 weaponsmith）幾乎沒被蓋起來/運轉 → manufacturing 鏈全鏈路空轉（`manufacturing_system.gd:100` 的 `manufacture.noop_no_facility` 本輪未量測，但邏輯上與此吻合）。
- ∴ **order-noise（arb_kill_nostock 42k-84k→本輪 94k-127k）不是獨立的 order-layer discipline gap，是 material-supply root（EXPAND 閘矛盾/facility 稀缺）的下游症狀**——那個 root 修好，掛單自然找得到貨，噪音自然消。**不建議另開 ungrounded-order 修復工**。

## 溯源
raw：`docs/measurements/2026-07-24-ordernoise-{42,1337}.txt`（新跑，1mo，main a61de984）。temp 探針（`order_system.gd:255` per-res kill_nostock bump、`resource_system.gd`~300 前 per-res production add_amount、`manufacturing_system.gd:118` `_add_output` 入口 per-res production add_amount，皆 `Probe.enabled` guard）**已 revert、3 檔 clean、grep 零殘留**。determinism-safe（bump/add_amount-only 零 RNG）。file:line：`order_system.gd:253-256`（arb_kill_nostock 判定）、`manufacturing_system.gd:35-60`（RECIPE_GROUPS，weaponsmith_level 產 weapon_melee_low/weapon_ranged_low）、`manufacturing_system.gd:100`（noop_no_facility tap，本輪未量測但邏輯吻合，供你深挖用）。別下 fix 結論，判讀供你判是否要連 material-supply root 一起修或另案追蹤。

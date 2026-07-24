---
from: measurer
to: systems
status: consumed
topic: "[verdict·material供給診斷(Q1+Q2+Q3賽跑lens)·★★race框架前提不成立:0清伐事件+harvest效率0.5-4.8%+EXPAND100%失敗(population門檻矛盾)+BUY chosen趨0] main a728fe90 seed42+1337 3mo。跨seed一致:forest tile資源池全程幾乎不動(sum_pool降幅<0.1%,busted<20%cap=0/189-191全程),實際harvest僅理論regen上限0.5%(1337)/4.8%(42)——★沒有隊在大量採伐forest,故 clear-event=0、recovery-time=N/A、latecomer-remaining=0樣本,賽跑根本沒開始比。★valve診斷:EXPAND(settle)兩seed皆100%失敗(93-795次attempt全fail)——不是沒人想擴張,是_dispatch_subteam_settle的population≥10門檻(faction_ai:576)比它自己的attempt-gate(population≥8,line567)更嚴,實際需≥13才過,5人缺口保證失敗=閘矛盾非數字問題。BUY:applicable常見(742-9761)但chosen趨近0(0-124,seed1337竟0)+deal全res僅24-28,弱閥非死閥。判讀:regen數字微調(用戶想做的事)在這局面下無意義——問題不是先手優勢維持夠不夠久,是根本沒人碰forest材料(harvest 0.5-4.8%效率+EXPAND結構性0%+BUY近乎0%),tune regen改變不了0事件的世界。真正待修=harvest動機(為何隊不去forest採)+EXPAND門檻矛盾(de-patch候選)+BUY chosen率。piggyback:arb_kill_nostock月率42253-84187(全res,巨大,另案)。別下fix結論,回你判閥/regen優先序。"
measured_at_head: "main a728fe90"
seeds: "42 + 1337（各 3mo）"
---

# material 供給診斷 verdict → systems（★★race 框架前提不成立）

工單三輪演化（①aggregate+valve→②ADDENDUM boom-bust骨架→③REFRAME 賽跑先手優勢，同一 run）。main a728fe90、seed42+1337、3mo。temp 探針（`faction_ai_system.gd` 2處 + `resource_system.gd` 1處 VALVE.* bump/add_amount）**已 revert、main clean、grep 零殘留**。**別下 fix 結論**。

## ★★核心發現：賽跑框架的前提（有人在清伐 forest）不成立
| 指標 | seed42 | seed1337 |
|---|---|---|
| forest tiles | 191 | 189 |
| Σ初始 cap（boom 存量） | 29563 | 28176 |
| sum_pool 降幅（3mo，初始→終態） | **0.0%**（29563→29549） | **0.0%**（28176→28165） |
| busted tiles（<20%cap，全程） | **0/191** | **0/189** |
| **實際 harvest/月**（positional 真值） | 3293 | 321 |
| regen 上限/月（理論穩態） | 68760 | 68040 |
| **★harvest 效率**（實際/理論） | **4.8%** | **0.5%** |
| **清伐事件**（pool 首次<30%cap） | **0/191** | **0/189** |
| recovery-time 樣本 | N/A（無清伐可量） | N/A |
| latecomer-remaining 樣本 | **0** | **0** |

→ **兩 seed 一致**：forest material pool 全程幾乎紋絲不動（降幅<0.1%），**零清伐事件**，harvest 效率僅理論上限的 0.5-4.8%。**Q3b（先手優勢持續度/latecomer-remaining）無法回答——不是「量不到」，是「事件沒發生」**：沒有隊大量採伐 forest，賽跑根本沒開始比，regen 數字快慢無關緊要（沒人在跟它賽跑）。

## ★valve 診斷：EXPAND 結構性 100% 失敗（閘矛盾，非數字問題）
| | seed42 | seed1337 |
|---|---|---|
| settle_attempt（forest+plains） | 795+325=1120 | 93+30=123 |
| settle_fail_pop（同上） | **1120（100%）** | **123（100%）** |

- **★根因**：`_dispatch_subteam_settle`（`faction_ai_system.gd:576`）要求 `population − settler_count ≥ MIN_PARENT_POP_AFTER_DISPATCH(10)`，`settler_count = clampi(pop/4, 2, 5)`。但**呼叫端**（`_try_dispatch_or_invite`）只要求 `population ≥ 8` 就會嘗試（`:567`）。解 `pop − clampi(pop/4,2,5) ≥ 10`：**實際需 pop≥13**——attempt-gate(8) 與 success-gate(隱含13) 有 **5 人缺口**，該區間的隊**必然嘗試、必然失敗**。兩 seed 皆 100% 失敗，跨 seed 穩健印證此為**結構性閘矛盾**（同絕境經濟 arc 熟悉的 attempt-gate≠success-gate 家族），非「數字剛好不夠、調大 regen 能救」。

## BUY：弱閥但非死閥
| | seed42 | seed1337 |
|---|---|---|
| decision.opt_applicable.買料 | 9761 | 742 |
| decision.opt_chosen.買料 | 124（1.3%） | **0**（0%） |
| trade.deal（全 res） | 28 | 24 |

- applicable 常見（想買的隊多），但**chosen 率極低**（1.3%→0%，跨 seed 惡化非改善）——買料在 decision-rank 裡輸給其他 option，即便偶爾 chosen，deal 也罕見（全 res 合計僅 24-28）。
- Q2 前提可達率（有市集+有 coin）：seed42 100%、seed1337 75%——**前提不是主要瓶頸**，是「chosen 率」本身低。

## Q1 aggregate（初始 boom + regen tail，分開報）
- 初始 boom 存量：29563（seed42）/ 28176（seed1337），可撐 **268-282 隊**一次性 afford（105/隊）——**遠超**實際隊數（62-64 隊），供給端**不是**問題。
- regen tail 理論上限：68040-68760/月，可撐 648-655 隊/月——同樣遠超需求。
- **實際 harvest** 僅 321-3293/月，可撐 **3.1-31.4 隊/月**——供給充裕但**幾乎沒被取用**。

## piggyback
`trade.arb_kill_nostock` 月率 **42253（1337）/ 84187（42）**——全 res 合計，量級巨大（遠超 order_placed 的 430/1407），另案供你參考（非 material 專屬，本輪未拆解）。

## ★★淨判（供你 patch-gate-first / de-patch 判斷）
1. **regen 數字微調（你原想做的事）在此局面下意義不大**——不是「先手優勢維持夠不夠久」的調校問題，是**根本沒人碰 forest 材料**（harvest 效率 0.5-4.8%，EXPAND 結構性 0%，BUY chosen 趨近 0%）。tune 一個沒人在互動的變數不會改變 0 事件的世界。
2. **真正待修（依證據強度排序）**：
   - **EXPAND 閘矛盾**（`faction_ai:567` vs `:576` 的 attempt-gate/success-gate 5 人缺口）——**明確結構 bug，de-patch 候選最強**（跨 seed 100% 失敗，非統計雜訊）。
   - **harvest 動機**（為何隊不主動去 forest 採material？——decision-rank 裡「生產/採集」類 option 是否也被其他 option 系統性壓過，同本 session 已測過的 survival-preempt/facility-binding 家族）。
   - **BUY chosen 率**（applicable 常見但 chosen 率低，兩 seed 皆低且惡化——decision-rank 層面的問題，非 valve 存在與否）。
3. 你判：先修 EXPAND 閘矛盾（結構最明確）？還是查 harvest 動機根因（可能更上游）？regen 數字暫緩（本輪數據不支持「調數字」是當前優先）？

## 溯源
raw：`docs/measurements/2026-07-24-materialsupply-{1337,42}.txt`（Q1 boom+tail、Q2 valve reachability、Q3 aggregate pool trace、Q3b per-tile clear/recovery/latecomer、piggyback）。temp 探針（`faction_ai_system.gd` settle_attempt/fail/success by terrain + `resource_system.gd` material_harvest by terrain）**已 revert、main clean、grep 零殘留**。determinism-safe（bump/add_amount-only 零 RNG）。3mo（rule3）。file:line：`world_generator.gd:10`（forest cap[80,220]）、`resource_system.gd:93`（regen 12/day 補到 cap）、`faction_ai_system.gd:142,567,576`（settle 閘矛盾）、`decision/options.gd:259`（買料 applicable）。

---
from: measurer
to: systems
status: consumed
topic: "[verdict·coin-poverty-cause split·★salary 是共同主因,mil-loot/civ-dealflow 皆真但次要] main HEAD f1d2a2b4 seed42+1337 3mo,ResourceBank.add/remove+AnonTreasuryBank 全 5 func 加 reason-tagged temp taps。★★net coin flow 兩族群兩 seed 皆結構性負(mil -0.03~-0.10/day/隊,civ -0.08~-0.09/day/隊)——機制性坐實上輪 91% chronic coin_urg。★★salary 是兩族群共同最大 drain(mil 50-67%,civ 51-55%,跨 seed 一致)——判準③『salary-drain 兩族群通吃』最強支持。★conquest-loot(loot_full/share/wipe/massacre)兩 seed 零事件——『mil loot 卡 anon_treasury』假說原型不成立(機制根本沒 fire)。但★發現類比機制:salary_anon 存入付薪隊自己的 anon_treasury(非流失,只是需 greed>0.4 或飢餓緊急才能 extract 回 spendable coin)——這是真的『wealth 鎖進 illiquid pool』但源頭是 salary 非 loot,兩族群都有,非 mil-specific。civ trade net 兩 seed 皆小幅負(-4~-31/3mo)=deal-flow/GATE-B 真有拖累但量級遠小於 salary(差一個數量級)。mil trade net 兩 seed 皆正(+4~+31/3mo)=mil 不因低賣而虧,反駁 mil-loot-drives-poverty 單因說。anon_treasury 持有相對 team.coin 不算大宗(非主要囤積處)。判準結論:salary 機制修正是最大槓桿(兩族群通吃、跨seed最大佔比);GATE-B/civ dealflow 是真但次要加成;mil-loot-routing 假說原型不成立(改為 salary_anon lockup 的類比版本,非 mil-specific)。你判 spec。"
measured_at_head: "main HEAD f1d2a2b4"
seeds: "42 + 1337（各 3mo）"
---

# coin-poverty-cause 機制 split verdict → systems（★salary 共同主因，mil-loot 假說原型不成立）

工單（`2026-07-23-systems-to-measurer-coin-mechanism-split`，consumed）。main HEAD f1d2a2b4、seed42+1337、§④b。temp 探針（`ResourceBank.add/remove` + `AnonTreasuryBank` 全 5 func，reason-tagged、gated `res=="coin"`）**已 revert、main clean、grep 零殘留**。**別下 fix 結論**。

## ★★① net coin flow：兩族群兩 seed 皆結構性負（機制性坐實上輪 91% chronic）
| | seed42 mil(7隊) | seed42 civ(58隊) | seed1337 mil(15隊) | seed1337 civ(51隊) |
|---|---|---|---|---|
| income/day/隊 | 0.18 | 0.09 | 0.14 | 0.09 |
| drain/day/隊 | 0.20 | 0.18 | 0.25 | 0.17 |
| **net/day/隊** | **-0.03** | **-0.09** | **-0.10** | **-0.08** |

→ 兩族群、兩 seed **全部負**——直接印證我上輪 coin-lock-scope verdict 的 91% chronic coin_urg（非猜測，這是機制面的因）。

## ★★② drain 分量：salary 是兩族群共同最大單項（跨 seed 一致）
| | seed42 mil | seed42 civ | seed1337 mil | seed1337 civ |
|---|---|---|---|---|
| salary_anon+salary_named | 85.0 | 508.6 | 166.8 | 402.4 |
| 佔 drain 總計% | **67%**（85/127） | **54%**（508.6/933） | **50%**（166.8/333） | **51%**（402.4/786） |

→ **salary 佔 drain 50-67%（mil）/ 51-54%（civ）**——兩族群、兩 seed 高度一致地是**最大單一 drain 來源**。

## ③ income 分量 + trade net：mil/civ 質性不同但量級皆遠小於 salary
| | seed42 mil | seed42 civ | seed1337 mil | seed1337 civ |
|---|---|---|---|---|
| trade net（sell+trade_in − buy+trade_out） | **+30.9** | -30.9 | **+4.2** | -4.2（約） |
| conquest-loot（TREAS loot_full/share/wipe/massacre） | **0 事件** | — | **0 事件** | — |

- **mil trade net 兩 seed 皆正**（+4~+31/3mo）——mil 不因低賣而虧，**反駁「mil 低賣導致貧窮」單因說**。mil 幾乎不跑市場板（seed42 零 market_sell 記錄，seed1337 才有小量），income 主靠 member_tax + 小額 bilateral trade_coin_in + extort。
- **civ trade net 兩 seed 皆小幅負**（-4~-31/3mo）——**deal-flow/GATE-B 確有拖累**（判準①部分成立），但**量級比 salary drain 小一個數量級**（civ salary drain 402-509 vs trade 赤字僅 4-31）。
- **★conquest-loot（loot_full/loot_share/loot_wipe/massacre）兩 seed 零事件**——**你原「mil loot 卡 anon_treasury」假說的「conquest-loot 機制」原型不成立**（機制根本沒 fire，非「fire 了但卡住」）。

## ★★④ 但發現類比機制：salary_anon 才是真的「鎖進 illiquid pool」——兩族群都有，非 mil-specific
- `salary_system.gd:76`：`AnonTreasuryBank.deposit(team, anon_paid, "salary")` —— **匿名薪水付款存入付薪隊自己的 `anon_treasury`**（非流失，team.coin 真的減少，但轉存自己的 treasury，非憑空消失）。
- `anon_treasury` 只能透過 `_extract_treasury`（`faction_ai_system.gd:2338`）取出變回 spendable `team.coin`，**閘 = 領袖貪婪>0.4 或飢餓緊急**（`:2367`/`resource_system.gd:175`）——**跟你原假設的 loot-routing 閘完全同構，只是來源是 salary 非 loot**。
- 終態 anon_treasury 持有（mil 25-63 / civ 101-131）相對 team.coin 持有（mil 77-103 / civ 555-588）**不算大宗**——目前尚未大量堆積，但持續的 salary_anon 流入是真實存在的漏斗（若領袖非高貪婪、非飢餓緊急，這筆錢會持續卡在 treasury 不回流）。
- **兩族群都有 salary_anon 流出**（mil 30-65、civ 129-165）——**非 mil-specific**，是薪資機制本身的共同副作用。

## ★★結論（對照你判準）
1. **判準②「mil=loot-routing」：不成立**（conquest-loot 機制零事件，mil trade 甚至net正）。mil 真正的問題跟 civ 一樣是**結構性負 net flow + salary 佔 drain 過半**。
2. **判準①「civ=deal-flow/GATE-B 崩」：部分成立但次要**（trade net 確為負，但量級遠小於 salary，非 civ 貧窮的主因）。
3. **判準③「salary-drain 兩族群通吃」：最強支持**——salary 是兩族群共同最大單項 drain（50-67%），且跨 seed 高度一致。
4. **★新發現（供你 spec 參考）**：真正類似「loot 卡池」的鎖倉機制是 **`salary_anon`→自己 `anon_treasury`**（同閘：貪婪>0.4/飢餓緊急才能取出），非 loot。若要開一個「treasury-extraction」修正，**目標該是 salary_anon 沉澱**，非 conquest-loot（那條線基本沒在用）。

## 溯源
raw：`docs/measurements/2026-07-23-coinsplit-{1337,42}.txt`（COIN.*/TREAS.* 逐 reason 分量 raw dump + 聚合 income/drain/net + 終態 anon_treasury/team.coin 持有）。temp 探針（`resource_bank.gd`/`anon_treasury_bank.gd` 6 處 reason-tagged add_amount）**已 revert、clean、grep 零殘留**。determinism-safe（add_amount-only 零 RNG）。3mo（rule3）。file:line：`salary_system.gd:65-76`、`faction_ai_system.gd:2338-2367`、`resource_system.gd:175`、`encounter_system.gd:1126-1446`（conquest-loot，本輪零事件）、`npc_combat_system.gd:550-559`（field-skirmish loot，直入 team.coin，本輪也近乎零）。

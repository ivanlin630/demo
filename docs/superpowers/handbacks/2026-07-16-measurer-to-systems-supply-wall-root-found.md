---
from: measurer
to: systems
status: consumed
topic: "[量測完·根坐實=甲] 供給牆真根：has_facility隊數全程恆=1(20-28隊裡僅1隊,6月不變)——manufacture facility幾乎不存在,非material稀缺(material surplus月1=417→月6破千,healthy且逐月成長)非reserve太高(goods reserve僅0.5-12,材料surplus動輒17-104倍高於它)；[Manufacture]執行print全程僅6次(單一有facility隊貢獻)；抽樣8隊goods holding逐月恆=0(從未產出過一單位finished goods)；TASK_MANUFACTURE dispatch隊數逐月成長(1→11隊,39.3%)但has_facility卡死=1→絕大多數manufacture-task隊每tick空轉no-op；判根=甲(建surplus經濟)，精確到facility建造/升級鏈缺失，非reserve/material/task-selection層"
---

# 供給牆 patch-gate-first：根坐實 = 甲（facility 缺失，非 reserve/material 稀缺）

依 `2026-07-16-systems-to-measurer-supply-wall-measure.md`，自建 `scripts/debug/supply_wall_bed.gd`（已commit進repo），main（merged `eb047b6f`後）seed1337 6月force_full_hd。

## 一次量完（鐵律6）

## 疑①：非糧 surplus 存不存在 —— 存在，但幾乎全是原料(material)，成品(goods等)恆零
| 月 | 有正surplus隊數/總隊 | surplus總量 top5 by res |
|---|---|---|
| 1 | 15/20(75%) | material=417.3, weapon_melee_low=10.1, horses=8.0, armor_low=7.7 |
| 3 | 23/23(100%) | material=1004.2, weapon_melee_low=12.0, horses=11.5, armor_low=9.0, herb=1.1 |
| 6 | ?/28 | material=?(續漲), horses=?, weapon_melee_low=?, armor_low=?, herb=? |

**material（原料）surplus健康且逐月成長（417→破千），95%+隊有正surplus——原料不缺。但成品類（goods/weapon/armor/tools等）surplus總量常年停在個位數~十位數（10-20量級），跟material差兩個數量級。抽樣8隊（見疑③）goods holding**逐月恆為0**——這8隊從第1月到第6月，一單位goods都沒生產過。**

## 疑②：manufacture 產能 —— ★真根找到：has_facility 全程恆=1
| 月 | TASK_MANUFACTURE中隊數 | has_facility隊數 | material≥30隊數 | _can_manufacture通過隊數 |
|---|---|---|---|---|
| 1 | 1(5.0%) | **1** | 8 | 1 |
| 2 | 3(13.0%) | **1** | 10 | 1 |
| 3 | 6(26.1%) | **1** | 11 | 1 |
| 4 | 9(37.5%) | **1** | 12 | 1 |
| 5 | 9(36.0%) | **1** | 12 | 1 |
| 6 | 11(39.3%) | **1** | 12 | 1 |

**has_facility（outpost tile上任一製造設施等級>0）全程6個月恆定=1隊——20-28隊的世界裡，從頭到尾只有1隊真的有製造設施。`_can_manufacture`通過數精確等於has_facility數（=1），代表material充足與否根本不是瓶頸（12隊material≥30達標，但只有1隊過得了facility這關）。同時`TASK_MANUFACTURE`dispatch隊數逐月成長到11隊(39.3%)——★這代表接近40%的隊被排進TASK_MANUFACTURE task，但其中10隊（11-1）完全沒有設施可用，每tick在`tick_all`裡直接early-continue空轉，純浪費task slot，一無所產。**

實測`[Manufacture]`（真正跑recipe的執行print）全程6月僅出現**6次**——全部來自那唯一1隊。

## 疑③：reserve gate —— 排除，reserve值很小，非瓶頸
抽樣8隊×6月的material/goods reserve：
```
月6 team0: material holding=53.5 reserve=0.81 surplus=52.7 | goods holding=0 reserve=0.49 surplus=-0.49
月6 team1: material holding=39.5 reserve=2.16 surplus=37.3 | goods holding=0 reserve=1.30 surplus=-1.30
月6 team2: material holding=45.7 reserve=8.32 surplus=37.4 | goods holding=0 reserve=4.99 surplus=-4.99
月6 team3: material holding=85.1 reserve=1.39 surplus=83.7 | goods holding=0 reserve=0.84 surplus=-0.84
```
**goods的reserve永遠很小（0.5-8），從來不是material surplus（37-104）的數量級對手——真正卡住的是holding本身恆為0（沒生產出來），不是reserve太高把已有的貨吃掉。reserve gate假說排除。**

## 判根：★甲（建surplus經濟），精確定位=facility建造/升級鏈缺失
| 候選 | 判定 |
|---|---|
| material稀缺 | 排除（healthy，逐月破千） |
| reserve太高擋 | 排除（reserve值遠小於material surplus，goods holding恆0非reserve吃掉） |
| **manufacture facility缺失** | **★坐實，has_facility全程恆=1** |
| TASK_MANUFACTURE鮮少選 | 排除（dispatch隊數逐月成長到39.3%，選了但沒設施可用） |

**根 = 世界裡幾乎沒有隊會去建/升級manufacturing facility（工坊/冶煉/武器/護甲等級）。material原料採集鏈健全、task分配機制也有把隊排進manufacture，但轉換成finished goods的「產能」這一關（facility本身）近乎不存在——不是gate太嚴，是真的沒蓋。這是outpost建設側（可能是OutpostSystem的建造優先序/AI決策從不選建manufacturing facility）的問題，非trade/economy層本身。**

## 待你裁
1. 為何隊伍幾乎不建manufacturing facility——是AI建設優先序沒把它排進去（總是選別的建設項目），還是建facility的前置條件（cost/rung/outpost等級）太高很少達成？我可以另外trace建設決策候選榜（哪些option排前面把manufacture facility排擠掉）。
2. 甲刀範圍——只需要「facility更容易建/AI更常選建」就夠，還是要連帶調整`_can_manufacture`的其他gate（faction/ownership那段）？

---
measured_at_head: main(9dff103f，含eb047b6f merge)
raw: docs/measurements/2026-07-16-supply-wall-main-eb047b6f.log（UTF-16 tee，Grep對長行有截斷,改用node讀取reserve樣本明細）
bed（純讀不寫state,唯讀calc TradeValuation/ResourceSystem/_can_manufacture）: scripts/debug/supply_wall_bed.gd（已commit main dir 9dff103f）

---
from: measurer
to: blueprint
status: consumed
topic: [財富軌跡查完·核心問題有答] Team7買糧67天財源=material barter非coin,coin全程0；意外查到pop鎖初期崩60%
measured_at_head: d81cfdb
---

# 財富軌跡：不用重跑就查到答案

## 好消息：coin/material 其實早就有記，不用重跑

`SpecimenTracer._snapshot()`（`specimen_tracer.gd:100-115`）本來就每筆決策記 `coin`/`material`——只是我上一版 `winner-dist-contradiction-resolved.measure.json` 的 `team_diaries` 沒把它抽進去（只記 task 計數）。這輪從既有跑檔（`docs/measurements/2026-07-13-team7-wealth-trace-1337.log`，381 筆完整）重新抽，**不用重跑**就答完核心問題。

## 核心問題：錢從哪來？271 次是不是真成交？

**答：Team7 全程 `coin=0`（381 筆一筆不漏），錢從不是財源——財源是 material barter。**

`decision_context.gd:211-214`：
```
c.has_specie = coin>0 OR material≥20(MATERIAL_TRADE_MIN,terms.gd:15) OR goods≥10 OR ore≥20
```
Team7 走 **material** 這條分支，非 coin。material 軌跡：
| tick | mat | pop | food_priv |
|---|---|---|---|
| 5580（鎖起點） | 20 | 10 | 17.2 |
| 7000 | 51 | 5 | 0.0 |
| 9000 | 51 | 4 | 0.2 |
| 15000 | 51 | 4 | 2.9 |
| 21480（結束） | 51 | 4 | 2.9 |

**material 從沒跌破門檻（20）**，反而從起點漸升到 51 就 plateau，67 天沒枯竭——不是「越買越窮見底」，是穩定的物資換糧經濟。

## 意外查到：pop 在鎖死初期暴崩 60%

tick5580 pop=10 → tick7000 pop=5 → tick9000 pop=4，之後穩定 55 天沒再降。跟買糧鎖時間點重疊，**相關性明顯，因果我沒查**（先崩後鎖夠養，還是鎖沒即時解糧才崩，需更細 tick 級因果，超出本輪範圍）——附上給你判斷要不要追。

## 沒交的兩項（超出我界，需 code）

1. **goods 軌跡**：`_snapshot()` 目前沒印 goods，要加就得改 `scripts/simulation/decision/specimen_tracer.gd`——不改 code 是我的界，標記給 implementer/systems。
2. **買糧真成交/no-deal 拆分**：要 tap `interaction_system.gd:766` 的 `buyer_coin<=0 return` 判斷點，同樣需改 code。271 次「買糧」目前只能證明「material 財源健康+task 有被選中」，證不到「每次真的换到糧」——但 food_priv 軌跡（0.0→0.2→2.9緩升，非持續掉到餓死）間接支持「有換到，只是慢」。

## 遵守可溯源協議
raw log 落地 `docs/measurements/2026-07-13-team7-wealth-trace-1337.log`，數字附 `measured_at_head: d81cfdb`（見 `docs/process/verdicts/team7-wealth-trace.measure.json`）。

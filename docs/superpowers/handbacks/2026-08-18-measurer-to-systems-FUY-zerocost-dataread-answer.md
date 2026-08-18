---
from: measurer
to: systems
status: consumed
topic: FUY-zerocost-dataread-answer
---

# FUY 兩問答案：廣度夠、但落敗根因是勞力配額不是常數本身——第三條路

ticket:`2026-08-18-systems-to-measurer-FUY-zerocost-dataread.md`
數字全落地:`docs/measurements/2026-08-18-FUY-farming-breadth-labor.measure.json`

## 先講零成本檢查結果：非零成本

`docs/measurements/2026-08-18-agriculture-a-food-account-gate.measure.json` 跟其底層 dump 我 grep 過，`farming_level` 命中數=**0**。既有 6mo dump 沒這兩欄位。照 ticket 自己給的分流走**小 tap 補一輪**（main 已含 agriculture-a merged，不用開 worktree，非阻塞農業b）。床：`scripts/debug/fuy_farming_breadth_bed.gd`（temp，用完已刪），seed=1337 peaceful_economy.json 6個月（跟原輪同條件）。

## ①farming_level>0 廣度：10/13隊(76.9%)——夠廣，非「寥寥」

```
team0=2  team1=1  team2=1  team3=1  team4=2  team5=1  team7=3  team9=1  team10=1  team11=1
```
終態13隊裡10隊有田。**排除 blueprint 分流(a)「純defer到12mo」**——不是農田沒發展的問題。

## ②farm_yield vs l0_forage：raw ratio 慘輸，但根因是勞力配額不是常數

| | 6mo累計 |
|---|---|
| farm_yield | 710.9 |
| l0_forage | 4572.9 |
| raw ratio(farm/forage) | **0.1555** |

單看這個比例像 FARM_UNIT_YIELD 該調高（blueprint 分流(b)）。但我多抽了一個數字：**farm labor_mult 平均飽和度=0.211**（n=2626 次farm生產機會取樣，1.0=需求全滿足）。

farm 的勞力位長期只拿到約 **21%** 應得配額——長期被 gather/mfg 在同一勞力池搶走大部分。若 farm labor 滿飽和（mult=1.0），farm_yield 線性外推 ≈ 710.9/0.211 ≈ **3369.7**，届時 farm/forage 比會從 0.1555 收斂到 **≈0.737**——差距從「懸殊落敗」變成「顯著但沒那麼誇張」。

**還有一個結構性因素**：l0_forage 完全不吃 LaborSystem 勞力池（免費 fallback 機制，隊伍站著不動就有），farm_yield 吃勞力池（`LaborSystem.labor_mult(tile,"farm")` 跟 gather/mfg 同池競爭）。這代表「per-labor」這個框架對 l0_forage 本身不是良定義比較——它的 per-labor 分母是 0。

## 結論：blueprint 原本的 (a)/(b) 二選一都不完全貼合，是第三條路

不是farm_yield產量的問題本身（那21%有拿到的勞力,單位產出是合理的），是farm勞力位**長期吃不到勞力**。調高 FARM_UNIT_YIELD 不會解決這個瓶頸——只會讓那已經吃到的21%配額產更多，緩解有限（21%×2倍常數=42%配額的等效產出，還是遠不到滿飽和的水準）。

真正該查的是：farm勞力位為何長期 under-served？`K_FARM=5.0`（每 farming_level 5手飽和，`labor_system.gd:10`）是否訂太高（分母太大→每級farming要更多勞力才滿）？還是 `labor_mult` 的分配優先序本身讓 farm 系統性墊底（跟 gather/mfg 比是不是有序位劣勢）？我沒有再往下拆這條（時間所限，這輪任務範圍是回答兩問非診斷勞力分配機制），標記給你判斷要不要開一輪查 LaborSystem 分配邏輯。

temp tap（`resource_system.gd` 的 `diag.farm_labor_mult_sum`/`_n`）+ `fuy_farming_breadth_bed.gd` 已revert/刪，`--headless --import` 確認乾淨編譯。

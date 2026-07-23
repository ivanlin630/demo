---
from: systems
to: blueprint
status: consumed
topic: "[②carrying-capacity 判定=①合法 carrying-capacity 壓力(非 rate calibration 洞)·死亡來自逃生閥被堵非 rate 錯] 查清:harvest 公式是 intentional carrying-capacity——pop_mult=clampf(sqrt(pop/5),0.5,2.0)(resource_system:63)=harvest sub-linear(sqrt pop),但 burn=pop×0.8 linear。∴harvest/burn ∝ 1/sqrt(pop)→大隊 per-capita 採集遞減=設計的人口邊界(用戶問的沒錯,邊界在,是 sqrt+cap)。pop5 collect/burn surplus、pop8 break-even、pop10 82%(壓力)、pop20+ 硬 cap(pop_mult 封頂 2.0 而 burn 續長)。∴pop10 collect6.55<burn8=合法 carrying-capacity 壓力(該逼隊 upgrade farming[level3 ×2.5→~11>8 撐得住]/擴территory[lv3 採鄰格]/分隊/貿易),非 rate 洞。★死亡真因=逃生閥被堵:farming/outpost upgrade(facility-build 稀少=你的 keystone flag)+trade(GATE-B 買糧崩)。∴②別動 harvest rate(動了破 carrying-capacity+讓過度擁擠隊不真實地存活),修=通逃生閥(facility-build+GATE-B),②其實是 facility-build+GATE-B 的下游非獨立 rate 修。用戶答案:有人口邊界(設計)、pop10 撐不住是意圖壓力、死亡是適應閥壞非 rate 錯。"
---

# ② carrying-capacity 判定 = 合法壓力（非 rate calibration 洞）

## 查清（patch-gate-first，file:line）
harvest 公式**本身就是 intentional carrying-capacity 機制**：
- **harvest sub-linear**：`resource_system:63` `pop_mult = clampf(sqrt(pop/5.0), 0.5, 2.0)` → 採集隨 **sqrt(pop)** 縮放、**pop20+ 硬封頂 2.0**。
- **burn linear**：`burn = pop × FOOD_PER_PERSON_PER_DAY(0.8)`。
- ∴ **harvest/burn ∝ sqrt(pop)/pop = 1/sqrt(pop)** → 隊越大 per-capita 採集越低 = **設計的人口/採集邊界**（**用戶問的沒錯——邊界在，就是 sqrt+cap**）。

| pop | burn | collect(measured base) | 判 |
|---|---|---|---|
| 5 | 4.0 | ~4.6 | surplus |
| 8 | 6.4 | 5.58-6.55 | break-even |
| 10 | 8.0 | 5.58-6.55（82%）| **壓力**（deficit） |
| 20+ | 16+ | cap（pop_mult=2.0）| **硬 cap** |

## 判定 = ①合法 carrying-capacity 壓力（非 ②rate 洞）
- **pop10 collect < burn = 設計意圖的壓力**：一格 farming outpost 在 base 養不起 pop10——該逼隊**適應**：upgrade farming（`(1+farming_level×0.5)`：level3 ×2.5 → ~11 > burn 8 = **撐得住**）/ 擴 territory（lv3 採鄰格 `:72-73`）/ 分隊降 pop / 貿易補。
- ∴ **harvest rate 沒洞**——它 CAN 撐 pop10（經 upgrade），設計是「base 養小隊、大隊需升級/擴張/貿易」。coherent。

## ★死亡真因 = 逃生閥被堵（非 rate 錯）
pop10 死不是因 rate 錯，是**該有的適應反應全被堵**：
1. **farming/outpost upgrade 被堵** = **facility-build 稀少**（=你早先 flag 的 keystone；隊太窮/餓沒餘力升級）。
2. **trade 補 shortfall 被堵** = **GATE-B 買糧空間錯配崩**（arrive→attempt）。
3. （分隊/擴張——survival-mode 下大概也不主動。）

## ∴ ② 的修 = 通逃生閥，非動 rate
- **別動 harvest rate**：動了會**破 carrying-capacity**（讓過度擁擠的隊不真實地存活、消掉「過度擴張有後果」的 coherent 悲劇）。
- **② 其實是 facility-build + GATE-B 的下游**（非獨立 rate 修）：通了 upgrade 閥 + trade 閥 → pop10 隊有出路 → ② 隨之解。
- **序不變**：①GATE-A 先 → 逃生閥（facility-build keystone + GATE-B）伺候 ②③。②不需獨立 harvest-rate slice。

## 用戶答案（求你轉述）
「我們不是已經針對人數做覓食/採集邊界了嗎？」→ **是，邊界在（設計的 sqrt harvest vs linear burn），且正常運作**（小隊盈餘、大隊壓力、超大硬 cap）。pop10 撐不住是**意圖的 carrying-capacity 壓力**，不是 bug。**死亡是「適應閥（升級/貿易）壞掉」**（facility-build 稀少 + GATE-B），不是採集率算錯。修方向=通閥，別調率。

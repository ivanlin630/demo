---
from: systems
to: blueprint
status: open
topic: granary 定位完成——真根≠net0,是 supply/demand cadence 24× 不對稱(regen+harvest 未 day-scale、consumption 有)→ forest 秘密 net-positive、整個世界食物太鬆;修=economy-wide 收緊 = 大 rebalance,需你 WHAT sign-off(非我單決)
---

# granary 定位：真根是 cadence 不對稱（比「net0」深、且 contradicts 前提）

回 `granary-fix-plus-observability-perf`（#1 定位→修根）。**定位一次完成、碼證airtight**（非 measure-loop）。結論**推翻你的 net0 前提**——這是好消息（真根更深、解釋更多）。

## 定位到碼：供需 cadence 24× 不對稱

三條 food 路徑都每小時跑（`sim_runner` NEAR cadence hourly），但**只有消耗按 day_fraction 縮放**：

| 路徑 | 檔:line | day_fraction 縮放? | 每日實效 |
|---|---|---|---|
| **regen**（tile 食物再生） | `resource_system.gd:78-82` | ❌ **無** | forest 3/hr = **72/day** |
| **harvest**（tile→granary 採集） | `resource_system.gd:222` | ❌ **無** | 0.05×pool/hr ≈ 70%/day |
| **consumption**（吃） | `resource_system.gd:91,108` | ✅ **有**（`day_fraction=cadence/TICKS_PER_DAY`） | pop×2.4/day |

**供給側(regen+harvest)未縮放 = 每小時全速；需求側(consumption)縮放到每日 → 供給 24× 快於需求。**

## 你的「net0」前提修正
- forest **不是活不了、regen 不是勉強餬口**——是**秘密 net-positive**（72/day 進 tile、harvest 灌進 granary、consumption 才 24/day for pop10）。
- foraging 實作看到的「private 平 288→264 + granary 釘 1999」= **net-positive 被 trap 進封頂 granary**（長到 cap=2000 卡住，看似停滯實為爆倉）。private 平是因 provision-carry 只補到 10 日 buffer，餘全溢進 granary。
- granary 單向陷阱（`resource_system.gd` 消耗先扣 private、granary 唯一 drain=provision-carry 節流 10 日 buffer、直接吃 granary 分支:122 是死碼、賣單需成交才減）→ 超額 harvest 單調累積入 granary → `effective_food`(stock 含 granary)撐爆 growth gate(`reaction_system.gd:201`)。

## ★ 更大現象（這根解釋的不只 forest）
供給 24× 太鬆 = **為何整個世界無 starvation pressure、無 trade need、turtle**（(a) arc 一路的「default 龜縮」可能部分源此）。食物太多 → 不缺 → 不交易 → 不擴張搏命。**修這根 = 可能 unlock 整個經濟/衝突 arc 的稀缺壓力。**

## 修根：兩層（耦合）
**R1（核心根）= 供給側對齊 day_fraction**：regen + harvest 也按 day_fraction 縮放 → forest 真 3/day（**非 nerf、是修 24× cadence bug，forest 仍你要的 3**）→ forest 真 marginal → 想長必須賣木買糧 → **「繁榮須交易」真轉**。
**R2（你原方向、結構補強）= growth 讀 flow 非 stock**：`reaction_system.gd:201` surplus gate 從 `effective_food`(stock) → 持續盈餘(收入>消耗 over window) → 不靠 stale 滿倉長。**單獨不足**（R1 不修則 flow 仍被 24× 灌水成正）→ R1+R2 一起。

## ⚠ 但 R1 = economy-wide rebalance，跨你的 WHAT 域，需 sign-off
R1 不是局部修——**全地形供給 ÷24**（plains 8/day 而非秘密 192/day、所有隊食物驟緊）：
- **正面**：食物變稀缺 = 「繁榮須交易」「搏命擴張」的前提，正是沙盒 bar 要的活經濟壓力。
- **風險**：mass starvation 潮、需**重 re-tune 所有食物常數**（FOOD_PER_PERSON、COLLECT_RATE、buffer、breed 門檻…）= 多 slice 的 rebalance arc，非一次 surgical。
- **這是為何呈報你**：食物從「隱性充裕」→「真稀缺」是**世界 feel 的 WHAT 級改變**（你的域）。我不單決 economy-wide 重平衡。

## 待藍圖裁
1. **R1 認可否**（供給 day-scale = 世界食物真稀缺、接受重 re-tune 的 rebalance arc）？這是真根、解鎖經濟壓力。
2. R2（flow-not-stock growth）我這邊直接做（結構、你已授方向）。
3. 若 R1 認可 → 我出 spec：供給 cadence 對齊 + 食物常數重校 plan（measure baseline→改→bed 驗不 mass-starve 且交易網轉）。**探針/perf（#2/#3）正好隨此鋪**（re-tune 要 process timeline 看食物流）。
4. 若 R1 緩（怕 rebalance 太大）→ 退而先只 R2 + 局部（但誠實：forest 仍會靠灌水 flow 長、trade 未必 fire，治標）。

**推薦：認 R1**（真根、且解釋整個世界食物太鬆）。rebalance 大但那正是活經濟的門票。你裁。

---
from: systems
to: reviewer
status: consumed
topic: [R②·★異質框外審必須·再過] slice A加層0求生util量級復原(真根,顛覆esteem-focus)+願景A兩層防線+真根3立場翻正
---

# R② 審：層0 求生 util 量級復原（併入 Slice A 架構）——★異質框外審再過

spec `2026-07-14-survival-budget-personality-architecture.md`（§真根 + §層0 + §願景 A 精修 為新增，讀）。blueprint 讀 v2 branch code 揪出**真根顛覆前診斷**（前 esteem-focus 是次要症狀），加**層0 求生量級復原**為地基，用戶拍願景 A。改動更底層（決策核心 util 量級），blueprint 明示**再過異質框外審**。

## 真根（我已 code 覆核坐實）
`terms.gd:52-54` survival_pressure eval 硬 `return 1.0`（T1 正規化把 urgency 移進有界 coeff [0.15,1]）→ 求生失去 food→0 碾壓量級 → v2 實測 覓食 0.91 vs 建設 1.14 → 發展死。coeff 軟乘子推不動求生自己過 1.0。

## 層0 設計（vision A：util 競爭框內、量級碾壓非硬中斷）
`rank_scored` 算完 u 後，survival-class option 在 `food_days < SURVIVAL_BOOST_FLOOR(~2)` 時加**加法 boost** `MAX * (FLOOR-food_days)/FLOOR`（food→0 放大，突破 1.0 封頂奪回 argmax）。floor 低=安全氣囊、boost 頻率=健康指標。restores 統一隊求生(經 util 非硬 floor)。真根3 翻正 need_hierarchy:70-71 立場。

## ★為何再異質（三對齊更深）
1. 動**決策核心 util 量級**（比上輪 threshold 更底層，直接改 argmax 勝負）。
2. **翻正剛拍的願景立場**（v2「野心餓死=特色」→ 願景 A「不許結構性餓死」）——立場翻轉本身要框外審。
3. 難逆 + fidelity 中。→ 不同模型/代 + refute prompt。

## 請 refute（主動找破綻）
1. **加法 boost 破封頂會不會過頭**：`MAX~2.5` 加在 survival→util ~3.5，碾壓一切。**攻擊**：boost 觸發時 survival 是否**碾壓過頭**到連「該逃的威脅、該投靠」都被蓋掉（survival-class 含掠奪/併入，boost 均等加→會不會餓隊無差別亂搶/亂投靠，而非選最該做的求生）？boost 該不該只加覓食/買糧(真補糧)而非全 survival-class？
2. **FLOOR 低 vs 安全網沒接好的雙重風險**：floor~2 天=只在快餓死才觸發。**攻擊**：若上層安全網(層2/5)這輪沒調好、隊仍常掉到 2 天→boost 常觸發→驗收 0b「頻率低」失敗——這是 boost 設計問題還是安全網問題？兩者同輪改，measurer 怎麼歸因(boost 常觸發到底怪誰)？
3. **加法 boost 與既有 coeff/commitment 疊加的量級失控**：層0 加法 + 既有 coeff 乘 + commitment 0.3——**攻擊**：多機制疊加會不會在某 food_days 帶產生非預期排序（如 boost 剛啟動的邊界 food_days≈FLOOR 抖動→survival util 跨越 dev 的瞬間 flip-flop）？邊界連續性夠不夠(線性 ramp 應連續，但 commitment latch 交互？)。
4. **真根3 立場翻正的完整性**：改註解夠不夠？有沒有別處 code **實質**依賴「野心餓死=特色」(非只註解)——如某 gate 故意不救野心隊？還是純註解、無 code 依賴？
5. **層0 使 esteem/門檻人格化(層2)變冗餘?** 若 boost 保證極端不死，層2 門檻人格化(日常風格)是否還有效用，還是 boost 一兜底就把 attrition 全解了、上層都是裝飾？(scope 精簡機會 or 各司其職?)

## 前提坐實
- `terms.gd:52-54` `return 1.0` 封頂坐實。
- `need_hierarchy:39` coeff 有界坐實。
- `faction_ai:3063-3064` PRIO_SURVIVAL 對統一隊退役坐實(v2 Fix1)。
- `DecisionOptions.SURVIVAL_OPTION_SET`(options.gd:49) 8 項存在。

## 時序 + 用戶鐵律
- measurer v2(層1-2)結果現**moot**（用戶鐵律：全好才量、不半套 bisect；層1-2 是次要症狀，單驗無意義）。implementer HOLD。
- 你 CLEAN → dispatch **全 slice A（層0+1+2+3+5+候選1+候選2）整包**→ implementer 一次做完 → 一次量測。
- premise_contradiction（尤其 #1 boost 碾壓過頭 / #2 歸因糾纏）→ halt 回報。

## 回報
CLEAN / issues / premise_contradiction。改到決策核心量級，寧可狠 refute。
（寄件永遠 open，你讀後改 consumed。）

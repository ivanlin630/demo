---
from: blueprint
to: measurer
status: consumed
topic: [量測請求·measure-first] established=0真根定位——讀de-patch acceptance run既有gate_fail_*funnel(A5可達盟友/A4盈餘/A6busy)判斷卡哪門+補B門(readiness≥0.7等)probe
---

# established=0 真根定位——funnel已備，先量再開藥

## 背景
de-patch建造權merge後死鎖解（獨立隊farming 0/7→5/12），但established12月全程恆0未變。systems零跑審出完整兩階段條件表（`2026-07-12-systems-to-blueprint-establishment-condition-table.md`）：階段A(獨立隊→組faction，6條件A1-A6同時滿足)、階段B(faction→established，4條件B1-B4)。farming只碰A3(間接)/A4(部分)，A5(可達獨立盟友)/B4(readiness≥0.7)完全與farming無關。

## 要你做的（measure-first，先量哪門卡再開藥）
1. **既有probe已instrument**（`_evaluate_independent_strategy:1185-1194`），讀你手上de-patch acceptance run的既有數據，抓：
   - `indep.gate_ambitious`（A2過的分母）
   - `indep.gate_fail_pop`（A3卡）
   - `indep.gate_fail_food`（A4卡，7日盈餘buffer）
   - `indep.gate_fail_busy`（A6）
   - `indep.gate_fail_nopath`（**A5卡=可達獨立盟友**，systems判最可疑候選之一）
   - `indep.gate_path_ok`（全A過的分母）
   - `indep.found_ally` / `indep.found_timeout`（信使結盟成功/逾時）
2. **階段B目前無專屬fail probe**——請你補一個（B2統領skill/B3野心/B4 readiness≥0.7各fail計數，`faction_ai:974-980`附近）。若A門就卡光（gate_path_ok趨近0），B門可以先不查，省工。
3. 若既有run數據不夠（例如沒存這幾個counter），才需要重跑；**別預設要重跑，先看能不能從既有數據撈**。

## 為何現在查
用戶主線=修「玩家世界從沒活過」，farming死鎖只是地基第一塊，established才是「立國/世界活起來」的直接指標。定位哪門卡死，才知道下一輪brainstorm該對症哪個條件（A5可達盟友稀?A4盈餘buffer太高?A6一直busy?還是A都過了卡在B4 readiness?）。

## 序
你定位斷點 → to:blueprint → 我brainstorm對症設計 → 對抗① → systems spec → build → 驗。

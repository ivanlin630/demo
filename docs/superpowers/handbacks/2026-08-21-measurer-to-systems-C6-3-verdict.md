---
from: measurer
to: systems
slice: estimator-audit
status: open
topic: "★C6-#3答案(死水兩欄新規範首用)：①呼叫頻率=3785次/90天,非死水②輸入變異性=food_days(6.8~31.25)/build_eta_days(0.05~0.15)皆真變異③閘確認誤放(同A4/A5,÷240非÷24,10倍低估工期)④★誠實邊界:30/3785樣本(bump_sample cap)全集中在遊戲早期,margin夠大,還沒撞到bug真正翻轉判準的邊界情況——不代表bug無害只代表這30筆沒抓到受害者,建議下一步交叉比對T1崩潰軌跡的4隊有沒有construction_team_id==自己且target是food_facility的重疊案例"
---

# C6-#3答案（死水兩欄新規範首用）

## ①呼叫頻率：3785次/90天，**不是死水**

`food_rescue.entry = 3785`。這條路徑持續在被呼叫，跟T3(faction層0次)/C-3(host_rep恆定)不同家族——per-team路徑確實活著。

## ②輸入變異性：兩個關鍵輸入都在真實變化

`food_days`範圍6.84~31.25；`build_eta_days`(bug估計)範圍0.05~0.15（隨build進度縮小）。都不是常數。

## ③閘確認誤放：與A4/A5同一種cadence除數錯誤

`faction_ai_system.gd:4582-4583`：`build_eta_days = cost.ticks / population / TICKS_PER_DAY(240)`。跟A4/A5一樣的bug——construction真實衰減是24次/日不是240次/日，正確公式該÷24。用÷240的估計值恆比真值小10倍，`P(survive_to_harvest)`系統性偏樂觀。

## ④★誠實邊界：30個樣本裡沒抓到真正的受害者

用bug公式通過閘=30/30；但用真值(÷24)重算後仍然會通過的=30/30——**假通過(bug通過但真值該fail)=0**。

**這不代表bug無害**，只代表：`bump_sample`上限30，只抓到3785次呼叫裡的**前30次**（集中在tick10-640，遊戲早期）。這時`food_days`還很高(6.8~31.25)，`margin`夠大，即使用正確公式也會通過——還沒撞到bug真正翻轉判準的邊界情況。真正的受害案例可能在遊戲中後期（`food_days`已經降到接近`true_eta`的臨界窗口），本輪樣本沒覆蓋到。

## 建議下一步（不開藥，指路）

要抓到真正「假通過→半途餓死」的受害者，兩個方向：
①改取樣策略（只記錄margin最小的N筆，非前N筆）
②直接交叉比對T1/breed-deathcause已有的4隊崩潰軌跡，看有沒有`construction_team_id==自己`且target是food facility的重疊案例——不用重跑，用既有資料查。

## 落地

`.measure.json`：`docs/process/verdicts/C6-3-food-rescue-gate.measure.json` @5e5f4f4b(main) 2026-08-21

## L3聲明

`faction_ai_system.gd:_food_rescue_eval`加entry計數(1行)+核心兩值sample tap(6行，含÷24真物理對照值)，Probe-gated零行為改動。

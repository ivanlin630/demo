# Pattern B banker — resources（第五池,最大,148 寫/23 檔）

> `state-fight-scope` Pattern B：resources[*] ~110(實 148)寫/23 檔，per-key RMW + 整 dict reset/clear，面積最廣。承 banker 模式。**守恆關鍵 → coin_eq/CoinAudit/InvariantAudit 為硬閘。**

## 病
`team.resources[key]` 散 148 寫無 banker：`+= / -= / =` per-key + 5 處 dict `= {} / .clear()`。無集中點 → 無審計、未來寫者可隨意 RMW。

## 修：ResourceBank 簡 wrapper（保原數學=守恆 by construction）
新 `scripts/simulation/resource_bank.gd`：
```
static func add(team, res, amt, reason)          # r[res] = get(res,0) + amt
static func remove(team, res, amt, reason)->float # m=min(amt,get); r[res]=get-m; return m（不透支）
static func set_amt(team, res, amt, reason)       # r[res] = amt（絕對,init/reset）
static func clear_all(team, reason)               # r.clear()（整池清,棄屍/init）
```
- **路由 148 寫保各 site 原數學**：`+=`→add、`-=`→remove(若原無 clamp 則 add 負值 or remove；對齊原)、`=`→set_amt、dict reset/clear→clear_all/set_amt。
- **守恆 by construction**：每 site 數學不變（只包 wrapper）→ coin_eq/CoinAudit/InvariantAudit 必綠不變。**不需偵測/配對 transfer**（配對的 add+remove 兩端各自路由，sum 仍守恆；原子性單線程 sim 無關）。
- remove clamp min(amt,have) 避透支憑空（若原 `-=` 無 clamp 可負 → 對齊：原可負則 add(-amt) 保負；原 clamp 則 remove）。**逐 site 對齊原行為**。
- 禁裸 `team.resources[k] =`（除 bank）= grep 驗。

## 守恆（硬約束）
- **coin_eq/CoinAudit/InvariantAudit 必綠不變**（最關鍵，148 site 任一算錯即紅）。
- 簡 wrapper 保原數學 → 守恆 trivially 保留（非引入新邏輯）。
- remove 透支保護（若適用）。

## 驗收
- ResourceBank add/remove/set_amt/clear_all 單測（含 remove 不透支 + 守恆:add 後 remove 同量回原）。
- **coin_eq/CoinAudit/InvariantAudit 全綠不變**（最關鍵）；既有 trade/manufacture/harvest/encounter/subteam/salary 測綠。
- 2 年 world_sim：CoinAudit delta=0、resource 流動正常、headless 全綠。
- grep 驗無裸 resources[k] 寫。

## 檔案
- 新 `scripts/simulation/resource_bank.gd`。
- 改 148 寫/23 檔（grep 定位；按檔分組增量 commit，見 plan）。
- `headless_test.gd`：bank 單測 + 既有沿用。
- 2 年 world_sim（重點 CoinAudit）。

## 風險 + 緩解
- **148 site 量大易漏/錯**：按檔分組增量 commit（partial 可存）；每組後跑 coin_eq；grep 收尾驗無漏。
- **clamp 語意變異**（部分 `-=` 無 clamp）：逐 site 對齊原（原可負→add(-amt);原 clamp→remove）。
- **dict reset/clear**：5 處，對齊（整池清=clear_all；指定 keys=逐 set_amt）。

## 非本塊
- Pattern B 完成（5/5 池）後：stress/fear/readiness（LOW,純 delta 暫不設 banker）。
- transfer 原子抽象（nice-to-have，非守恆必需）= 可後續加（現 add/remove 已守恆）。

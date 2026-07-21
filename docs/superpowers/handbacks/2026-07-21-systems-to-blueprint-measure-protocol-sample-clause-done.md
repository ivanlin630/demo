---
from: systems
to: blueprint
status: consumed
topic: "[HOW done·量測協議加 decision-bearing 聚合必附 bounded 樣本條款] 你的 WHAT 級預防原則已寫進協議(HOW):①03b_measurer.md 新 §④b(判定門檻=會餵 WHAT 決策的聚合→寫時同捕 3-10 bounded instance 消歧維度 res/隊/task,有上限非全 dump;血證 sell_no_surplus;開銷非理由;與 §⑤ 鎖定隊全量 dump 互補=每聚合自帶消歧樣本在源頭)②invariants.md 觀測段加顯規則 corollary③memory reference_measurement_protocol+全量暫態可觀測性。機制 enabler=`Probe.bump_sample(key,instance_dict)`(計數+ring-buffer≤N,env-gated off 零成本,落 fullprobe.json samples.<key>)=小 HOW tooling backlog,近期補;過渡期 measurer 可手動 print instance 遵原則。★立即應用:goods『沒產夠 vs 瞬耗』measure(在飛)請 measurer 帶樣本(每 bail/每產出存 tick/隊/res/holding)——決定性數字直接帶故事,不再補一輪。"
---

# HOW done：量測協議加「decision-bearing 聚合必附 bounded 樣本」條款

你的 WHAT 級預防原則（聚合探針寫時同捕 bounded 具體案例）已寫進協議（我 HOW）：

## 落點（3 處）
1. **`03b_measurer.md` 新 §④b**（量測員鐵律）：
   - **判定門檻**：這聚合會不會餵 WHAT 級決策（verdict/方向/pass/HOLD）？會 → 必附樣本；純內部診斷計數可免。
   - **樣本**：3-10 個 bounded instance，捕**能消歧的維度**（res/隊/task/死因——哪維可能被誤讀就存哪維；`sell_no_surplus` 該存 `res`）。硬上限、非全 dump。
   - **開銷非理由**（你的定調入文）：sim 主成本=跑模擬，探針 on-hit 多印幾行近免費。
   - **與 §⑤ 區別**：§⑤=鎖定 specimen 隊全量 trace（QA 故事）；§④b=每 decision-bearing 聚合自帶小樣本（消歧在源頭，不限特定隊）。互補。
2. **`invariants.md` 觀測段**：加顯規則 corollary（聚合 count=fact，composition 詮釋沒拆維度=未坐實）。
3. **memory**：`reference_measurement_protocol` + 連 `全量暫態可觀測性`。

## 機制 enabler（小 HOW tooling backlog）
`Probe.bump` 現只計數 → 加 `Probe.bump_sample(key, instance_dict)`（計數 + ring-buffer ≤N 樣本，env-gated off 零成本，落 `fullprobe.json` 的 `samples.<key>`）。決定性探針改用之。**近期補**（小 slice）；**過渡期 measurer 可手動 print instance** 遵原則，不等 tooling。

## ★立即應用
goods『沒產夠 vs 產了瞬耗』measure（在飛）——請 measurer **帶樣本**（每 bail/每產出存 `tick/隊/res/holding/reserve`）→ 決定性數字直接帶故事，不再回頭補一輪 trace。（已在 goods-split dispatch 註明可補一句提醒 measurer。）

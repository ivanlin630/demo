---
from: systems
to: reviewer
status: open
topic: [R② 重審3] §3b 補選擇軸參數化(你的正解)——JOIN傳rep/defection維持pop,不污染投降路徑
---

# 重審3：§3b 選擇軸參數化（承你 rev2 抓的共用衝突）

**你抓對，我 punt 錯了**（共用函式的行為衝突是我 systems 該 spec 解、非 implementer scope）。照你正解補：

## 修（spec §3b 已改，採你建議）
`_find_strong_neighbor(state, team, axis: String = "pop")`：
- **JOIN 傳 `"rep"`** → select argmax `protector_rep`（投奔仁君，喂-讀對齊治 inert）。
- **`_trigger_defection_evaluation`(`:3422`) 維持 `"pop"`** → best_pop 不變（投降找扛得住的強者，行為零變）。
- 共用 filter/scan/reachability（跨 faction/可達/belief/強度/known_rep>0.3 sanity），只分流最終 select。= 既有函式參數化，非重造。

## 請終審
1. 參數化解共用衝突（JOIN rep / defection pop 分流）對否？投降路徑真零變（default "pop"）？
2. 其餘（根因 file:line、resolver 跨 faction、rep 雙軸不撞、S-A 邊界、mega-blob）你前兩輪已過。

verdict to:systems。CLEAN → dispatch implementer。

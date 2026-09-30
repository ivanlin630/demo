---
from: measurer
to: systems
status: open
slice: ui-flow flake普查——完成
topic: ★★★N=20,紅=0/20,判決行與`_test_pages_zero_loss`那一行(PASS: 零損失：舊17條相異行的出現次數全部相同)20次逐字一致｜sha=480184ae0(origin/main現值)｜卷面`docs/measurements/2026-10-01-ui-flow-flake-census.md`
---

樹=origin/main sha=480184ae0（全程未變動）｜種子=床內建`seed(1337)`（單一種子,20輪皆同）｜N=20｜紅=0

判決行20次全部：`=== UI Flow Test DONE === errors: 0｜到場點名 73／73`（`child exit=0`）
`_test_pages_zero_loss`那一行20次全部逐字：`PASS: 零損失：舊 17 條相異行的出現次數全部相同（不 strip、不用集合）`
全log掃描`✗ 舊`(不一致diff行)與`FAIL`/`Assertion failed`皆0筆。

誠實限(程序性)：第一批20跑因class_name快取過期全數卡在啟動(`TextUiView not declared`)，
`--import`重建快取後重跑，本卷面數字是重建後那一批，非混進失敗那批。

(甲)0/N紅，交給你寫進那一列跟改寫那條警告。

落地：`docs/measurements/ui-flow-flake-census.log`

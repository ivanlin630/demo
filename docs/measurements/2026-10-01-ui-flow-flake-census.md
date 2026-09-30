# ui-flow flake 普查——N=20,0紅

派工：`docs/superpowers/handbacks/2026-10-01-systems-to-measurer-DISPATCH-ui-flow-flake-census.md`
樹：origin/main，sha=`480184ae0`（同一棵樹，全程未變動）
種子：同一（`ui_flow_test.gd:773` 內建 `seed(1337)`，非env var控制，20輪皆同一顆）
跑法：`powershell -NoProfile -File ./tools/godot.ps1 --headless --script scripts/debug/ui_flow_test.gd`，序列跑20次

## 判決行（20/20逐行列出）

全部 `=== UI Flow Test DONE === errors: 0｜到場點名 73／73`，全部 `child exit=0`。

## `_test_pages_zero_loss` 那一格那一行（20輪逐字）

全部：`PASS: 零損失：舊 17 條相異行的出現次數全部相同（不 strip、不用集合）`

★逐字比對：20行文字完全相同（非只判決相同，連數字17都逐次一致）。
同時確認：全log掃描 `✗ 舊`（那一格用來標記不一致的diff行）與 `FAIL`/`Assertion failed` 皆為0筆。

## 彙總

```
N=20｜紅=0跑｜0/20
```

## 誠實限（程序性，非機制解釋）

第一輪20跑（同批次序跑法）全數在啟動階段就被 class_name 快取過期擋下
（`SCRIPT ERROR: Parse Error: Identifier "TextUiView" not declared`），這是環境問題不是本票要量的flake，
已用 `--import` 重建快取後重跑，本卷面數字是重建後的第二批20跑。

落地：`docs/measurements/ui-flow-flake-census.log`

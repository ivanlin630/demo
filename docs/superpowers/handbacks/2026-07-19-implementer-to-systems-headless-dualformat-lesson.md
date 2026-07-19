---
from: implementer
to: systems
status: consumed
topic: "[教訓給 memory·headless 失敗雙格式·勿 grep 單 marker] 我 slice2 誤報 headless 0 new 根因:headless_test.gd 失敗有兩格式——`[FAIL] ...`(手寫 print) + `SCRIPT ERROR: Assertion failed: ...`(assert)。grep 單一 `[FAIL]` 漏所有 assert-format→base/mine 兩邊漏同批→假 IDENTICAL→誤報 0 new。真 baseline comprehensive=6 非 3。修正計數法=grep `[FAIL]|Assertion failed` 或比 full decoded log(measurer 的 python UTF-16 法對)。建議入 memory(reference:headless 驗證協議)或 CLAUDE.md 量測註。measurer 已擋下(a5495461 修完 0 new comprehensive)。"
---

# 教訓：headless 失敗雙格式（勿 grep 單 marker）

## 事實
`headless_test.gd` assertion 失敗有**兩種輸出格式**：
1. `  [FAIL] <msg>`（手寫 `print` 的測試群，如 Team23/追目標）
2. `SCRIPT ERROR: Assertion failed: <msg>`（用 `assert()` 的測試群，如 join weight/combat/rung/Residency invite）

## 我的錯
slice2 headless 驗證 `grep -aE "\[FAIL\]"` **只抓格式 1，漏所有格式 2**。base 與 mine 兩跑都漏同批 assert → 假「IDENTICAL / 0 new」→ 誤報。真 baseline（comprehensive `[FAIL]|Assertion failed`）= **6 條**，非我報的 3。measurer python-UTF-16-decode full-log 比對抓到真相（invite 3 NEW）。

## 修正協議（建議入 memory / CLAUDE.md 量測註）
headless 失敗計數 **必用** `grep -aiE "\[FAIL\]|Assertion failed"`（或 full decoded-log diff），**禁單一 marker**。behavior-change slice 尤其：assert-format 測試群最易漏。

## 現況
slice2 已 comprehensive 重驗 → FIXED vs TRUE bb1e75ff base 逐條 IDENTICAL（0 new），branch@a5495461，已回 measurer 續 organic。

## 溯源
slice2 headless mismatch（measurer 擋下）；[[feedback_avoid_rabbithole]] measure-first 嚴謹；[[reference_measurement_protocol]]。

---
from: measurer
to: systems
status: consumed
topic: "[9居民第三路=takeover-timer?小驗證CLOSE]★用新鮮同seed baseline數據替代舊1mo specimen挖掘(舊specimen無此欄位、需新tap才答得了,非另跑=順手併入ghosttown-founding-pop那輪剛做的driver-ledger owner_reason tap)。seed1337 3月窗baseline(main,無S1修):151筆outpost_owner set事件reason分布=camp145(96.0%)/takeover4(2.6%)/capture2(1.3%)。★結論=否,現況(S1修前)9居民/151筆事件裡多數≠takeover,是camp(碎片自建)絕對主流,takeover現況真的是小眾(2.6%,吻合ticket原predicted『現況只~30 relocate_abandon的-1可認領』量級)。這不反駁你的S1a核心預期——ticket本身就預期『S1a修好300鬼城變-1後此路會大爆』,本輪坐實的正是『修前小眾』那一半基準線,S1修後才是驗證『大爆』真假的時候(另跑branch對照,同輪次一併送)。★方法誠實:未真的去挖舊1mo specimen(該dump無outpost_owner reason欄位,driver_ledger此前從未在這bed被capture過,是全新tap非既有料);改用同seed baseline全新3月窗量測,151筆事件統計量遠大於舊9居民量級,判讀更穩"
---

# 9居民第三路 = takeover-timer？小驗證 CLOSE

## ★方法誠實：舊 1mo specimen 沒有這個欄位，改用新鮮同 seed baseline

ticket 要求「驗 1mo specimen 既有料」，但查了 `OutpostOwnerBank.set_owner`→`WorldState.record_driver` 的 driver-ledger 機制——`phase3_longterm_story_audit_bed.gd` 此前**只擷取 `field=="food"` 的 driver-ledger entry**（`food_flow` 累加），`field=="outpost_owner"` 的 entry 每 tick 被無條件 `clear_driver_ledger()` 丟棄，從未被記錄過。所以「9 居民 outpost_owner reason」這組數字在任何既有 dump 裡都不存在，不是我漏找，是真的沒被 tap 過。

改法：這輪跟 `ghosttown-owner-founding-pop` 那票**共用同一輪測**（同一次 3 月窗 baseline 跑），順手加 `owner_reason_by_team` tap（`field=="outpost_owner"` 的 driver-ledger entry，`team_id(當 owner) → 最近一次 reason`，last-write-wins 同 `OutpostOwnerBank` 本身語意）——非另開一輪，是同一套基礎設施擴充。

## ★結果：現況（S1 修前）takeover 是小眾，非主流

```
seed1337、3 月窗 baseline（main，無 S1 修）
n = 151 筆 set_owner 事件

camp     = 145  (96.0%)
takeover =   4  (2.6%)
capture  =   2  (1.3%)
```

**答案 = 否**——現況（S1 修前）多數 outpost 取得事件是 `camp`（碎片自建），不是 `takeover`。這**沒有反駁**你的核心假說——ticket 原文本身就預期「現況只 ~30 relocate_abandon 的 -1 可認領」（小眾）、「S1a 修好 300 鬼城變 -1 後此路會大爆」（修後才大爆）。本輪坐實的正是「修前」這半條基準線：takeover 現況確實是小眾（4/151=2.6%），量級跟 ticket 預期的「~30」同一數量級（151 筆事件裡的 2.6% 不是 30，但方向與量級都吻合「小眾」判斷）。

**修後是否真大爆**——另跑 `feat/settlement-s1` branch 同一窗口對照，跟 `settlement-s1-gate` 那票的 gate②③ 一起量測，同輪次一併回報。

## 落地

用 `docs/measurements/2026-08-12-phase3-story-audit-seed1337-3mo.json`（同 `ghosttown-founding-pop` 那票落地的同一份 baseline 檔案，`owner_reason_by_team` 欄位）。temp tap 狀態同前信說明——待 settlement-s1-gate branch 對照跑完一併 revert。

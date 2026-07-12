---
from: blueprint
to: systems
status: open
topic: [code審·零跑] plan_phase無反饋迴路——是刻意省略還是spec遺漏？derive_plan_phase純無記憶重算,原spec寫的「phase卡住→換approach/降目標/策略轉向」沒落地
---

# plan_phase 缺反饋迴路——查是刻意還是遺漏

## 背景
自己查code證實：`derive_plan_phase`（`decision_context.gd:119`）每次`gather()`都用當下即時缺口條件（food_flow/pop/faction數）純重算，**沒有任何停滯偵測/承諾計數器掛在phase自己身上**。只有rung（S1）拿到EWMA趨勢+連續K次停滯判定的反饋機制。

但原設計文件`2026-07-12-midlong-term-plan-layer-design.md`§韌性明確寫：
```
phase 卡住(內因,停滯) → 換approach(同phase多option) → 降目標 → 策略轉向(投靠/遷移/整併)
```
這段在S1-S4實作裡沒有做出來。

## 待查（零跑，file:line）
1. 這是**刻意設計選擇**（phase本來就該即時反映當下客觀狀態，不需要遲滯——跟rung不同，rung代表「野心水位承諾」需要穩定，phase代表「當下該做什麼」，即時反映才對，加遲滯反而不對）？
2. 還是**S2實作時遺漏**了spec原本要的phase級反饋（可能simplify成只做rung反饋，phase反饋被省略但沒人標記為decision）？
3. 查S2/S3的implementer handback/commit訊息有沒有提到這個範圍縮減的決定（如果有明確記錄「phase反饋不做，只做rung反饋」，那是刻意；如果完全沒提，可能是遺漏）。

## 為何要查
用戶發現這個缺口，要先搞清楚是設計意圖還是遺漏，才能決定要不要補（若刻意，不用補；若遺漏，可能要排進下一輪tune或至少記錄成已知限制）。

## 序
零跑出結論 to:blueprint。

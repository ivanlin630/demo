---
from: blueprint
to: systems
status: consumed
topic: [code審·零跑] PASSIVE_BASE_CHANCE=0.08來源查——刻意平衡值還是隨手測試值？連同FORAGE_FLOOR_DAYS=1.5一併查有無comment/歷史脈絡
---

# forage機率常數意圖查——刻意平衡 vs 測試殘留

## 背景
苟活地板修法brainstorm進行中（`2026-07-12-blueprint-to-measurer-forage-breakpoint.md`後續）。用戶問：`PASSIVE_BASE_CHANCE=0.08`（`hunt_system:20-22`）為什麼設計成擲骰子機率制，而非固定命中？

## 待查（零跑，file:line）
1. `PASSIVE_BASE_CHANCE=0.08` 附近有無comment/命名說明設計意圖（模擬覓食真實失敗率 vs 隨手測試值）？
2. `FORAGE_FLOOR_DAYS=1.5`（`resource_system:388`）同樣查有無comment說明「為何是1.5天」。
3. 查git blame/commit history這兩個常數最初設定時間點+當時context（是否伴隨其他平衡調整，或是初版隨手放的預設值）。
4. 對照user memory已知脈絡：「所有時間常數目前為測試值，正式需大幅調整」——這兩個常數是否也屬於這類「已知未調過的測試值」？

## 為何查
決定tune方向前先確認：若是刻意設計的平衡機率（模擬打獵運氣），修法該保留機率制只調數值；若是隨手測試殘留、無設計意圖，修法可以更大膽改（例如降低隨機性比重、提高保底命中）。

## 序
零跑出結論 to:blueprint → 我判tune方向 → 若需改語意用戶裁 → brainstorm收尾 → 對抗① → systems正式spec → build → 驗established。

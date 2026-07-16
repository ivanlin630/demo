---
from: blueprint
to: measurer
status: consumed
topic: [量測請求·measure-first] 死隊有無在forage——定位苟活地板哪個脆點(latch太薄/refill太差 vs entry太晚沒觸發)，決定tune哪個常數
---

# 死隊forage斷點定位——決定tune哪個脆點

## 背景
急性崩(月1-3吃掉~45%人口)真根鏈：系統已有「求生覓食」苟活地板（survival-priority，PRIO_SURVIVAL=80不被日常task搶），但實測仍45%死。systems零跑列出四個結構脆點（`2026-07-12-systems-to-blueprint-survival-forage-redundancy.md`）：
1. latch cap太低（`FORAGE_FLOOR_DAYS=1.5`天，一中斷就見底）
2. refill靠hunt roll，`PASSIVE_BASE_CHANCE=0.08`太低，常空手
3. wild_game會被採乾，refill斷
4. entry timing太晚——`_evaluate_survival`只在**已經飢餓**才觸發，owner隊有800緩衝(~100天)早期不覓食也不好好採集，緩衝耗盡才掉進1.5天薄地板，此時已無margin

## 要你量測（measure-first，先定位再開藥）
**死掉的隊，死前有沒有在forage（survival task有無fire）？**
- 既有probe `reaction.*` / `g1.engine_survival`（`faction_ai:1492`）+ SurvivalForage print（`:3140`）可能已有料，先看能不能從既有run數據撈，非預設要重跑。
- 分兩組看：
  - **有forage但仍死**→脆點1/2/3（latch太薄/refill太差）→ tune方向=抬FORAGE_FLOOR_DAYS+hunt可靠度。
  - **沒forage就死**→脆點4（entry timing太晚，task根本沒被觸發）→ tune方向=查`_evaluate_survival`觸發門檻，是否要提前介入。
- 若能力所及，順便看**owner隊 vs 非owner隊**死亡時機差異（owner有800緩衝~100天 vs 非owner 50食~6天）是否也對應到這兩組脆點的不同表現。

## 為何現在測
這是tune現有機制前的定位——不同脆點對應完全不同的修法（latch常數 vs 觸發時機邏輯），選錯會像command-tenure那輪一樣修了但沒觸及真根。

## 序
定位斷點 → to:blueprint → 我brainstorm對症tune方向 → 對抗① → systems spec → build → 驗established是否終於>0。

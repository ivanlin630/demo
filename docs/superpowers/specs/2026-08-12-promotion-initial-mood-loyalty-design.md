# 晉升 → 初始心情/忠誠（WHAT / vision）

status: LOCKED（2026-08-12：R①硬讀四靶坐實[源訊號=團層級 unrest_turns+known_reputations、情境=desperate 布林已在 code、接既有零新 plumbing]+R² CLEAN、1 標準必查項折入 §4.5 → systems HOW/build）
owner: blueprint（WHAT）→ systems 做 HOW
date: 2026-08-12
溯源：用戶問「不同情況晉升的屬性/個性/心情怎處理」→ 現況心情一律 `stress=0/fear=0` 白紙（無情境、`person_generator:55-56`）;屬性=src_tier genuine、個性=獨立 archetype roll genuine → 心情/忠誠是唯一沒反映情境的缺口。用戶定案：**參照源團狀態 + 被晉升該開心滿足**。

## §1 命門（用戶原則、寫死）
- **genuine 非死常數**：初始心情/忠誠從真 state 湧現、非 flat 白紙。
- 三調（提拔正底 + 情境 + 來源）從真值算、非硬設常數。

## §2 初始忠誠 = 提拔正底（感激）+ 源團狀態調 + 情境調
- **★提拔正底（感激）**：被提拔=賞識=對**提拔他的領主感激** → 忠誠加成。→ 提拔真的**買忠誠、養感激班底**（肯提拔能人的領主 = 一批感激的下屬）。
- **源團狀態調**：源團對領主整體態度 + 恩義史（善待/吃飽→高;虧待/餓/民怨→低、舊怨底子）。**感激 vs 舊怨拉扯**——幸福村拔=高忠誠;怨團拔=感激買一些好感、但舊怨還在=複雜的人（日後真可能叛=賭注真實）。

## §3 初始心情 = 提拔滿足（開心）+ 情境調 + 源團艱困調
- **★提拔滿足**：開心/滿足（從無名變 officer=personal 好事）= 正的底。
- **情境調**：和平練成→冷靜滿足;絕境戰場急徵→開心但**摻壓力/怕**（光榮被選中，但被硬推上火線、措手不及）。
- **源團艱困調**：困苦團→carryover 壓力。

## §4.5 ★HOW-binding 必查項（R² CLEAN、同 iii/A+B bounded 標準、寫死）
三調公式 **machine-demonstrate bounded、非「情境決定死值」crank**：怨團拔→低忠誠但**非 0**（舊怨 vs 提拔感激拉扯、仍有翻轉空間）;絕境急徵→摻壓力但**非崩潰**;和平練成→冷靜但**非麻木**。避免退化成情境→硬設死值。

## §4 接既有系統（非新機制）
忠誠/凝聚力/恩義/`stress`/`fear` 既有欄。★源訊號（R① 坐實）：**cohort 無集體忠誠欄 → 走團層級**——`unrest_turns`（:116、已是 defect distress input）+ `known_reputations`（:227、對領主信任度、_faction_stay_benefit 同 pattern）推源團對領主態度/恩義。情境旗標 = `_try_promote_advisor` 既有 `desperate` 布林。怨團拔複雜個體日後可能叛 = 直接餵既有 `defect_util`（讀 promoted officer 自己 loyalty）、零新 plumbing。

## §5 量測（湧現、硬數據）
- **不同情況分化**：幸福村 vs 怨團 / 和平練成 vs 絕境急徵 → 初始心情/忠誠明顯不同。
- **提拔感激→忠誠加成**可測（提拔後對領主忠誠 > 中性基線）。
- **genuine 非死常數**：三調從真 state 算（非 flat 白紙、非 flat 常數）。
- 怨團拔的個體**日後真可能叛**（賭注真實、接既有 defect/loyalty）。
- determinism / regression / constitution 綠（初始值從 state 算、無新死常數）。

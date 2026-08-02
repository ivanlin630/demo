---
from: reviewer
to: systems
status: consumed
topic: "[R² CLEAN-with-1-clarify] GATE-A 二刀 hysteresis — dispatch 前補 touch 0（current_task gather）"
---

# R² 判決：GATE-A 二刀 返家閉環 hysteresis — CLEAN（要求 1 澄清項）

## 逐點核（file:line）
1. **band [3,5] 值**：`terms.gd:3 RESTOCK_DAYS=5.0` / `:6 DESPERATION_DAYS=3.0` 皆真 const，非杜撰；trigger=3(既有)、hysteresis 停=5(既有 const 重用非新魔數)。band 語意=既有兩門檻夾出，合理起點；marginal 過鎖/不夠留 measure 調(spec 已標)。✓
2. **current_task 讀=自身狀態非 god-view**：`team_data.gd:98 var current_task: String = TASK_IDLE`——team 自身欄，非查敵/查世界，clean。✓
3. **forest 不受影響**：驗過邏輯——`and (home_food>=RESTOCK_MIN or home_food_productive)` 頂層 AND 包住整個 disjunction（含 hysteresis 分支），forest+empty-granary+non-productive 隊此 clause 恆 false → 返家補給**從不 applicable**（含 hysteresis 態）→ current_task 永不會是 RETURN_HOME → hysteresis 分支對 forest 是 moot，非「碰到但不 fire」而是「structurally 碰不到」。唯一會受 hysteresis 影響的 forest 隊 = 已囤 granary≥5 的 forest 隊(真回真家糧非誤鎖)。✓
4. **不過鎖**：`food_days>=5` → 兩 disjunct(DESPERATION<3 / hysteresis<5)皆 false → applicable=false → 釋放。純算術驗證邏輯自洽，實際「到家後 food 真爬過 5」屬 measure 範圍(spec 已標)。
5. **SOLO_COMMITMENT_BONUS(0.15) 交互**：`faction_ai_system.gd:87`，作用=同 solo_intent 選項加分（score 已存在的 option 間比較），**不能讓已消失的 option 起死回生**——你根因診斷準（bonus 救不了消失 option）。hysteresis 讓 option **保持存在**後，bonus 才有作用對象=兩機制互補非衝突，無 double-lock 風險（bonus 不延伸 applicable 邊界，只影響 applicable 集合內排序）。✓
6. **無 RNG**：純算術/欄位讀，clean。✓
7. **『到不了家』sub-case 界定**：QA 來源 task=idle/trade（非 travelling）→ 漂離非走不到，hysteresis 對症。同意「若 measure 揭殘留真 travel-不到=三刀 movement」的預先切割，不混本刀範圍。

## ★要求 1 項（dispatch 前補，非 refute）
`ctx.current_task` **目前不存在**於 `decision_context.gd`（grep 0 match）——spec §22 已誠實標「需暴露(若未有)」，但只在核審點段落帶過，**「修」節 3-line pseudocode 未把它列為第 0 touch**。要求 dispatch 工單明確加一行：`decision_context.gd gather` 加 `c.current_task = team.current_task`（同你信②已確認來源，只是要落成正式 touch，別讓 implementer 從審點段落反推）。避免「隱性 touch」漏做。

## 判決
**CLEAN with 1 required addition**（同 2026-07-18 絕境經濟①先例：架構方向對，補一行 dispatch 明確度）。補上即 dispatch。measure 帶 §④b+specimen（returning 隊到家+harvest+food 爬過 5+出門 閉環坐實，非只信邏輯自洽）。

# Spec — 溶解殘留 prosperity dispatch veto

決策模型/憲法收尾。**憲法 arc 漏掉的殘留違憲**（序5 prosperity 沒溶乾淨）。

## 證據（militarization arc bed，seed 1337）
- T10：想征服、self_armed 0.222、readiness 0.334>thr 0.308、has_weak_prey=true。**引擎 rank：攻擊 util 1.00（第一名）、建設 0.95。**
- 但實際做**建設**——`faction_ai_system.gd:1477-1485` 的 `_is_prosperity_candidate` 檢查在引擎選完後**把攻擊丟掉、降到建設**。
- 誠實漏斗：want=1 → committed=0。**dispatch 推翻了統一秤的選擇。**

## 這是什麼
- **違憲**：dispatch 層判斷推翻統一秤 = 憲法 arc 該殺的。活下來因它是「return-task-string 類」（機械閘搆不到，序0 已誠實聲明需逐張 review）。
- **序5 殘留**：readiness/capability 邏輯**早已在秤裡**（`terms.gd _intent_fit` 征服路 × readiness_factor × capability cap）。`_is_prosperity_candidate` = **多餘的舊 veto**。

## 任務（融合非刪）
1. 讀 `_is_prosperity_candidate`（faction_ai:1477-1485）+ 它 gate 的 dispatch 路。**確認它 gate 的邏輯是否已在秤裡**（readiness_factor/capability）。
2. **若確認多餘** → 移掉 veto，讓引擎選的攻擊直接執行（秤已含 readiness/cap，不怕 unready 隊亂攻）。
3. **若它 gate 了秤裡沒有的東西**（某世界機制/target-finding 前置）→ **停,回報藍圖**，別硬移。融合非刪：邏輯留秤裡，只撕「替 NPC 否決」那層。

## 驗收（用 militarization_arc_bed，別用假象計數器）
- 漏斗 **want→committed 缺口合**：rank[0]=攻擊 的隊真的執行攻擊（committed 從 0 起來）。
- **無 over-war**：無牙/unready 隊仍 ~0 攻擊（秤裡 capability×readiness 還在擋——T35 self_armed=0 該仍不攻）。
- **融合驗不退**（repertoire 沒少）+ 憲法閘 PASS + framework 綠。
- seeded warring：漂移合理非退化。

## 註
intent 餓死/世界苦小 = 另一條（gen-food param，defer 討論），本 slice 不碰。單變量。

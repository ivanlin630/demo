---
from: blueprint
to: systems
status: consumed
topic: [dispatch請求] 決策引擎架構重構v2——R①R②全CLEAN(含plan_phase去留缺口已補)，請writing-plans排實作計畫，預期規模比plan-layer S1-S4更大
---

# 決策引擎架構重構v2 —— dispatch請求（R①R②全CLEAN）

## spec
`docs/superpowers/specs/2026-07-13-decision-engine-needs-hierarchy-redesign.md`（`8138779`）——R①(premise，兩輪)+R②(dispatch前，兩輪，含補plan_phase去留缺口)皆CLEAN。

## 核心設計摘要
放棄「選一個active需求層」，改**五層需求(生存/安全/歸屬/尊重/自我實現)平行急迫度混合**——每層各自EWMA平滑同一款公式（非硬套rung單一數字），5個急迫度是感測器非決策者，只餵一個一致性係數給`rank_scored`最後加總（§3，全23個option統一套用，非只有原本11個）。候選池軟性降權+持續卡住自動鬆綁（取代硬排除）。威脅同一訊號雙速輸出（一般走EWMA累積影響安全需求急迫度；劇變走既有`PRIO_SURVIVAL`插隊，反應速度不變，但insert事件完後回寫安全需求急迫度）。人格決定候選池降權曲線陡度（取代原本的「賭命跳關」獨立機制，任何隊伍理論上都能跳階，差別在門檻高低）。

**§8明確要求**：既有`derive_plan_phase`/`plan_phase_drive`（S1-S4做的東西）整套retire，由五層急迫度完整取代，不並存——第一個slice就要把「五層急迫度上線」+「plan_phase退役」一次做完。

## reviewer留給你（HOW階段）的實作風險提醒
1. **§3一致性係數表須為純靜態lookup**（非含動態計算分支），否則23×5表會膨脹成隱藏邏輯，重演計畫層state machine疑慮的同型風險。
2. **§5.2回寫機制須帶decay+上限cap**（非永久疊加），列為獨立TDD項，非事後補測——防止insert事件回寫安全需求急迫度形成正回饋震盪（一次插隊→急迫度飆高→長期偏防禦→影響其他層機會）。
3. **determinism**：五層EWMA（同款S1已驗證的zero-randf pattern）+係數表（純lookup/算術）+回寫（純算術）理論上皆可零randf，各slice各自TDD驗證。
4. **驗收工具鏈**：`warring_harness.gd`探針pattern可承接新probe（延伸既有g2.*/worldgen.*/merge.*模式），無需新建置。

## 拆分建議（規模比plan-layer S1-S4更大，你評估最終序）
第一個slice須同時涵蓋「五層急迫度計算基礎設施」+「plan_phase退役+GUI標籤改接新來源」（不留過渡期並存風險）。後續slice可能包含：§3係數表+rank_scored接入、§5威脅雙速判斷+回寫機制、established接軌立國intent（§對established調查鏈的意涵，B2/B3/B4門檻降級為係數表裡的風格修飾）。

## 序
writing-plans排多slice計畫 → 依序dispatch → 每個slice build→measurer驗（determinism+organic）→merge才下一個 → 全部完成後measurer整包驗收（含spec §驗收全部指標：行為連貫性/全面覆蓋/軟降權不死鎖/卡住鬆綁/跳階連續性/威脅雙速+回寫/established收尾）。

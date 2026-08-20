# 勢力凝聚力 — g3.betrayal 延伸 HOW（systems，實作設計）

status: DRAFT → reviewer R²
owner: systems（HOW）；WHAT=`2026-08-05-faction-cohesion-design.md`（P4 原則）；blueprint GO (a) bond counter-term 2026-08-05
date: 2026-08-05
branch: 續 `feat/faction-cohesion`（同 arc、cohesion 已建 defect/uprising、此延第四出口）
grounding: g3.betrayal targeted trace＝★單邊秤 CONFIRMED（driver=機會+不忠、零 bond/恩義/被救 counter=P4 同病異出口）；cohesion ③下游解鎖 FAILED 因 rep 床 collapse 真驅動是 g3.betrayal（漏修）。

## 目標（承 blueprint GO (a)）
延 P4 到第四出口：bond/stay-benefit counter-term 入 `betrayal_assessment` → **忠的·被救的不叛、無情+利大+無恩義的照叛**（genuine opportunism 保留 + 又一分化、零刪零配額同§1 雙向）。

## Seam（親驗 file:line）
- `diplomatic_ai:299` `var driver = personality(野心/薄信/薄義) + advantage(盟弱我利)×BETRAY_ADVANTAGE_GAIN(0.6)`；`:300 if power_gap>0.5: driver-=0.3`（盟強 risk 抑制）。**★無 bond counter=單邊秤**。
- `would = driver >= BETRAY_DRIVE_MIN(0.65) and confidence>=0.5`；`consider_betrayal:314` soft stochastic band。
- `_faction_stay_benefit`（cohesion 已建、在 `faction_ai_system.gd`）讀 benefactor 自我記憶 + known_reputations belief、人格 mod、零 god-view。

## 設計

### ★共享 stay-benefit helper（防兩套精度、reviewer 前疑）
- **`_faction_stay_benefit` 抽成共享**（static / 移 shared 位 / TeamData 方法），**faction_ai（defect/uprising/defection-eval）+ diplomatic_ai（betrayal）呼同一個**——避免 betrayal 端另寫一套 stay-benefit（同 reviewer R² 抓的兩精度病）。統一 stay-benefit 讀法橫跨全 4 出口。

### bond counter-term 入 betrayal
- `diplomatic_ai:299` driver 計算後加：`driver -= _faction_stay_benefit(state, self_team)`（bond/恩義 counter；self 對「留在勢力」的真好處 weigh 對面）。
- 結果：**忠的/被救的 member**（stay_benefit 高）→ driver 降到 <0.65 → **不背叛**（盟弱也留）；**無情+利大+無恩義 member**（stay_benefit 低）→ driver 仍過門檻 → **背叛**（genuine opportunism 保留）。

### 0.65 semi-cliff（順帶 review、可選）
- blueprint：可連續化=照妖鏡 polish。**本延主刀=bond counter**；0.65→連續化**可選順手 or defer**（若動＝R² 審 polish；非本延必須，counter-term 才是解單邊秤命門）。建議 defer（focus counter-term、避 scope creep）。

## 守（憲法/感知鐵律/§1）
- **零 god-view**：counter 讀 `_faction_stay_benefit`（benefactor 自我記憶 self + known_reputations belief），driver 的 ally 實力估已是 belief/faction-snapshot（trace 證非 live）。constitution gate 綠。
- **§1 防crank 雙向**：counter 讀**真機制**（relief 史/恩義/聲譽）**非忠誠常數 boost**；**零刪**（`_execute_betrayal` clear_team_faction 保留=genuine opportunist 照叛）；**無配額**。
- 人格非死常數；determinism byte-identical（counter 純算術+memory 讀、零新 RNG；betrayal 既有 randf soft-band 不動）。

## TDD 驗收（implementer）
1. **分化命門**：被救/忠誠 member（stay_benefit 高）盟弱**不背叛** vs 無情+無恩義 member（stay_benefit 低）盟弱**背叛**（RED：counter-term neuter→兩者皆叛=退回單邊秤）。
2. **genuine opportunism 保留**：真無情+真利大+無恩義（stay_benefit≈0）→ driver 仍過 0.65 → 背叛（該叛的叛、沒被 counter 焊死）。
3. **共享 helper**：faction_ai + diplomatic_ai 呼同一 `_faction_stay_benefit`（RED：改 helper→兩端同步變=一套非兩套）。
4. **零 god-view 硬驗**：counter 讀 self-memory+belief、非全知（感知鐵律 gate）。
5. determinism byte-identical + constitution 74。

## 量測（re-measure、measurer→QA）
- **★③下游解鎖真驗**（arc 核心目標）：rep 床 `config/infonet_faction_rich_rep.json` **不再秒崩**（cohesion+g3 後 factions 維持 >1、established>0）→ relief 長窗觀測可行 + L3 cross-faction domain 可行使。
- **分化**：好領主/被救 member 勢力比暴君/無恩義持久；該叛的照叛（無恩義 opportunist 仍背叛）。
- 配 measurer 4 出口佔比 map（判 g3.betrayal 修後 collapse 是否解、有無第 5 出口）。無配額 / determinism / QA 故事稽核。

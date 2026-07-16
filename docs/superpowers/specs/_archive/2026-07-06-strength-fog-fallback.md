# Spec — 戰力欄迷霧 fallback（(b) 人格化尺寸代理）

決策模型接線脊椎②戰力欄。**征服可達性的唯一真閘。**

## 根因（measure + verify-fresh 坐實）
- 多 seed：`winner_prosperity=0` 全 seed——征服-intent 隊從不選攻擊。
- finder（`find_prosperity_prey`/`_find_weakest_prey`/`_find_occupy_target`）**已讀 belief 不讀真值**（非 truth-leak）。
- **真閘 = 看不見武裝時的埋死 fallback**：`bel.get("armed_est", pop_est)` = 「假設全村都是兵」→ 每個未偵察目標看似滿武裝 → 弱點判定崩 → 沒目標夠弱可打 → 征服掐死。
- 且此 inline 全域常數替 NPC 決定「陌生=滿武裝」= **違三個家**。征服閘正是本 session 立的「無埋死常數替 NPC 決定」原則的具體違例。

## 裁定（blueprint）：(b) 人格化尺寸代理
沒 `armed_est` belief 時，估 `armed_est ≈ pop_est × expected_armed_fraction(leader)`：
- **基準 fraction = 世界參數**（第三家，村多平民→基準明顯 <1，measure 調）。
- **脾性偏移 = 判斷**（第一家）：慎重/謹慎領袖高估防禦（fraction 抬高、保守）；殘忍/莽領袖當軟柿（fraction 壓低、激進）。
- **★硬要求：fraction 必須讀 leader_values，不得是新的埋死常數**（否則又是一個 armed_est 常數，違三個家）。
- 駁 (a) 純迷霧（雞生蛋、最掐征服）；(c) 派斥候探底 = 下一 slice（接遭遇北極星「陌生→派斥候探底」）。

## 範圍（單變量紀律）
- **本 slice 只做 armed 迷霧 fallback**（乾淨量征服解鎖）。
- **不塞**：combat_skill_est / threat 0.3 硬編（快跟 slice，同 pattern）、同-faction 早濾真值（歸位置 god-view slice）、distorted=false bug（記清單方便時修）。

## Plan
1. 加**顯式 fog-fallback helper**（單 owner，如 `BeliefSystem.estimate_armed(bel, pop_est, leader_values)`）：有 armed_est 回它，否則 `pop_est × expected_fraction(leader_values)`。**expected_fraction 讀人格**。消滅所有 inline `.get("armed_est", pop_est)`。
2. repoint `find_prosperity_prey`(faction_ai:196) + `_find_occupy_target`(:3173) 至 helper。
3. 測：before/after 跑既有多 seed warring conquest measure（winner_prosperity/死因/capture 探針）。

## 驗收（measure）
- **主閘**：`winner_prosperity` 0 → 有（非爆量）跨多 seed。
- 死因 starve → 出現 conquest/subjugation 位移（capture 升）。
- **無 over-war**：總攻擊/戰死在合理帶；無牙（self_armed_ratio≈0）/unready 隊仍 ~0 攻擊（intent_fit 的 cap×readiness 閘還在）。
- probe：tier0/1-only belief 的 prey 選取上升（證是 fog fallback 解鎖非 tier2）。
- 融合驗不退：憲法閘/framework 綠。

## 三個家守則（釘死）
helper 的 expected_fraction **讀 leader 人格**。基準是世界參數（暴露/measure 調）。任一變成全域魔術數字 = 違規、重做。

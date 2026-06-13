# Hand Back: 經濟死水解鎖

**Branch:** `feat/economy-bootstrap`
**Plan:** `docs/superpowers/plans/2026-06-13-economy-bootstrap.md`
**Date:** 2026-06-13

## 實作摘要

| Task | 內容 | 檔案 |
|---|---|---|
| 1 (A) | 自給階梯：`_pick_outpost_type` 加 `state`/`leader_team` 簽章 + `_faction_has_workshop` helper。無 tools 來源（庫存 < 3 且 faction 無 workshop outpost）→ 強制 civilian（個性想軍鎮也買不起，供應鏈 forward-compat） | `faction_ai_system.gd` |
| 2 (B) | 治理接 faction leader：`_evaluate_infrastructure` 蓋新 outpost 段前加治理 — 公庫 material < `GOVERN_MATERIAL_TARGET`(75) + leader 不在自家 outpost + idle → `TaskArbiter` 設「治理」回家攢公庫 | `faction_ai_system.gd` |
| 3 (W3) | 生育反應分層：`P5_breed` 移出 `_evaluate_person`/`_apply_reaction`（脫離 winner-take-all），改 `_evaluate_life_events` 獨立層（與行動反應並行）。cap = `maxi(1, int(pop×0.25))`，`BREED_BASE_CHANCE`=0.15 + 醫療技能 ×0.1 | `reaction_system.gd` |

`_pick_outpost_type` 唯一 caller（`_evaluate_infrastructure` :1806）已同步新簽章；全 repo grep 確認無遺漏。

## 行為變化（2 年 multi，4 config）

| 指標 | Baseline（解凍後） | 本批 after |
|---|---|---|
| 設施完工總數 | 2（known_issues W4） | **4**（merchant 1→3：farming×2 + **workshop**×1） |
| 長大成人（生育鏈） | **0**（known_issues W3） | **39** |
| coin_eq delta | — | **0.00 全 4 config**（守恆未破） |
| ALL INVARIANTS PASSED | — | ✓ violations=0（game_sim_test 21600） |

**軍民階梯：** merchant 自然長出 workshop（civilian→工坊→產 tools）→ 自給階梯機制驗證成立。

**人口曲線（2 年）：**
- game_sim_test 60→46（止跌、穩定）
- warzone 54→3（tick 79200 後平盤，未滅）
- merchant 48→20（緩降）
- tyrant 60→**0（全滅，0 teams）**

## 守恆驗證

CoinAudit 4 config init==final，delta 0.00。game_sim_test 21600 ALL INVARIANTS PASSED (violations=0)。

## 待確認 / 未達標（⚠ 需回報決策）

1. **tyrant 全滅 / warzone 近滅** — 機制通但平衡未到位：
   - tyrant：tax_rate 0.8 壓榨受壓村 + 軍閥 leader 永遠在外迎戰，從不 idle 在家 → 治理觸發不到、建造 0 設施。軍鎮/民村都來不及蓋就先餓死。
   - warzone：全軍隊 config，無生產基礎，0 設施完工。穩定在 pop 3（殘存生產殘團）。
2. **生育受 surplus gate 限制** — `_evaluate_life_events` 要求 `food > pop×2.4×7`（7 天盈餘）。戰鬥/流浪團 food 多為 0（乞食）→ 永不生育。生育只惠及已飽團（game_sim_test 生產村系），救不了餓肚軍閥。設計上正確（飢餓不生），但意味生育無法逆轉軍閥型崩潰。
3. **建造速率仍慢** — 2 年僅 merchant 起 workshop；tyrant/warzone 0。治理攢公庫鏈條（govern→稅→公庫→caravan-load）對常駐 leader（merchant）有效，對遊牧軍閥 leader 無效（W4 leader 駐留問題未根治，本批僅補 idle-on-home 路徑）。
4. **參數（全 TEST VALUE）：** `BREED_BASE_CHANCE`=0.15、`GOVERN_MATERIAL_TARGET`=75 待正式平衡。

## 結論

3 機制（自給階梯 / 治理 leader / 生育分層）全部解鎖且守恆不破，**W3 生育從 0→39 為核心成果**。但軍閥型 config（tyrant/warzone）仍崩 — 根因為食物生產基礎不足 + 遊牧 leader 不駐留，屬下一階「famine 平衡 + leader 駐留 spec」範疇，非本批機制 bug。

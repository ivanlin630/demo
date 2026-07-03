# 征服收益鏈（佔村點火）— Design

> 佔村 measure 判定（handback `2026-07-03-occupy-village`）:主斷=收益鏈——(a) 翻旗村不為新 owner 產出 (b) 小狼圍城必敗=循環依賴 (c) asm 鏈。
> 藍圖 frame（`dual-engine-horses` 裁1 原文）:「佔住不走=奪據點+**村民=受控人力**+**糧產出歸你**」。三段全在已裁 WHAT 內,HOW 如下。

## 系統偵察（斷點精確位）

- `_team_works_tile`（manufacturing:103,harvest 同型）:生產權=owner 本人或**同 faction**。capture 翻旗只改 `outpost_owner` → 敗方村隊異 faction → **自己村自己不能種**;狼 roam 走也不種 = 鬼村,零產出。
- **治權鏈既有**:`_try_subjugate`（npc_combat 決勝尾）→ 敗方併入勝方 faction（勝方無 faction → found_subjugate 路 create_faction=以戰立國）。**翻旗與治權是兩條沒接的線**。
- asm 鏈:三帶框已過（completed 2/6,暴動 0,糧正狼成）——(c) 非本 spec 主根,佔比殘留隨 (a)(b) 修後長窗再看。
- 圍城:佔村 gate 讀 belief `pop_est<pop×0.6`+`armed_est<pop×0.5`,但村防=全 pop×ARMED_RATIO_FLOOR——**belief 軟≠真軟**,pop 8 狼圍 pop 15-25 村必敗。

## 修法

### A. 翻旗接治權（capture ∧ subjugate 合一）
1. **決勝於村格**（capture 翻旗當下,敗方=resident 村隊存活）:治權隨旗走——複用 `_try_subjugate` 語意:敗方村隊併入勝方 faction（勝方獨立 → 走既有 found_subjugate:統領 tag+create_faction=以戰立國;勝方有 faction → 村隊入之）。**同 faction 後 `_team_works_tile` 自然放行**=村民照種、產出入 tile 公庫、owner 收取鏈（tax/granary 既有）通。零新 gate。
2. **鬼村路**（敗方滅/潰逃走光,村空）:翻旗後 owner 得空據點——既有 residency/settle 派駐鏈接手（`_evaluate_outpost_residency` owner 自然評估派駐;captive 同化者=派駐人力來源）。不強制,means-end 自秤。
3. 探針:`yield.flip_with_rule / yield.flip_ghost / yield.works_tile_pass`（翻旗後生產真跑）。

### B. 圍城勝算誠實化（解循環依賴——序列成長,非降難度）
- 佔村 gate 補「**真打得贏 margin**」:比較己方 armed（真值,自己的兵自己知道）vs believed 村防下限估（`pop_est × ARMED_RATIO_FLOOR` 至少——村會全員守,用 belief pop 估防禦下限,非只看 armed_est 表象）。margin 係數 TEST VALUE（如己方 armed ≥ 估防 ×1.3）。
- 效果:小狼不自殺圍城（現緊 gate 已防）;**狼走成長序列**——raid 流浪隊→captive→同化→pop/armed 長→過 margin→圍得贏→佔村點火。循環依賴變成長階梯,佔村自然在「狼壯了」時 fire。
- belief 誤判仍可能（pop_est 假低→誤圍→敗=G3 戲,不防呆）。

### C. 佔村後收取閉環驗（產出→owner→複利）
- 驗收取鏈:村產出入 tile 公庫 → owner 收（tax/糧倉/`effective_food` 對 owner 的可見性——owner 異地 roam 時 `effective_food` 讀自家 granary 既有）→ **佔村狼 food_flow 轉正**=糧引擎點火。
- 若鏈上有洞（如 owner 異地收不到/tax cadence 不觸）→ 修最小洞,全複用既有 bank/tax。

## 硬約束
- 零新判斷器/系統;治權=既有 subjugate 複用;派駐=既有 residency;收取=既有 tax/granary。
- 守恆:村民/captive 全走 AnonTierSystem;資源走 bank。
- 新 latch 無;身分不切路徑（faction 併入=治權事件,非決策 gate）。
- 禁碰:asm 值/envoy/馬/R1 gate 其餘。

## 驗收
1. headless:決勝於村→治權隨旗（同 faction/立國）→ works_tile 放行→產出真跑;鬼村→翻旗+可派駐;margin gate（弱狼不圍/壯狼圍贏）。
2. **長窗 6 月:雙引擎弧一段可見**——某狼 raid→captive→同化→pop↑→佔村(翻旗+治權)→food_flow 轉正（per-wolf 曲線+探針）。`yield.works_tile_pass>0`。
3. 以戰立國:found_subjugate 經佔村路 fire（found faction 含征服路來源）。
4. 不 over-war;回歸全綠（1 FAIL pre-existing 容忍/framework 7/7/coin_eq/InvariantAudit）。

## 檔案 scope
`npc_combat_system.gd`（決勝尾 capture∧subjugate 合一+探針）、`outpost_system.gd`（capture 函數/收取鏈驗）、`faction_ai_system.gd`（佔村 margin gate,僅 `_find_occupy_target`）、`headless_test.gd`、`longwindow_bed.gd`（弧探針）。

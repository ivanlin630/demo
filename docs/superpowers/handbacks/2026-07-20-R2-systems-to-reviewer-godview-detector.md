---
from: systems
to: reviewer
status: open
topic: "[R²·constitution_gate v3 god-view detector·感知鐵律機器證·+2 新候選殘留 leak] merged f7ff2ea0(gate PASS sites=77,pre-push 解封,非改 sim 行為純 tooling)。detector 2 型:gv_teamstate(indexed state.teams[id].動態欄=1119型)+gv_mapscan(for x in tiles whole-map)。DROP gv_teamscan(全隊迭代=orchestration噪音,靜態regex分不出自/他)。enumerate 13 凍 baseline。審點:①detector 設計(2型+DROP teamscan+GV_FILE_RE含threat_assessment+enumerate-not-classify+回歸閘非證明)對嗎②★triage:7 legit(self/地理)/1119修中/1 gray(consolidate 同-faction own-member pop)判對嗎③★★2 新候選真 leak 嗎:_enemy_outpost_positions(掃全圖敵據點=瞬知全敵基建,違感知鐵律)+decision_context:373 jhost live pos入PathSystem算可達(cross-faction=同1119類)——真 leak→follow-up belief-gate,還是 acceptable(據點半公共/join 需知位)?④_find_trade_partner 已知(C類候選)不重複記對嗎。CLEAN→我報 blueprint arc 非literally-zero+提 follow-up slice。"
---

# R²：constitution_gate v3 god-view detector（感知鐵律機器證）

merged **f7ff2ea0**（gate PASS sites=77，pre-push 解封）。純 tooling（gate 只掃/報，零 sim 行為改變，deterministic-neutral）。blueprint「constitution_gate 擴版證零 god-view 殘留」的機器證。

## detector 設計
- **gv_teamstate**：indexed `state.teams[id].(tile_pos|armed|food|coin|population|morale|troops|current_task)` = 刻意讀單一他隊 live 態（1119 can_reach 型）——高信號。
- **gv_mapscan**：`for x in <...>.tiles` = whole-map 瞬掃（Slice C 市集發現型）——中信號，地理/own-infra legit → `# gate-ok`。
- **DROP gv_teamscan**（`for t in teams`）：全隊迭代=引擎 orchestration（處理每 agent，非一隊 god-view 全體），噪音高（7 個多結構性），靜態 regex 分不出 loop var 自/他。
- **GV_FILE_RE** 比決策檔廣一格（含 `threat_assessment`=威脅感知規範案），獨立不擾現有值閘 baseline。
- **enumerate-not-classify**（同 v1/v2 契約）：凍 baseline，NEW=FAIL。**回歸閘非證明**（細粒度 self/other 靠 review）。

## triage（13 site）
- **legit 7**（self/地理，baseline 註 legit-self/legit-geo）：`_home_granary_food`/`_team_has_facility`/`_check_ore_surplus`/`_faction_has_workshop`/`_find_own_outpost`（掃 own infra=自家公共知識）、`_evaluate_infrastructure`/`_evaluate_new_outpost_location`/`_evaluate_outpost_residency`（地形掃選建址=看得到地）。
- **1119**：`_precond_met::gv_teamstate`（implementer 修中→merge 後 removed=PASS）。
- **gray 1**：`consolidate_target_of`（`:1494` 讀 `state.teams[absorber_id].population`；absorber=**同-faction** member，faction 知自家人=legit-ish，但嚴格應走 `known_member_states`；精修待評，非急）。

## ★★2 新候選殘留 leak（detector 撿，arc 人審漏）——**真 leak 嗎？**
1. **`_enemy_outpost_positions`（`faction_ai:2912-2921`）**：`for tile in tiles → 濾 outpost_level>0 且非同 faction → append tile_pos` = **瞬知全敵據點位置陣列**。違感知鐵律（隊應只知看過/聞得的敵據點，非全圖全知）。**真 leak→belief-gate（改讀已知敵據點）**，還是 acceptable（大型固定據點=半公共地標，不算隱匿情報）？行為敏感（改 belief 影響防禦/攻擊規劃 → measure）。
2. **`decision_context.gd::gather`（`:373`）**：`state.teams[_jhost].tile_pos` 入 `PathSystem.find_path` 算 join 可達；`_jhost`=strong_neighbor（cross-faction 時）或 consolidate_target（同-faction）。cross-faction case = **讀 jhost live pos = god-view，同 1119 can_reach 類**。**真 leak→belief_pos-gate（同 1119 範式，無 belief→不可達）**，還是 acceptable（想 join 需知對方在哪）？

## 其餘
- `_find_trade_partner`（strategic_ai）discovered-partner 但 outpost pos live = 半漏，**已知**（known_issues「finder 濾鏈 C 類候選」+ invariants「team_discovered fallback 最終應刪」），不重複開新 leak。

## 回覆
`to:systems`：CLEAN / 修正。審 detector 設計 + triage + **2 新候選判真 leak vs acceptable**（★感知鐵律 owner 是我，但行為敏感 fix 值得你 skeptical + 可能 blueprint 看 doom 影響）。
- CLEAN + 候選=真 leak → 我報 blueprint「arc 非 literally-zero，detector 揪 2 殘留」+ 提 follow-up belief-gate slice（enemy_outpost + jhost 可同批同 belief_pos 範式）。
- CLEAN + 候選=acceptable → gate-ok 標註 + arc 收官（zero-untracked-residual）。

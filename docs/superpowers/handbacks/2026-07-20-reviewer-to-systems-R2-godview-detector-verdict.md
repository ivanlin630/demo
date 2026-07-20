---
from: reviewer
to: systems
status: consumed
topic: "[R² verdict·god-view detector·CLEAN 設計/triage + ★2 新候選皆真 leak] detector 2 型+DROP teamscan+enumerate-not-classify(回歸閘非證明)SOUND;triage 7legit/1119/gray RIGHT。★2 新候選皆真 leak:①_enemy_outpost_positions(2912 全圖掃敵據點 live=god-view,Slice C 已裁 infra 位需 belief→「半公共」REFUTED)②decision_context:373 jhost cross-faction live pos 算可達=1119 型(「需知位」REFUTED,belief last-seen 即可)。→follow-up belief-gate slice(可同批,同 belief_pos 範式)。arc 非 literally-zero,誠實報 blueprint。"
---

# R² verdict：constitution_gate v3 god-view detector

**VERDICT: CLEAN（detector 設計/triage）+ ★2 新候選確認皆真 leak（→ follow-up slice）**。tooling merge f7ff2ea0 純 gate（零 sim 改）已 merged。factcheck 對 HEAD `c13b3876`。

## ① detector 設計 → SOUND
- **gv_teamstate**（indexed `state.teams[id].動態欄`）= 讀單一他隊 live 態（1119 型）=高信號。✓
- **gv_mapscan**（`for x in tiles` whole-map）= Slice C 市集發現型=中信號，geo/own-infra legit→gate-ok。✓
- **DROP gv_teamscan**（`for t in teams`）→ **對**：全隊迭代=引擎 orchestration（處理每 agent，非一隊全知全體），靜態 regex 分不出 loop var 自/他 → 保留=7 個結構性 false-positive。**分不出就 drop（免誤報）> 硬 flag**。✓
- **GV_FILE_RE 含 threat_assessment** + 獨立不擾值閘 baseline → 合理（威脅感知規範案納入）。
- **★enumerate-not-classify（回歸閘非證明）→ 誠實框架，認可**。detector 抓 NEW leak（回歸），**非證明零殘留**（細粒度 self/other 靠人審）。systems 明言「非證明」= 好 epistemic 誠實（同我 slice1 對 bed classifier「該工具是 gate 非 proof」的 flag）。

## ② triage → RIGHT
- **7 legit（自家 infra/地形）**：_home_granary_food/_team_has_facility/_check_ore_surplus/_faction_has_workshop/_find_own_outpost（own infra=自家知識）+ 3 個 outpost/地形選址（看得到地）= 非他隊 god-view。合理。
- **1119**（修中→merge removed）。✓
- **gray consolidate_target_of:1494**：讀 `state.teams[absorber_id].population`，absorber=**同-faction** member → faction 內豁免（legit-ish）；嚴格應走 `known_member_states`（一致性）=**minor 精修非急**。同意判斷。

## ★★③ 2 新候選 → **兩者皆真 leak**（acceptable framing 皆 REFUTED）

**候選1 `_enemy_outpost_positions`（`faction_ai:2912-2921`）= 真 leak**。`for tile_id in tiles: outpost_level>0 且非同 faction → append tile_pos` = **全圖掃所有敵據點 live 位**（選址用 min-dist 避敵）。
- **「半公共地標=acceptable」REFUTED**：**Slice C 已裁「市集/infra 位置零豁免、必經 belief」**（blueprint 明否決「公開地標豁免」）。敵據點位=同類 infra 位置 → 同理需 belief。全圖瞬知全敵基建=god-view（你只該知看過/聞得的敵據點）。
- → **follow-up belief-gate**（改讀已知敵據點=team 的 belief/discovered 敵 outpost）。**behavior-sensitive**（改防禦/攻擊選址）→ measure doom-delta。

**候選2 `decision_context:373` jhost = cross-faction 部分真 leak**。`PathSystem.find_path(team.tile_pos, state.teams[_jhost].tile_pos)` 讀 jhost **live 位**算 join 可達。
- **cross-faction（strong_neighbor）= god-view**（讀他勢力隊 live 位=1119 can_reach 同型）。**same-faction（consolidate_target）= 豁免**（own member，保 live OK）。
- **「想 join 需知對方在哪=acceptable」REFUTED**：**經 belief last-seen 知位即可**（去最後見位 join）；沒見過的隊=不知在哪=不可達（合理，非瞬鎖 live）。
- → **belief_pos-gate 僅 cross-faction 路**（同 1119 範式：belief_pos，無 belief→不可達）；same-faction consolidate 保 live（豁免）。

## ④ _find_trade_partner → 不重記，對
已知（C 類候選 known_issues + invariants「team_discovered fallback 最終應刪」）→ 不重複開新 leak。✓

## 回覆
CLEAN（detector/triage）+ **2 新候選確認皆真 leak** → 你可：
1. **誠實報 blueprint「arc 非 literally-zero」**：detector 揪 2 殘留（arc 人審漏，機器補到）+ gray 1（consolidate minor 精修）。**這正是 detector 價值**（enumerate 揪人審漏）——非 arc 失敗，是機器證比人審細。
2. **提 follow-up belief-gate slice**：`_enemy_outpost_positions`（infra 位 belief-gate，同 Slice C 範式）+ `decision_context:373 jhost cross-faction`（belief_pos-gate，同 1119 範式）**可同批**（都 belief_pos/discovered-infra 範式）。behavior-sensitive（尤 enemy_outpost 選址）→ measure。
3. gray consolidate → known_member_states 一致性精修，排 follow-up 或 known_issues。

——detector enumerate-not-classify + 2 新候選被機器揪出，示範**「機器證比人審細」**（arc 六 slice 人審漏這 2）。「literally-zero」宣稱**別下**（detector 是回歸閘非零證明；2 殘留 + C 類 fallback + gray 都是 tracked non-zero）。誠實 tracked-residual > 假 zero。

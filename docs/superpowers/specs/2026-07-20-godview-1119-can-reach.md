# spec：god-view 1119 — can_reach 距離讀 belief（便宜收尾）

> 層級：L3-ish（1-2 行 belief-gate，便宜）。off main HEAD。god-view arc 最後 leak（A/F/E/D/B/C 已 merged）。blueprint「便宜清」。
> 來源：god-view Slice E measure 撿（known_issues「can_reach」），systems 裁近-vacuous 低優先歸下批。

## god-view leak（決策 precondition 讀 live 距）
`_check_precondition` 的 `"can_reach"`（`faction_ai_system.gd:1115`）：`_hex_dist(leader_team.tile_pos, state.teams[target_id].tile_pos) < 999` = **決策 precondition 讀 live 他隊位算距離**（周圍 `force_ge_target:1109` 用 `BeliefSystem.best_estimate` belief，**不一致**）。

## 修（belief-gate 距離，同 god-view arc 範式）
`:1115` target 位 → belief：**可見（belief last_tick==current_tick）用 live 距；斷視線→belief last-seen 位算距；positionless/無 belief → `can_reach` false**（無位=無法算可達）。
- 同 Slice D position 態範式（belief_pos + freshness）。
- **★順帶疑（非 god-view，記 known_issues 別擴本刀）**：`<999` 近-vacuous（hex 距遠小於 999→恆真）。若 can_reach 本該真 reachability gate，vacuous=決策品質洞（以為任 target 可達即攻/追，PathSystem 真可達性沒查）。**本刀只治 god-view（belief-gate 讀）**，vacuous/真可達語意=另評（economy/decision-quality 地盤，非 god-view）。

## 驗收
- **TDD**：can_reach 可見→live 距/斷視線→belief 距/positionless→false（不瞬鎖真位算可達）。
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical。
- **measure**：輕（近-vacuous，行為影響小）——doom-delta 不惡化即可；god-view audit 這條路無 live 讀（belief-gate 證）。

## ★god-view arc 收尾
1119 belief-gate → **god-view arc 全部 leak 治完**（A/F/E/D/B/C+null-belief-flee+1119）→ constitution_gate 擴版（god-view detector）證零殘留 → economy arc。

## 排序
便宜，off main HEAD。R²（belief-gate 範式一致 + vacuous 另記不擴刀）→ dispatch。

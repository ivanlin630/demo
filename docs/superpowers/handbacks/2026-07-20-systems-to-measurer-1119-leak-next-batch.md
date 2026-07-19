---
from: systems
to: measurer
status: open
topic: "[裁·1119 can_reach=真 god-view leak 但近-vacuous 低優先·歸下批非 Slice E] 評估 faction_ai:1115 can_reach `_hex_dist(leader.tile_pos, state.teams[target].tile_pos)<999`:①是真 god-view leak(決策 precondition 讀 live 他隊位,周圍 1109 force_ge_target 用 belief best_estimate 不一致)②但 <999 近-vacuous(hex 距遠小於 999→恆真)→ 效果近無害、低優先③out Slice E R²-scoped 4-site(守 scope 不 fold,免 mid-slice creep)。歸下批 god-view cleanup（Slice E follow-up or D 批一起）。★順帶疑:若 can_reach 本該真 reachability gate,<999 vacuous=決策品質洞(以為任 target 可達即攻/追,PathSystem 真 reachability 沒查)——另記 known_issues,非 god-view 而是 reachability 語意。謝 flag,1625 gate-ok(probe)確認。你續 Slice E measure(E1/E2/E3/E5 doom-delta)。"
---

# 裁：1119 can_reach = 真 god-view leak 但近-vacuous，歸下批

謝 flag（+1625 gate-ok probe 確認）。評估 `faction_ai:1115` `can_reach`：
```gdscript
"can_reach":
    return target_id != -1 and state.teams.has(target_id) \
        and _hex_dist(leader_team.tile_pos, state.teams[target_id].tile_pos) < 999
```

## 判：真 god-view leak，但低優先
1. **是 god-view leak**：決策 precondition 讀 live `state.teams[target].tile_pos` 算距離。周圍 `force_ge_target:1109` 用 `BeliefSystem.best_estimate`（belief）→ 此處讀 live **不一致**（違感知鐵律：決策憑 belief 非 live）。
2. **但 <999 近-vacuous**：hex 距遠小於 999 → 恆真 → **god-view 效果近無害**（gate 幾乎不因真距離改變結果）。
3. **out Slice E 4-site**（E1/E2/E3/E5 R²-scoped）。

## 裁：歸下批 god-view cleanup，非 Slice E
- **不 fold Slice E**（守 R² scope，免 mid-slice creep；Slice E 保持 4-site 乾淨）。
- **歸下批**：Slice E follow-up or Slice D 批一起清（belief_pos 化，同型機械）。低優先（vacuous 效果）。已記 known_issues god-view 殘留。

## ★順帶疑（非 god-view，另類）
若 `can_reach` **本該是真 reachability gate**，`<999` vacuous = **決策品質洞**（以為任 target 可達即攻/追，PathSystem 真 reachability 沒查）。這非感知鐵律問題，是 reachability 語意問題——另記 known_issues 供評估（可能 can_reach 該用 PathSystem 真可達性 + belief 位，一次治 god-view + vacuous）。

## 你續
Slice E measure（E1/E2/E3/E5 belief 化 doom-delta，敵脫視野可甩追=intended）。1119 我記著，不擋 Slice E。

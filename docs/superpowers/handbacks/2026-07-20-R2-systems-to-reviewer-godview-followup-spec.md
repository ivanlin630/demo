---
from: systems
to: reviewer
status: consumed
topic: "[R²·god-view follow-up spec·enemy_outpost+jhost belief-gate·你已判兩者真 leak] spec=2026-07-20-godview-followup-enemy-outpost-jhost.md。①jhost(decision_context:373) trivial=同 1119 belief_pos 範式(無 belief→不可達)。②★enemy_outpost(faction_ai:2912) 設計點:用途=選址軟 penalty(建近敵-分非硬排除);fix=belief-about-owner proxy(觀察者對 owner team 有 best_estimate belief 才納避讓,★store-free 復用既有 belief,不建 team_outpost_known 大 store)。審點:①jhost belief_pos 範式一致②★★enemy_outpost proxy 可接受嗎(imperfect:belief_pos 給 owner last-seen 位非據點位,見過owner≠知據點;但 store-free+軟penalty 容忍+「避已知敵」語意合理)vs 需建真 sighting store(過重?)③baseline drop 2 CANDIDATE-LEAK 註對(fingerprint 修後 removed=PASS)④無新 RNG。CLEAN→dispatch(off post-1119 main 避 faction_ai 衝突)。這批 merged→真 zero-untracked-god-view→arc 收官。"
---

# R²：god-view follow-up spec（enemy_outpost + jhost belief-gate）

spec：`docs/superpowers/specs/2026-07-20-godview-followup-enemy-outpost-jhost.md`。你 R² 已判**兩者皆真 leak**（半公共/需知位 REFUTED），本 spec 定 fix。

## 2 site
1. **jhost（`decision_context:373`）trivial**：`state.teams[_jhost].tile_pos` → `belief_pos`，無 belief→不可達。**完全同 1119 範式**。
2. **★enemy_outpost（`faction_ai:2912`）1 設計點**：全圖敵據點 live → belief-gate。用途=`_evaluate_new_outpost_location` 選址**軟 penalty**（建近敵據點<5 減分，非硬排除）。

## ★★審點：enemy_outpost proxy vs 真 store
- **提案 = belief-about-owner proxy**（store-free）：`if BeliefSystem.belief_pos(observer, owner.team_id) == (-1,-1): continue` → 只避「見過該敵隊」的據點。
- **imperfect**：belief_pos 給 owner 隊 **last-seen 位**（非據點固定位）；owner 可 roam，見過 owner ≠ 精確知據點位。
- **為何仍取 proxy**：①store-free（不建 `team_outpost_known` sighting store=Slice C 級重工，vision/relay 三源）②軟 penalty 非硬排除（容忍度高，proxy 誤差不致命）③「避已知敵」語意合理。
- **★你判**：proxy 可接受（實用 vs 完美），還是軟 penalty 也該建真 sighting store（我認為過重、不值——軟 penalty ROI 低）？

## 其餘審點
- jhost belief_pos 範式一致（同 1119/Slice D）。
- baseline：修後 2 site fingerprint drop → constitution_gate removed=PASS，baseline 該 2 CANDIDATE-LEAK 註行移除。
- 無新 RNG。measure=behavior-sensitive（enemy_outpost 影響選址分佈/衝突率→doom-delta；jhost 輕）。

## 回覆
`to:systems`：CLEAN / 修正。CLEAN → dispatch（off **post-1119** main 避 faction_ai 衝突，jhost 同範式可緊接）。這批 merged + baseline drop → **真 zero-untracked-god-view-residual** → arc 收官 → economy arc（re-baseline）。

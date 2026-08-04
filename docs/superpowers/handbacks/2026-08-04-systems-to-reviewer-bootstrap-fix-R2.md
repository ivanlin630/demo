---
from: systems
to: reviewer
status: consumed
topic: "[R²審bootstrap fix spec(2026-08-04-infonet-bootstrap-fix-HOW.md,用戶RATIFIED GO)·root=Part2 herald/scout 0 fire=bootstrap死結(help/scout_target_pos卡best_estimate live-belief,faction成員從不meet→無belief位→永不applicable)·fix=名冊fallback(fresh belief優先,無→_faction_roster_pos查自家勢力固定據點位,組織常識)·守WHAT補則5硬界:①只位置零live-state(內容仍信使抵達傳)②移動隊不含(_find_own_outpost只回固定outpost)③敵據點不含(faction_id gate)④分裂faction-gate讀當下faction_id自動排ex-faction(MVP faction-gate忘掉達④outcome,frozen-snapshot全模型=forward refinement設計註)⑤HexTileData.outpost_hidden=false一行stub不加功能·★審點:①genuine非crank(help/scout util一字不改只加target_pos fallback讓applicable非crank讓fire)②感知鐵律(名冊據點位=組織常識position-only same-faction,載體物理走delay,constitution_gate綠自家outpost讀legit非indexed敵live-state)③5界encode正確尤④frozen-snapshot-vs-forget是否滿足用戶硬界(可戳)④無框內平行求解器(reuse _find_own_outpost加1 helper+1 filter非增殖)·CLEAN→build續feat/info-network-whole→re-measure canonical harness→QA故事稽核"
---

# R² 審 bootstrap fix spec（用戶 RATIFIED GO）

**spec**：`docs/superpowers/specs/2026-08-04-infonet-bootstrap-fix-HOW.md`
**WHAT 依據**：`2026-08-03-information-network-core-design.md §感知鐵律「結構常識補則」`（用戶三問定案 + 5 硬界）。
**root**：Part2 herald/scout = 0（measurer verdict）= bootstrap 死結（`decision_context.gd:342-370` help/scout_target_pos 卡 `best_estimate` live-belief、faction 成員從不 meet→無 belief 位→永不 applicable）。

## 一句話修法
名冊 fallback：help/scout_target_pos **fresh belief 優先、無→`_faction_roster_pos`** 查自家勢力固定據點位（組織常識）。util **一字不改**。

## ★審點（R² refute checklist）
1. **genuine 非 crank**（[[feedback_genuine_value_not_crank]]）：help/scout **util 一字不改**（severity/staleness×人格），只加 `target_pos` 的名冊 fallback（讓 option **applicable** 成立）。確認**非藉 crank util 讓 fire**（真病=target_pos 無值→不 applicable、非 util 太低）。
2. **★感知鐵律 + god-view**：名冊據點位=**組織常識（position-only、same-faction 固定據點）**、非讀 target live state；載體物理走+delay、到了才傳 content。**constitution_gate god-view detector 必綠**——`_faction_roster_pos` 只讀**自家勢力 outpost 位**（`outpost_owner==target` 且 `target.faction_id==member.faction_id`）=legit intra-faction 結構、**非 indexed 敵 live-state / whole-map 掃**。標 gate-ok legit。
3. **★5 硬界 encode 正確**（WHAT 補則）：①位置零 live-state ②移動隊不含（`_find_own_outpost` 只固定 outpost）③敵據點不含（faction_id gate）④分裂（faction-gate 讀當下 faction_id→ex-faction 自動排）⑤`outpost_hidden=false` 一行 stub 不加功能。**★尤 ④ 可戳**：MVP 用「faction-gate 忘掉 ex-faction」達 ④ outcome（分裂後不 live-track 對方）；用戶模型「凍成 belief 快照帶走」=更豐富 forward refinement（需 stored 名冊 snapshot）。**確認 faction-gate 是否滿足 ④ 硬界**、或需 frozen-snapshot 全模型（若需→標 tracking 另 slice、非 MVP block）。
4. **無框內平行求解器**（[[feedback_no_patch_on_settled_architecture]]）：reuse `_find_own_outpost`、加 1 helper（`_faction_roster_pos`）+ 1 filter（hidden stub）、非增殖平行機制。

## determinism / need-gated
- outpost lookup 確定性零 RNG；help 仍 gated `help_need_severity>0`、scout 仍 gated 領主+info-gap（不動）。

**CLEAN → 回 systems → build（續 `feat/info-network-whole`）→ re-measure whole（canonical harness 中性 specimen、併 observer-RNG 方法 re-run）→ QA 故事稽核（回溯三因果+whole、出 verdict ref）→ blueprint 對用戶驗收。** 卡/BLOCKER → 報 `to:systems`。

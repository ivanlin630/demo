---
from: systems
to: implementer
status: consumed
topic: "[dispatch build bootstrap fix(R²CLEAN+④訂正,spec=2026-08-04-infonet-bootstrap-fix-HOW.md,用戶RATIFIED GO)·root=Part2 herald/scout 0 fire=bootstrap死結(help/scout_target_pos卡best_estimate live-belief,faction成員從不meet→無belief位→永不applicable)·fix=名冊fallback:decision_context help/scout_target_pos解析fresh belief優先→無→新helper _faction_roster_pos查自家勢力固定據點位(組織常識)·_faction_roster_pos(state,member,target_id):回target自家固定outpost位(_find_own_outpost:outpost_level>0且owner==target)若target.faction_id==member.faction_id且not tile.outpost_hidden,否則-1·5界:①只tile_pos零live-state②_find_own_outpost只固定outpost(移動隊無→-1落belief)③faction_id gate(敵→-1)④★MVP非④全模型誠實known gap(faction-gate分裂後對ex-faction零資訊≠用戶凍belief快照帶走,non-blocking現無人讀ex-faction位,別聲稱滿足④只標未實作)⑤新欄HexTileData.outpost_hidden:bool=false一行stub恆false不加功能(對抗資訊戰層parked)·守:help/scout util一字不改(genuine非crank,真病=target_pos無值非util低)/感知鐵律(名冊position-only same-faction,信使物理走delay,constitution_gate綠)/determinism零新randf/★全量tap(help.herald_dispatched·scout.dispatched·roster_fallback命中)·branch續feat/info-network-whole·完HANDBACK to:systems我路measurer re-measure whole(canonical WarringHarness harness掛specimen=中性,禁手寫loop)→QA故事稽核"
branch: feat/info-network-whole
---

# dispatch build — bootstrap fix（R² CLEAN + ④ 訂正、用戶 RATIFIED GO）

**spec**：`docs/superpowers/specs/2026-08-04-infonet-bootstrap-fix-HOW.md`（R² CLEAN；④ 已訂正=誠實 known gap 非全模型）。
**branch**：續 `feat/info-network-whole`。**root**：Part2 herald/scout 0 fire=bootstrap 死結（help/scout_target_pos 卡 `best_estimate` live-belief、faction 成員從不 meet→永不 applicable）。

## 建什麼（名冊 fallback、接既有）
- **`decision_context.gd` help/scout_target_pos 解析**：fresh belief 優先 → 無 belief → 新 helper `_faction_roster_pos`。
- **`_faction_roster_pos(state, member, target_id) -> Vector2i`**：回 target 自家**固定 outpost 位**（reuse `_find_own_outpost(target)`：`outpost_level>0` 且 `outpost_owner==target`）**若** `target.faction_id == member.faction_id`（同勢力、組織常識）**且** `not tile.outpost_hidden`（⑤ stub）；否則 `(-1,-1)`。
- help→target=自家領主（`leader_team_id`）；scout→target=自家子民（最陳舊）。

## 5 硬界（build 硬守）
1. **①只 `tile_pos`、零 live-state**（不讀 target runway/resources/pop；求援/偵察內容仍信使抵達傳）。
2. **②移動隊不含**：`_find_own_outpost` 只回固定 outpost（移動隊無自家 outpost→-1→落 belief/信使）。
3. **③敵據點不含**：`faction_id` gate（他勢力→-1→要偵察）。
4. **④★MVP 非 ④ 全模型、誠實 known gap（別聲稱滿足）**：faction-gate 分裂後對 ex-faction 回 -1（零資訊）≠ 用戶「凍 belief 快照帶走（會變舊）」。**non-blocking**（現 Part2 消費者只鎖同勢力當下、無人讀 ex-faction 位）。**code 註 + 我記 known_issues**：未來需「分裂後仍知對方舊據點 stale」才建 stored 名冊 snapshot。**別在 code/handback 聲稱已滿足 ④**。
5. **⑤隱匿 stub**：新欄 `HexTileData.outpost_hidden: bool = false`（一行、恆 false、不加功能；filter `not outpost_hidden`）。對抗資訊戰層（parked）將來令首領設 true。

## 守（build 硬守）
- **genuine 非 crank**（[[feedback_genuine_value_not_crank]]）：help/scout **util 一字不改**——真病=target_pos 無值→不 applicable、**非 util 太低**；只加 target_pos fallback 讓 applicable 成立。
- **感知鐵律**：名冊 position-only、same-faction 組織常識；信使物理走+delay；`constitution_gate` god-view detector **必綠**（自家 outpost 讀 legit、非 indexed 敵 live-state）。標 gate-ok legit。
- **determinism 零新 randf** + **need-gated**（help gated `help_need_severity>0`、scout gated 領主+info-gap 不動）。
- **★全量 tap**（[[feedback_full_transient_observability]]）：`help.herald_dispatched`/`scout.dispatched`/`roster_fallback` 命中 + candidate 生成——餵 measurer 驗 Part2 真活。

## 驗收（re-measure whole、我路 measurer）
- `help.herald_dispatched >0` + `scout.dispatched >0`（Part2 活）。
- **`distribute.dispatch / food_delivered >0`**（症1：herald 送居民 need 達領主 team_known→distribute fire→convoy 送糧）。
- 人格分化保留（fallback 不動 util）、determinism byte-identical、economy 不爆、Part1+3 不退。

**完 → HANDBACK `to:systems` → 我路 measurer re-measure whole（★canonical `WarringHarness.run()` 掛 specimen=中性、禁手寫 loop、observer-RNG 方法 re-run 併此）→ QA 故事稽核（回溯三因果+whole、出 verdict ref）→ blueprint 對用戶驗收。** 卡 → 報 `to:systems`。

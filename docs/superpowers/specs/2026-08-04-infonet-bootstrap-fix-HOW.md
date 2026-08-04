# 資訊網 bootstrap 死結 fix — HOW spec

**from**: systems | **status**: FINALIZED → reviewer R²（用戶 RATIFIED GO 2026-08-04） | **branch**: `feat/info-network-whole`（續）
**root**: Part2 herald/scout = 0 fire = bootstrap 死結（measurer verdict + 我獨立驗）。
**WHAT 依據**: `2026-08-03-information-network-core-design.md §感知鐵律「結構常識補則」`（用戶三問定案）：**faction 成員天生知自家勢力所有「固定據點」位置**（組織常識、建成公告名冊自然更新）+ **5 硬界**（見下）。

## 病（code-proven）
`decision_context.gd:342-370`（worktree）：help_target **identity 對**（:350 自家 faction 領主 `leader_team_id`）**但 POSITION 卡 `:348 BeliefSystem.best_estimate(team,lord).tile_pos`**——faction 成員從不 meet→無 live-belief 位→`_hpos=-1`→`help_target_id` 留 -1→option 永不 applicable。scout 同（:365 子民 belief 位無→跳）。

## 修（名冊 fallback：faction 固定據點位；守 5 硬界）
help/scout_target_pos 解析加 **fallback 到「自家勢力名冊」的固定據點位**（fresh belief-pos 優先、無 belief→名冊 floor→無 dead-end）：
```
# help_target_pos：fresh belief 優先；無→名冊查領主固定據點位（組織常識）
var _hpos = BeliefSystem.best_estimate(state, team.team_id, lord_id).get("tile_pos", Vector2i(-1,-1))
if _hpos == Vector2i(-1,-1):
    _hpos = _faction_roster_pos(state, team, lord_id)   # ★名冊 fallback
if _hpos != Vector2i(-1,-1):
    c.help_target_id = lord_id; c.help_target_pos = _hpos
```
**`_faction_roster_pos(state, member, target_id)`**（新 helper，組織常識、守 5 界）：
- 回 target 的**自家固定據點位**（`_find_own_outpost(target)`：`outpost_level>0` 且 `outpost_owner==target`），**若** `target.faction_id == member.faction_id`（**同勢力**）**且** `not tile.outpost_hidden`（⑤ stub）。
- 否則回 `(-1,-1)`（移動隊無固定據點=②、他勢力=③、隱匿=⑤）。
- **scout 同款**：子民 belief 位無 → 名冊查子民 assigned 固定據點位。

### 5 硬界 encode（WHAT 補則）
1. **①只位置零 live-state**：helper 只回 `tile_pos`，**不讀 target live runway/resources/pop**。求援/偵察**內容**仍靠信使物理抵達傳（見下界）。
2. **②移動中隊伍不含**：`_find_own_outpost` 只回**固定 outpost**（軍/商隊/半路領主無自家 outpost→回 -1→落 belief/信使）。
3. **③敵方據點不含**：`target.faction_id == member.faction_id` gate（他勢力→-1→要偵察）。
4. **④分裂——★MVP 非 ④ 全模型、誠實標 known gap（R² 訂正 2026-08-04，我原「達 ④ outcome」自我認證過頭）**：MVP faction-gate 讀**當下 `faction_id`**——分裂後 ex-faction 成員 `faction_id` 已變→`_faction_roster_pos` 對他們回 -1（**零資訊**）。**★這 ≠ 用戶 ④ 硬界**：用戶原文（ratified）=「分裂=名冊**凍成 belief 快照帶走**（對方後續新建/棄置不知、會過時）」＝**帶走一份會變舊的快照**（分裂後仍記得對方分裂瞬間的據點、之後 stale）。MVP 是**分裂瞬間零資訊（連快照都沒過）**——**機制不同、非同 outcome 換包裝**。**non-blocking**：現 Part2 消費者（help=自家領主、scout=自家子民）只鎖**同勢力當下**、**無人讀 ex-faction 位** → 缺 frozen-snapshot 現無害。**記 known gap**：未來若有消費者需「分裂後仍知對方舊據點（stale）」→ 另 slice 建 stored 名冊 snapshot + copy-on-split。**本 MVP 不聲稱滿足 ④、只誠實標未實作。**
5. **⑤預設公告 + 隱匿旗位（一行前瞻不加功能）**：`HexTileData.outpost_hidden: bool = false`（新欄、預設 false=公告；helper filter `not outpost_hidden`）。**現恆 false（不加功能）**、對抗資訊戰層（parked）將來令首領設 true=秘密據點。

## ★界（用戶硬守）
- **只 position**（名冊固定據點位）、**零 live state**。求援/偵察 **CONTENT 仍信使物理抵達傳**（herald 走到據點位、deposit 求援 msg 進 team_known/board；scout 走到子民據點、觀察帶 fresh belief 回）。**≠被否的直掃**（跳過信使直讀 live state）。
- **感知鐵律**：名冊據點位=組織常識（靜態、成員知自家勢力分部）；載體物理走+delay；到了才傳 content。領主已離據點（移動）→信使抵據點撲空→msg 留 board 等領主回讀（Part1 relay 承接）=延遲非 dead-end。

## 守（reviewer R²）
- **genuine 不變**：help/scout util（severity/staleness × 人格）**一字不改**——只補 target_pos 解析的 fallback（讓 applicable 成立）、非動 util（非 crank 讓 fire）。
- **determinism**：outpost lookup 確定性（零 RNG）。
- **need-gated**：help 仍 gated `help_need_severity>0`、scout 仍 gated 領主+有 info-gap。
- **感知鐵律 / god-view**：fallback 只讀**自家 faction 結構的 outpost 位**（constitution_gate：outpost_owner==自家 leader/member=legit intra-faction 結構、非 indexed 他隊 live 態）。標 gate-ok legit。
- **無框內平行求解器**：改 target_pos 解析一處、reuse `_find_own_outpost`、非增殖。

## 驗收（execution-end、re-measure whole）
- `help.herald_dispatched >0` + `scout.dispatched >0`（Part2 活）。
- **`distribute.dispatch / food_delivered >0`**（症1：herald 把居民 need 送達領主 team_known → 領主 distribute candidate 見 buy-order → fire → convoy 送糧）。
- **人格分化保留**（per-option util dump 傲少求/務實早求，fallback 不動 util）。
- determinism byte-identical、economy 不爆、fog 保住。

**用戶 RATIFIED GO** → 路 R²（審 5 界 encode + genuine + 感知鐵律）→ CLEAN → build（續 `feat/info-network-whole`）→ re-measure whole（**canonical harness** 掛 specimen=中性、observer-RNG 方法 re-run 併此）→ **QA 故事稽核（回溯三因果 + whole、出 verdict ref）** → 綠 → blueprint 對用戶驗收。（§Alt seed-初始-belief 已 moot：用戶 confirm fallback 路。）

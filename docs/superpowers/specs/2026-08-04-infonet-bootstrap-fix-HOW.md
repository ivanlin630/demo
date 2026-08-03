# 資訊網 bootstrap 死結 fix — HOW spec

**from**: systems | **status**: draft **（build PENDING 用戶 confirm 感知鐵律 read；blueprint 授權平行設計）** | **branch**: `feat/info-network-whole`（續）
**root**: Part2 herald/scout = 0 fire = bootstrap 死結（measurer verdict + 我獨立驗）。
**依賴**: 用戶 confirm「faction 自家 seat 位=membership 結構知識非 god-view」（blueprint PROVISIONAL YES、Telegram 問用戶中）。**用戶否 → 走 §Alt（立 faction 時 seed 初始 belief）。**

## 病（code-proven）
`decision_context.gd:342-370`（worktree）：help_target **identity 對**（:350 自家 faction 領主 `leader_team_id`）**但 POSITION 卡 `:348 BeliefSystem.best_estimate(team,lord).tile_pos`**——faction 成員從不 meet→無 live-belief 位→`_hpos=-1`→`help_target_id` 留 -1→option 永不 applicable。scout 同（:365 子民 belief 位無→跳）。

## 修（position fallback 到 faction-結構 seat；守 blueprint 界=只 position、零 live state）
```
# help_target_pos：fresh belief-pos 優先（見過就用新位）；無 belief → fallback faction seat（結構知識）
var _hpos = BeliefSystem.best_estimate(state, team.team_id, lord_id).get("tile_pos", Vector2i(-1,-1))
if _hpos == Vector2i(-1,-1):
    _hpos = _faction_seat_pos(state, lord_id)   # ★fallback：領主 home outpost（membership 已知位）
if _hpos != Vector2i(-1,-1):
    c.help_target_id = lord_id; c.help_target_pos = _hpos
```
- **`_faction_seat_pos(state, lord_id)`** = 領主自家 home outpost 位（reuse `_find_own_outpost(lord)` 範式、faction_ai home_tile `outpost_owner==leader.team_id`）。**靜態結構知識**（成員知自家首府在哪）、**非讀領主 live tile_pos/state**。
- **scout 同款**：子民 belief 位無 → fallback 子民 assigned outpost 位（`_find_own_outpost(sub)`、領主派駐它在那=結構知）。
- **priority**：fresh belief-pos 優先（感知鐵律：見過用新位）、seat fallback = 永遠可用的 floor（無 dead-end）。

## ★界（blueprint 硬守、用戶在乎）
- **只 position fallback**（faction 結構 seat/assigned outpost）、**不含任何 live state**（不讀領主/子民 live runway/resources/pop）。
- **求援/偵察 CONTENT 仍靠信使物理抵達傳達**（herald 走到 seat 位、deposit 求援 msg 進目標 team_known / board；scout 走到子民位、觀察帶 fresh belief 回）。**≠被否的直掃**（那是跳過信使直讀 live state）。
- **感知鐵律**：seat 位=membership 結構知識（靜態、你知自家首府）；載體物理走+delay；到了才傳 content。若領主已離 seat（移動），信使抵 seat 撲空→msg 留 board 等領主回讀（Part1 relay 承接）=延遲非 dead-end。

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

## §Alt（用戶否 fallback 時）
立 faction / 成員派駐時 **seed 一次初始 belief**（成員記自家 home/領主 seat 位 = 初始 belief claim）——資訊網「intra-faction 冷啟動即知自家結構」的 belief 版。效果同（help/scout 有位可解析），差別=fallback（讀時算）vs seed（建時記）。用戶偏好定。

**build PENDING 用戶 confirm** → confirm 後路 R² → build（續 `feat/info-network-whole`）→ re-measure whole（含 observer-RNG measurer 方法 re-run）→ QA 故事稽核 → accept。

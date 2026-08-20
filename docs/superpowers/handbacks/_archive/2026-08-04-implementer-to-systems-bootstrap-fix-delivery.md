---
from: implementer
to: systems
status: consumed
topic: "[資訊網 bootstrap-fix 交付·名冊 fallback 破 herald/scout 0-fire 死結·feat/info-network-whole d9550ad8·util 一字不改(genuine 真病=target_pos 無值)·TDD 6/6·headless 3=baseline·constitution 74(gv_mapscan gate-ok 感知鐵律守)·determinism 3 跑 byte-identical E87F455·5 硬界 encode(④誠實標 known gap 非 frozen-snapshot)]。help/scout_target_pos:fresh belief→無→_faction_roster_pos(自家勢力固定據點位、組織常識)。tap help/scout.roster_fallback。待你 R² 融合驗→measurer re-measure whole(canonical WarringHarness 掛 specimen 中性、禁手寫 loop)→QA 故事稽核。"
branch: feat/info-network-whole
commit: d9550ad8
base: main（續 whole build）
---

# 資訊網 bootstrap-fix — 名冊 fallback 破 herald/scout 0-fire 死結

root（measurer + 你獨立驗）：Part2 herald/scout **0 fire = bootstrap 死結**——help/scout_target_pos 卡 `best_estimate` live-belief；faction 成員從不 meet → 無 belief 位 → option 永不 applicable。**真病 = target_pos 無值、非 util 低**。

## 做（照 spec 5 硬界、util 一字不改）
- **`HexTileData.outpost_hidden: bool = false`**（界⑤ 一行 stub、現恆 false 不加功能；對抗資訊戰 parked）。
- **`faction_ai._faction_roster_pos(state, member, target_id)`**（新 helper、組織常識）：回 target 自家固定 outpost 位（`outpost_level>0 && owner==target`），守 **5 硬界**：
  ①只 `tile_pos` 零 live-state（content 仍靠信使物理送）②只固定 outpost（移動隊無→-1 落 belief）③同勢力 gate（敵/無 faction→-1）**④★MVP=當下 faction_id**（分裂後 ex-faction→-1 零資訊；**★誠實標 known gap：非用戶 frozen-belief-snapshot ④、非同 outcome 換包裝；non-blocking 現無 ex-faction 位消費者；未來需 stale-snapshot→另 slice stored 名冊+copy-on-split**）⑤`not outpost_hidden`。
  - gv_mapscan 標 **`# gate-ok`**（own-faction infra 位掃、同 `_find_own_outpost` 地理型、讀 static outpost_owner 結構非 indexed 他隊 live 態、③已限同勢力）。
- **`decision_context` help/scout_target_pos**：**fresh belief 優先 → 無 → `_faction_roster_pos` fallback**（破 bootstrap）。scout 無 belief 子民走名冊 → `staleness=1.0`（從沒親聞=max、genuine）。**help/scout util 未動一字**（非 crank 讓 fire、只補 target_pos 解析使 applicable 成立）。

## tap（全量觀測）
`help.roster_fallback` / `scout.roster_fallback`（名冊 fallback 命中）；help.herald_dispatched/scout.dispatched（既有）。

## 驗（全綠）
- TDD `infonet_bootstrap_test` **6/6**：①`_faction_roster_pos` 5 界（同勢力→位 / 敵→-1 / 移動隊→-1 / 隱匿→-1）②help 無 belief→名冊→help_target_id 成立 pos=(9,9)（破 bootstrap、herald applicable）③scout 無 belief 子民→名冊→scout_target staleness=1.0。
- **headless 3=baseline**（p2a/197/rung pre-existing）。
- **constitution PASS 74**（gv_mapscan gate-ok 後；★god-view detector 綠=感知鐵律守；名冊只讀自家 faction 結構 outpost 位）。
- **determinism 3 跑 byte-identical MD5 E87F455**（≠前 whole 34C8B74=bootstrap fix 真使 herald/scout applicable、真改行為；byte-identical=零新 randf、outpost lookup 確定性）。

## ★守則自查
- **genuine 不變**：util 一字不改（真病=target_pos 無值非 util 低；非 crank 讓 fire）。
- **感知鐵律**：名冊=position-only 自家 faction 結構（組織常識靜態）；content 仍信使物理走+delay；領主離據點→信使抵撲空→msg 留 board 等回讀（Part1 relay 承接）=延遲非 dead-end。constitution god-view detector 綠。
- **determinism 零新 randf**；**need-gated 不變**（help severity>0 / scout 領主+info-gap）；無框內平行求解器（改 target_pos 解析一處、reuse _find_own_outpost 型）。

## ★待你 / 交 measurer（whole 一次量、bootstrap 通後真驗）
- Part2 活：`help.herald_dispatched >0` + `scout.dispatched >0`（bootstrap 前恆 0）。
- **症1 解**：`distribute.dispatch / food_delivered >0`（herald/scout 把居民 need 送達領主 team_known → distribute 見 buy-order → fire → convoy 送糧）。
- famine 解（food_seek_target 獲值 relocate）+ **人格分化保留**（util 不動：per-option dump 傲少求/務實早求、統領多查/野心少查）+ fog 保住 + economy 不爆 + ⚠attrition 健康性。
- ★hub 效應（R² ②）+ perf-watch（_market_peer_trade / roster scan per gather）。
- measurer canonical WarringHarness 掛 specimen（中性、observer-RNG clean、禁手寫 loop）→ QA 故事稽核（回溯三因果 + whole verdict ref）→ blueprint JUDGE → 用戶驗收。

★誠實 measured 才宣稱（[[feedback_verify_execution_end]]）。待你 R² → measurer whole → QA → blueprint。

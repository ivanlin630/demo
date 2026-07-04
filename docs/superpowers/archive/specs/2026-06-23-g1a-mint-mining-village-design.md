# G1a 鑄幣脈絡：礦村（山村特化）— 讓特產經濟物理上可開採

> 系統 HOW spec。承藍圖 ruling `2026-06-22-otherdomain-ruling` #4（mint 現在排 G1a，建廠決策走統一引擎/utility 非硬腳本）。
> P0（他域解鎖鏈首塊，獨立可平行）。用戶裁定模型 = **B 礦村（山村特化）**：山地可建靠外部供糧的礦村，真採金。

## 量測（推翻 stale premise）

[[feedback_verify_backlog_fresh]]：S5/W8 backlog 記「default 無金礦 tile + 鑄幣廠從沒用」與現碼**部分矛盾**。`measure_mint.gd` 跑 1yr：

| | world_sim (r4) | default (r8) |
|---|---|---|
| 金礦 tile（生成） | **0**（11 山×12% RNG 槓龜） | 3（45 量） |
| 末態挖出 | 0 | **0（45 全留地底）** |
| mint_tiles / g1.mint | 0 / 0 | 0 / 0 |

**真根 = 金礦物理上不可開採**（非「無金礦 tile」、非「鑄幣 code 壞」——harness mint=1 證 code 對）：
1. 金礦只在**山地**；山地 food 再生 **0.5/天**（`resource_system.gd:30`，平原 8.0）→ 自給人口餓死。
2. 採礦**需隊站該 tile**（`resource_system.gd:44` 自格；鄰格採只 L3 outpost 0.5×，:61-67）。
3. 定居/紮營 picker `_find_unowned_farmable_tile`（`faction_ai_system.gd:2173`）明文 `if terrain=="mountain": continue`，註解「山不可農（見**山村特化待 spec**）」——本 spec 即此缺口。
4. 戰略建址 `_evaluate_new_outpost_location`（:1752）：山地 `TERRAIN_BUILD_BONUS=-10`（:1741）+ `productivity×100` 低 + 距離懲罰 → 壓過 ore bonus +35（:1747）。
5. mint deficit gate 要 vault `ore>10`（`faction_ai_system.gd:2028`）→ ore 永在 `tile.resources`（地底）沒進 `public_storage`（vault）→ 鑄幣廠永不建。

雞生蛋死鎖：住不了山 → 採不到 → 無 vault ore → 不建廠 → 無 coin。

## 願景對齊（藍圖 owner，越界呈報）

礦村 = 新世界概念（靠外部供糧的非自給聚落），屬 `game-design.md`（藍圖願景）領域。用戶（跨角色導演）已直裁採 B。**系統呈報**：本 spec 落地後需藍圖把「礦村/特產經濟」記入 `game-design.md`（handback `g1a-mining-village-vision`）。非阻塞。

## 設計：礦村 = 靠外部供糧的山地 civilian outpost

核心觀念：**礦村就是蓋在含礦山地的 civilian outpost，不自給、靠母聚落供糧**。最大化複用既有機制：
- 採礦：既有 `_collect_from_tile` 自格採 ore（隊站礦村 tile = 站含礦山 → 自動採 ore_gold/silver 進 vault）。**零改**。
- 鑄幣：既有 mint facility（`FACILITY_DEF` mint allowed=civilian）+ `_pick_facility`（vault ore>10 → utility 評分建廠，非硬腳本）+ `_tick_mint` 轉 coin。**零改**（雞生蛋一旦解，自動 fire）。
- 供糧 pull：既有 food 買單（merge `a4c4cf8`）——礦村缺糧發 food buy，mint coin 付帳。
- 糧倉：既有 WS-1 granary（礦村 food 存 public_storage，`effective_food` 合併池讀）。
- subteam 建造：既有 `dispatch_subteam` + `begin_subteam_construction` + `_complete_construction`。

### 新增 4 塊（spec scope）

#### S1. world-gen 保證礦脈（小圖修）
`world_generator.gd`：生成後若全圖 `ore_gold` tile 數 < 1，強制挑一座山地 tile 注入 ore_gold（同理 ore_silver 可選）。保證 measurement台（world_sim r4）+ 任意小圖 mint 魂有燃料可 fire。
- 量值對齊既有範圍（gold 5-30×mult）。
- 大圖（default r8）本有 3 金礦 → guard 不觸發、零影響。
- 純世界生成 + config，不碰守恆。

#### S2. 礦村建址：含礦山地條件解禁
讓 AI 能選含礦山地建礦村，**全程 utility-scored（非硬腳本）**：
- `_evaluate_new_outpost_location`（:1752）：含礦山地（`terrain=="mountain"` 且本格/鄰格有 ore_gold/silver）成為合法候選。
- 評分：含礦山地的 ore bonus（:1747）對**貪婪/野心 leader 加權放大**（leader 貪婪×係數），壓過 `TERRAIN_BUILD_BONUS=-10` + 低 productivity。普通 leader 仍嫌山地（礦村稀有=擬真，呼應 ruling「稀有蓄意」精神）。
- 礦村 outpost_type = `civilian`（mint allowed）。
- 解禁**僅限含礦山地**：`_find_unowned_farmable_tile`（survival/bootstrap 紮營）的 `:2173` 山地 ban **不動**（餓荒隊不會誤往山地紮營、無糧死）。礦村是蓄意富裕擴張行為，非絕境求生。

#### S3. 外部供糧迴路（不自給核心）
礦村山地 food 再生 0.5 → 必靠外部。兩通道：
- **bootstrap（push，founding）**：founding sub-team 攜帶起始 food 存量（covers N 天，撐到 mint coin → market buy 閉環）。複用 subteam 攜資源建造。
- **sustaining（pull，market）**：礦村缺糧發 food buy 單（既有 `a4c4cf8`），mint coin 付帳 → 母聚落/商隊賣糧運上山。閉「金→coin→買糧→續採」迴路。
- **believability**：糧車運糧上山（市集履約走既有同格 trade，守恆）。
- **缺口（接受，記 backlog）**：若 market 沒賣家/co-location 失敗 → 礦村 bootstrap 耗盡可能餓退（emergent 失敗=礦村廢棄，非崩潰）。母聚落主動 push 供糧（faction 內糧 haul）= 後續 enrichment（更可靠），本 slice 先靠 bootstrap+market，量測 fire 率再決定是否補 push。

#### S4. AI 開採驅動（礦村建造派工）
- founding：S2 選址回含礦山地 → 既有 `_evaluate_infrastructure` build-new-outpost 路徑 `dispatch_subteam` 派 builder 上山建礦村（複用，非新派工系統）。建造完成 `_complete_construction` 設 civilian outpost → 隊駐留 → 自動採礦（S1 既有）。
- 一旦 vault ore>10 → 既有 `_pick_facility` 評分建 mint（utility，非硬腳本，符 ruling #4）。

## 驗收

- **mint 魂 default 活**：world_sim（補 S1）跑 2yr → `g1.mint > 0`、`mint_tiles > 0`、`team_coin` 顯著增（coin 非純零和）、金礦地底量下降（真採）。
- **礦村 emergent**：含礦山地出現 civilian outpost（`[Site]` log 顯示選含礦山）；普通世界**稀有**（非每隊衝山）= 擬真。
- **不自給驗證**：礦村 food 靠 buy 單補（trace food buy fulfilled→礦村 effective_food 週期回補，非餓死即廢）。
- **守恆**：coin 只經 mint 創造（既有 CoinAudit 認 mint 為合法源）；coin_eq delta=0（mint 轉換守恆 by `_tick_mint`，既有測 `鑄幣守恆`）；InvariantAudit 0。
- **回歸不破**：S2 山地解禁僅限含礦山 + 僅富裕擴張路徑 → survival/紮營/既有平原拓殖零影響；headless 全綠（飢荒/絕境/既有 outpost 測）；TC1/4/6/7 原樣。
- **pricing 守恆隱患查**（[[project_causal_spine]] G1 待辦）：`trade_valuation ore_gold BASE_PRICE=10` vs `GOLD_TO_COIN_RATIO=20`——確認 ore_gold 一般交易 + mint 兩路 coin_eq 不破（mint coin_eq 公式已含 ore×ratio，但 trade ore_gold 用 BASE_PRICE 估值，買賣 ore_gold 後再 mint 是否雙重計值 → plan 階段驗算 + 測）。

## 檔案（預估，plan 細化）

- `scripts/simulation/world_generator.gd`：S1 礦脈保證 guard。
- `scripts/simulation/faction_ai_system.gd`：S2 `_evaluate_new_outpost_location` 含礦山候選 + 貪婪加權 ore bonus；S4 founding 走既有 build-new-outpost（多半零改或小改）。
- `scripts/simulation/resource_system.gd`：確認自格採 ore 對礦村山地 tile 運作（多半零改，驗證即可）。
- `scripts/simulation/outpost_system.gd`：確認 mint facility 在礦村 civilian outpost 可建（零改，驗證）；礦村 food buy 觸發確認（既有 `a4c4cf8` 路徑）。
- `config/world_sim.json` / `world_generator`：礦脈保證後 world_sim 應自然有礦。
- `scripts/debug/headless_test.gd`：新測（礦村建址選含礦山 / 礦村採 ore 進 vault / vault ore>10 建 mint / mint 出 coin / 礦村靠 buy 補糧不餓死 / 山地解禁僅含礦山——餓荒隊仍不上山）。
- `scripts/debug/framework_validation.gd`：S5 mint 場景由「強塞 mint_level/ore」改為**走真礦村迴路**驗（選址→採→建廠→鑄）。
- `scripts/debug/probe_stats.gd`：加 `g1.mine_founded`（礦村建立）探針（Probe taxonomy = systems owner）。

## 風險 + 緩解

- **供糧迴路脆**（最大風險）：礦村靠 market buy 補糧，但經濟 plumbing 歷史 finicky（履約 unseeded）。緩解：bootstrap 起始糧撐長 + 量測 fire 率，不穩則加母聚落 push 供糧（S3 backlog）。**measure-first**：先跑 world_sim 量礦村存活率，別預設完美。
- **礦村過頻/過稀**：貪婪加權係數 TEST VALUE → world_sim 量「含礦山 outpost 數」，過頻調低（破擬真稀有）、過稀（魂不 fire）調高。
- **山地解禁洩漏**：嚴格 `僅含礦山 + 僅富裕擴張路徑`，survival picker 不解禁 → 回歸驗餓荒隊不上山。
- **pricing 雙重計值**：見驗收，plan 驗算 ore_gold BASE_PRICE vs ratio。
- **小圖 RNG**：S1 guard 保證 ≥1 礦脈，消 world_sim 槓龜變異。

## 開放細節（plan 定）

- 貪婪加權 ore bonus 公式（`ore_bonus × (1 + 貪婪×K)` 初值 K）。
- bootstrap 起始 food 量（covers 幾天 = RESTOCK 對齊？）。
- S1 礦脈保證：只保 gold 或 gold+silver；注入量。
- `g1.mine_founded` 探針打點位置。
- framework_validation S5 改真迴路 vs 保留強塞（建議改真迴路，證端到端）。

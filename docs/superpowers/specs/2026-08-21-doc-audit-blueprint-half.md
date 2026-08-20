# docs 瘦身審計——blueprint 格(game-design.md+specs/)

status: 待用戶勾(flag-only 未動刀);systems 格另份,齊後合併呈用戶
產出:agent 全掃 2026-08-21(game-design 1704 行逐段+specs 145 檔逐檔 status);本檔=curated 清單

## A. game-design.md
### [改](事實過期/牴觸新法,18 處)
- L436-451 full-HD 正典原則+L440 near/far 描述+L144 LOD 紅線條+L185 LOD cadence+L557/577/639 分班語彙+L1137-1151 聚合模擬(遠離玩家群體運算)+L1155-1169 高重要 NPC(fidelity 綁玩家)——**全部=零 LOD/附身鏡頭新法牴觸**
- L726-746「1 Tick=10 秒」+L750-768 Turn 定義——時間重錨牴觸
- L112/140 ×5 時代 tick 尺;L442/451/256 breed 舊描述(per-capita 新法);L1105-1115+L1173-1187 玩家特權描述;L92 玩家死續玩(未寫 headless 不凍);L346 farming 舊公式;L502 失敗升級(已升格為失敗律通則)
### [刪](已收官 arc 過程殘留,5 段)
- L126-131 serial over-claim 逐版推翻紀錄/L117-118+L120-122 MERGED arc 疊寫/L1571-1618 2026-06 UI 時代四階段表/L133+L149 重複待辦
### [瘦](死數字/過期盤點→指 code/checklist,10 段)
- L273-347 綜合發展模型死公式/L348-434 統一路線圖逐項進度/L446-451 perf 死數字/L460-489 兩份 2026-07 盤點/L604-616 引擎舊數字/L550 照妖鏡清單(→checklist D4)/L789-811 世界尺度(→time spec)/L964-979 情報盤點/L1521 死常數

## B. specs/ [刪→_archive](116 檔)
**判準=已 merge/CLOSED/自標 SUPERSEDED 的過程 spec**(godview 全系列/infonet 全系列/logistics 全系列/framework F0-F4/settlement S2-S4 系列/labor v1v2/scale-econ 量測/cohesion/care-loop/recovery/desperation/junmin HOW/perf phase2 三刀/seam1-3/threat-oracle/arc1-need-oracle/晉升系列/unified-dispatch/…完整清單見 git 本 commit agent 輸出)。
特急兩檔:`2026-08-03-L1-intra-faction-distribute-depatch-HOW`(自標 ★★SUPERSEDED 別實作,標死未搬)+`2026-08-19-labor-v2-HOW`(同)。

## C. specs/ 仍活但[改/瘦](~20 檔)
- **[改] lod-redline-HOW**:整份建在 near/far 率補償上,零 LOD 後作廢(歷史留檔+標「由事件比例計算取代」)
- **[改] time-frequency-inventory**:WORLD_SPEED_MULT 記 live/收成 6h 記 live/近遠分班快照——標「舊法快照,以 time_const_check 為準」
- [瘦] survival-economy 兩檔/junmin design/長程計劃兩檔(A5 唯一 WHAT 源,瘦成 scope 骨架)/持守統一 design(B7 PARK)/L3-circuit 兩檔/missing-contact 兩檔/world-vitals(與長考閘職能重疊待釐)/subteam-idle-latch(B6 活,血證壓一行)/settlement design 刪除線收攏/breed-HOW 舊 funnel 數字
## D. 保留(新法本體 8 檔)
checklist/time-reanchor design+HOW/T0-HOW/event-proportional-HOW/observer-never-freezes-HOW/directive-stamp-HOW/owner-outpost-index-HOW

## 移交 systems 兩線索
1. 「統領 0.08→cap6」舊敘述在我格查無實體→可能活在 known_issues/progress(你格),掃時留意。
2. `2026-08-18-settlement-agriculture-HOW:17`「pop_cap=領導唯一、無據點放大」=放大器 slice 動機前提;AT_CAP=0% 後**動機需重論證**(放大器意圖本身=用戶已裁不動,動機敘述要更新)。

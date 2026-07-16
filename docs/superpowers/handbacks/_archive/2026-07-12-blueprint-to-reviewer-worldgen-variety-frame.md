---
from: blueprint
to: reviewer
status: consumed
topic: [對抗①/框外] world-gen variety 設計 refute——資源加權散布/放野/build-verify cap 框 + characterize code斷言,systems spec 前
---

# reviewer 框外①：world-gen variety 設計 refute（refute-by-default）

新概念大框（重寫世界生成核心 pick_start_positions/outpost 數/faction 生成，redirect 大工）+ 有 code 斷言。工作流：對抗① 在 00→01 前——systems 出技術 spec 前先 refute。**用不同模型/代 + 明確 refute（非 confirm）。**

審 artifact：`docs/superpowers/specs/2026-07-12-worldgen-variety-design.md`（committed）。

## refute 靶 A：資源/戰略加權散布真產「有機、變化」世界？
框主張：據點按資源價值+戰略因子評分 seeded 挑高分 → 聚落有道理且每 seed 不同。
- 攻擊：「撒在高分 tile」會不會**反而 re-regularize**——每 seed 大家都擠向同幾個資源富點（礦/肥沃），聚落又變可預測/同質，只是換個規則？資源分布本身每 seed 變，但「挑最高分」是否收斂到少數熱點 → 失去「有機散布」意圖？「有價值的地」模型是否比 key-order 更規則（只是規則在資源而非 key）？

## refute 靶 B：cap 據點數真讓 build-outpost 可驗？（前提：build-outpost 行為存在）
框主張：據點數硬上限留空地 → 「隊蓋新據點」play-time 行為可觀測。
- 攻擊：**build-outpost 行為現在存在且會 fire 嗎**？grep 驗——有沒有「隊在空地蓋新據點」的 code 路徑、organic 會不會真觸發？若 build-outpost 根本罕/不 fire（如同本 session 一堆 never-fire），那「留空地供驗」是**為一個可能不存在的行為留 headroom**＝假前提。先驗 build-outpost 是真行為。

## refute 靶 C：結構地板真保證「能跑」？放野的退化角落
框主張：≥1 勢力/≥幾隊/據點≤上限/不重疊 = 世界能跑。
- 攻擊：放野下有沒有**地板漏掉的退化世界**——如所有據點擠地圖一角（間距守但群聚一隅）、某 faction 分到 0 個可達據點（領土 share 甩到 0）、獨立隊全生在無資源死角？「能跑」≠「跑得有意義」，地板夠不夠擋「技術能跑但結構壞死」的開局？

## 前提 factcheck（file:line，grep 驗）
design §現況的 code 斷言逐一驗：
- `world_generator:62 terrain=_random_terrain(rng)` 地形已 seeded（∴ 不用做，真的嗎）
- `pick_start_positions:180` 按 tile key 順序貪婪、無 rng（＝規則+每 seed 同，真兇）
- `_plan_outposts:71` 取 rng（types/faction 分配 seeded）、`total_count` config 固定
- game_setup team placement（`_random_near`/`_random_empty_tile` seeded、main 隊錨 outpost[0]）
- 地圖 grid radius = config 固定

## 產物
verdict JSON（clean|issues + premise_contradiction + issues[claim/file_line/truth] + note）to:blueprint。issues → 我 halt 調 design；clean → 推 systems 出技術 spec。

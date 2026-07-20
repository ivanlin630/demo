---
from: implementer
to: measurer
status: consumed
topic: "[measure·★economy 敏感] god-view Slice C 市場 belief-gate → feat/godview-c@a6cf4466。★economy 對照(貿易觸發率/成交量/coin 流通/市集發現曲線)+冷啟動不死鎖(創世-nearby 出得了門)+★market-info relay 坐實傳得到(承 B R① 教訓)+doom-delta seed1337/42/4201+8 config sanity。TDD 13/13、headless 0new(2 stale WS-2b fixture 補 team_market_known)、gate 64、determinism seed1337 2mo byte-identical(md5 6b10deeb,無新 RNG)、game_sim_multi 無崩。"
---
# Hand Back: god-view Slice C（市場 belief-gate + market-discovery store）

承 dispatch `2026-07-20-systems-to-implementer-godview-C-dispatch.md`（異質 R² v4 CLEAN）。★economy measure 敏感。

## 實作摘要
branch `feat/godview-c@a6cf4466`（off local main 9d427a39；★禁 origin 落後~55）已 push（★過 installed pre-push 兩閘）。4 部：
- **① `WorldState.team_market_known`**（team_id→Set[tile_id]）market-discovery belief store，**三源**：創世-nearby（game_setup，proximity≤CREATION_KNOW_RADIUS）/ 直接親見（vision 半徑內 outpost，bounded local scan）/ relay harvest（team_known 的 order/outpost_built 訊息 market pos，★濾 outpost_level>0 避無 outpost 隊 live pos noise）。★**無新 RNG**（harvest 讀既有 entry/tile）。
- **② `_nearest_market_outpost` belief-gate**：只掃 team_market_known（非全 tiles），無已知→(-1,-1)。re-validate outpost_level>0（demolish 略）+ 排自家。
- **③ 貿易 to_task guard**：target==(-1,-1) 且**非-resident**→TASK_IDLE（roaming 無市集=無事）；★**resident 擺攤 (-1,-1) 保 TASK_TRADE**（村攤不關門，r3 regression guard）。
- **④ cleanup 只 demolish（outpost_level→0）**清所有隊此 tile known；★capture/set_owner 不清（市集還在=known 位置仍有效，習得後穩定）。

## 我的驗證
- **TDD** `godview_c_test` **13/13 PASS**（discriminating：known vs 未知市集 / demolish 清 vs capture 保 / roaming→IDLE vs resident→TRADE）。①創世-nearby ②直接親見 ③relay harvest+noise 濾 ④belief-gate nearest+無 known→(-1,-1) ⑤demolish 清 team1/2+capture 保 ⑥roaming/resident guard。
- **headless** `=== DONE ===`，3 fail = **baseline 0 new**（2 stale WS-2b trade fixture 補 team_market_known entry——商隊須「知」它巡的市集）。
- **game_sim_multi sanity**：無 SCRIPT ERROR / 無崩。
- **constitution_gate** PASS **sites=64 removed=0**。
- **determinism** seed1337 2mo 2 跑 **byte-identical，md5 `6b10deeb`**（★無新 RNG）。

## ★請你量（spec §measure，economy 敏感）
市場全知→belief-gate = 貿易目標從「全圖最近」變「已知中最近」→動 economy 行為。**非盲改**：
- **before/after doom-delta**（seed1337/42/4201）+ **economy 對照**：貿易觸發率/成交量/coin 流通、**市集發現曲線**（隊逐漸知市集經 proximity/vision/relay）。
- **★冷啟動不死鎖**：開局隊憑創世-nearby 市集出得了門（貿易/買糧不因不知市集全卡死）；relay 傳播讓遠市集漸知。
- **★★market-info relay 真傳得到**（承 Slice B R① 教訓「別假設 relay」）：坐實市集資訊 relay 機制真傳得到（order/outpost_built message harvest origin_pos/source_pos）——否則市場發現只 proximity=可能經濟卡。**★我已初驗 harvest plumbing（order params.origin_pos + outpost_built source_pos 皆騎既有 _exchange_intel relay copy），但 organic sim 中 relay 真傳達率請你坐實**（同 B 的 relay premise 驗）。
- **逐 config sanity**：8 explicit config bed 跑不崩（承 Slice B，那些是你域）。
- 你用 `godot --path .worktrees/godview-c` 跑（★禁原地 checkout）。

## 連動風險
- **貿易目標縮**（全圖→已知）=預期修（冷啟動更真實）。判準=economy 對照無崩 + 冷啟動不死鎖 + doom-delta。
- **直接親見 harvest bounded scan**（vision 半徑 per _nearest 呼叫）=局部非全圖，perf 有界（vision radius≈37 tile）——若 measurer 量到 _nearest 熱點 perf spike 請 flag。
- market_orders 本身 pre-existing 洩漏（capture/demolish 不清 market_orders）=**未繼承**（記 known_issues；team_market_known demolish-only cleanup 是正解）。

## out-of-scope
市集 GOODS/PRICES belief（賣什麼/多少錢）——order message 已傳播（殘缺市場知識湧現）。C 只管市集**位置發現**。1119=後。

## 完成判定
task 完成 = systems + reviewer 判，非自判。你量完（economy + 冷啟動 + relay 坐實）→ .qa.json/餵 blueprint 或 pre-merge to:systems。我 hold warm 等裁決。

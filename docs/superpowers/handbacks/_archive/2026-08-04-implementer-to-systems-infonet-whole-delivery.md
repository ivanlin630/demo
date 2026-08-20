---
from: implementer
to: systems
status: consumed
topic: "[資訊網 whole 全 4 slice build 完+整合 gate 綠·branch feat/info-network-whole·S-prop 99deaa80/S-herald d17cd050/S-scout d4766834/S-trade ac7d3975·各 TDD 綠(prop5/herald8/scout8/trade3)·整合:headless 3=baseline、constitution 74(god-view detector 綠=感知鐵律守)、determinism 3 跑 byte-identical MD5 34C8B74(零新 randf)·per-option util dump 證人格分化(help 務實0.640>傲0.102、scout 統領0.800>野心0.160)·calibration 常數皆錨真值(decay=TIME_DECAY_PER_TICK、util base=真severity/staleness、modulation coeff 非 fire-crank)·全量 tap(board.relay_*/help.*/scout.*/trade.peer_deal)·★whole emergent 量交你路 measurer(§5 商業 unstall/famine 解/人格分化/fog/hub 效應/economy 不爆)·⚠flag:1mo warring attrition 0.68%→0 teams 84→86=可能 emergent 合作 vs 戰鬥抑制,measurer 跨 seed/月斷·perf-watch:_market_peer_trade O(teams)/市集到訪。待你 R² 融合驗→measurer whole 量→blueprint JUDGE。"
branch: feat/info-network-whole
base: main b52cd5e5
commits: [S-prop 99deaa80, S-herald d17cd050, S-scout d4766834, S-trade ac7d3975]
---

# 資訊網 whole — 全 4 slice build 完 + 整合 gate 綠（接既有 seam、非新引擎）

一 root 三症（propagation dead-end :79）的通例修。4 slice 各 commit+TDD 綠、整合 gate 綠。**whole emergent 量交你路 measurer**（spec：量=whole 一次）。

## 4 slice（各 commit、TDD 綠）
| slice | commit | 做 | TDD |
|---|---|---|---|
| **S-prop** Part1a | 99deaa80 | 看板 relay hub：訪客抵市集 deposit 自知異地單→累積再輻射（先後訪即交換、修 :79 共位 dead-end）；decay 錨 TIME_DECAY_PER_TICK | 5/5 |
| **S-herald** Part2a | d17cd050 | 求援 option→TASK_HERALD：needy+知施助者→派信使子隊送 need 訊到領主 team_known（修症1） | 8/8 |
| **S-scout** Part2b | d4766834 | 偵察 option→TASK_SCOUT：領主查子民 stale belief→帶 fresh need 回 team_known（active 症1） | 8/8 |
| **S-trade** Part3 | ac7d3975 | 交易面 broaden：訪客與同格非 owner peer 交易任何 store、keep-line=reserve 守（修症 iv） | 3/3 |
| **Part4 famine** | (通) | Part1+2 通→food 賣單/求援達餓隊→food_seek_target 有值→relocate/賑濟（無獨立修、量時驗） | — |

## 整合 gate（全綠）
- **headless 3=baseline**（p2a/197/rung pre-existing；新 3 option 入 rank + 新 tap 零新失敗）。
- **constitution PASS 74**（★god-view detector 綠——大量 belief/team_known/deposit 工作**無新 indexed 他隊 live 態讀/whole-map 掃**；感知鐵律守）。
- **determinism 3 跑 byte-identical MD5 34C8B74**（≠baseline 4D6FCB46=info-network 真改行為；byte-identical=**零新 randf 於 deterministic 路**；herald/scout deposit/board relay/peer trade 皆純算術+既有 seed 路）。
- 非凍：teams 84→86（成長非凍）。⚠ **flag：1mo warring attrition 0.68%→0**（info-network→更多 trade/help→早期少戰？=可能 emergent 合作 **vs** 戰鬥抑制）——**measurer 跨 seed/多月斷健康 vs 破**（誠實 flag、非宣稱）。

## ★守則自查（R² 硬守項）
- **人格非死常數門檻**：求援/偵察 applicable=need/knowledge-based（有 need+知對象 / 有 gap+在乎），**零 runway<X/沉默>N 死常數**；propensity=人格 util。
- **genuine 非 crank + per-option util dump**（R² anti-crank）：util base=**真期望價值**（help=真 severity DERIVED from runway 缺口；scout=真 staleness=belief age/SCOUT_TIMEOUT），人格只 MODULATE。**dump 證分化**：help 務實(求生欲1)**0.640** > 傲(野心1)**0.102**；scout 統領1 **0.800** > 野心1 **0.160**。
- **★calibration 常數皆錨真值（R² ①、同 idle-labor PER_HAND 紀律）**：board decay=`SimMessageSystem.TIME_DECAY_PER_TICK`（既有非 invent）、BOARD_RELAY_CAP=32（perf/memory bound 非 fire-crank）、HELP_PRIDE_SUPPRESS=0.6/SCOUT_AMBITION_NEGLECT=0.5（modulation coeff、非「能讓求援 fire」的 crank）、herald/scout cost=implicit argmax opportunity（無 invent cost 常數）。全 TEST VALUE 標 + rationale 註。
- **感知鐵律**：載體物理 belief-pos travel（無 belief→不 applicable/不派）、延遲（走路耗 tick）、board relayed 帶 decay stale；deposit 只在物理所在/co-located。
- **need-gated**：severity/staleness=0 → 不 fire。**economy 不爆**：peer trade keep-line=reserve 守（TDD 驗 food≤reserve 不賣）。

## 全量 tap（餵 measurer）
board.relay_deposit/read/prune/evict（Part1）；help.herald_dispatched/delivered/need_deposited/timeout（2a）；scout.dispatched/info_returned/timeout（2b）；trade.peer_deal（Part3）。

## ★待你 / 交 measurer（whole 一次量）
- **§5 商業 unstall**：trade.deal/convoy.dispatch/order_fulfilled 真 >0（多床）。
- **famine 解**：distribute.dispatch/food_delivered >0（領主經傳到 belief 賑濟）+ relocate（food_seek_target 獲值）。
- **人格分化**（per-option util dump 傲少求/關切多查）+ **fog 保住**（遠/敵 stale）+ **★hub 效應**（R² ②：熱門市集造訪頻率 + belief freshness 分佈→是否功能 near-global-awareness；board.relay_* taps 就位，measurer 量 freshness 分佈；若功能逼近全知→調 board decay/cap/訪問成本）。
- **economy 不爆**（keep-line 不空掏）+ **⚠attrition 0→? 健康性**。
- perf-watch：`_market_peer_trade` iterate 同格 teams per 市集到訪（無 tile→teams index）；若 measurer §量顯著→記 known_issues。

★誠實 measured 才宣稱（[[feedback_verify_execution_end]]）。待你 R² 融合驗 → measurer whole 量 → blueprint JUDGE → 用戶驗收。

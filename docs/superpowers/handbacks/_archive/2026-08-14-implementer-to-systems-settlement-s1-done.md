---
from: implementer
to: systems
status: consumed
topic: "[settlement S1 DONE·feat/settlement-s1 commit f9817f6d]死亡釋放+目標池撿现成=解鎖鬼城靠既有timer·★硬禁2 code點守: ①S1a world_state.erase_teams 單pass over world.tiles 配既有dead:Dict O(1)(非O(dead×tiles))→dead tid owned tile outpost_owner=-1 ②S1b faction_ai _find_unowned_farmable_tile(一code點)先掃team_market_known(belief discovered set)無主既有outpost撿现成優先、無→fallback原邻7格空農地·未碰_tick_solo_settle convert/occupy/未增搶城動詞·到達後既有分流(空地establish_crude_camp/既有outpost _evaluate_outpost_takeover 3天既有timer set_owner)·感知鐵律touch-point分責(目標選擇=belief只掃team_market_known非god-view、抵達timer讀腳下live合法)·驗:settlement_s1_test 13/13 PASS+headless 0-new(既有finder 2 assert仍PASS)+constitution 75+determinism seed1337 1000t三跑byte-identical=728d62ef(無新RNG)·fp intended-change(解鎖認領行為變、baseline差量→measurer)·★measurer bounded gate:鬼城owner死id→-1、認領真fire(撿现成>蓋新)、端到端(團到-1 outpost timer認領)、不over(先到先得無雙認領)·★flag:reclaim距離無cap靠team_market_known belief自然bound(vision/relay習得)、若measurer見starve-en-route再議距離閘·請merge-gate硬讀→measurer→綠merge→S2(L0階梯)"
branch: feat/settlement-s1
commit: f9817f6d
---

# settlement S1 DONE — 死亡釋放 + 目標池撿现成（解鎖鬼城靠既有 timer）

feat/settlement-s1 commit `f9817f6d`（off main；已 push）。★**硬禁 2 code 點守住**。

## fix（2 code 點、非新認領動詞、既有 timer/travel 複用）
### ①S1a 死亡釋放 — `world_state.gd erase_teams`
死團 erase 漏 `outpost_owner` → 死團 tile 永掛死 tid=鬼城累積。加**單 pass over `world.tiles`** 配既有 `dead:Dictionary` O(1) membership（同 :315 `for otid...if dead.has` pattern、**非每 dead team 各掃全圖 O(dead×tiles)**）→ dead tid owned tile `outpost_owner=-1`。

### ②S1b 目標池擴充 — `faction_ai_system.gd _find_unowned_farmable_tile`（一 code 點）
home-seeking 靶先掃 **belief-known（`team_market_known`=vision/relay 習得 discovered set）無主(owner==-1)既有 outpost(level>0)** 為候選、**撿现成優先**（修缮 << 新建工期）；無 → fallback 原邻 7 格空農地新建。
- 到達後**既有分流**（本 slice 不新增動詞）：空地 → `establish_crude_camp`；既有 outpost → `_evaluate_outpost_takeover` 站滿 `OUTPOST_TAKEOVER_DAYS=3` 天 → `set_owner`。

## 命門守
- **感知鐵律 touch-point 分責**：目標選擇（旅行前決定走遠方 -1 據點）=**須 belief**（只掃 `team_market_known` discovered set、**非直掃 `world.tiles` god-view**；讀 known tile live 結構=既有 market-finder 同慣例）；抵達後 timer 讀腳下=live 合法（既有 :5118 `team.tile_pos` 自站處）。
- **硬禁守**：只動這 2 點；**未碰** `_tick_solo_settle` convert 分支 / `occupy` / **未增任何搶城 action**。
- 無新 RNG。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `settlement_s1_test`（新 TDD） | **13/13 PASS**：①erase 死團 tile owner→-1、他隊/無主不動 ②未 belief-known 鬼城不撿(感知鐵律)/belief-known→撿现成優先/有主退候選 ③端到端 團站 -1 outpost 3 天→既有 timer set_owner ④regression 自家 outpost 不撿、level>0 `establish_crude_camp` 拒不覆蓋 |
| headless | **0-new**（既有 `_find_unowned_farmable_tile` 兩 assert 仍 PASS：`team_market_known` 空→fallback 路徑不變） |
| constitution_gate | **PASS sites=75** |
| determinism | seed1337 1000t **三跑 byte-identical=`728d62ef`**（無新 RNG） |
| fp | **intended-change**（S1a+S1b 解鎖認領=行為變；baseline 差量→measurer bounded bed） |

## ★measurer bounded gate（綠才 merge）
- 鬼城 owner 死id→-1（S1a）。
- 認領真 fire（**撿现成 > 蓋新** 於 home-seeking）。
- 撿现成端到端（團到 -1 outpost → 既有 timer 認領）。
- **不 over**（先到先得無雙認領、既有 :5127-5131 check-and-set 同步）。
- （seed1337 1000t 短窗鬼城未必積夠 → 用 `seeded_warring_bed` 長窗 WARRING_MONTHS + baseline diff。）

## ★flag（呈報、非自加）
reclaim 距離**無顯式 cap**——靠 `team_market_known` belief 自然 bound（只撿 vision/relay 習得的鬼城、非全圖）。若 measurer 見**餓死途中**（desperate 團 travel 遠鬼城 starve-en-route），距離閘再議（=新 logic、硬禁範圍外、須你/藍圖裁），非自加。

## 路
你 merge-gate 硬讀（2 code 點 + 感知鐵律 belief-gate + 既有 timer 複用無新動詞）→ measurer bounded → 綠 merge → **S2（L0 階梯）**。地基 KEEP。

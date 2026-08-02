---
from: systems
to: blueprint
status: consumed
topic: "[god-view 殲滅 arc 真實 scope·遠大於『3+創世』·含我 dead-code 誤訂正+2 個待你 WHAT 裁] 異質 audit(git-blame+讀 caller)盤點:economy 前 god-view 殘留=6 slice(A-F)非 3。★我的錯:『path_system 死碼』全錯(我 grep glob bug `**/*.gd` 漏頂層檔)——實 11 production caller 讀 live 位=live god-view leak=最大塊 Slice D,非死碼。invariants:174+memory 已訂正。scope:A=slice2 3點(在飛)/B=創世全知(game_setup:569-578,8/11 config 用 explicit→多數 sanity run 開局全知,待你裁 intentional?)/C=has_food_market(真後門+doc 衝突:invariants:186 說 market 公開地標豁免 vs game-design:322 說後門,待你裁哪個)/D=PathSystem 位置 leak(11 caller+threat 核心信號,最大,需 measure before/after)/E=平行 dispatch 路(_commit_conquest_attack/_try_join_target/envoy/strategic 未被統一 arc 掃到)/F=fallback-to-live 反模式(.get(tile_pos,live)→sentinel,一次過清幾個)。+8 死 *_pos 欄(landmine 便宜清)。已補 6 leak 全驗無回歸。建議序見內。"
---

# god-view 殲滅 arc 真實 scope（遠大於「3+創世」）

## ★先認我的錯（dead-code 誤，源=我 grep bug）
我本 session 說「`path_system` estimate_catch_up/observe_velocity/predict_intercept = 死碼、零 production caller、勿復活」——**全錯**。根=我 grep 用 `scripts/simulation/**/*.gd`，**`**` glob 漏掉頂層檔**（faction_ai_system.gd 直接在該目錄下未被配到）→ 假 dead。**實有 11 production caller**（faction_ai finder 族 :201/289/1364/2087/3537/3566/3596/3645/3677 + `threat_assessment:27` 核心威脅信號）以 `trusted=true` 跳 discovery 讀 live 位置 = **live god-view leak**。異質 audit 靠 git-blame + 讀 caller 抓到。**invariants:174 + [[project_time_scale_wave]] 已訂正**（死碼→live 待修）。你當初 ratify 的「死碼 landmine」也是建在我這 grep bug 上=一起訂正。**教訓：我 grep 不可靠（glob bug），scope-critical audit 用 exhaustive（git-blame/多形式）非單 grep。**

## economy 前 god-view 殘留 = 6 slice（audit 盤點，file:line 坐实）
| slice | 內容 | 大小 | 待裁? |
|---|---|---|---|
| **A** slice2 3點 | threat_pos(ctx:192)/absorb(ctx:369)/invite 距離 | 小·**在飛** | — |
| **B** 創世全知 | `game_setup:569-578` explicit-mode all-pairs `team_discovered` seed。**8/11 config 用 explicit**(world_sim/warzone/tyrant/demo/merchant/survival_start/game_sim_test/econ_bed)→多數 sanity/demo run **開局全知** | 中 | **★你**:explicit 全知=intentional scenario 便利 or bug? |
| **C** has_food_market | `_nearest_market_outpost:2065-2078` 全 tiles 掃無 discovery gate=真後門 | 小-中 | **★你**:doc 衝突 invariants:186(market 公開地標豁免) vs game-design:322/known_issues:37(後門待 belief-gate),裁哪個 |
| **D** PathSystem 位置 leak | **最大**：11 caller + threat_assessment 核心信號讀 live 位作 reachability/eta。stats 已 belief-gate 唯 position leak | **大** | 需 measure before/after(改 threat/finder 距離行為) |
| **E** 平行 dispatch 路 | `_commit_conquest_attack`(confident 攻擊繞 belief_pos)/`_try_join_target`(subteam JOIN 繞)/envoy tracking/`strategic_ai` encirclement+breakout——統一 arc(序1-8)沒掃到的 legacy 路 | 中 | — |
| **F** fallback 反模式 | `.get("tile_pos", target.tile_pos)` 缺 belief 時默認 live(違「無估=保守」)——envoy/encirclement/等幾處。**一次機械 pass 清幾個** | 小 | — |
| +死 *_pos 欄 | ctx 8 個 `*_pos` 從 live 填但**沒消費者**(landmine)。便宜清 | 微 | — |

**已補 6 leak（1a-1f）audit 全驗仍 belief-gate 無回歸** ✓。

## ★2 個待你 WHAT 裁（我不越界）
1. **創世 explicit-mode 全知**：是**scenario authoring 便利**（某些劇本要開局全知）還是**bug**（該全 belief-based 從創世）？8/11 config 用 explicit 影響大。你定 → 我 spec。
2. **has_food_market doc 衝突**：`invariants:186` 留「market=公開地標、豁免 belief」（統一商業 arc 裁）vs `game-design:322`/`known_issues:37`/你 2026-07-19 handback 說「god-view 後門待 belief-gate」。**兩者矛盾**，你裁哪個為準（market 買賣憑公開廣播 or 憑 belief 聽過），我改 invariants 對齊。

## 建議序（HOW，你調）
1. **A**（slice2，在飛）先落。
2. **F + 死 *_pos 欄**（機械便宜清，一 pass，closes several + 除 landmine）。
3. **E**（平行 dispatch 路，接統一 arc 精神 belief_pos）。
4. **D**（PathSystem，最大，需 measure before/after threat/finder 行為漂移）。
5. **B + C**（待你 2 個 WHAT 裁後 spec）。
6. 全落 → **零 god-view gate 綠**（constitution_gate 現只抓 task 指派，需擴抓 god-view 讀 or 一次性 audit 證零）→ 才 economy。

## economy 前差多少（你問的）
**差 6 slice**（非 3）。A 在飛，F/E/D 是主工，B/C 待你裁。**這比原估大**——但正是你/用戶要的「框架零殘留才判 economy」：has_food_market 等後門不修，economy 診斷就在汙染資料上。我不 sugarcoat scope。

## 溯源
異質 god-view audit(git-blame+讀 caller,42 tool use);我 grep glob bug 訂正(invariants:174+memory);blueprint 改序(框架先 god-view 殲滅);[[project_unification_matrix]] 零殘留閘;doc 衝突(invariants:186 vs game-design:322)。

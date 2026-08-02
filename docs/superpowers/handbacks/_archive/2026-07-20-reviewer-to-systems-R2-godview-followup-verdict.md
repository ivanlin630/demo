---
from: reviewer
to: systems
status: consumed
topic: "[R² verdict·god-view follow-up·CLEAN + ③baseline 訂正] ①jhost belief_pos 同 1119 CLEAN(gv_teamstate fingerprint 真 drop=removed)②enemy_outpost proxy ACCEPTABLE(store-free/軟penalty/membership-proxy 非真position-belief,附誠實標籤)。★③訂正:enemy_outpost 保全圖 loop→gv_mapscan fingerprint 仍在→應 RE-CLASSIFY gate-ok(belief-filtered legit)非「移除」;唯 jhost 真 removed。④無 RNG。"
---

# R² verdict：god-view follow-up（enemy_outpost + jhost）

**VERDICT: CLEAN（+ ③ baseline 訂正）** — 兩 fix 方向對；enemy_outpost proxy 可接受（附誠實標籤 + baseline 分類訂正）。`premise_contradiction: false`。factcheck 對 HEAD `c13b3876`。

## ① jhost belief_pos gate → CLEAN
`belief_pos(state, team.team_id, _jhost)` 取代 `state.teams[_jhost].tile_pos`；`_jpos==(-1,-1)→_reachable=false`。同 1119/Slice D position 範式（無 belief→不可達，合 null-belief-flee）。`team.tile_pos`=自身（god-view 自己合法）不動。→ **gv_teamstate indexed read 消失 → fingerprint 真 drop = removed=PASS**。✓

## ② enemy_outpost proxy → ACCEPTABLE（附誠實標籤）
belief-gate：`if belief_pos(leader.team_id, owner.team_id)==(-1,-1): continue`（只避「有 owner belief=見過/聞得」的敵據點）。
- **imperfection（誠實 vet）**：這是 **membership-proxy 非真 outpost-position-belief**——(a) gate 用 owner **last-seen 位存在性**、(b) gate 後仍讀 outpost **live `tile.tile_pos`**（見過 owner roaming ≠ 見過其據點，卻用據點真位）。so「見 owner→用據點真位」殘一絲 leak。
- **但可接受**（軟 penalty 場景）：①**store-free**（復用 best_estimate，不建 team_outpost_known 三源 store=Slice C 級重工）②**軟 penalty**（建近敵-分非硬排除）容忍 imperfect 高③語意「避已知敵」合理④真 store 對軟 penalty = **over-engineering**（不值）。
- **實務 leak 減 real、行為影響小**：site-selection 是 local（近己土建址），min-dist 到**最近**敵據點通常=**已知本地敵**（proxy 幾乎不濾掉它）；proxy 只濾遠方未知敵（對 local 選址評分影響微）。→ **修 god-view 純度、行為變化小**（低 measure 風險）。
- **★要求（非 blocker）：code comment 誠實標**「membership-proxy（見 owner→避其據點真位），非真 outpost-sighting belief;軟 penalty 容忍;真 store 另評若日後需硬 gate」——免日後誤讀為「outpost 位真 belief-gated」。

## ★③ baseline 訂正：enemy_outpost = gate-ok 非「移除」
spec/handback 稱「2 CANDIDATE-LEAK 註行**移除**」——**對 jhost、錯 enemy_outpost**：
- **jhost（gv_teamstate）**：belief_pos 取代 indexed read → fingerprint 真消失 → **移除**（removed=PASS）✓。
- **enemy_outpost（gv_mapscan）**：fix **保留 `for tile_id in state.world.tiles` 全圖 loop**（只加內部 belief filter）→ **gv_mapscan fingerprint 仍在**（detector 抓 loop signature，非 loop 內容）→ **不能「移除」，應 RE-CLASSIFY 為 `# gate-ok`**（belief-filtered geo 掃=legit，同其他 legit-geo 地形掃）。
- ∴ baseline 變更 = jhost 註移除 + **enemy_outpost 註改 CANDIDATE-LEAK→gate-ok（belief-filtered，非全敵瞬知）**。**別把 enemy_outpost 當「fingerprint drop removed」**（loop 還在，會漏未來若有人拿掉 belief filter 卻不觸 detector）。gate-ok 標註保留 detector 對此 loop 的可見性。

## ④ 無新 RNG → CLEAN
belief_pos 純讀。determinism 保。

## 回覆
CLEAN → dispatch。impl pre-merge R² 重點：①jhost belief_pos（gv_teamstate 真消失）②enemy_outpost belief filter + **comment 誠實標 membership-proxy** + **baseline 該行改 gate-ok（非移除，loop 還在）** ③無殘 live read（jhost）/全敵瞬知（enemy_outpost 已 filter）④measure：enemy_outpost 選址/衝突率 doom-delta（behavior-sensitive，arguably 更多衝突=更好戲藍圖看數）。

——arc 收尾誠實度：jhost=真 removed；enemy_outpost=**belief-filtered gate-ok（非零 loop，是合法 filtered loop）**。「真 zero-untracked-god-view」宣稱要精確：**zero-untracked-LEAK**（enemy_outpost loop 仍在但 belief-filtered=tracked legit，非 leak）。detector 保持對此 loop 可見（gate-ok）才是誠實收官，非「移除當沒事」。

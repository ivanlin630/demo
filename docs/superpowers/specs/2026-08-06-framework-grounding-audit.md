# 框架收尾 grounding audit（systems、measure-first、非盲改）

status: IN-PROGRESS（行為線 batch1 done、續行為線+結構線）
owner: systems（HOW）→ blueprint 據真數字 spec 兩硬綠 program
date: 2026-08-06
溯源：復甦 arc 收官 → 用戶排序 A 觸發框架收尾兩硬綠大工程。★blueprint kickoff：grounding audit 非盲改（roadmap l.356「剩項先 R①-verify 真缺否」、oracle 稽核 over-count 3 次前科）→ 逐條 re-grep 實證 still-live 非假設 stale。

## ①行為線 grounding：§殲滅清單 A 殘留非框架閘 re-verify
**格式**：條目 | still-live? | 閘型(硬門檻/override/RNG/god-view) | de-patch 靶 or 已修

| 條目 | file:line | still-live? | 閘型 | 判定 |
|---|---|---|---|---|
| `_threat_recent` 硬 gate | faction_ai:4385 | ❌ | (硬門檻) | **已修**：「取代反應式 _threat_recent 硬 gate、純人格+狀態零 randf」（roadmap 序4 done）。stale。 |
| `has_food_market` 全圖掃 | decision_context:304 / faction_ai:2957 `_nearest_market_outpost` | ❌ | (god-view) | **已修**：讀 `state.team_market_known`（`_harvest_market_known`=vision 半徑親見+relay）=belief-gated 非全圖掃。god-view Slice C 已建 market-discovery belief store。stale。 |
| diplomatic betrayal RNG | diplomatic_ai:325 | ⚠️ legit | (RNG) | **legit tie-break**（非殘留）：driver≥HARD→deterministic、僅門檻邊界(MIN..HARD)小 stochastic tie-break（invariants 已祝 blessed）。**但未 inline gate-ok 標**（machine-gate 覆蓋待確認）。 |
| 創世全知 all-pairs | game_setup:592-621 | ❌ | (god-view) | **已修**：god-view Slice B「創世知識 seed(②proximity+③parent 非全知)取代舊 all-pairs 全知」、`omniscient_discovery` default false（僅純機制 test）。stale。 |
| **PathSystem/threat 位置 leak** | threat_assessment:23/39/40 讀 `other.tile_pos` **live** | ⚠️ **TBD-live** | (god-view) | ★**genuine 殘留候選**（最大 D 項）：threat_assessment 讀 `other.tile_pos` live 作 dist/reachability。stats 已 belief 化（invariants:193 _power_ratio fallback）、但**位置似仍 live**。需細查：caller 傳 live team 還是 belief-pos？threat DEFEND 走 belief last-seen（invariants:174 intended）與此讀 live 是否矛盾。 |

★**batch1 信號**：前 5 條 = **4 已修(stale) + 1(D 位置 leak)genuine 候選**。多數 stale=**正證 re-verify 紀律**（盲改會白工已修項）。

### 續 verify（TBD、下批）
- 紮營/獵食硬門檻（options.gd forage/camp applicable）
- `applicable` DESPERATION 天閾（options forage/buyfood/自救建田 DESPERATION_DAYS gate）
- tribute override（diplomatic/interaction）
- near-far LOD 非中性（sim_runner；已知 partition 讀 player_pos 非 god-view、「非中性」疑指 observer/RNG）
- D 位置 leak 細查（threat_assessment caller + PathSystem 11-caller live-pos 現況）
- **★constitution_gate 閘型覆蓋缺口**：現抓 taskarbiter(引擎外 task 指派)+ 部分 rng/gv/threshold/route/early_return（type 分布：taskarbiter 27/gv_mapscan 10/route 10/threshold 9/dispatch 8/early_return 6/rng 3/gv_teamstate 1）。缺哪些閘型沒 machine-prove（值閘 override / god-view 位置 leak / 控制流 return-gate）→ 零殘留機器證缺口。

## ②結構線 grounding（TBD、序=先行為後結構）
- 所有權/耦合 map：clean-extractable(marginal/message/labor 2-3 ref) vs 纏。
- ★faction_ai 5018 行內部拆解：行為 chunk 可抽進引擎自然瘦 / 剩切哪幾個有邊界模組 / 對接介面。

## output → blueprint
兩份 grounding 清單（行為線閘表 + 結構線 map）→ blueprint 據真數字 spec 兩硬綠 program（非憑印象）→ R①→R²→slice 切。

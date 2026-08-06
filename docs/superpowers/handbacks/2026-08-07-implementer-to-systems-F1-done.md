---
from: implementer
to: systems
status: consumed
topic: "[F1 threshold 死常數人格化 DONE·①硬綠首 slice·feat/framework-F1 commit b0e5a41f]靶A DESPERATION entry-gate 人格化:DecisionTerms.desperation_entry_threshold(膽/懼/慎重 modulate、中性=raw 3.0 零漂)、★單一計算點 gather 一處算 6 處 survival-entry applicable(返家/併入/紮營/乞食/買糧/遷移找糧)共讀+買料(>=)讀同值保 mutex(§2.5.1)、★物理錨 DESPERATION_DAYS raw 留(need-anchor faction_ai:1577/1665/3216 不動、§2.5.3)、★entry vs PRIO_SURVIVAL 獨立(§2.5.2)。靶B MINING_GREED 硬 gate(貪婪+野心>=1.1)→ ore bonus 連續 ∝ greed×WEIGHT、山懲自然差異化、零損失無 1.1 懸崖。genuine 非 crank(乙教訓)。驗:f1_test 5/5+constitution 75(去硬 gate 無新 site)+headless 0-new+★F1 fp 對 F0 baseline 22 same(中性零漂)+5 changed(recovery 忠/傲村+warring 長 tick 人格分化=intended)+determinism byte-identical(EAA56B43 純值零 RNG)。baseline 更新 ce201650(F1 行為新參考、舊 c31a43a7 replaced)fake-coverage 全域 vary。★註:spec 引 5 處行號 stale(覓食用 FORAGE_VIABLE_POP 非 DESPERATION)、實 6 survival-entry 皆統一。請 R²(核單一計算點+entry-仲裁分離+物理錨 raw+genuine+fp 分化 intended+baseline 更新)→measurer→QA→merge=F1 收→F2。"
branch: feat/framework-F1
commit: b0e5a41f
---

# F1 threshold 死常數人格化 DONE（①硬綠首 slice、行為變）

feat/framework-F1 commit `b0e5a41f`（已 push、pre-push constitution PASS 75）。①人格化行為變 slice、F0 fp 預期分化（intended、與②結構 byte-identical 分不混）。

## 靶A DESPERATION entry-gate 人格化（HOW §2.5 寫死全守）
| 守 | 實作 |
|---|---|
| ★單一計算點（§2.5.1） | `DecisionTerms.desperation_entry_threshold(leader_values)` = 膽/懼/慎重 modulate；`DecisionContext.gather` **一處**算 `c.desperation_entry_threshold`；**6 處** survival-entry applicable（返家/併入/紮營/乞食/買糧/遷移找糧）+ 買料（`>=` mutex 補集）**共讀之**（禁散點各改）。 |
| genuine 非 crank | 慎重↑/求生欲↑→threshold↑（謹慎/懼早進絕境）；好戰↑（膽/冒險）→threshold↓（膽大撐更低糧才進）。**中性(全0.5)=raw 3.0 零漂**（fp 只對人格分歧隊分化）。真風險容忍、禁調逼 fire 率（乙教訓）。 |
| ★物理錨分離（§2.5.3） | `DESPERATION_DAYS` 作 need-anchor（買糧量/relief=DESPERATION×pop×0.8、`faction_ai:1577/1665/3216`）**留 raw 不動**、只 entry-gate 人格化。 |
| ★entry vs PRIO_SURVIVAL 獨立（§2.5.2） | 只動 candidate 生成層 applicable、不動 task 仲裁優先序（PRIO_SURVIVAL 未碰）。 |

★**註（呈你、透明）**：spec §1 引 5 處行號（:100/152/183/193/263）**stale**——實 options.gd survival-entry `<DESPERATION` 為 **6 處**（返家/併入/紮營/乞食/買糧/遷移找糧；★**覓食**用 `FORAGE_VIABLE_POP` 非 DESPERATION、非此類）。已全 6 統一讀 threshold（+買料 `>=` 補集）＝完整覆蓋、無散落 raw（勝 spec 5 引、守統一紀律本意）。

## 靶B MINING_GREED persona-gate → soft weight
`_evaluate_new_outpost_location`：去 `is_greedy_leader` 硬 gate（貪婪+野心≥1.1）→ **ore bonus 連續 `∝ (貪婪+野心)×MINING_GREED_WEIGHT`**；山地地形懲罰自然差異化（普通 leader 小 bonus 壓不過→不建礦[稀有擬真保留]、貪婪壓過→蓄意富裕擴張）。**零差異化損失**（貪婪隊 bonus ≥ 舊 gate 值）、**無 1.09→1.1 懸崖**。ore 山搜索亦去 greed gate（差異化改由連續 score 定、普通 leader 搜到但不選→fp 不變）。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `framework_f1_test` | **5/5 PASS**（persona threshold 三態[中性3.0/謹慎5.1/膽大1.5] / entry-gate 讀 persona[乞食] / 買糧-買料 mutex / 物理錨 raw / mining greedy 選礦連續無懸崖） |
| constitution_gate | **PASS sites=75**（去硬 gate 無新 site；entry 統一點無散閘） |
| headless | **0-new**（Team23建設×2/弱目標/p2a/197/rung 皆 pre-existing baseline） |
| ★F0 fp 分化（行為變驗） | F1 對 F0 baseline：**22 same（中性零漂）+ 5 changed**（recovery:1337/42 @1000/2400[忠/傲村人格分化]+ warring:1337@2400[長 tick 累積]）＝**intended 人格分化**（早期 tick/中性床零漂、人格分歧+長 tick 才分化=正確 signature、非 regression） |
| determinism | recovery re-run **byte-identical EAA56B43**（F1 formula 純值 modulate、零 global RNG）→ F1 決策仍 deterministic |
| baseline 更新 | `fingerprint-baseline-ce201650.json`（F1 行為、**為後續②結構 slice 新參考**；舊 F0 `c31a43a7` replaced）+ fake-coverage 全域 vary + signals OK |

## 路
1. **你 R²**（核：單一計算點[禁散點] + entry-仲裁分離 + 物理錨 raw + genuine 非 crank + fp 分化 intended[22 same/5 changed] + baseline 更新 ce201650 ratify + spec 5→6 site 訂正）。
2. → measurer 量（靶A entry 分化[膽大撐久/謹慎早進]+物理錨不變 + 靶B greed 連續無懸崖）→ QA → merge = F1 收（硬綠①推進）→ F2 純程序模組切。

地基 KEEP。

---
from: reviewer
to: systems
status: consumed
topic: "[R② verdict] mark batch2 7 terminal-legit：CLEAN，逐 fingerprint 查無 collision（含補查 :3092/:3118 兩處 systems 未列但同批合法的額外命中）。可 apply 標。附註：seam#2 registry 已 merge 進主線，output_scale/agg_mode 兩欄位確認落地正確（呼應先前 R② HALT 要求）。"
---

# R② 判決：mark batch2（7 terminal-legit）— CLEAN

## 附註：seam#2 已 merge，先前 HALT 要求已落地
核對 `_facility_deficit` 現況（`faction_ai_system.gd:3067-3123`）時發現 seam#2 registry 化已 merge 進主線。**先前本 reviewer 對 seam#2 HALT 的兩項要求（apothecary ×0.5 純量、workshop/armorsmith 聚合模式不同）已正確落地**：`FACILITY_DEFICIT_DEF`（:3067-3078）加了 `output_scale`（apothecary=0.5，其餘=1.0）與 `agg_mode`（workshop="min_per_res"、其餘="pooled_sum"）兩欄位，`_facility_deficit` 泛型 evaluator（:3097-3119）依欄位分支計算，非單一無條件迴圈。C 類（farming/weaponsmith/mint）改 registry `special` dispatch 到獨立 `_deficit_*` 函式（:3127-3145），與 spec 目標一致。此為背景資訊，非本輪判決標的。

## 逐 fingerprint 核實（含補查同 fingerprint 下有無漏列的合法命中）

1. **`_send_diplomacy_message::rng`**（`diplomatic_ai_system.gd:174`）：核實 `state.player_forced_event_id = str(randi())`，event-ID 生成，函式全文（:162-187）只此一處 `randi()`，無其他 RNG 混入，legit。

2. **`try_proactive_diplomacy::rng`**（`diplomatic_ai_system.gd:130`）：核實 `if randf() < _caut2*_caut2*_caut2: return`，慎重³ 陡曲線人格加權機率，同 Bucket C 已判 legit 案③族。

3. **`_facility_deficit::early_return`**（`faction_ai_system.gd`）：systems 引 `:3086`（`if entry.is_empty(): return 0.0`）。**逐行掃全函式（:3082-3123），補到 2 個 systems 未列的同 fingerprint 命中**：`:3092`（`if tile.weaponsmith_level==0 and tile.armorsmith_level==0: return 0.0`，smeltery facility-gating guard）、`:3118`（`if total_tgt<=0.001: return 0.0`，pooled_sum 分支空目標 guard）。**三處皆同型 guard**（entry 缺失/facility 未建/target 為零），無人格決策混入，無 collision，legit。

4. **`_facility_deficit::threshold`**（`faction_ai_system.gd`）：systems 引 `:3104`（`if tgt<=0.001`）。**掃全函式補到 `:3118` 也同時符合 threshold regex**（`<=0.001` 本身即比較式，與 early_return 各自獨立命中同一行，非互斥）。兩處（3104 min_per_res 分支 / 3118 pooled_sum 分支）皆「該資源無 need+demand → 不驅 deficit」的 world-mechanic 空目標判斷，同型，legit，無 collision。

5. **`_facility_terrain_fit::threshold`**（`faction_ai_system.gd:3043-3058`）：systems 引 `:3050`（apothecary）。**掃全函式補到另 3 處同型命中**：`:3052`（smeltery/weaponsmith/armorsmith 三設施共用）、`:3054`（mint）、`:3057`（stable）——皆「鄰格資源存在>0.0→地利加成 else 基準值」的地理世界機制，`:3046`（clampf harvest_factor）/`:3048`（workshop，無數值比較）不匹配 regex 不計入。4 處命中同型，legit，無 collision，未見任何人格加權或需求判斷藏入。

6. **`_pick_facility::early_return`**（`faction_ai_system.gd:2957-2983`）：systems 引 `:2973`（`if best=="": return {}`）。掃全函式僅此一處符合 same-line if:return（`:2979-2980`/`:2981-2982` 皆跨行 if-block，不觸發 regex——detector 的已知限制，非本批問題）。單一 guard，legit，無 collision。

7. **`_pick_facility::threshold`**（`faction_ai_system.gd`）：systems 引 `:2968`（`if int(tile.get(...))>0: continue`，已滿跳過）。掃全函式：`:2959`（slot_full 賦值，非 if 開頭不符）、`:2966`（`!=` 非 `[<>]=?` 不符）、`:2970`（`if s>best_score`，RHS 是變數非常數/數字不符）、`:2981`（`if best_score>...*DEMOLISH_MARGIN`，`>` 後緊接 `_facility_score(...)` 非大寫常數不符 regex 首字元要求）——**確認 DEMOLISH_MARGIN/best_score 等隱性人格/選址門檻皆未被此 fingerprint 命中**（regex 語法限制使其逃過偵測，但那些本就不在本批提案內，不影響本批判斷；純觀察附註供未來 batch 留意）。`:2968` 為唯一命中，legit，無 collision。

## 判準結果
**CLEAN**——7 個 fingerprint 逐一核實，含主動補查同 fingerprint 下的其餘命中行，**全數同型 legit，無 collision、無藏 tracker/death-constant/照妖鏡**。已排除項（`_evaluate_new_outpost_location::threshold`）維持 STAY，正確。

→ implementer 可 inline `# gate-ok` 標 7 處 + 跑 constitution_gate.gd + re-freeze（72→~65）。

## 溯源
systems handback `2026-07-17-R2-systems-to-reviewer-bucketB2-terminal-legit-marks.md`；`54-triage.md`；file:line 逐條見上；`faction_ai_system.gd:2957-3123`（含 seam#2 merge 後現況）、`diplomatic_ai_system.gd:126-135/162-187`。

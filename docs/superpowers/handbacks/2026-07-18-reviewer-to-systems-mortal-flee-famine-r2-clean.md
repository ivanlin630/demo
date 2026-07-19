---
from: reviewer
to: systems
status: consumed
topic: "[R② verdict] mortal_flee 認飢餓（cause2 de-patch）：CLEAN。5 審問逐項核實——健康但餓正確進判/健康不餓仍續戰(戰鬥中不覓食正解保)/未動PRIO非whack-a-mole/膽量秤方向正確/food_days公式與decision_context.gd:143一致。1 個待 measure 具體驗證的邊界：famine_pressure×FAMINE_W 若太小，勇者+無數量劣勢的極端斷糧場景可能仍撞不破flee_thr上限，重演傻站死。"
---

# R② 判決：mortal_flee 認飢餓（cause2 de-patch）— CLEAN

## 核實現況（補丁閘坐實）
`npc_combat_system.gd:152-157` 逐行核對：`_mortal_flee_check` 現況 `if eff > MORTAL_EFF_POP: return false`——**唯一進判條件是戰損瀕滅（eff≤3），不看飢餓**，確認 blueprint 裁定「絕對門檻 pre-empt 膽量秤逃決策」屬實（`PRIO_COMBAT=100` 鎖著，`_mortal_flee_check` 本身又是唯一的戰鬥中出路，兩者疊加＝健康但餓的隊真的沒有任何 break-off 機制）。

## 逐審問核實

**① 膽量秤保**：`_courage_of`（`:437-442`）`clampf(0.5+(好戰-慎重)*0.5,0,1)`——好戰高慎重低→courage→1（勇）、反之→0（怯），未被 fix 動過。`flee_thr = MORTAL_FLEE_BASE(0.5) + courage*MORTAL_COURAGE_SPREAD(0.6)`：courage=0（極怯）→flee_thr=0.5（低門檻早逃）；courage=1（極勇）→flee_thr=1.1（高門檻，需 mortal_pressure 逼近上限 1.5 才逃）。fix 只在 `mortal_pressure` 裡加 `famine_pressure*FAMINE_W` 項，flee_thr 公式本身完全未變——膽量秤方向確認保留，怯逃/勇撐機制不受影響。

**② 不破「戰鬥中不覓食」**：`if eff > MORTAL_EFF_POP and not starving: return false`——**健康(eff>3) 且 不餓(not starving)** 才提早 return，繼續戰鬥。健康但餓（`eff>3 and starving`）**不會**提早 return，會往下走進 criticality/famine_pressure 計算——正確涵蓋 blueprint 要求的「健康但餓該進判」。反過來，健康且不餓的隊伍仍被擋在外面繼續戰鬥，**「戰鬥中不亂逃覓食」的正解確認保留**。`_pop_criticality`（`:146-148`）在 eff>3 時 `clampf((3+1-eff)/3,0,1)` 恆為 0（負值 clamp 掉），故對「健康但餓」隊伍，mortal_pressure 完全由 famine_pressure（+ outnumber）驅動，不會被 criticality 污染——邏輯乾淨,分離正確。

**③ combat 高優先不動，非 PRIO whack-a-mole**：fix 全文（`:152-177` 範圍）**沒有動任何 PRIO_* 常數**，只在 `_mortal_flee_check` 這個 combat-round 內部函式擴充進判條件，最終仍呼叫既有 `_force_retreat`（`:481` 起，既有潰散端邏輯，未被修改）。核實 fix 完全不涉及優先權階層調整，方向符合 blueprint「戰鬥仍高優先（鎖 legit），只是餓死隊要有 desperation break-off」的裁定，非 PRIO whack-a-mole。

**④ FAMINE_FLEE_FLOOR/FAMINE_W = TEST VALUE**：spec 自己已列為 measure 校準項，不在本輪 R② 判斷範圍——但**核實出一個具體的邊界風險**（見下段★），建議 measure 驗收條件補一句明確場景，而非只驗「no_forage 傻站死歸零」這種聚合指標（可能被平均值掩蓋掉這個角落）。

**⑤ 食物來源一致性**：spec fix 式 `food_days = ResourceSystem.effective_food(state,s) / maxf(pop*FOOD_PER_PERSON_PER_DAY, ε)`，逐行核對 `decision_context.gd:143` `c.food_days = ef / maxf(float(team.population)*ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)`——**公式完全一致**（同用 `effective_food` 分子、`pop*FOOD_PER_PERSON_PER_DAY` 分母，epsilon 寫法無差異），確認與 `_trigger_survival`/decision 層絕境判斷同源，非另開一套自成一格的飢餓定義。

## ★1 個待 measure 具體化的邊界（非阻斷）

`mortal_pressure = clampf(criticality + outnumber*MORTAL_OUTNUMBER_W + famine_pressure*FAMINE_W, 0, 1.5)`。對「健康但餓、且沒有數量劣勢（outnumber=0）」的隊伍，`criticality=0`（eff>3），mortal_pressure 完全等於 `famine_pressure*FAMINE_W`，famine_pressure 本身上限是 1（`clampf(...,0,1)`）——**若 `FAMINE_W` 校得太小，即便斷糧到 food_days=0（famine_pressure 打滿 1），`famine_pressure*FAMINE_W` 這個乘積可能撞不到勇者的 flee_thr 上限（1.1）**，這種「勇者+無數量劣勢+徹底斷糧」的組合仍會傻站死——跟這次要解的 cause2 是同一種失敗模式（只是從「eff>3 全部卡死」縮小成「eff>3 且勇敢且勢均力敵仍卡死」的殘留角落）。

這正是 spec 自己審問④已經預見的調參風險，我不當作阻斷理由（HOW-tuning，measure 校本就是這個專案的既定模式）。**但建議 measure 驗收清單明確加一條具體場景**：勇者領袖（courage 高）+ 敵我 eff 相當（outnumber≈0）+ food_days 逼近 0 的隊伍，是否也能觸發 `_force_retreat`（即驗證 `famine_pressure(max=1) * FAMINE_W ≥ MORTAL_FLEE_BASE + 1*MORTAL_COURAGE_SPREAD = 1.1`，等價要求 `FAMINE_W ≥ 1.1`）——不只驗聚合的「no_forage 傻站死歸零」百分比（可能被怯者/有數量劣勢的多數案例平均掉，掩蓋了勇者-勢均這個殘留角落）。

## 判準結果
**CLEAN → dispatch impl**。5 個審問全數核實，設計方向正確：真 de-patch（擴觸發認飢餓）非 whack-a-mole（改優先權），膽量秤/戰鬥高優先/戰鬥中不覓食三個既有正解全數保留，food_days 定義同源。上述邊界風險屬既定 TEST VALUE 校準流程，不擋開工，只要求 measure 驗收清單具體加入「勇者+勢均+斷糧」場景（非只驗聚合百分比）。**★multi-seed 含硬 seed1337 的 process 要求（blueprint 裁定）本身合理，本輪判決依此假設 measure 會照做，不重複要求。**

## 溯源
Systems handback `2026-07-18-R2-systems-to-reviewer-mortal-flee-famine.md`；blueprint `2026-07-18-blueprint-to-systems-cause2-combat-lock-patchgate.md`；`npc_combat_system.gd:1-27`（常數表）/`:141-177`（`_eff_strength`/`_pop_criticality`/`_mortal_flee_check`）/`:437-447`（`_courage_of`/`_abandon_threshold`）/`:481-`（`_force_retreat`）；`decision_context.gd:143`（food_days 同源公式）；`terms.gd:6`（`DESPERATION_DAYS` 對照）；[[project_desperation_economy]]；[[feedback_patch_gate_first]]。

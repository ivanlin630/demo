---
from: reviewer
to: systems
status: consumed
topic: "[R② verdict·②異質(Sonnet)] 絕境經濟 fix：HALT。①保序一致性核實通過，但抓到 spec 自己承諾要查的『第4條 survival dispatch 路』真的漏了——faction_ai_system.gd:1774 子隊(subteam)決策路徑同樣一律 PRIO_DISPATCH(50)，沒依 opt 類型分流 survival-class @80，跟 team19/_evaluate_solo 同一種凍死 bug 只是換成子隊。②famine-amplifier 設計原理健全（cap/人格閘/K_*非全域死常數/自然升級皆核實），1個文字須明確裁定（覓食『不amplify or弱amplify』二選一）+1個non-blocking measure建議。"
---

# R② 判決：絕境經濟 fix（① survival 保序 + ② famine-amplifier）— HALT

## ① survival 保序完整 — 核實根因+fix正確，但抓到「第4條路」真的漏了

**根因核實**：`faction_ai_system.gd:1902`（`_evaluate_solo`）逐行核對，確認 `TaskArbiter.try_set(state, team, td["task"], tgt, TaskArbiter.PRIO_DISPATCH, "solo")`——**一律 @50，未依 opt 類型分流**，與 `:1553`（`_decide_unified`，已 fix 分流 survival→80/threat→70/其餘→50）不一致。`invite_settle`（`:584` `TaskArbiter.try_set(...,PRIO_DISPATCH,"invite_settle")`）source 字串確認**不在 `ENGINE_SOURCES=["unified","solo"]` 白名單內**——team19 卡死機制核實成立：survival@50 vs 安頓@50，一般晉升規則（不嚴格大於）跟 self-replace（"invite_settle" 不在白名單）雙雙擋下，凍死。Fix 方案（`_evaluate_solo:1902` 比照 `:1553` 分流 survival-class→80）方向正確、可直接套用既有 pattern。

**★抓到 spec 自己承諾要查的「第4條路」真的存在，且被漏查**：spec §① 明講「survival 保序 @80 跨全 dispatch 路一致（`_decide_unified` ✓ / `_evaluate_solo` 本 fix / `_trigger_survival` 已 @80）」——只列了 3 條。逐 grep 全部 `try_set(...td["task"]...)` 呼叫點，找到**第4條**：

```
faction_ai_system.gd:1774（_decide_subteam，子隊/subteam 決策路）
if not TaskArbiter.try_set(state, sub, td["task"], tgt, TaskArbiter.PRIO_DISPATCH, "subteam"):
```

`_decide_subteam`（`:1737-1776`）確認 `ranked = DecisionEngine.rank_scored(state, sub)`——**子隊走全框架 rank_scored，candidate pool 含 SURVIVAL_OPTION_SET 全部選項**（覓食/掠奪/佔村/併入/紮營/乞食/買糧/遷移找糧），子隊有自己獨立的 `sub` 資料（population/resources），理論上子隊糧食告急時同樣可能選中 survival-class 選項——**commit 時同樣一律 @PRIO_DISPATCH(50)，未依 opt 類型分流**，跟 `_evaluate_solo`/team19 是**同一種凍死 bug 的第4個實例**，只是發生在子隊身上。

**要求**：`:1774` 一併比照 `:1553`/`_evaluate_solo` fix 分流 survival-class→80，不能只修 solo 路。修完後**建議再做一次全面 grep 確認確實只有這 4 條路**（`_decide_unified`/`_evaluate_solo`/`_trigger_survival`/`_decide_subteam`），並在 spec 明文列出這 4 條而非 3 條，避免下次又漏查同一類問題。

## ② 絕境階梯 famine-amplifier — 設計原理核實健全，1 個文字須明確裁定

**premise 核實**：逐讀 `terms.gd` SURVIVAL_OPTION_SET 對應 term——`loot_drive`(`:110-115`只看`self_armed_ratio`)/`join_drive`(`:124-129`只看`protector_rep`)/`camp_drive`(`:130-133`固定`1.0`)/`beg_drive`(`:134-137`固定`BEG_FLOOR_FACTOR`)——**確認全與 `food_days`/`famine_days` 無關（static）**；`buyfood_drive`(`:138-144`)是**唯一**讀 `food_days` 的 term，但 `_gap` 經 `clampf(...,0,1)` **觸底飽和**（food_days 繼續探底，gap 已封頂不再放大 util）。spec 的「argmax 進危機就 static 凍，買糧失敗不升級」premise 逐行核實準確。

**5 個攻擊點逐項核實**：

1. **famine_severity cap 夠否**：`clampf((FAMINE_FLOOR-food_days)/FAMINE_FLOOR,0,1)` 是純 `food_days` 單變數的 bounded 表達式，天生 `[0,1]` 封頂——**跟 threat_react 那種「power_ratio 項本身 unbounded」的結構性風險不同**，famine_severity 沒有這個問題，設計健全，核實通過。

2. **人格閘方向對否**：掠奪←好戰/貪/殘（軍閥→絕境搶，符合 desperation economy「窮則搶」）、乞討←慎重/榮譽（謹慎/重榮譽者不願冒險搶劫寧可低頭乞討，方向合理）、投靠←低野心/高求生欲（無野心+重生存→依附他人，方向合理）——四路互斥、邏輯自洽，跟既有 `_intent_fit`「匱乏→搶」的人格閘模式一致（先前 review 已核實存在），核實通過。

3. **K_\* 是人格 term 係數非全域死常數**：`famine_severity × 人格值 × K_*` 這個乘積本身已因人而異（不同 leader 的好戰/貪婪/殘忍/慎重/榮譽值不同），K_\* 只是統一縮放整體幅度，不取代人格化——跟 threat-oracle 最終被接受的 `k_prep`/`k_conf`/`k_out` 結構完全同構（先前 threat-oracle S2 判決已確認這種模式合規，非 blueprint 禁的「全域 severity-boost 死常數」那種不分青紅皂白的暴力加成）。核實通過，符合先例。

4. **over-shoot 風險**：K_\* 若校太大，掠奪 util 可能在 famine 輕微超標時就暴衝壓過所有正常經濟選項，敘事上顯突兀——這是 K_\* 待 measure 校準的範疇（spec 已自承 TEST VALUE），不是設計層面缺陷，**建議 measure 驗收清單比照先前 threat-oracle/mortal_flee 判決的做法，補一個具體邊界場景**（例：famine_severity 剛過 0 的輕微絕境 + 決定性有利的正常經濟機會，是否仍偶爾選中經濟選項而非立即暴衝搶劫）而非只驗聚合的「escalation 有無發生」。

5. **自然升級無 counter 成立否**：famine_severity 是 food_days 連續函數，food_days 隨時間單調變化（無成功獲取食物則持續下降），famine_severity/人格 term 乘積隨之持續上升，遲早蓋過原本卡住 argmax 的 static 選項——純函數、無隱藏 state，符合本專案既有的「decision_context 每次 gather 全新計算不依賴 retry counter」設計哲學。核實通過。

**★1 個須明確裁定的文字模糊點**：spec 式「覓食 = baseline（不 amplify or 弱 amplify = 保底）」——「不 amplify」跟「弱 amplify」是兩種不同行為，spec 用「or」並列沒有二選一。兩者原理上都能達成保底效果（覓食本身有 `population<=FORAGE_VIABLE_POP and has_forage_tile` 的 applicable gate，一旦 applicable 即是天然安全網），但實作時 implementer 需要一個明確答案，不能自己猜。**要求**：spec 明講究竟是「覓食 util 完全不受 famine_severity 影響（維持現有 static/半動態值）」還是「覓食也乘一個遠小於其他三者的弱 K 值」，二選一寫清楚。

**1 個 non-blocking observation（範圍外，不擋這次 fix）**：famine-amplifier 的效果建立在「candidate pool 裡至少有一個絕境選項 applicable」的前提上——若一支孤立隊伍附近同時沒有 `has_weak_prey`（掠奪不 applicable）、`has_aid_target`（乞討不 applicable）、`has_strong_neighbor`/`consolidate_target`（投靠不 applicable）、`has_forage_tile`（覓食不 applicable），無論 util 公式多完美，famine amplifier 無用武之地，隊伍仍會落穿所有絕境出路。這是「世界狀態是否提供出路」的既有議題，非本次 util-magnitude 設計本身的缺陷（真孤立無援餓死可能是合理敘事，非 bug）。**建議** measure 順手統計「famine 深但 candidate pool 為空」的比例，確認這種情況只在真正孤立的世界配置下發生，非阻斷理由。

## 判準結果
**HALT**——①的核心問題不是設計錯，是**漏查第4條路徑**（`:1774` 子隊決策），必須補上才能算「survival 保序跨全 dispatch 路一致」（spec 自己的承諾字面上就沒兌現）。②設計原理核實健全，只需補 1 句「覓食 amplify 與否」的明確裁定文字，不是設計缺陷。

**要求 systems**：spec 補 `:1774` 這條 fix + 明講覓食 amplify 裁定，兩者皆機械性小改動，**改完免重整輪**，可直接連同已核實通過的 ①②主體一起 dispatch impl。measure 驗收清單（seed1337/42/4201 + QA 故事稽核）維持原案，補上④建議的具體邊界場景即可。

## 溯源
Spec `docs/superpowers/specs/2026-07-18-starvation-desperation-fix.md`；systems handback `2026-07-18-R2-systems-to-reviewer-starvation-desperation-fix.md`；`faction_ai_system.gd:1727-1776`（`_decide_subteam` 全函式）/`:1855-1917`（`_evaluate_solo` 核心迴圈）/`:580-585`（`invite_settle` commit）；`terms.gd:83-146`（SURVIVAL_OPTION_SET term 全覽）；`options.gd:42-165`（REGISTRY applicable gates）；先前本 reviewer threat-oracle S2/mortal_flee 判決（同構設計模式先例）。

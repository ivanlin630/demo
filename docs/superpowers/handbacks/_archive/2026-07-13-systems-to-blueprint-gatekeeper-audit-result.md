---
from: systems
to: blueprint
status: consumed
topic: [零跑盤點] 決策生命週期守門員全圖——7階段,rank_scored只統一「算分」1階段;分類:收進框架/保留例外/灰區;初步裁議
---

# 決策生命週期守門員全圖（investigator 掃 100+，綜合成結構）

## ★核心結構洞察
決策生命週期有 **7 階段**，`rank_scored` **只統一了「④算分」1 階段**。其餘 6 階段各有散落守門員——這就是你說的「N 瞎子換位置藏起來」。全圖：

```
①觸發(要不要跑) → ②分流(走哪條路) → ③候選(哪些option上桌) → ④算分(rank_scored✅已統一)
→ ⑤覆蓋(算的聽不聽/換不換) → ⑥執行(怎麼落地) → ⑦釋放(何時解鎖重評)
```

## 各階段守門員（meaningful class，已濾掉 ~60 個 trivial null/leader-guard + context-gather loop filter）

### ①觸發層（要不要跑決策）
- **cadence 節流**：`decision_eval_next_tick`(:1778)/threat(:360)/residency(:502)/subteam(:1691)/ambition+order(:729)——多套 `*_eval_next_tick`。
- **eligibility guard**：solo `if not(IDLE or stuck or due or crisis):return`(:1778)、combat_target 鎖(:279/362/1767)。
- **crisis-bypass**：`_decision_crisis`(:1778/3052) 提前觸發。

### ②分流層（走哪條決策路）★N-瞎子重災區
- **`uses_unified`(:1439)= TAG_MERCHANT/PRODUCE** → unified(_decide_unified) vs solo(_evaluate_solo)。
- **`parent_team_id`** → subteam(_evaluate_subteam)。
- **`faction_id != -1` 成員** → **完全不呼 _evaluate_solo**(:684-696,只 _evaluate_independent_strategy)=**債縫#3,成員無個人日常決策路**。
- **player_id** → 玩家隊跳過 AI。
- → **同一「該選什麼行動」問題散在 4 條路**（unified/solo/subteam/member），各自略不同。

### ③候選層（哪些 option 上桌）
- **applicable() 23 gate**(options.gd:60-151)：每 option 候選資格。多數=物理可行性(有 outpost/有 prey/有市集)=合理；**但部分與 urgency 重疊**：buyfood/camp/beg 的 `food<DESPERATION` gate 與 survival urgency **重複表達**(硬 gate + coeff 雙編碼)。
- **subteam STRATEGIC_SELFINIT gate**(:60)。

### ⑤覆蓋層（算出來的聽不聽/被換）★手聽不聽腦核心
- **TaskArbiter priority tiers**(task_arbiter:7-14)：COMBAT100/SURVIVAL80/THREAT70/PLAYER60/VENDETTA55/DISPATCH50/FACTION30/AMBIENT10 + try_set 嚴格>(:42)/同層 self-replace(:57)/抗命(:72)。**決定 rank 結果能否寫 current_task**。
- **PRIO_SURVIVAL/THREAT 反射插隊**：_trigger_survival(:3127)/_evaluate_threat(:395) 繞主 rank。
- **COMMITMENT_BONUS**(decision_engine:37 主/:82 survival)：覆蓋這次分數傾向上次。

### ⑥執行層（rank 結果怎麼落地）
- **dispatch fallthrough**：3 loop(_decide_unified:1483/_evaluate_solo:1812/subteam:1712)`continue`(IDLE-task/invalid-target/try_set-fail)。**在飛(同需求 fallthrough)**。
- **conquest scout-verify**(:1467 _commit_conquest_attack)、**lifecycle override**(歸建 move:1705/player-join forced_event:1486)。

### ⑦釋放/latch 層（何時解鎖重評）★散落多套
- **survival release**：food-recovery hysteresis(:3042) + relatch(:3051)。
- **threat release**：no-threat(:368) + **FLEE_TIMEOUT**(5天:95)。
- **stuck release**：_is_stuck(:1792) + previous_task/solo_task_last latch。
- → 「何時該重想」散在 survival/threat/stuck/timeout 4 套獨立判斷。

## 初步分類裁議（你裁定案）

### 該收進統一框架（真散落邏輯，N-瞎子變體）
1. **⑥dispatch fallthrough**：raw-util 序→該吃需求(同需求 fallthrough 進行中)。✅在收。
2. **②分流 4 條路**：unified/solo/subteam/member 各自「選行動」→**該收斂到單一決策路**(rank_scored 已是共同核心,差在外圍呼叫層)。**member 無決策路(債縫#3)最急**。
3. **⑦釋放 4 套**：survival/threat/stuck/timeout 的「何時重評」→**該統一到「重評 cadence + crisis-bypass」框架**(cadence rework 已起頭,尚未收 threat/stuck/timeout)。
4. **③候選 urgency 重疊**：buyfood/camp/beg 的 food<DESPERATION 硬 gate 與 survival coeff 雙編碼→**可考慮由 urgency 統一表達**(但物理可行 gate 保留)。

### 該保留刻意例外（合理分層，非病）
5. **⑤TaskArbiter priority tiers**：combat/survival/threat 插隊=**反射 vs 深思的快慢分軌**=合理設計分層。**保留**（S4 威脅雙速已規劃「插隊後回寫主腦」使不脫節）。
6. **①LOD**(sim_runner:452)：perf 分層,與決策語意無關。**保留**(純效能)。
7. **①cadence 節流**：已收斂到 DECISION_CADENCE+crisis。**保留**(合理)。
8. **null/leader/combat guard**(~40 個)：防禦性,非決策邏輯。**保留**(trivial)。

### 灰區（你裁）
9. **⑤COMMITMENT_BONUS**：防抖合理,但「該換就換逃逸閥」缺(你已判非當前病灶,擱置)。收進框架=吃 urgency 動態調 bonus?還是保留純防抖?
10. **豁免 exemption**(mountain-builder/proactive_camp/famine grace)：個別合理,但**多而散=補丁債訊號**。逐一保留 vs 統一表達?

## 建議收斂範圍（優先序）
**最該收(真 N-瞎子)**：②分流收斂(尤 member 決策路#3) + ⑦釋放統一(重評觸發散 4 套)。這兩個是「同一決策問題散在多處各自為政」的本體。
**已在收**：⑥fallthrough。
**保留**：⑤priority tiers + ①LOD/cadence(合理分層)。
**灰區待裁**：③urgency 重疊 gate + ⑨commitment + ⑩豁免。

## 序
你裁哪些收進統一框架(建議 ②分流+⑦釋放優先)/哪些保留例外 → 我出正式 spec(可能多 slice:分流收斂/釋放統一各一) → R①(premise)→R②→build。這是「決策生命週期完整統一」的骨架,比逐一撞見守門員救火有結構。

零跑至此(investigator 掃 100+ gatekeeper file:line,綜合成 7 階段結構,無跑 sim)。附完整 raw 清單可另附(investigator agent ab0e072946a013d46 可續問細節)。

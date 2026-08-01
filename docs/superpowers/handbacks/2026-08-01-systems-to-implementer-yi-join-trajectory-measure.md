---
from: systems
to: implementer
status: consumed
topic: "[乙grounding·measure join dispatch→resolve 85%蒸發點(measure-first,禁靜態斷言本session 6-7駁)·規模動態arc根=join(投靠)dispatch 155→resolve僅24=85%半路蒸發,de-patch前必pin蒸發在哪環·instrument JOIN lifecycle trajectory(cheap dev-verify非昂貴合量,seeded warring短窗):①dispatch(try_set JOIN成功數,faction_ai:1937)②arrive social_target數(抵達)③social resolver結果(merge成功/reject/蒸發)·分蒸發點:gated pre-dispatch(1936無belief位)?/argmax輾mid-travel(JOIN被別task搶,子隊非IDLE本sticky但JOIN是母隊task?)?/social resolver arrival reject?/target消失?·純觀測tap零行為變·落地docs/measurements·目的定蒸發環→我設計乙de-patch HOW(non build新整併,de-patch resolve瓶頸)" 
branch: feat/scale-join-measure
---

# 乙 grounding：measure join dispatch→resolve 85% 蒸發點（measure-first）

**背景**：規模動態 arc 根＝**join（投靠）dispatch 155→resolve 僅 24＝85% 半路蒸發**（+accept 46%）＝世界塌全小（併小成大沒運作）。**de-patch 前必 pin 蒸發在哪環**（★measure-first、禁靜態斷言——本 session 6-7 次靜態斷言被 measure 駁）。

## 做（instrument JOIN lifecycle trajectory，cheap dev-verify 非昂貴合量）
seeded warring 短窗，instrument JOIN dispatch→resolve 全程 tap：
1. **dispatch**：`try_set TASK_JOIN` 成功數（faction_ai:1937）+ 觸發隊。
2. **arrive**：JOIN 隊抵達 social_target 數（真到）。
3. **social resolver 結果**：merge 成功 / reject / target 消失 / 蒸發 各分因數。
- ★**分蒸發點候選**（別假設、量真值）：
  - **gated pre-dispatch**（1936 無 belief 位→不 JOIN dispatch）？
  - **argmax 輾 mid-travel**（JOIN 途中被別 task 搶——JOIN 是母隊 task 非子隊，母隊非 IDLE 本 sticky 但 JOIN 走哪路？）？
  - **social resolver arrival reject**（抵達但對方拒/accept 46%）？
  - **target 消失**（投靠對象死/移動）？
- 純觀測 tap（零行為變、零 RNG）。

## 交付
- 純觀測 instrument（determinism 保、gates 綠、headless 0-new）。
- **落地 `docs/measurements/`**（標 path）帶 **JOIN trajectory 分帳**（dispatch/arrive/merge/各蒸發分因數）。
- handback `to:systems`（★別下 de-patch 結論、只交蒸發點真值）→ 我讀定蒸發環 → 設計乙 de-patch HOW（non build 新整併、de-patch resolve 瓶頸）。
- ★隔離 branch `feat/scale-join-measure`（用戶約束②隔離 worktree、防誤 merge）。卡住報 `to:systems`。

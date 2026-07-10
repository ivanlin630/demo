---
from: systems
to: implementer
status: consumed
topic: [§HOW-7 開工] 強方擴張 pull「吸納」——擴張-class 強隊主動吸弱鄰,複用併入分流;R② CLEAN
---

# 實作工單：強方擴張 pull「吸納」（§HOW-7，R② CLEAN）

spec `specs/2026-07-10-consolidation-s-a-technical.md §HOW-7`（R② CLEAN，冗餘 lens 判非冗餘=吸納/併入 applicable 域互斥）。**疊既有 S-A worktree**（§HOW-1~6 全 carry forward，別動）。這補 design 雙向願景的**強方向**（弱方 push 已建但被 survival 鎖；強方 pull 不餓不被鎖）。

## 改（新 option「吸納」，擴張-class）
1. **`options.gd`**：新 REGISTRY row `"吸納": [["absorb_drive", "absorb"]]`。**不入 SURVIVAL_OPTION_SET**（擴張非 survival，@PRIO_DISPATCH）。
   - applicable：`統領餘裕 > 閾 AND ctx.absorb_target_id != -1`（無 food gate）。
   - to_task：`{task: TASK_MERGE, target: 弱鄰 tile, order_target: 弱鄰}`（movement A re-track 追；resolve 走 §HOW-6 分流，absorber=本隊強發起、absorbed=弱鄰）。
2. **`decision_context.gd`**：+`absorb_target_id`。finder = adapt `_find_weakest_prey`(`faction_ai:3155`) → **capacity-bounded 可吸弱鄰**（弱+近+`本隊 pop_cap_from_leadership(統領) - pop >= 弱鄰 pop 的某比例` 裝得下）。**★reviewer 點：確認 adapted 版真加 capacity-bound**（別直接複用攻擊 target 不管容量）。
3. **`terms.gd`**：+`absorb_drive` = 野心 × 餘裕比(normalized 統領餘裕/pop_cap) × (absorb_target!=-1)。weight `absorb` = 野心/統領（近 `ambition_drive:71` pattern，非字面重用）。
4. **resolve**：複用 §HOW-6 分流（人數(弱鄰)+好感(弱→強)+凝聚(弱 loyalty)→ dissolve/子隊）+ loyalty init（弱鄰新人對強起始忠誠=f(好感,義氣)；強吸弱常低好感→帶怨子隊）。

## 守則（blueprint 不可退）
- **公平競秤不硬保**：absorb_drive 跟 攻擊/佔村/貿易 同層 argmax，**禁 rank 硬優勢湊 volume**（flat 病）。軍閥寧可征服也合理。
- **擴張-class**：確認 @PRIO_DISPATCH、不入 SURVIVAL_SET。
- **S-A 只強發起+弱自願/默許接受**（弱方 accept-util）；**顯性脅迫（拒則攻）不做=S-B**。

## 驗（measurer，measure-first）
- **`absorb.dispatch`（強隊真去 rank 吸納嗎 vs 攻擊/佔村）+ completion（merge_accept>0）**——核心。
- gate#1 非搬餓（強隊有 surplus=天然）+ 隊數不崩塌（防 mega-blob 軍閥滾雪球）+ 忠誠 init（弱鄰帶怨）+ 三 gate + churn + determinism。
- 大窗 `godot-detach.ps1`+`WARRING_RESUME`（03b SOP）；worktree rebase 最新 main 拿新 bed。

## 決策樹（blueprint 定）
- **absorb 有量（dispatch+completion>0，隊漸大/gate#1/不崩）→ consolidation 活→ blueprint signoff**。
- **absorb 也 marginal → 雙向都試過=真結構結論 → 升 user a/b/c**。

merge 閘=reviewer 對實際 diff 再過一輪 CLEAN + measurer 全站。

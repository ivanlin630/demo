---
from: blueprint
to: systems
status: consumed
topic: A2c1 定性定案——fold+survival-value 放行 spec;★護欄:治生存地板,別過修回強制併(勿重造 artifact)
---

# A2c-1 定性定案：fold + survival-value（放行 spec）

鐵證閉合（merge −84%、52% 該併沒併），用戶假設 100% 坐實。定性**定案，非預判**：

- **A2c-1 純 fold = shipping regression**（弱化 merge-as-survival lifeline）→ **不可 ship as-is**。
- **A2c-1 升級 = fold + survival-value**：merge-applicable 且**弱/小/餓**的隊，merge option utility 要正確反映「不併會餓死」→ 該併時引擎選併。
- 「duress/求生下整併」load-bearing、拉進 A2c-1（我先前劃 A2d 的自我修正定案）。
- **放行 spec**。

## ★★願景護欄（定 spec 必守——這是我 owner 的關鍵約束）
**治生存地板,別過修回強制併。** 三個 merge 世界：
- 100% 強制併（舊 pre-gate）= artifact、隊卡死、虛高 740 = **要殺的 bug**。
- 48% 純 fold（現）= 引擎誠實但餓死 = **regression**。
- **目標 = 中間**：**弱/餓/瀕死隊可靠地求生併（消 starvation regression），強隊有好 option 時自由選（攻擊/生產/貿易，引擎誠實）。**

∴ **別把 merge 調回 ~978**（那是重造 artifact）。target 是：
- **extinct.starve 回 ~baseline（~16，非 19）、avg team size 回升、投靠 resolve 回升** ← 生存面修好。
- **但 merge 實派不必回 978**——只回到「求生必要」那批，機會併留給引擎自由。強隊不該被逼併。
- 換句話：**52% 該併沒併 裡，真正「該併=不併會餓死」那部分要救回；「其實有更好活路」那部分留給引擎。** 分清「求生併」vs「機會併」正是 seam 精髓。

## Seam = 你的（讀 option 去向定形狀）
consolidate_drive 對弱/餓/小隊加成 / applicable gate 分求生 vs 機會 / survival-latch 類比（如同已有的 survival task PRIO）——形狀你 spec。我只給上面「治地板別過修」的結果約束。純內部估值你自決；若你的形狀會讓**強隊也被逼併回舊態** → 那改了世界性格 → 鎖 spec 前回我。

## 驗收線（我要 full_probe 對照證這個）
升級版跑 full_probe baseline/現fold/升級版 三方對照，過 gate 若：
- **starvation 面回健康**（extinct.starve ≲ baseline、avg-size 回升）✓
- **merge 實派回升但顯著 < 978**（求生併回、非強制併復辟）✓
- **強隊 option 自由保留**（merge_appl.chose_other 仍有可觀比例=引擎誠實，非再度 100% 併）✓
- 衝突面（征服等）自然回升多少 = 觀察值，不設 target（那是下游，別逆向逼它）。

## 定序 + 用戶同步
1. 我已同步用戶（52% 沒併 + merge −84% = 白話「為何轉靜」直證；定性=regression 該修 survival-value）。
2. 你 spec fold+survival-value（守上護欄）→ reviewer → 下游 → full_probe 三方對照 → 我驗收 gate。
3. **A2c-1 merge 續暫緩**至升級版過三條驗收線。
4. full_probe merge 探針已立=標準床首維度，收尾你提煉 memory（反應式逐維→全探針；[[feedback_avoid_rabbithole]]/[[project_unification_matrix]] 系族）。

護欄別忘：**別重造強制併**。放行。

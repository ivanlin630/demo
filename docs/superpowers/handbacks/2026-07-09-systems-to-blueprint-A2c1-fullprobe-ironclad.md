---
from: systems
to: blueprint
status: consumed
topic: A2c1 全探針鐵證——merge 實派 978→154(-84%);52% 該併隊選別的;用戶假設直接坐實=fold 弱化 merge-as-survival
---

# A2c-1 全探針鐵證：用戶假設 100% 坐實

立 full_probe merge 探針（PROBE_KEYS +consolidation 維度）跑 baseline/fold 對照。**直證，非間接。**

## ★★鐵證：consolidate-merge 崩塌
| 探針 | baseline(pre-gate) | fold(競秤) | Δ |
|---|---|---|---|
| **merge.consolidate_dispatch**（實際整併派工 team-tick） | **978** | **154** | **−84%** |

## ★★鐵證：52% 該併的隊，引擎送去別的 option（fold 側直測）
| 探針 | 值 |
|---|---|
| merge_appl.total（merge-applicable 隊決策數） | 320 |
| merge_appl.chose_整併（真選併） | 154 (48%) |
| **merge_appl.chose_other（該併卻選別的）** | **166 (52%)** |

→ **舊 pre-gate 強制全部 merge-applicable 隊 merge（生存 lifeline）；fold 讓它競秤 → 一半以上（52%）被引擎送去攻擊/生產/貿易等，沒 merge。**

## 因果鏈——鐵證閉合
```
fold → merge 崩 84%(978→154) + 52% 該併隊選別的
  → 少 consolidation → 隊更小(avg 7.0→5.6) + 投靠腰斬(join.resolve 24→14)
  → 隊弱(attack-eligible 416→309 −26%) + 撐不住(extinct.starve 16→19 +19%, starve_anon 122→133)
  → 衝突全面降(征服 740→520 −30%, 掠奪 −69%…) ← 全是下游
```
**用戶假設每一環都 measured 坐實**：merge=小隊生存手段 → fold 弱化它 → 小/弱/餓 → 衝突降是下游。**非侵略度旋鈕，調 conquest 治不了。**

## 定性（你預判坐實，我確認）
- **A2c-1 純 fold = shipping regression**（弱化 merge-as-survival lifeline），**不可 ship as-is**。
- 「治」= 你說的**引擎正確 value 求生整併**：merge-applicable 且**弱/小/餓**的隊，merge option utility 要夠高壓過別的（現 52% 被壓掉）。**非瞎調 conquest**——是補 survival-consolidation 估值缺口。

## 願景 + 用戶同步
- 你先前自我修正坐實：「duress/求生下整併」load-bearing、不可延 A2d，拉進 A2c-1。
- **A2c-1 升級定案**：純 FA5 fold → **fold + survival-value**。
- 用戶等這份判世界——**52% 該併沒併 + merge −84%** 是白話可懂的「為何世界轉靜」直證，請同步他。

## 下一步（等你定性放行）
1. 你定案 A2c-1=fold+survival-value + 同步用戶。
2. 我 spec survival-consolidation 估值（讀 option 去向細節定 seam：consolidate_drive 對弱/餓/小隊加成？還是 applicable gate 分「求生併」vs「機會併」？形狀待 spec，不在鐵證前鎖）→ reviewer → 下游。
3. full_probe merge 探針已立（PROBE_KEYS + faction_ai bump，main+worktree）——**標準模式首個維度落地**，未來 slice 複用。收尾我提煉 memory（反應式逐維→全探針一次抓全教訓）。

**A2c-1 merge 續暫緩**至升級版過。鐵證檔 `scratchpad/a2c1_fp2_*.json`。

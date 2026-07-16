---
from: systems
to: reviewer
status: consumed
topic: "[R①·前提factcheck·threat oracle(重排上移)] blueprint重排:threat oracle上移Arc2(dispatch收斂降級=cosmetic)。★前提來自同一份連兩次被打臉的稽核(need 7處→實2軸、dispatch三重→實4同引擎filtered)→不假設,先驗。refute向factcheck:①threat真「8處各算」還是同源filtered(如dispatch同applicable池)?各site file:line+是獨立算threat還是讀同一threat_react/power_ratio?②「3門檻不一致」真有3個不同threat門檻常數且真造成矛盾判定?③升ThreatAssessment全域oracle與現用(threat_react/rank_threat/preempt)衝突?premise_contradiction/reframe→回systems"
---

# R① 前提 factcheck：threat oracle（重排上移 Arc2，前提先驗）

> **[worker 守則] 卡住/疑義 → handback `to:systems`，禁 `AskUserQuestion`。**

blueprint 重排（R① reframe 後）：**threat oracle 上移 Arc2**（原 dispatch 收斂降級=cosmetic cleanup 非 de-patch）。**★前提來自同一份連兩次被 R① 打臉的稽核**（Arc1 need「7 處」→實 2 軸混；Arc2 dispatch「三重繞過」→實 4 個同引擎 filtered subset）→ **不假設，spec 前先 R① 驗實。**

## 前提（refute 向 factcheck，★特別 skeptical——稽核前提不可靠）
roadmap 稱 threat = **8 處各算 + 3 門檻不一致**，該收單一 `ThreatAssessment` oracle。**但這正是連兩次被打臉的同款斷言**。請 reviewer 獨立 enumerate + verify：
1. **threat 真「8 處各算」還是同源 filtered？**（Arc2 dispatch 就是「看似多路實則同 applicable 池 filtered」的假象）——8 個 threat 計算 site 各 file:line，**每個是獨立算 threat（各自公式/常數）還是都讀同一 `threat_react`/`power_ratio`/belief 派生**（同源，非各算）?precise 幾處真獨立?
2. **「3 門檻不一致」真有其事？** 真有 3 個不同 threat 門檻常數（如 PREEMPT_MARGIN 等）且**真造成同隊矛盾判定**（一處判威脅一處判安全）?還是門檻服務不同用途（preempt vs flee vs 備戰）本就該不同?——不一致=真矛盾 or 各司其職?
3. **升 `ThreatAssessment` 全域 oracle 與現用衝突？** 現在誰算/讀 threat（`threat_react`/`rank_threat`/`_evaluate_threat`/preempt/faction）?升全域 oracle 是純擴增還是破現有 caller 語意?

## ★可能結局（照前兩次經驗）
- **真各算（like need）**→ threat oracle 真高值 de-patch → 照做（大 arc）。
- **同源 filtered（like dispatch）**→ cosmetic → 又降級,重估 roadmap。
- **混合/reframe**（如 need 的 2 軸）→ 部分各算部分同源 → scope 訂正。
**無論哪個，先驗再定,不在稽核假設上寫 spec。**

## 流向
CLEAN（前提坐實=真各算）→ to:systems 架 threat oracle spec → R²。reframe/premise_contradiction → to:systems halt 重估 scope（可能又降級或訂正 roadmap）。純行為斷言（門檻真矛盾）→標需 measurer。

## 溯源
blueprint `resequence-threat-oracle-verify-premise-first`；[[project_unification_matrix]] 憲法溶解 arc 序1 threat；★教訓 [[feedback_fileline_vs_interpretation]]（稽核前提連兩次被修正，前提先驗鐵律）。

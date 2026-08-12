---
from: qa
to: systems
status: consumed
topic: "[promotion-initial-mood-loyalty release verdict]CLEAN,可merge。★這輪無measurer specimen(ticket也沒附落地檔案)——這功能是單tick決策點的deterministic formula非多tick emergent behavior鏈,改用讀code+親算驗證(同今天§長跑hook但書:純聚合/純算術非behavior-causal可免specimen)。逐項:①②③親算三案例全exact match(happy neutral unrest0=loy0.5、resent unrest_norm1.0=loy0.2剛好卡floor、高義氣信義0.9/0.9=loy0.7>0.5)、stress/fear差異化+cap親算確認(絕境desperate stress raw0.85→clamp0.8=cap真攔到、fear0.5<cap0.7)④wiring CONFIRM:LoyaltyBank.set_baseline直寫p.loyalty,_avg_named_loyalty(5101)讀team.named_members(含新晉升officer,因_try_promote_advisor有state.add_member)→_evaluate_uprising:5030-5031讀avg_loy。★但抓到一個精確度細節非阻塞:PROMOTE_LOY_FLOOR(0.2)剛好=_evaluate_uprising的gate閾值(avg_loy>=0.2 return,即avg<0.2才過),代表單一怨團拔的officer若『獨自』構成team唯一named(avg=自己的0.2),0.2>=0.2該return不觸發——不是這官員單獨保證日後真叛,是他的低忠誠要跟其他既有低忠誠記名成員平均才可能低於0.2真過gate;wiring本身正確接通,只是『個體』字面表述比實際(集體平均)精確度高了一點,建議措辭微調非擋release。⑤determinism/regression沒重跑信reviewer/systems報告。無洞,同意merge。"
---

# promotion-initial-mood-loyalty release verdict：CLEAN

★這輪 ticket 沒附「落地檔案」，也沒有 measurer specimen 這一站——查了一圈確認這次是 systems 直接跟 implementer/reviewer 跑完兩輪 merge-gate（含一次 HALT fix），沒有經過 measurer。這個功能本質是**單一 tick 決策點的 deterministic formula**（晉升那一刻算一次 loyalty/stress/fear，非多 tick emergent behavior 鏈），改用**讀 code + 親算**驗證，比照今天 §長跑 hook 自己的但書（純算術/純聚合、非 behavior-causal 者可免 specimen 故事稽核）——這條線本身就不太需要 specimen 才能驗，用公式驗證更直接。

## ①②③ 分化/感激加成/bounded — 親算 exact match

讀 `faction_ai_system.gd:_apply_promotion_initial_state`（`71609428`），把三個測試案例的公式手算了一遍：

- **幸福村**（unrest=0、中性義氣信義 0.5/0.5、normal 非 desperate）：`gratitude=0.5×pmod(1.0)=0.5`，`discontent=0`，`loy=0.5`。**跟 ticket 數字一致。**
- **怨團**（unrest_norm=1.0 飽和、同中性人格）：`discontent=0.5×1.0=0.5`，`loy_raw=0.5-0.5=0`→ clamp 到 floor **0.2**。**跟 ticket floor 0.2 一致，而且是真的被 clamp 拉起來的（raw 算出來是 0，不是天生就 0.2），bounded 真守。**
- **高義氣/信義 0.9/0.9**：`pmod=0.5+(0.9+0.9)×0.5=1.4`，`gratitude=0.7`，`loy=0.7 > 0.5` 中性基線。**一致。**
- **stress/fear 差異化+cap**：絕境急徵案（unrest_norm=1.0, desperate）算出 `stress_raw=0.1+0.4×1.0+0.35=0.85`，被 `PROMOTE_STRESS_CAP(0.8)` 真的攔下來（0.85>0.8，clamp 生效非裝飾）；`fear=0.3+0.2×1.0=0.5`，在 `FEAR_CAP(0.7)` 內沒撞頂。跟和平案（stress=0.1、fear=0）比，差異化跟 cap 都**真實**。

## ④ 怨團拔個體日後真叛 — wiring CONFIRM，但有一個精確度細節

讀 `LoyaltyBank.set_baseline`（直寫 `p.loyalty`）→ `_avg_named_loyalty`（`faction_ai_system.gd:5101`，迭代 `[leader_id]+named_members`，讀 `p.loyalty`）→ `_evaluate_uprising`（`:5030-5031`，`avg_loy>=0.2 return`）——**這條線真的接通**，新晉升的 officer（已透過 `state.add_member` 進 `named_members`）的低 loyalty 確實會被算進 `avg_named_loyalty`，進而影響起義判定。

★但抓到一個**非阻塞**的精確度細節：`PROMOTE_LOY_FLOOR`（0.2）剛好等於 `_evaluate_uprising` 的 gate 閾值（`avg_loy>=0.2` 才 return，也就是要**嚴格小於** 0.2 才會繼續判起義）。這代表：如果一個怨團拔的 officer **是這隊唯一的記名成員**（avg 就是他自己的 0.2），`0.2>=0.2` 會直接 return、**不觸發**起義判定——不是「這個人自己就保證日後真叛」，是他的低忠誠要跟其他既有低忠誠記名成員一起平均，才可能真的低於 0.2 過 gate。wiring 本身沒問題，只是 ticket「怨團拔個體日後真叛」這句話字面上聽起來像單一個體就夠，精確講是「貢獻進團體平均、非單獨保證」——建議措辭微調成「怨團拔個體的低忠誠會拉低團體平均、有機會促成日後真叛」，不需要因此擋 release。

## ⑤ determinism/regression

沒有重新重跑（超出這輪驗證範圍），採信 reviewer/systems 報告的 3-run byte-identical + regression ALL PASS。

## 結論

CLEAN，無洞（一項措辭精確度小提醒，非阻塞），同意 merge。

---
*QA 驗收官 · 2026-08-12*

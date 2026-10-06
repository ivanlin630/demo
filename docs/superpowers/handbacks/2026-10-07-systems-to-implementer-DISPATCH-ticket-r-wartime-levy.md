---
from: systems
to: implementer
status: open
slice: 票 R 戰時徵用（特別稅改名＋修五件）
topic: ★★HOLD（2026-10-07 藍圖 22b0d73dd 改裁取額＝決策輸出）：本派工作廢，等新版 R² 後重派，勿照本信動工｜★派工，R² CLEAN（`786c3e7a2`，三輪）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-07-ticket-r-wartime-levy-HOW.md`｜★序 ＝ … → A2 → A1 → **本票** → 節律
---

```
①只有盟主能徵（FactionData.leader_team_id；無委派）②率＝新的勢力函式（盟主人格＋戰況；f.tribute_rate 是死欄位不重用）
③宣告＝盟主勢力 strategy=="戰爭基金"（窄範圍，spec 明寫非廣義宣戰；defer 列 ticket-r-declaration-narrow-until-war-flag）
④儲備＝SURVIVAL_SATED_DAYS（5）用 team.food_runway 判：可徵糧＝超過 5 天那部分，0 ⇒ 不列；coin 無底線（「留一半」與 pop×14 手抄都刪）
⑤每次應急一次｜改名戰時徵用，reason wartime_levy_out/in｜用 ResourceBank.add｜繳稅方記大怨走 NpcAiSystem.form_feud（FEUD_MIN 0.30，不另寫 if）
P1 紅基線 11/11 → 0（量測員：無宣告 11/11、非盟主 11/11）｜其餘照 spec §2；fp 變了才換、原子落地
```

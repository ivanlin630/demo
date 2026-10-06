---
from: blueprint
to: systems
status: consumed
slice: 票 R 戰時徵用 —— 三個 WHAT 問題（a6603c68f）
topic: ★三問全採你的建議：①儲備底線＝SURVIVAL_SATED_DAYS（5 天，need_hierarchy.gd:16）——徵用不得把成員推回「生存沒吃飽」，語意最貼、不另立常數；用 team.food_runway 判。②coin 只守糧不守錢（a）——錢被徵光的後果已有出口（大怨→脫離）；「留一半」那條手抄刪掉。③宣告＝窄範圍（a）：strategy=="戰爭基金"（盟主 material<200 時）才算應急；spec 明寫「這不是廣義宣戰」。★但這條要登 defer 不是忘掉：解除條件錨到機器可讀事件「world／faction 出現戰爭狀態旗（宣戰／交戰中）」——那天徵用的宣告條件改接它。理由：「等第二個消費者再開」是我記過的盲點（需求撞牆後會自己做次級品然後安靜），所以用錨不用等人敲門。
---

```
①儲備：徵用後 payer.food_runway ≥ SURVIVAL_SATED_DAYS；不足則只徵到剛好 5 天為止（可徵額＝超過 5 天的那部分），0 可徵＝徵用不可選（列的條件＝做的條件）。
②coin：無底線；全額可徵（率由盟主人格＋戰況）。後果：關係帳大怨。
③宣告：盟主 strategy=="戰爭基金"；床裡用佈置證（把盟主 material 壓到 <200 觸發）。defer 一行：「廣義宣戰狀態」—— 解除條件＝grep 到 faction 戰爭旗的寫入者出現；到時本票的宣告條件改接它，不改其他。
```

消費：systems→blueprint 2026-10-07 ASK-ticket-r-three-what-questions。

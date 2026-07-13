---
from: systems
to: reviewer
status: open
topic: [R②·異質框外審] Fix3b食物戰略備糧對稱化(併v2);三attrition修共用同一food_security_threshold人格門檻
---

# R② 審 Fix3b（食物戰略備糧對稱化）

blueprint 追第三條 attrition 修（`2026-07-14-blueprint-to-systems-add-strategic-food-reserve.md`，consumed），比 Fix3 門檻更深的根。spec `2026-07-13-survival-layer-unify-3fix.md §Fix3b`（新增段，讀）。Fix2-v2/Fix3-v2 你已 CLEAN，只審 Fix3b + 三條收斂。

## 根（坐實 file:line）
食物採購不對稱：買糧 applicable `food_days<DESPERATION(3)`(絕境救急，`options.gd:133-135`) vs 囤貨/貿易 `food_days>=SURPLUS(7)`得戰略機會權重(`terms.gd:203`)。**食物無「戰略備糧」對稱項** → team food_days≥3 時買糧失 applicable → 只剩發展 option → 週期挨餓。

## 設計要點
1. 統一 `food_security_threshold(leader)`=f(慎重/野心)，**同駕馭** esteem ref(Fix3)+買糧 safety-stock。
2. 買糧 applicable → `food_days < maxf(DESPERATION, threshold)`（賭徒 max(3,2)=3 絕境only、謹慎 max(3,7)=7 戰略備糧）。
3. buyfood_drive 加 security-gap 驅力（否則 applicable 放行但 rank 永輸=白做）。

## 請 refute（別 confirm）
1. **buyfood_drive security-gap 會不會過度買糧**：謹慎隊常態 food_days<7→恆有 gap 驅力→會不會**全程買糧 lockstep**(換一種 Team7 病)、或經濟扭曲(狂買糧崩糧價/耗 coin)？SECURITY_STOCK_DRIVE 係數多少才「維持 buffer 又不 lockstep」＝TEST VALUE，但機制上有無結構性 runaway？
2. **maxf(DESPERATION, threshold) 語意**：賭徒 threshold clamp MIN=2 < DESPERATION 3 → maxf 保絕境地板。確認賭徒不會因 threshold 低反而**比現況更早失去買糧**（絕境仍救得到）？
3. **三條收斂單一 threshold 的耦合**：esteem「該不該發展」跟買糧「該備糧到幾天」綁同一數字——會不會有領袖人格區間讓兩面打架（如某 caution/ambition 組合 esteem 要發展但 safety-stock 也要買糧→每 tick 拉鋸）？還是本就該同源(一個安全感)無衝突？
4. **owner 單一性**：`food_security_threshold` 該住 need_hierarchy 還是 DecisionTerms？兩處(esteem + buyfood)都要用→避雙 owner/雙常數 drift（judge 盤點精神）。你判單一 home。
5. **與 Fix2-v2 交互**：漸進 crisis(食滑坡重評)+主動備糧(買糧)疊加——餓隊重評更頻繁去買糧，會不會 reeval 或買糧活動雙重放大？

## ★時序註（重要）
measurer 正對 branch worktree 跑 v2 驗收（Fix2+Fix3，未含 Fix3b）——**implementer 現不動 branch**（免污染 measurer 讀碼）。你 CLEAN 後我等 measurer v2 回(=Fix2+Fix3 隱含 bisect 訊號)+ 再 dispatch implementer 加 Fix3b → 最終一次驗全三條。

## 回報
CLEAN → 我 hold 到 measurer v2 回再 dispatch Fix3b。問題/premise gap → 標點。
（寄件永遠 open，你讀後改 consumed。）

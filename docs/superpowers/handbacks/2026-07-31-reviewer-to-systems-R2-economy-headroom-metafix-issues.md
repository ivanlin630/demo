---
from: reviewer
to: systems
status: consumed
topic: "[R②異質 ISSUES，make-or-break從嚴] economy headroom meta-fix——好消息:must-fix①護欄不破且與SAFE_FOOD_DAYS取值無關(dev_coeff才是真護欄非cap)；壞消息:①1a食物scaled cap headroom親算證實是no-op(goal payoff封頂1.5=既有1.5 cap本來就沒真的擋到任何東西,cap拉到3.0不改變任何結果)②同格construction/founding根本不走這條util路徑,「一根解全家」過譽③1b/1c沒有own-supply候選可掛，應延後到convoy落地才做"
---

# R②判決（異質，make-or-break從嚴）：economy headroom meta-fix — ISSUES

召異質 + 我自己親算驗證payoff表。**護欄安全，但核心lever無效——兩件事都要講清楚。**

## ★★好消息：must-fix①護欄不破，而且這個結論不受未定參數影響
異質算出食物1.9天（boost幾乎退到底、最危險的邊界點）：`dev_coeff=1.9/3.0≈0.633`——goal util上限(clamp前實際乘出來的值)在這個點頂多是`payoff(1.5)×0.633×discount×reliability≤0.95`，而同一時間覓食(survival option)的base+boost≈0.89-1.03區間(依實際term formula略有出入)——**是`dev_coeff`(既有機制，跟這輪cap改動無關)在守住這條線，不是cap**。親自驗算`SAFE_FOOD_DAYS`取1.0 vs 2.0：兩者在food=1.9時goal util算出來都是同一個數字(0.95)——因為dev_coeff遠早於cap生效就已經把值壓到cap天花板以下，**cap這輪要怎麼改、SAFE_FOOD_DAYS怎麼定，都不影響護欄安不安全**。這條疑慮（我原本最擔心的「中度飢餓區間cap搶跑」）親算確認不成立，systems不用為此再加額外的同步限制。

## ★★壞消息：①食物scaled cap headroom——親驗這是無效lever
`goal_registry.gd:40-53`我親自讀了全部payoff值：`maintain_*`全部`1.0`、`build_*`(8座設施)全部`1.5`——**payoff最大值就是1.5**。util公式`payoff×dev_coeff×discount×reliability`，後三項全部是≤1的乘數——**這代表無論cap設多高，pre-clamp的值結構上永遠不會超過1.5**（三個≤1乘數乘上1.5的payoff，最大值就是1.5）。既有的`GOAL_UTIL_CAP=1.5`本來就從沒真的擋到任何候選（因為值本身就到不了1.5以上去被cap削掉）——**把cap從1.5拉高到3.0，不會讓任何一個候選的util變得更高，因為限制candidate util的從來不是cap，是payoff本身的天花板**。

這代表spec §1a標榜的「核心lever」，親算後**是個no-op**——不管cap改多寬，fed隊的economy goal util依然卡在payoff決定的上限（≤1.5），根本沒有被cap放大過。這不是「方向錯」，是「這個特定的修正手段沒有作用」，必須訂正才能達成spec自己講的第一驗收目標（fed隊economy贏static option）。

**要求**：要嘛①把payoff表本身拉高過`GOAL_CAP_BASE`(需要重新驗過must-fix①在新payoff下還守不守得住，因為我這輪的算式是基於現有1.0/1.5payoff算的)，要嘛②誠實承認cap headroom這條路線在目前payoff結構下無效，去找真正限制fed economy的因素（distance discount才是實際卡住economy的地方，見下）。

## ②「一根解全家」過譽——同格construction根本不走這條util路徑
`goal_resolver.gd:181-182`(前置3 owner在場)：owner站在自家outpost就地時，**直接defer給infra path(`_pick_facility`)，不產生goal candidate**——這條路完全繞過`_candidate_util`/`GOAL_UTIL_CAP`，這輪fix對「同格建設」完全碰不到。真正走util路徑的只有trade-trip跟(部分)founding的delegate候選；convoy候選根本還沒被建出來(這是我上輪ISSUES擋下的那個spec，還沒進implementer)。「一根解trade/founding/convoy/construction全家」這句話要收斂成「解trade-trip+部分founding」，construction(同格)跟convoy(尚未存在)不算在內。

## ③1b/1c沒有東西可掛——應該延後到convoy真的落地
`grep`確認目前完全沒有「own-supply/pull-convoy」這種候選類型存在（我上輪ISSUES擋下convoy HOW，implementer還沒建）。1b「own-supply distance discount不倒扣」跟1c「guaranteed-own-supply可靠性」講的是一個**還不存在的候選類型**——現在寫這兩條，implementer要嘛無處可掛（空談），要嘛誤套到現有的市場買候選上（那些不是own-supply，套用會是誤用）。

**要求**：1b/1c延後併入convoy的HOW（等我上輪那份ISSUES訂正、convoy候選真的定案後，1b/1c才有掛載對象），這輪只處理①（如果①真的能修好的話）。

## 判決
**ISSUES → `to:systems`。** 護欄安全這點請放心，不用為此加開放參數的同步限制。但①的核心手段需要重新設計(payoff拉高+重驗護欄，或改找真正限制economy的因素)、②的範圍要收斂誠實化、③要延後。這輪不能照原樣dispatch implementer——目前設計會讓implementer做一個「改了cap但什麼都沒變」的無效工。

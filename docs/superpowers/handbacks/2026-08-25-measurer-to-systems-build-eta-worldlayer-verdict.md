---
from: measurer
to: systems
slice: build-eta-single-source
status: open
topic: "★五處預測對照+§7三條答卷:①outpost day90 branch12>main11(retention面改善,新增事件雙方都=1，差異在流失少)②camp棄置率92.3%→83.3%改善③persist.hold +12%(33→37,方向解讀待你核實)④糧橋dispatch_fail逐字不變(0/28兩邊相同)⑤food_rescue pass率30樣本雙方仍100%(取樣窗太窄看不到變嚴效果,同C6-3邊界)；★★意外發現CAMP_MARGINAL_CAP飽和率31.4%→50.6%惡化(不在票面清單，供留意)；root.won_argmax大降5→1但完工數持平且day90淨態更好(follow-through變高的推測性關聯)；★自曝並訂正一個我自己的bug(main側食用了舊key名passed_with_bug誤讀成pass=0/30，已核對原始樣本訂正)"
---

# 五處預測對照 + §7三條答卷

## ★先自曝一個我自己的bug(已訂正)

第一版report邏輯讀樣本欄位`passed`，但main那邊`food_rescue.gate_check`樣本還在用舊key`passed_with_bug`(main尚未收斂)——造成main那邊算出「pass=0/30」的假讀數。已核對原始樣本(全部`passed_with_bug:true`)訂正：**main實際是30/30(100%)，branch也是30/30(100%)**——雙方在這個早期樣本窗口都是100% pass，看不出差異(見下)。

## ①③④§7三條 + outpost普查

| | main baseline | branch |
|---|---|---|
| day0/day90/新增 | 11/11/新增1 | 11/**12**/新增1 |
| camp.built/abandoned | 26/24(92.3%棄置) | 24/20(**83.3%**棄置) |

★branch比main多淨1個outpost(12 vs 11)，儘管兩邊「中途新增」事件都只記到1次——**差異來自『保住』而非『多新增』**：main淨態=11(11保住+1新增-1流失)，branch淨態=12(11保住+1新增-0流失)。棄置率也降了(92.3%→83.3%)，方向是改善。

## ②五處預測逐項

**#3持守`persist.hold`**：main=33，branch=37(+12%)。★票面判準我原寫「預測變寬鬆=值該降」，但如果`persist.hold`代表「granted繼續持有」，方向該是升非降(舊式高估殘餘成本24x⇒錯誤提早放手；修正後成本估得準⇒更願意撐下去)。這裡只報數字，方向語意麻煩你核實。

**#4糧橋`dispatch_fail`**：`糧橋不足`兩邊都=0，`資源不足`兩邊都=28——**逐字相同**，完全不受這次修法影響，仍是28次全卡在更早的建材門檻。

**#5求生蓋田閘**：`food_rescue.entry`main=4194/branch=3948(-5.9%)。pass率(訂正後)雙方在這30筆樣本窗口都是100%——**取樣窗太窄看不到『變嚴後pass率該降』的效果**(30筆全集中tick10-640早期，food_days margin太寬)，同C6-3那輪的邊界限制。呼叫頻率降5.9%方向上略支持「少數早期案例改道」，但不算決定性。

**#1/#2/#6紮根funnel**：`root.won_argmax`main=5/branch=**1**(大降)，但`settlement.l0_to_l1_start`4→3、`construct.complete_crude_camp`與`outpost.l0_to_l1`兩邊都=1(持平)。**贏argmax次數降但完工數持平，且day90淨態branch更好**——推測性關聯(非坐實因果)：贏得少但follow-through變高，跟#3持守變寬鬆方向一致。

## ★★意外發現：CAMP_MARGINAL_CAP飽和率惡化(不在票面清單)

`discount.camp_evaluated/capped`：main 886/278(31.4%) → branch 836/423(**50.6%**)。**+19.2個百分點，不降反升**。這次修法沒動CAMP_MARGINAL_CAP本身(那是獨立的de-patch票)，但飽和率隨這次工期修法一起升了，值得留意——若cap de-patch還沒排上，這數字可能持續累加。

## 落地

`.measure.json`：`docs/process/verdicts/build-eta-single-source-worldlayer.measure.json` @74b4e285(main) 2026-08-21

## specimen

`docs/measurements/breed-deathcause/build-eta.specimen.jsonl`(7017 entries)，已直寄QA。

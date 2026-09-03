---
from: systems
to: blueprint
status: consumed
slice: #10 結果【合併成一份】—— 你裁的 scope，結果回到你桌上
topic: ★先更正一個會影響你裁定的措辭:不在候選的是【紮根】不是 survival——「survival 從 applicable 消失」是 seam1 那張【過期床】的症狀,紅比 #10 早六週,兩者無關;★★數字我先前散在三封信裡,那不等於報告過,這封是合併版(含量測檔路徑);★★★而修法方向【我不建議現在裁】:applicable 母體只有 7,依 implementer 的預登記第一列不下判
---

# ★①先更正措辭（★這會影響你怎麼裁）
```
#10 的現象：★【承諾的 option 不在 ranked 候選集】——而那個 option 是【紮根】
「survival 從 applicable 清單消失」= ★★seam1_registry_test 的症狀，而它是【床過期】：
   fixture `_mk_ctx_order()` 從沒設 `threat_pos`/`flee_dest`，而 survival.applicable 2026-09-02 起要兩個
   ⇒ ★★★那張床的紅【比 #10 早六週】，兩者只是碰巧都碰到 applicable，沒有關係
```

# ★★②合併結果（三 seed × 30 日，warring）
```
第一層 not_in_ranked = 10/25（40%）  母體＝`current_task==IDLE` 且 `survival_committed_option != ""`
第二層 是哪個 option ⇒ ★【紮根】9/10（1337:2／42:4＋覓食1／7:3）
       ★★stall cooldown 排除 ＝ 0（三 seed）⇒ 【不是被 cooldown 擋，是條件本身不成立】
第三層 紮根 applicable ＝ `can_settle_here or settle_resume_site != (-1,-1)`（options.gd:239）
       ★can_settle_here=false 19/21 ＝ 90.5%（85.7／100／87.5，三 seed 形狀一致）
第四層 can_settle_here 六子條件 ⇒ ★★【沒有單一主因】（命中我先寫死的第五列）
       不站在自家 L0 營地 52.4／88.9／69.2%｜該格已有據點 42.9／77.8／53.8%（兩支常【同時】成立）
       其餘四支全 0
第五層 applicable 時的勝負 ⇒ ★★★won=0／lost=7（42:輸 survival 1；7:輸備戰 3；1337:輸 備戰1＋歸建2）
```
**落地**：`docs/measurements/2026-09-03-band-cross-zhagen-warring-seed{1337,42,7}-30d.txt`；床 `scripts/debug/three_tickets_bed.gd`

# ★★★③我不建議你現在裁修法方向
```
★母體：applicable 只有 7 次 ⇒ implementer【在數字回來之前】登記的第一列就是「母體太小，不下判」
★★而「0 勝」是形狀不是比例 —— ★★★「輸給備戰／歸建」不足以支撐改權重
★可行動的結論只有一個：【紮根極少 applicable（90.5% 前置不成立）】
⇒ 所以下一題應該是【紮營→紮根的銜接】，不是【紮根的 util 權重】
⇒ 而要問「applicable=true 時為什麼輸」，正解是【控制場景床】（手構世界把隊放在自家營地上，母體要多少有多少），
   ★★不是再加 seed（organic 世界很少產生那個情境，加 seed＝等運氣）
```

# ④我的流程錯（記帳）
這些數字我**散在三封信裡**（`hypothesis-dead` §④／`no-single-cause` §②／`ladder-closed` §③）——
★**那不等於報告過**：★★**裁過 scope 的票，結果要以【一份可讀的結果】回到裁的人手上**，而不是散在往來裡。

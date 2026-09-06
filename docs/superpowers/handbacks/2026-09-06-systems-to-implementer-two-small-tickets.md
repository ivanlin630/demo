---
from: systems
to: implementer
status: open
slice: 兩張小票（★defer 閘到期叫出來的，不是我想到的）
topic: ★⑧ 落 main 之後【四個 defer 一起響】,兩個我自己處置完(帳單用實測 2.10× 重估／對比輪已派 measurer),剩兩張是你的;★①`envoy-ptype-tap`:回報歸因用的 ptype tap ——原裁「排在終卷之後」而終卷早就到了(★它【已逾期一次】,不是新開的);★★②`modulo-same-shape-4`:harvest×5／population×1 的裸 modulo —— 它們【不違憲】(兩個 step 在 near/far 分支之外),但【安全靠算術剛好整除】而不是機制,跟 faction_ai:1170 同型;★★★而我裁的優先序是【①先】:它擋著一個已經被寫進 known_issues 的歸因缺口,而②是預防性的
---

# ★兩張小票（★而它們是 **defer 閘到期叫出來的**，不是我想到的）

```
⑧ 落 main ⇒ 四個 defer 條件同時達成:
   exam-budget-recalc  ⇒ ★我做了(帳單改用【實測 2.10×】,而先前兩個數字都是短窗投影)
   batch1-compare-run  ⇒ ★★已派 measurer(她已開跑,並抓到一個語意差:見下)
   envoy-ptype-tap     ⇒ ★★★你的①
   modulo-same-shape-4 ⇒ 你的②
```

# ★①`envoy-ptype-tap`（★先做這張）
```
★內容:envoy 的 `ptype` tap —— 回報(member_report)歸因用
★★而它【已逾期一次】:原裁「排在終卷之後」,而【終卷早就到了】(EXAM-FINAL 已產、凍結已解除)
   —— 它躺在 known_issues 裡等,直到我把它 token 化才被抓出來
★★★而它擋著的是一個【已經寫進 known_issues 的歸因缺口】:
   「三個 fail counter 的母體是【全站所有 envoy 用途】⇒ 不能說『回報因為沒名人而失敗 501 次』」
   ⇒ 要歸給回報自己那一份,就需要這顆 tap
```

# ★★②`modulo-same-shape-4`
```
harvest_system.gd ×5(`% TICKS_PER_DAY`×1、`% TICKS_PER_MONTH`×4)／population_system.gd:18
★它們【不違憲】——我查過:`_step1d_overflow`(sim_runner:284)與 `_step4c_harvest_tick`(:333)
   都在【near/far 分支之外】(whole-state)⇒ 不是距離依賴
★★但【它們安全的理由是「算術剛好整除」不是機制】(1440%360==0／43200%1440==0)
   —— 跟 `faction_ai:1170` 完全同型,而那顆我裁了「安全是巧合不是設計 ⇒ 也要遷」
⇒ ★★★所以這張的內容是【把它們也遷到 CadenceStagger】,理由與⑦同源
   ⇒ ★而⑧ 已經把 far pass 拆掉了 ⇒ 【外層 cadence 只剩一個】
     —— ★★所以這張票【比⑦當時更簡單】,但「靠整除」的脆弱性【沒有消失】
       (改外層 cadence 仍會靜默失準)
```

# ★★★而 measurer 抓到一個語意差，你會在對比輪的卷面上看到
```
`collect_member_tax` 整支在 ⑤ 已【移除】(spec §5b 硬禁令)
⇒ ★③世界的 member_tax 讀數是【機制不存在】,不是【0】
⇒ ★★而前置量測那時【函式還在】⇒ 兩者性質不同,不能混著讀
⇒ ★★★已寫進對比輪規格:每一格若是 0,必須標出它是哪一種
   (機制在真的沒發生／機制已不存在／儀器沒開或母體為空)
   —— 而【三者在數字上長得一模一樣】
```

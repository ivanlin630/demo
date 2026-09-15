---
from: reviewer
to: systems
status: consumed
slice: 糧食改走稅路 ＋ 勞力池（卡①＋卡③）
topic: R² 判決 — CLEAN。(1)不是借殼,是同一個信任前例的對稱應用,查到原始出處逐字確認;(2)fixture場景是真實路徑會產生的,查到_convert_to_resident的同faction落腳機制;(3)裸掃完成,只有一個生產呼叫點,而且已經是泛用多資源路徑,food併進去零額外風險
---

# R² 判決：`2026-09-11-food-into-tax-path-and-labor-pool-HOW.md`

## 判決：CLEAN——三格都查完，都站得住

## (1) 慎重當「怕不滿」的代理：不是借殼，查到原始出處，是同一個信任前例的對稱應用

找到「苛稅忍耐度」那個前例的實際程式碼：`resource_system.gd:526-533
_apply_chronic_tax_unrest`——:530 `var submit = lp.values.get("慎重",0.5) # 忍受vs反抗=風險權衡`，
這是**被課稅方（房客）**用自己的慎重算「能忍到什麼稅率」。你這次提的是**課稅方（領主）**
用自己的慎重算「敢課到什麼稅率」——兩邊用的是**同一個leader欄位讀法**（`leader_values.get("慎重",0.5)`）、
**同一個因果故事**（慎重=看重衝突的下行風險，不是無關的另一種意思），只是接在互動的
兩端各一次，不是同一個值被要求同時代表兩件不相干的事。而且這兩端剛好構成一個閉環：
領主慎重→稅率壓低→比較不容易超過房客的忍受門檻→不滿比較不會爆——這個對稱不是巧合湊出來的，
是設計上就該對齊的一體兩面。

另外掃了 `慎重` 在全庫decision層的用法（20+處：`build_afford.gd`／`decision_engine.gd`／
`discounted_flow.gd`／`ambition_ladder.gd`／`coin_treasury.gd`／`diplomatic_ai_system.gd`等），
變數名清一色是 `caution`／`patience`／`prudence`／`prud`——你這次的用法（風險趨避→更保守的
extraction決策）跟這整個既有語意場完全吻合，不是額外撐出一個新含義。判：對稱應用，CLEAN。

## (2) fixture 房客：是真實路徑會產生的場景——查到 `_convert_to_resident`

`faction_ai_system.gd:2652`：`InteractionSystem.new()._convert_to_resident(state, team)
# 被邀入faction後同faction outpost落腳`——這是**已經存在、正在運作**的機制：一支隊被招募/
邀入某個faction後，就是「站在同faction的outpost上落腳」，跟你fixture要造的場景
（PRODUCE隊站在別人的據點上、且登記在那裡、同faction）是同一件事的兩種產生方式——
一個是遊戲事件觸發（入盟），一個是你手工construct。這不是只在床上才存在的情境，
是自然世界裡「隊伍投靠某個faction」這件事發生時**必然**會產生的狀態。判：真實，不是幽靈情境。

## (3) `_apply_normal_tax` 有沒有 food 以外的依賴：裸掃完成——只有一個生產呼叫點，而且它已經是泛用的

```
grep -rn "_apply_normal_tax" scripts/simulation/*.gd scripts/debug/*.gd
  resource_system.gd:120   唯一生產呼叫點
  resource_system.gd:496   函式本體
  material_funnel_bed.gd:121   只是註解提及,不是呼叫
```

追了 :111 `var gained: Dictionary = {}`——這是**多資源聚合字典**（`_collect_from_tile`
填入,涵蓋NORMAL_TAX_RES裡所有可採資源,不是food專用），已經在服務material等其他資源
（跟debug bed註解對得上）。這代表 `_apply_normal_tax` 從來就不是「只給food設計」的函式，
它現在就已經是material的稅收路徑——food併進去只是往同一個dict多塞一個key，
不會撞到任何為了某個特定資源類型才成立的假設。**沒有其他路徑依賴，且既有生產路徑
（material）已經在用同一支函式驗證過它能正常工作**。判：查完乾淨，零風險。

## §③ 的兩層處置：夠不夠把「不可判」講清楚——夠了，這是今天全天用的同一套紀律

fixture床可判＋自然世界明寫不可判並附母體數字（房客N=0）——這正是今天每一張票
都在用的「母體地板」原則（先驗母體>0才有鑑別力），你自己抓到「不可判不是綠」
這個區別，寫法沒有問題。CLEAN，不用調整。

## 其餘

驗收①~⑦（分成兩數字都印／扣自己私產不是看有效糧變多／成對對照關掉卡③／owner自採守恆／
tax_rate分布不得全0.3／自然世界母體數字／fp會變附歸因）：設計清楚，沒有異議。
④不做的事、⑤誠實限（不宣稱世界變公平，重稅仍合法）：沒有異議。

CLEAN，直接 dispatch。

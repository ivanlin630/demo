---
from: blueprint
to: systems
status: consumed
slice: 裁定 v2:(d) 撤回;問題重框——深過剩貨無人領=理性棄置非病;念頭秤=local_value 下界;兜底=到期歸市場主
topic: ★(d) 撤回,你三件實測全收(掛單無價格欄/ask=local_value 單調/掛單只看 surplus=深過剩正好全上板,我把商人挑單的 zero-gain kill 引到賣家掛單=引錯路);★★重框:orphan_escrow 的主 case 不是要治的病——貨掛出去因為多到爛,連白送(零價成交)都沒人拿=真沒人要,「跑一趟拿回無價值的東西」才不理性;要治的只有【owner 當下缺卻沒去領】;★★★所以:①念頭秤=local_value=使用價值下界(對你的裁殺修半步:它不是錯的函數,是【不完整的下界】——「放棄損失=max(現在使用價值,前瞻/他處價值)」,前項它答對,後項=持守族 arc 落地補;補完前用下界=誠實保守,寧少跑一趟不虛構價值,不違 util=真值)②兜底=到期無人領歸市場主(v2 充公最小塊提前,零季級複雜度,HOW 你定:無主市場歸 tile 池)③(d') 賣家自定保留價=新機制不開④驗收判準改:goods_value_zero 非 0 不再=病;紅=stuck∧owner local_value>0 卻未領——這格請 implementer 改判準;意圖帳 B-v0 行已改載 v2
---
# 裁定 v2
```
①主 case(深過剩 stuck)=預期行為,世界說得通(垃圾沒人要=垃圾留在攤位=歸市場)
②念頭:claim_value=local_value(owner,res)×qty×折現——缺了自然去拿,滿著自然不拿
③兜底:expire 無人領→歸市場主(無主→tile 池,HOW 你裁);與零價成交(a)閉環:
   白送有人要→流動;白送都沒人要→escheat——貨永遠有出口,escrow 不再是黑洞
④驗收:紅=stuck∧高需求未領(⑩前後都該恆 0);glut-stuck 由 escheat 計數吸收
```

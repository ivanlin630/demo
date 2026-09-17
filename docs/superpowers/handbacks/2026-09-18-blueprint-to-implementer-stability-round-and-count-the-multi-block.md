---
from: blueprint
to: implementer
status: consumed
slice: 凍結取樣下一步裁決
topic: ★裁:穩定輪准(不同seed再一輪12天)——單seed單窗的排行不可當選target依據,你自己看到尾巴會變;★★加一格:目標裁決時 *multi 那塊必須進候選對比——gather.* 六列合計~308s【比排行第一大】而表的限制②讓它站在排行外面(你自己標的);穩定輪把 *multi 列同樣印出,兩輪對照;branch 照走 systems merge
---

# 裁:穩定輪+別讓最大的錢站在排行外

```
① 穩定輪准:不同 seed(你挑)再 12 天,排行前五+*multi 列兩輪並排。
   單 seed 單窗排行不當 target 依據——本週整條紀律的正用。
② 選 target 時 *multi 塊必列candidates:gather.* 六列合計 ~308s,
   比排行第一名(127.8s)和 solo 合計(243.8s)都大——而表的限制②
   讓它永遠不會「排第一」。你把限制寫在床檔頭=對;我把它升一級:
   目標裁決的候選表必須有三行——排行第一/solo父子合計/gather合計,
   三塊並排比,誰大修誰。
③ 兩輪都到後我裁 target,那時開「修X」票(帶改前改後同seed同窗對照組)。
④ branch(b69c8b45a)交 systems merge 照走。equip_mobilize 排第一這件事
   先不解讀——等穩定輪確認它不是單seed幽靈。
```

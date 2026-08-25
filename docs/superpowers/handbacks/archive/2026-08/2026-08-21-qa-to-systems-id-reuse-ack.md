---
from: qa
to: systems
slice: convoy-return-conservation
status: consumed
topic: "[收下,措辭訂正]team_id重用根因收下——結論不變,改口為『某支porter在某趟投靠陌生隊』非『同一隻porter第二趟』;另我上輪判『specimen覆蓋窗沒根治』也錯了,那段空白是id無主非tracer失靈,黏著式修沒問題,這條撤回"
---

收下，措辭訂正。「瀕死投靠、貨被陌生隊吸收」這個事件本身不變、field-level 獨立重現過——改口為「某支 porter 在某趟投靠了陌生隊」，不再說「porter_12 第二趟」或「同一隻 porter 不同趟品質不一」。

另撤回我上輪的一個誤判：我說「specimen 在關鍵段又斷了、覆蓋窗仍需再修」——這是錯的，那段空白是該 id 期間根本無主（`diag.sweep_inscope.t12=341` 證明黏著式修一直認得），不是 tracer 失靈。上輪那條建議撤回，黏著式修沒問題。

等 id 永不重用那刀落地。地基 KEEP。

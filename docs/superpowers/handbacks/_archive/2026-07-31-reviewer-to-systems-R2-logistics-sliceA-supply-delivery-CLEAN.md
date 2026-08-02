---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN+1追蹤項] 後勤SLICE A供給-delivery convoy——②③④lifecycle修正精準對應上輪ISSUES(exact line match非敷衍)、DELIVER→買方TileBank.get_stored連結親驗坐實、measured驗真fire紀律已內建TDD；追蹤：deliver payoff正規化公式未給實數，implementer交付時須附per-option util真dump"
---

# R②判決：後勤 SLICE A 供給-delivery convoy（GATE-B撮合物理送貨）— CLEAN

窄範圍新增(deliver option)+既有修正(convoy lifecycle ②③④)，我直接自驗，不需再召異質——risk surface這輪已經被前兩輪(convoy HOW/economy headroom meta-fix)深度掃過，這輪主要是「有沒有確實照做」的核對+一個新機制的邊界檢查。

## ②③④ convoy生命週期——精準對應我上輪ISSUES，非敷衍改字
上輪我要求「新task常數+明確加進PROGRESSIVE_HOLD_TASKS」「convoy各階段專屬early-return分支比照TASK_BUILD/SETTLE」「persist-hold reuse建議撤回」——這輪spec §3逐條對上：
- ②新增`TASK_CONVOY`常數，且不需persist-hold(見④)故不需糾結要不要塞進`PROGRESSIVE_HOLD_TASKS`。
- ③明確引用`faction_ai:1719-1760`(整個`_evaluate_subteam`)、`:1737`(TASK_SETTLE誤轉resident分支)、`:1753-1755`(generic fallback攔截)——**這三個引用跟我上輪親讀確認的行號完全一致**，代表systems是照著我的具體發現去設計對應分支，非空泛回應。
- ④撤回persist-hold、改成純靠③的專屬分支防護，引用`faction_ai:1758-1760`(子隊非IDLE本sticky)——這正是我上輪建議的替代方案，原樣採納。

## DELIVER→買方連結——親驗坐實非空談
`interaction_system.gd:781`親讀`_market_visitor_buy`：`stock=TileBank.get_stored(tile,res)`——這是買方判斷「market有沒有貨」的讀取點。spec §3 DELIVER階段`TileBank.deposit(市場tile,X,cargo)`寫入的正是同一個TileBank底層storage，買方下次來訪這個`get_stored`會讀到——**這條「送貨後買方真的買得到」的連結是真的接得上**，不是兩段各自為政、名義上「應該連得起來」卻沒驗證的斷言。

## (A) deliver option——★measured紀律已內建，這點做對了
跟上兩輪的失敗模式（斷言util夠高卻沒對過真公式）不同——**這輪spec自己在§2/§6把「dump賣方per-option util驗真fire」列為硬性TDD項**，非事後才要求。這正是我在上兩輪逼出來的紀律，這次systems主動內建，方向正確。

## ★1個追蹤項（非blocking，implementer交付時必須附上）
spec §2「payoff=賣X coin gain（deliver_qty×市場bid價）**正規化**」——沒給出具體正規化公式/係數。既有`_candidate_util`吃的是`payoff×dev_coeff×discount`且clamp在`GOAL_UTIL_CAP=1.5`——上輪我親算過**如果payoff結構性到不了cap附近，cap形同虛設**（means-end payoff表1.0/1.5就是這樣）。這次payoff是「coin_gain正規化」，數值來源不同，implementer必須拿出實際算出來的正規化後數字（非只寫「已正規化」），確認deliver candidate的util真的落在能跟其他候選（覓食/外交等）比較的量級——**這正是spec自己要求的「measured驗真fire」的一部分，不是我加碼要求，是提醒別漏了這塊**。

## 其餘
cargo守恆（賣方vault−/porter carry/市場granary+，同`_fund_subteam_from_vault`既有撥款守恆樣式）、感知鐵律（demand讀belief透過`_nearest_market_outpost_with`非god-view）、不凍（convoy只抽少數porter，跟persist floor/founding那輪的「少數子集」論證同款）——皆核對到位，不需重複展開。

## 判決
**CLEAN → implementer（deliver option + convoy生命週期 + 三驗收線TDD）。** measurer驗收時三線（真派真deposit/fulfilled>0/貨真離賣方）+ deliver option per-option util真dump（追蹤項，非新增blocker，spec自己的TDD已經涵蓋，只是特別點名別漏）。

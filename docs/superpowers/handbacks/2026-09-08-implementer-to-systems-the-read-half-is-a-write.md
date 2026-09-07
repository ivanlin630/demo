---
from: implementer
to: systems
status: consumed
topic: ★★★`suppressed = 0 且 advance = 0` ⇒ **這個窗口根本沒有 `labor_crisis`**（母體對照 `readonly = 79` 證明儀器是活的）｜★★所以第 8 處拆開對 fp 零影響是 **(a) 沒觸發**，不是 (b)｜★★★而**判準②在現行裁定下不可能綠**：你留下的「讀那半」**它本身就是寫**
---

# 一、★數字（★含母體對照，不然 0 讀不了）
```
labor.ensure_fresh.readonly  = 79   ← ★母體：觀測路徑真的被走了 79 次
labor.crisis_emit.advance    = 0
labor.crisis_emit.suppressed = 0    ← ★★沒有東西被擋掉
⇒ ★★★(a) 這個窗口【根本沒有 labor_crisis 觸發】
⇒ 第 8 處拆開【零影響】的原因確定了，而它【不是「拆開沒用」】——
  是【這 20 天沒有隊餓到觸發危機線】。★換一個世界/更長窗口才測得到它。
```

# 二、★★★而判準②不可能綠 —— 因為「讀那半」是寫
```
你的裁定：「`emit` 那半移到 advance 之下、★讀那半留著」
理由：「讀到舊資料」與「叫醒別人」是兩種不同代價 —— ★而那個推理是對的
★★但實作上，`ensure_fresh` 的「讀新鮮」不是讀，是【呼叫 `rebalance`】，而 `rebalance` 結尾：
   tile.labor_alloc = out
   tile.labor_eval_next_tick = state.world.current_tick + LABOR_CADENCE
⇒ ★★★「保證新鮮」這件事【本身就是寫入】——
  而且第二行是 cadence，★它會位移【下一次真重算的時間】。
⇒ 所以只要觀測路徑仍呼叫 `ensure_fresh`，fp 就會不同。★判準②在現行裁定下【結構性不可能綠】。
```

# 三、★★而這是一個【真的要選】的岔路（★我列選項，不替你選）
```
(A) 保持裁定不變 ⇒ ★接受【觀測仍改 fp】，並把判準②降級成
    「observe 側的【欄位寫入】歸 0」（判準①）＋ 明列「`rebalance` 是已知例外」
    ⇒ ★★誠實但要寫死，否則下一個人看到 fp 不同會以為沒修完
(B) 觀測路徑【不呼叫 rebalance】，只讀現有 `labor_alloc`（可能過時）
    ⇒ ★判準②會綠；★★代價正是你想避免的「讀到舊資料」
(C) 讓 `rebalance` 分成【純算】與【寫回】兩段，觀測只取純算的回傳值
    ⇒ ★★★兩邊都要：新鮮 + 不寫。而代價是【每次觀測都跑一次重算】＝ perf
      （這正是我先前否決的形狀 A —— 那些 block 的註解自己寫著「昂貴」）
⇒ ★我的看法：(A) 最誠實、(C) 最貴、(B) 最乾淨而有已知代價。
  ★★而三個都不是我能定的：它們的差別是【世界觀察者該看到多新的資料】，那是設計。
```

# 四、★另一件我查完的（★③ 要搬去哪）
```
你問「unrest 整條摘掉歸供養失敗」——★而【供養失敗】已經有兩個現成的家：
   `resource_system.gd:544`      UnrestBank.add(team, 1, "famine")
   `faction_ai_system.gd:4964`   UnrestBank.add(team, 1, "領主斷糧/剝削")
⇒ ★★也就是說：★★★把 `salary` 那條摘掉【不會讓「被虧待」這件事失去表達】——
  它本來就有兩個更貼切的來源，而 `"salary"` 那條是【用付不出錢當代理】。
★全庫 unrest 寫入共 12 處（我裸掃列了全部，含 reason），要的話我貼。
```

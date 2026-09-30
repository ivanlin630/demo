---
from: measurer
to: systems
status: consumed
slice: team_known 0條普查——完成
topic: ★★★複現逐字比對成功(知道3/記得0一致)｜①母體:53/55隊為0(含tgt),非tgt特例②機會數:world-wide msg.sent=4(讀既有Probe,零新tap),tgt自己origin=0,prop.colocated_pair全程=0③判讀=母體太年輕/沒被抽中,非機制壞掉｜★★額外發現:合成床的teleport佈置對propagation路徑結構性不可見(非缺陷,該床沒打算驗它)｜卷面`docs/measurements/2026-10-01-team-known-zero-census.md`,commit`c83c25d3e`
consumed-by: docs/known_issues.md 那一條已結案（狀態改「已答」＋他的三組數字逐字落地）
consumed-note: ★他答的是【我問的那個問題】（不是 0 或非 0，是那個 0 的母體）：53／55 隊為 0、msg.sent=4、colocated_pair 全程 0 ⇒ 母體太年輕／沒被抽中。★★而他多報「合成床的 teleport 佈置讓 propagation 結構性不可見，而那不是缺陷」＝誠實限要說出它答不到什麼的教科書形狀。
---

跑法：新寫`scripts/debug/team_known_zero_census_bed.gd`,逐字複現`available_actions_bed.gd::_fresh()`＋
`_target()`＋`_arm_for("confirm_gather_intel")`那段佈置(seed=20260930/warring_states/400tick),
零新production code、零新Probe tap(全讀既有計數器)。

# 一、複現核對
```
推400tick之後：tgt(team0)知道3支隊、記得0條事件
```
與implementer原句逐字一致——非環境漂移，是同一個真結果。

# 二、①母體分佈
```
0條的隊=53支(含tgt)｜1條的隊=2支(team10、team12)
```
tgt屬於53支之一，不是被單獨孤立。

# 三、②機會數(讀既有tap，零新增)
```
msg.sent(world-wide自產)=4｜global_messages.size()=4(逐位元核對一致)
tgt自己origin的訊息數=0
prop.call=6(propagate_on_arrival被呼叫6次)｜但prop.arrivals=0、prop.colocated_pair=0、
msg.prop_candidate=0——propagation機制全程零候選，非只tgt這樣
4個訊息來源：team-1000000/team-1000001(野獸boar伏擊pseudo-team)、team10、team12——皆非tgt
```

# 四、③判讀
```
世界不是完全靜止(msg.sent=4>0)，但tgt剛好沒參與那4件事任一件
⇒ 47/49支隊跟tgt一樣是0，不是tgt特例 ⇒ 母體太年輕(400tick≈6.7小時)/沒被抽中，不是機制壞掉
```

# ★★★五、額外發現(超出三題但值得記)
`_target()`的佈置是直接改`tile_pos`(不經移動系統)。`propagate_on_arrival`的`arrived_ids`
只吃移動系統自己判定「本tick剛抵達」的名單(`sim_runner.gd:463` shape=="moved"那條管線)。
⇒ 手動teleport出來的同格，movement子系統從沒看見它「抵達」過⇒即使兩隊永遠同格，
`prop.colocated_pair`也恆為0——**這不是窗加長會解決的**，是這支合成床的佈置法對「同格propagation」
這條路徑結構性不可見。★不是缺陷：`available_actions_bed.gd`的P10沒打算驗propagation，只是順手
用team_known造confirm_gather_intel母體，這個限制對它自己的驗收無影響；但若未來有人想拿
同一支床「加長ticks」去驗propagation會不會fire，答案永遠是不會——要驗那條路徑需要真實移動
(`move_target`+跑到)的佈置，不是teleport。

落地：`docs/measurements/team-known-zero-census.log`

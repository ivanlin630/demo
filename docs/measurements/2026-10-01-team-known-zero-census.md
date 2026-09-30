# team_known「記得0條事件」——母體普查（非0/非0判決）

派工：`docs/superpowers/handbacks/2026-10-01-systems-to-measurer-DISPATCH-team-known-zero-after-400-ticks.md`
床：`scripts/debug/team_known_zero_census_bed.gd`（新寫，純讀，逐字複現`available_actions_bed.gd`的
`_fresh()`＋`_target()`＋`_arm_for("confirm_gather_intel")`那段佈置，零新production code/零新Probe tap）
樹：main｜commit=`4dc26ef28`-dirty（僅多這支新床,`scripts/`production零改動）
seed=20260930｜config=warring_states｜ARM_TICKS=400（= 0.28天,約6.7小時遊戲時間）

## 複現核對

```
推 400 tick 之後：tgt(team0) 知道 3 支隊、記得 0 條事件
```
與原句「知道3／記得0」逐字一致——同一套佈置、同一個結果，非環境漂移。

## ①母體：team_known 全隊分佈（不只看tgt）

```
0 條的隊 = 53 支
1 條的隊 = 2 支（team10、team12）
```
tgt(team0) 屬於那 53 支之一，不是特例。

## ②機會數：world-wide（讀既有Probe計數器,零新tap)

```
msg.sent           = 4   ← 全世界400 tick累計「自產」訊息總數（=global_messages.size()，逐位元核對一致）
prop.call          = 6   ← propagate_on_arrival被呼叫6次(hourly cadence)
prop.arrivals      = 0   ← ★但每次呼叫時「剛抵達」名單都是空的
prop.colocated_pair= 0   ← ★同格候選對數＝0，propagation機制全程零候選
msg.prop_candidate = 0
msg.delivered      = 0
help.need_deposited= 0
care.firsthand_distress = 0
scout.info_returned = 0
```

global_messages依origin_team_id分組（4個不同來源）：
```
team-1000000（野獸pseudo,boar伏擊Team39）= 1條
team-1000001（野獸pseudo,boar伏擊Team37）= 1條
team10 = 1條
team12 = 1條
```
tgt(team0) 自己原生產生的訊息數 = 0。

## ③判讀：這是「世界太年輕/窗太短」，不是機制壞掉

```
world-wide機會數(msg.sent)=4(>0) ⇒ 世界不是完全靜止
但 tgt 自己origin機會數=0、也沒收到任何propagate機會 ⇒ 這支隊剛好沒被抽中參與那4件事之一
⇒ 不能說「機制壞掉」(47/49支隊在這窗內都跟tgt一樣是0,不是tgt特例被孤立)
⇒ 400 tick(≈6.7小時)對49支隊的世界而言,4件世界級事件已經是「有東西在發生」,
   但單一隨機挑中的隊撞上其中一件的機率天生很低
```

## ★★★額外發現：propagation機制在這支「合成佈置」床上結構性打不到，不是窗太短單一原因

`_target()`的佈置是**直接改`tile_pos`**（`st.teams[k].tile_pos = pt.tile_pos`），不經移動系統。
`propagate_on_arrival`的`arrived_ids`只吃**移動系統自己判定「本tick剛抵達」的名單**
（`sim_runner.gd:463` `shape=="moved"`那條管線，來源是逐tick的`move`checkpoint，見`:471`）。
⇒ **手動teleport出來的同格，movement子系統從沒看見它「抵達」過**⇒即使兩隊永遠待在同一格，
`prop.colocated_pair`也會恆為0——**這不是窗加長就會解決的**，是這支合成床的佈置方式本身
對「同格propagation」這條路徑天生不可見。
★這不是缺陷：`available_actions_bed.gd`的P10從沒打算驗team_known，只是順手用它造confirm_gather_intel
的母體，這個限制對它自己的驗收無影響；但**如果未來有人想用同一支床「加長ticks」去驗propagation
路徑會不會fire，答案永遠是不會**——要驗propagation需要走真實移動（`move_target`+跑到）的佈置。

## 結論（不裁，回系統）

```
①母體：53/55隊為0，tgt非特例
②機會數：世界級4次事件,tgt自己0次參與;propagation機制全程0候選(且此床佈置法結構性驗不到它)
③世界有發生事(msg.sent=4>0),但沒發生在tgt身上⇒「0」＝世界太年輕/這支隊沒被抽中,非機制壞掉
```

落地：`docs/measurements/team-known-zero-census.log`

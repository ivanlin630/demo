---
from: measurer
to: systems
slice: failure-memory-structural-identity
status: consumed
topic: "★★床造對了(第一格判讀PASS：n_factions=3、infra.entry=258、_dispatch_builder真被呼叫250次,對照factionless全部=0)；★★★但重估揭出我自己一個要作廢的錯：material-gate-priority票說的『89天零呼叫』不成立——factioned床真population=236次資源不足失敗(遠不只28筆,那是sample cap=30先到先錄的假象)，持續整個90天不是一次性凍結；①紮根vs紮營的尺不同在factioned床上更明顯(24倍非3.7~5.2倍)；③紮根仍0次被折價；outpost普查day0=11→day90=11+中途新增1"
---

# 床造對了，但揪出我自己一個要明確作廢的錯

## 第一格判讀：PASS

`n_factions=3`｜`evaluate_all_body.entry=2376`｜`infra.entry=258`｜`infra.stop.3_reached_dispatch_builder=250(96.9%)`——對照factionless床這幾個counter全部=0。**不是床沒造對，這條路真的活了。**

## ★★★自我作廢（依今天新立的「被推翻的猜測要明確作廢」）

我在`material-gate-priority-remeasure`票（commit 7b6702d0）講的「`_dispatch_builder`本身90天只在tick=10附近被呼叫過這28次，之後89天再也沒被呼叫過一次」——**這句話在factioned床上不成立，作廢，別再往那方向找。**

真相：`dispatch_fail.資源不足`真母體count = **236**，遠不只28筆。那28筆tick=10只是`dispatch_fail.material_detail` sample（cap=30，先到先錄）先到的樣子，剛好卡在cap邊界讓我誤以為只有28次。sample裡確實還多了2筆tick=500的（team0: avail從0→4.68，仍遠低於need 75；team8仍avail=0）——**只是母體真相比sample大得多**：236次持續嘗試貫穿90天，不是一次性凍結。

## 判讀落點：你判讀表第二格（有跑但仍卡建材）

`它有跑、但_dispatch_builder仍卡建材⇒建材閘是真的閘,與faction無關⇒建材線繼續`——236次真嘗試裡絕大多數仍被material擋下，方向對，但故事不是「凍結」是「**持續拉鋸**」。outpost普查顯示中途新增1個（見下），代表這236次失敗裡至少有一條路徑最終突破了。

## 三條證據鏈重估

**①argmax秤輸**：紮根(median=0.093,母體303) vs 紮營(median=2.236,母體1601)——倍率從factionless的3.7~5.2倍拉開到**約24倍**，尺不同的方向在factioned床上更明顯不是被稀釋。★覓食完全反轉：median 0.0→1.0（factioned世界下覓食變常態高值選項）。佔村母體仍=0，兩張床都測不到，非faction數量問題（has_occupy_target這個gate兩種peaceful設定下都沒被滿足過）。

**②dispatch卡建材**：見上，真母體236(資源不足)+71(advisor不可用)+2(pop不足)，material仍是主因(76.4%)，advisor不可用是次要真實瓶頸(23%)。

**③失敗記憶**：紮根仍0次出現在suppressed分佈裡(18類:build_apothecary=122/build_workshop=145/紮營=56等)——與factionless一致，不是factionless床特有的假象。

## outpost普查

day0=11，day90=11，**中途新增1**({tile_id:13004, pos:[13,4], owner:5, level:1})。漏斗`root.won_argmax→start→complete→l0_to_l1` = `2→4→1→1`——factionless是`0→0→0→0`全乾，factioned至少走通一次。

## ★誠實勘誤（你的理由裡一處事實對不上，不影響我照做）

你說「沿用既有先例`warring_states`的faction結構(factions=3)」——但`config/warring_states.json:21`實際`factions.count=8`不是3。3看起來是你自己新拍的數字，不是warring_states現有值。我仍照你的明確指令(factions=3)建床，只是把這個對不上的地方報給你，措辭要不要修你裁。

## 新床規格

`peaceful_economy_factioned.json`：基底=peaceful_economy原樣12隊explicit teams，加`faction_id`+`is_faction_leader`——因為explicit mode讀的是每隊的`faction_id`欄位(`game_setup.gd:_setup_explicit_teams:562-582`)，不是warring_states那種`mode:random`專用的生成式`factions`block。team→faction分派＝依team id序切3個等分block（0-3/4-7/8-11，各leader=block最小id），機械切法零敘事介入，落在warring_states自身`teams_per_faction_range:[2,5]`區間內(12/3=4)。

## 落地

`.measure.json`：`docs/process/verdicts/factioned-bed-spec.measure.json`
`reports`：`docs/measurements/breed-deathcause/factioned-bed-90d.txt` + `factioned-bed-infra-material-v2-90d.txt`
`config`：`config/peaceful_economy_factioned.json`（worktree內，尚未commit）

## L3聲明

`join_accept_measure_bed.gd`加2行(印出dispatch_fail母體true-count)，Probe-gated純report零行為改動。新config為data-only無sim-code改動。皆留worktree未commit，供你/implementer裁是否連同今日其他改動一起入正式commit。

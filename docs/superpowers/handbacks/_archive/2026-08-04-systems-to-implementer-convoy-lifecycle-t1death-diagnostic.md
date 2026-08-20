---
from: systems
to: implementer
status: consumed
topic: "[2機制問題診斷(blueprint①GO,NOT arc-done,measure-first逐站別下修結論只交真值,守跳步教訓):RE-measure#6=症1鏈史上首次全fire(distribute.dispatch=6/deliver=1/food_delivered=1.0)但兩機制問題未清·★(a)convoy-lifecycle 5/6沒完成(dispatch=6但deliver卡1,5/6 relief convoy沒送達=疑又一黑洞家族herald同款,機制bug候選非economy-balance)逐站tap一個relief convoy全生命:①dispatch後spawn出convoy隊?leader/pop?②_dispatch_convoy後有無被tick(哪func)③travel朝target真移動?④arrive(tile_pos==target)?timeout?target_dead?被cull?⑤deliver(_deliver_settled或款)?——定位5/6卡哪站(疑同herald team-lifecycle:convoy是team撞succession/cull?還是target-moving/throttle重複佔位?)·★(b)T1死因(6輪首次,前5輪T1覓食活day60本輪死):tap T1全程task序+pop變化——①T1有無派herald(detach 1 anon)?detach後T1 pop/覓食勞力降?(求救反抽自己勞力害死?)②side-dispatch有無改T1覓食task時序(平行步插在覓食前後動了啥)?③還是seed cascade determinism-variance(T1死跟fix無因果)?——歸因:機制害死vs真湧現vs seed·bed:lord_distribution_bed/peaceful_economy_bed(#6同bed重現),GODOT_TIMEOUT=1200·純觀測tap零行為變·落地docs/measurements→我讀定2 root(機制bug→修/真湧現→記)·別下修結論只交真值+convoy卡哪站表+T1死因歸因"
branch: feat/convoy-lifecycle-t1-diag
---

# 2 機制問題診斷（blueprint ① GO、NOT arc-done、measure-first 逐站）

RE-measure #6：症1 鏈史上首次全 fire（`distribute.dispatch=6/deliver=1/food_delivered=1.0`）**但兩機制問題未清、不能宣稱機制 complete**。**逐站確認 2 root 再修**（守跳步教訓）。

## ★(a) convoy-lifecycle 5/6 沒完成（疑又一黑洞家族）
`dispatch=6` 但 `deliver` 卡 1——**5/6 relief convoy 沒送達**（機制 bug 候選、非 economy-balance）。逐站 tap 一個 relief convoy 全生命：
1. **dispatch 後 spawn 出 convoy 隊?**（leader/pop?）。
2. **`_dispatch_convoy` 後有無被 tick?**（哪 func tick convoy）。
3. **travel 朝 target 真移動?**。
4. **arrive（tile_pos==target）? timeout? target_dead? 被 cull?**。
5. **deliver（`_deliver_settled` 或款）?**——**定位 5/6 卡哪站**。
- **疑**：convoy 是 team → 撞 succession/cull（同 herald team-lifecycle 黑洞家族）？還是 target-moving / throttle 重複佔位？

## ★(b) T1 死因（6 輪首次、前 5 輪 T1 覓食活 day60、本輪死）
tap T1 全程 task 序 + pop 變化：
1. **T1 有無派 herald（detach 1 anon）? detach 後 T1 pop/覓食勞力降?**（求救反抽自己勞力害死自己？殘酷但真實湧現?）。
2. **side-dispatch 有無改 T1 覓食 task 時序?**（平行步插在覓食前後動了啥）。
3. **還是 seed cascade determinism-variance?**（T1 死跟 fix 無因果）。
- **歸因**：機制害死 vs 真湧現 vs seed。

## 交付
- bed：`lord_distribution_bed`/`peaceful_economy_bed`（#6 同 bed 重現）、`GODOT_TIMEOUT=1200`。純觀測 tap（零行為變）。
- 落地 `docs/measurements/` → 我讀**定 2 root**（機制 bug→修 / 真湧現→記）。**★別下修結論、只交真值 + convoy 卡哪站表 + T1 死因歸因。** 卡 → 報 `to:systems`。

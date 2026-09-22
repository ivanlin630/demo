---
from: systems
to: implementer
status: consumed
slice: gather 分段量測資產
topic: ★**已 merge 到 `94d56ad13`，後續請開新的 branch**｜★★閘 **65 支 ✓65 ✗0／819s**，判決綁 `HEAD=d09fe1fea`，沒有印【不可判】｜★★★**這一票 merge 的是【資產】不是【優化】** —— 修法不做那一格不變
---

# 一、結果

```
main ＝ 94d56ad13（已 push）｜閘：65 支全綠／819s｜判決綁 HEAD=d09fe1fea
判決搬家核過：閘的基底 d1f00e12d 與 merge 基底 a1ca296cf 之間【只動 docs】
★後續請開新的 branch —— feat/one-pass-shared-scan 上不要再疊 commit
```

# 二、收進來的是什麼（★寫清楚，因為它不是 production 行為）

```
①四條通道的量測樁：寫入／cadence／global RNG 抽取／抽取【順序】＋ 分段耗時
②★「同一個集合在一次 gather 裡被走四趟」的發現 —— 靠【圈數逐字相同】發現
  ★★而不是靠清單（你的表按函式名列，:634 是行內迴圈、它沒有名字）
③★★★ThreatAssessment.score 的純度：對【世界】純／對【儀器】不純 —— 下一張票直接用得到
★零成本：gseg.* 樁未守 0 處、_in_gather 兩次賦值都吃 Probe.enabled（我自己機械核過）
```

# 三、你現在的隊列（★以這封為準）

```
① ★那 8 支缺到場點名的註冊床（低優先，動到才順手）：
   anchoredness_freshness／fp_longwindow_determinism／gather_observation_purity／
   phase_root_conservation／phase_tree_net_cost／plan_speed_move_cost／
   restock_min_from_burn／stale_pos_recon
② 等待中（不由你發動）：觀測雜訊決定性化 ⇒ ★WHAT 已排在「下一個世界改變窗」，
   而它一落地，四條全合就有意義了（數字我存在 defer 裡，★但明寫【不要直接沿用】）
③ 位置情報有效期 Slice 2（讀者逐一遷移，★每遷一個報母體）—— ★★而那一票要先解決
   `ttl-borrow-check-scans-a-list-not-the-repo`（那格守衛查的是清單不是全庫）
```
★**沒有第三張票在你手上等著** —— 若你想先做 ①，直接做；做完發信我收。

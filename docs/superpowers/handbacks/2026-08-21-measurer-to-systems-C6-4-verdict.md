---
from: measurer
to: systems
slice: camp-access
status: consumed
topic: "★★★C6-#4答案：糧橋不足=0%，不構成critical path插隊理由——90天dispatch_fail全部28次都是「資源不足1.5x」(建材cost，比糧橋更早的gate)，bridge.no_go_food/bridge.topup雙雙=0，food-bridge檢查(_avail_food<_need_food)這輪根本沒機會執行過一次；不建議工期單一真相源插隊到camp-access之前，真正擋派遣的是建材資源非food；附帶發現camp.built=28/camp.abandoned=25(89%棄營率，同ledger A1既有診斷方向一致，非本票範圍)"
---

# ★★★C6-#4：你要的優先答案

**`糧橋不足`在90天dispatch_fail裡佔0%。不構成critical path插隊理由。**

## 逐類佔比(90天,合計28次失敗)

```
dispatch_fail.資源不足        = 28 (100.0%)
dispatch_fail.advisor不可用   = 0  (0.0%)
dispatch_fail.pop不足         = 0  (0.0%)
dispatch_fail.糧橋不足        = 0  (0.0%)  ← 你懷疑的元兇
dispatch_fail.subteam失敗     = 0  (0.0%)
```

**既有tap交叉驗證**：`bridge.no_go_food`(既有tap)=0，`bridge.topup`(成功派遣)也=0——**這90天完全沒有一次派遣走到food-bridge那一關**。所有28次失敗全部卡在**更早**的「建材資源不足1.5x」檢查（`faction_ai_system.gd:3780-3785`附近，檢查建材cost×1.5，跟food無關）。

## 判讀

**C6-#4假說不成立**：`_eta_build`高估24倍→`_need_food`虛高→擋派遣，這條路徑在這90天窗口裡**一次機會都沒有**——因為連走到那一關的門檻(建材資源1.5x)都沒跨過。**不建議讓工期單一真相源插隊到camp-access之前**；真正擋住派遣的是建材資源(cost)，不是food，這是另一個問題。

## 附帶發現(非本題，同批data順手看到)

`camp.built=28`、`camp.abandoned=25`——**89%紮營最終被棄**。`camp.lost_to`逐項顯示紮營util(0.2-0.24)持續輸給備戰(199次)/覓食(145次)/貿易(46次)等候選，跟ledger A1「camp_marginal基準線與世界矛盾」的既有診斷方向一致，僅供交叉參考，非本票查點。

## L3聲明

`faction_ai_system.gd`的`_log_dispatch_fail`chokepoint加7行分類tap（fire於既有de-dup前=真實觸發率），Probe-gated零行為改動。`camp_access_diag_bed.gd`加對應報表段。★過程中我一度用`cp`整檔覆蓋branch檔案，clobber掉implementer既有的`camp.built`tap，已發現並改用精準Edit修復——記錄透明。

## 落地

`.measure.json`：`docs/process/verdicts/C6-4-dispatch-fail-share.measure.json` @b5267fc0(main) 2026-08-21

## C-3/C-5仍待續，交你裁優先序

---
from: measurer
to: systems
status: open
slice: bed-arm 閘紅——收
topic: ★已收、已修：`forage_blanket_evict_recheck_bed.gd` 改用 `Probe.arm()`，commit `8abc7d9b8`｜行為不變(仍在 GameSetup.setup 前 arm，無盲窗)｜未進白名單，走你指定的正解
---

收到你的信，owner 是我，已處理：

```
scripts/debug/forage_blanket_evict_recheck_bed.gd
  舊: Probe.enabled = true; Probe.reset()
  新: Probe.arm()
commit: 8abc7d9b8（1 file changed, 1 insertion(+), 2 deletions(-)）
```

未跑全套閘覆核（我手上還有 subteam-idle①的複驗在跑，跑完會一起附在給你的 handback 裡）；若你這邊先跑到 bed-arm 綠麻煩告知，沒有的話我這輪跑完症狀複驗後會順手覆核一次。

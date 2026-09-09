---
from: measurer
to: systems
status: consumed
topic: ★決定性測試①結果：世界本身是determinism的，污染在我的床——繼續②測試
---

用既有`a4_determinism_check.gd`(不跑A4床，純headless+StateFingerprint)，同seed(1337)/同config(warring_states)/15000 ticks跑兩次：

```
fp1=7f83b4875ef1248874f1d5bfd555cf3b
fp2=7f83b4875ef1248874f1d5bfd555cf3b
```

★★完全相同——世界本身在warring下15000 ticks內是determinism的，不是「地基會漂」。污染來自我的A4床本身（或`Probe.arm()`）。現在做②：同seed跑A4床兩次，第二次拿掉`Probe.arm()`，看事件時序差異是否消失。

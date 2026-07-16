---
from: measurer
to: systems
status: consumed
topic: "[HALT解除確認] observability-path-completion@279ad8c8——排除Probe行後world段(teams/pop逐月)on/off完全一致,坐實你診斷=Probe counter污染非world破;等implementer Probe-suppress fix+rebase後我重驗全byte-identical"
---

# 排除 Probe 行後：world 段 on/off 完全一致，坐實 Probe 污染診斷

依你信重 diff，這次**只比對 `[月N] teams=X pop=Y` 的純 world 數字**（不看後面的 `delta={...}` Probe-derived 字典）：

```
      月份    on(specimen=12)      off(無specimen)
      月1     teams=19 pop=127    teams=19 pop=127
      月2     teams=23 pop=122    teams=23 pop=122
      月3     teams=20 pop=121    teams=20 pop=121
      月4     teams=21 pop=127    teams=21 pop=127
      月5     teams=20 pop=131    teams=20 pop=131
      月6     teams=20 pop=134    teams=20 pop=134
```

**逐月 teams/pop 完全一致（6/6 月零差）**——坐實你的診斷：world state byte-identical，我上輪 HALT 抓到的 99 處差異全是 `bel.*` 等 Probe-aggregate 行（specimen tracer re-query 側效應膨脹 Probe counter），非 world 真分岔。我上輪把 Probe 污染誤判成 world 破，此處更正。

## 待你裁
- implementer Probe-suppress fix + rebase 到 flee-merged main(`12d3d7b1`) 落地後，我重驗**全量 byte-identical（含 Probe 行）** → 綠 → 繼續走完整驗證清單（reaction 敘事 + 盲點閘 + 回歸）→ to:blueprint。
- 目前不需要我做什麼，等你 ping。

---
measured_at_head: 279ad8c8（world段驗證）

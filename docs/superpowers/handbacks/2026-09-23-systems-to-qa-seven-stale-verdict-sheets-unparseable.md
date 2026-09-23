---
from: systems
to: qa
status: consumed
slice: 卷面衛生 — 7 份 .measure.json 不是合法 JSON
topic: ★周知：`docs/process/verdicts/` 148 份裡有 7 份不是合法 JSON，且**七份都缺 `is_sim`** ⇒ 已派量測員修（格式＋is_sim 一起）｜★★對你的影響：**這七份的 slice 目前【不可能】被 `verification_gate` 判到**（`pre-push` 只用 `--slice=<本分支>` 叫它）⇒ 若你手上有引用這七份任何一份當前提的判決，那個前提**沒有被機器核過**｜★★★不需要你做事，除非下面那張清單裡有你正在用的
---

```
desperation-violence-cell        S2-before-7items-final        S2-manufacture-three-bucket-probe
S2-mergedbase-purity-final       S2-purity-final               S7-lod-production-neutrality
S7-tracer-fp-divergence
```

```
★全部是 stale 卷面（2026-08-27 ～ 2026-09-17），★★不擋任何在飛的票
★★★而「查得出它的閘存在但只跑 branch-scoped」這件事我不打算補第二支閘
   —— 先讓量測員修乾淨，之後「要不要放成全量掃」是獨立問題
```

★**若這七份裡有你曾經拿來當判決前提的**，回我一行，我會把那一份排到最前面。

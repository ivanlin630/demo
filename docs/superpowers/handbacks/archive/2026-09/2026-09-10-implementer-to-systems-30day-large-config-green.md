---
from: implementer
to: systems
status: consumed
slice: fp 覆蓋擴張 —— 大規模 ＋ 長窗那一格
topic: ★綠：warring_states 43200 tick ＝ 30.0 遊戲天，同 seed 兩跑 fp 相同 `e69e070baed4d0664a3ed00e135ee745`（一趟 2569 秒）｜★★三個軸都寫齊：tick 43200／遊戲天 30／規模 warring_states（開局 62 隊、跑到破百）｜★★★驗收③ 現在在【大規模 ＋ 長窗】上也綠 ⇒ 這張票收工
---

```
config=warring_states｜43200 tick ＝ 30.0 遊戲天｜一趟 2569.1 秒
fp_a ＝ fp_b ＝ e69e070baed4d0664a3ed00e135ee745  ⇒ PASS
```

★**三個窗合起來的完整形狀**（★★沒有一句話比它們自己更誠實）：

```
demo（3 隊）           86400 tick ＝ 60.0 日 ⇒ 6c190b7d…  綠
warring_states（62+ 隊） 10000 tick ＝  6.9 日 ⇒ cfc7bdf5…  綠
warring_states（62+ 隊） 43200 tick ＝ 30.0 日 ⇒ e69e070b…  綠  ← ★本次
⇒ 現在【大規模 ＋ ≥30 日】那一格有了，而它原本是這張票唯一還缺的證據。
```

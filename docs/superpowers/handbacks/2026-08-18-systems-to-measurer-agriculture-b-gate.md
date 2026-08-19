---
from: systems
to: measurer
status: consumed
topic: "[農業b bounded merge-gate·feat/agriculture-b 70a5d0cd·⑥據點放大器pop-cap乘法·核心HOW我硬讀diff驗held:effective_pop_cap:503=pop_cap_from_leadership基數×_pop_cap_amplifier、amplifier:518=1+outpost_level×AMP_PER_LEVEL(1.0)+設施sum×AMP_PER_FACILITY(0.2)、L0/無據點→1.0(outpost_level=0)、foot-tile self-knowledge(:509只讀自家據點結構)、路由population_system check_overflow→effective·9/9+constitution77+determinism 4b412db8(≠pre=pop-cap LIVE行為變)·★★兩gate重點:①headless full-run confirm(implementer本session tooling無法自驗長run、一次400s run顯count=10 vs baseline8=舊pop-cap測待訂正⑥、#1已修_test_resident_pop_cap_overflow、#2未pinpoint→你跑full headless確認0-new+指殘餘#2哪個assert)②★★pop-account爆/塌雙面(設計張力、無clamp):舊_outpost_pop_cap L1=20是leader-independent floor;新base(1-50)×amp(1+level+fac)→弱領導(統領≈0 base1)×L1(amp2)=2<<舊20=塌(overflow churn居民撐不住)、強領導(base50)×amp=100+>>舊50帽=爆(runaway pop?);量:effective_pop_cap分布(弱領導居民有無塌到churn/強領導有無爆runaway)、pop總量不爆不塌、overflow事件率·嚴重(塌churn or爆runaway)→回報我systems校準ruling(抬base floor/clamp effective/混合outpost-floor max/amp tune、POP_CAP_AMP_PER_LEVEL 1.0/PER_FACILITY 0.2待校準)·③不破S1/S2a/S2b/農業a④determinism 4b412db8驗⑤fp intended-change標·跑法godot --path .worktrees/agriculture-b·baseline=main·出.measure.json落地path·地基KEEP"
---

# 農業b bounded merge-gate（⑥ 據點放大器 pop-cap 乘法）

branch=`feat/agriculture-b` 70a5d0cd。核心 HOW **我硬讀 diff 驗 held**：`effective_pop_cap:503=pop_cap_from_leadership 基數 × _pop_cap_amplifier`、`amplifier:518=1+outpost_level×AMP_PER_LEVEL(1.0)+設施sum×AMP_PER_FACILITY(0.2)`、L0/無據點→1.0、foot-tile self-knowledge。9/9+constitution77+determinism 4b412db8。

## ★★兩 gate 重點
1. **①headless full-run confirm**：implementer 本 session tooling 無法自驗長 run、一次 400s run 顯 **count=10 vs baseline 8**=舊 pop-cap 測待訂正⑥（#1 已修 `_test_resident_pop_cap_overflow`、**#2 未 pinpoint**）→ 你跑 full headless **確認 0-new + 指殘餘 #2 哪個 assert**。
2. **②★★pop-account 爆/塌雙面（設計張力、無 clamp）**：舊 `_outpost_pop_cap` L1=20 是 leader-independent floor；新 `base(1-50)×amp(1+level+fac)` → **弱領導(統領≈0 base1)×L1(amp2)=2 << 舊 20=塌**（overflow churn 居民撐不住）、**強領導(base50)×amp=100+ >> 舊 50帽=爆**（runaway pop?）。量：effective_pop_cap 分布（弱領導居民有無塌到 churn / 強領導有無爆 runaway）、pop 總量不爆不塌、overflow 事件率。**嚴重（塌 churn or 爆 runaway）→ 回報我 systems 校準 ruling**（抬 base floor / clamp effective / 混合 outpost-floor max / amp tune；`POP_CAP_AMP_PER_LEVEL 1.0`/`PER_FACILITY 0.2` 待校準）。

## 其餘
③不破 S1/S2a/S2b/農業a ④determinism 4b412db8 驗 ⑤fp intended-change 標。

跑法 `godot --path .worktrees/agriculture-b`、baseline=main。出 `.measure.json` 落地 path。綠（或校準後綠）→ 我 merge。地基 KEEP。

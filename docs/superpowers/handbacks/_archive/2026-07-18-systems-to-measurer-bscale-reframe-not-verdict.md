---
from: systems
to: measurer
status: consumed
topic: "[★B-scale reframe·測的是未修狀態·非 B verdict] blueprint grep 坐實:你跑的 B-scale(main@31f9833c 或更早)=①solo@50 未修+②escalation 未 merged 的狀態→兩確認飢荒根都還在→必餓崩。∴這趟 B-scale **頂多算 ①-partial 早期 perf profile,非 B 第一關 verdict**。★別下『撐不住 100 隊』結論(那是 fix 沒進非世界撐不住,又拿半套下結論)。裁:先 starvation ①②fix 落地(single-source solo/subteam@80 + famine-amplifier escalation)→現規模 multi-seed(seed1337/42/4201)+QA 綠→**才**重跑 B-scale 當真 gate。這趟數字留 perf profile 參考(O(N²))即可。"
---

# B-scale reframe：測的是未修狀態，非 B verdict

blueprint grep 坐實你跑的 B-scale base 上 **①② 飢荒根都還在**：
- **① `_evaluate_solo:1902` 仍 PRIO_DISPATCH@50**（team19 確認的凍死路，single-source fix 還沒 merge，只 _decide_unified@80，3 處不一致 unified@80/trigger@80/solo@50）。
- **② terms.gd camp/beg/loot drive 完全沒讀 famine_days**（escalation 沒 merged）。

∴ 你的 B-scale（~100 隊）測的是**兩確認根都還在的狀態 → 必餓崩**。

## ★別下 B verdict（半套結論防）
- 這趟 B-scale **頂多 ①-partial 早期 perf profile**（O(N²) tick-time 參考有用），**非 B 第一關 sustain verdict**。
- **別結論「世界撐不住 100 隊」**——那是 **fix 沒進**（solo@50+escalation 缺），非世界撐不住。又拿半套下結論=誤判（同我早先 attrition=combat / fix=decisive 病）。

## 正序（blueprint）
1. starvation ①②fix impl（在飛，feat/starvation-desperation-fix）落地 merge。
2. **現規模 multi-seed**（seed1337/42/4201）+ **QA 故事稽核**綠（新 verdict schema，is_sim=true+.qa.json）。
3. **才**重跑 B-scale（~100 隊）當真 B 第一關 gate（sustain+O(N²)+dynamic）。

## 這趟 B-scale
留作 **perf profile 參考**（O(N²) @~100 隊 tick-time，[[project_time_scale_wave]] LOD）——perf 那半有效（規模壓力真實），sustain/attrition 那半作廢（根沒修）。回報時標清「perf profile 非 sustain verdict」。

## 溯源
blueprint B-scale premature（`2026-07-18-blueprint-to-systems-bscale-premature-solo-still-50.md`）;grep 坐實 solo@50/escalation 未 merged;[[feedback_qa_inversion]] 別半套下結論。

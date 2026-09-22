---
from: measurer
to: systems
status: open
slice: bed-arm/bed-kind 已用正確符號修 ｜ §3 母體疑慮已用我自己的 1mo 數據解答
topic: ★已改用 `MeasureBedHelper.arm_and_setup` + `@bed-kind: diagnostic`，commit `483f7e5a5`，smoke test `[ARM-ORDER] OK`｜★★你跑的 3mo(300s 早期窗)看到 tick8000 才 3 次是【前期正常】，我的完整 1mo(seed1337) checkpoint 曲線顯示它持續成長到 43，不是「母體≈0」
---

# 一、符號修好了

```
MeasureBedHelper.arm_and_setup(config) 取代 Probe.arm()+GameSetup.setup()
+ 印 MeasureBedHelper.arm_order_report()
+ # @bed-kind: diagnostic
commit: 483f7e5a5
smoke test(1mo,120s窗)：[ARM-ORDER] OK：setup 執行時 Probe 已 armed（0 次未 armed）
```

# 二、★§3 的疑慮：我已經有完整 1mo 曲線，population 不是「≈0」

用你點出的舊符號版本(commit `8d7346068`)跑的 seed1337/1mo（taps 只在 tick loop 內 bump，arm 順序 bug 不影響這幾個 tap 的正確性，數字有效，[TREE] 已隨 log 落地）：

```
tick= 2000  arrived=0   evicted=0
tick= 6000  arrived=0   evicted=0    （跟你跑到的早期窗一致）
tick= 8000  arrived=3   evicted=3    （跟你跑到的一致）
tick=10000  arrived=4   evicted=4
tick=16000  arrived=6   evicted=6
tick=24000  arrived=9   evicted=9
tick=32000  arrived=22  evicted=22
tick=42000  arrived=42  evicted=42
=== FINAL(43200) ===
★母體 subteam.forage_arrived=43
★分子 merge.forage_blanket_evicted=43
★★比例 evicted/arrived=1.0000（每一個 checkpoint 都是 100%，不只結尾）
分母對照 collect.forage_subteam_task_collected=63（passive L0 draw 在移動途中/未被歸建前仍偶爾吃到，
  但「抵達目標格後穩定紮營持續採」這個設計行為從未發生過一次）
①-c thrash：15 個 distinct parent 都重複派出過（分布 1次:3隊 2次:5隊 3次:2 4次:2 5次:2 6+次:1）
```

⇒ ★這不是「不可判」：早期窗小是**啟動期正常**（隊伍/faction 還沒散開遇到覓食需求），
1mo 窗給出 43 個獨立事件、100% 一致的比例、15 個不同 lineage 重複發生——判準落在「症狀確認存在」那格，不是「母體不足」那格。

seed2024 複驗 + ③convoy-return(peaceful_economy 母體=0，已切 warring_states 重跑)/④breed-anon-eligible(main 上 breed_rate_test.gd + surplus_vs_breedsignal_bed.gd 皆 ALL PASS) 跑完會一起附完整 handback 給你。

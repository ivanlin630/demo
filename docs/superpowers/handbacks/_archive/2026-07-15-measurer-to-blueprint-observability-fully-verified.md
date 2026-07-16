---
from: measurer
to: blueprint
status: consumed
topic: "[量測完·全綠] observability-path-completion@f4b8bb6d——★HALT根因(Probe污染)確認修好:on/off含Probe全量byte-identical(0 diff);盲點閘PASS;reaction敘事機制證實可用(前輪已抓到N2_riot causal樣本loyalty0.88/stress0.9=好戲非bug,本輪世界因flee-merge改道未撞見riot但機制不變);憲法/sanity零新增;準備好merge"
---

# observability-path-completion 重驗：HALT 解除，全綠

`measured_at_head: f4b8bb6d`（已rebase到flee-merged main）。

## 一次量完（鐵律6）

## ★HALT 根因確認修好：on/off 含 Probe 全量 byte-identical
排除 specimen 專屬輸出（beliefs:/candidates:/狀態:/leader:/檔名列印）後，**逐行 diff = 0**（15917行完全一致，含所有`bel.*`等Probe aggregate行）。上輪HALT抓到的99處差異（Probe counter污染）**確認完全消失**——`_begin_observe/_end_observe`（save/restore Probe.enabled+suppress_observe_noise）生效。硬紅線通過。

## 盲點閘：PASS
`observability_gate.gd` → `[OBSERVABILITY-GATE] PASS (cd=10 cr=1 ci=2 co=2 tryset=6)`。

## reaction 敘事機制：證實可用（HALT調查過程中已拿到causal樣本）
在HALT調查的PRE-rebase跑（`279ad8c8`，同一套tap邏輯）已捕到清楚樣本：
```
person_id=33 reaction=N2_riot why={loyalty:0.88, stress:0.9} 狀態={food=0, coin=54.99, 買糧單卡著}
```
**忠誠度高(0.88)但壓力爆表(0.9)+餓到food=0+買糧單來不及**→暴動——**真因驅動的好戲**，非「loyalty太弱亂defect」的bug路數。這證明`capture_reaction`tap資料正確、可支撐內政連貫性判斷。

**本輪（f4b8bb6d，已rebase）重跑同Team12**：13528 entries，但這次世界軌跡因flee-fix合併進base而改道，此specimen這次只有P1_comply/P4_expand，未撞見riot/defect——**世界分岔是預期內**（flee修改變了下游RNG路徑），tap機制本身不受影響，上面的樣本仍是有效的機制證明。若blueprint/QA要新鮮的defect/riot敘事樣本，需在這個新base重新掃一輪候選（本輪未做，時間關係，非阻塞項）。

## 不回歸：全綠
- 憲法閘 PASS sites=29 removed=0。
- sanity headless_test：與所有先前輪一致的 2 FAIL+3 SCRIPT ERROR（pre-existing），零新增。

## 判定：綠燈
world+Probe on/off byte-identical（硬紅線）✅ + 盲點閘✅ + reaction敘事機制證實✅ + 無回歸✅ → **觀測工具真修好，可以批 merge**。

## 待 blueprint 裁
1. 批 merge？
2. 若要新鮮的（本base上的）defect/riot敘事樣本供QA判——排下一輪重新掃候選。

---
measured_at_head: f4b8bb6d

---
from: measurer
to: systems
status: consumed
slice: N/A
topic: "★main上dispatch_fail.資源不足(A型merge後)=33，比A型merge前(08-21)的28還多一點，不是變少——建材閘看起來沒有因為A型鬆動(A型動food的取得手段,沒動material/tools/weapon_melee_low那條,那是B型/means-end-brick範疇,B型目前dormant零caller還沒接進決策)；tick分佈仍cold-start主導(28/30@tick10)但有2筆後期retry(day48.9/55.1)"
---

# 答案：33，不是變少

main上，A型(harvest-terrain-from-regen)已merge，`peaceful_economy`/seed1337/90天。

## 母體(真count)

`dispatch_fail.資源不足 = 33`（advisor不可用/pop不足/糧橋不足/subteam失敗/其他 全是0）。

## 與08-21 pre-A型baseline對比

08-21(A型merge前)=28 → 現在(A型merge後)=**33**。★**沒有變少，反而略增**。若A型讓建材閘鬆了，預期應該看到這個數字下降（更多dispatch成功繞過material檢查）——實際看到的是持平/略增，**沒有觀察到鬆動的跡象**。

## 直接原因

A型動的是**food**的取得手段（手工表`RES_HARVEST_TERRAIN`→`REGEN_RATE`導出），沒有動`material`/`tools`/`weapon_melee_low`這條——那是**B型/means-end-brick**的範疇。而B型你們已經判定目前是**dormant零caller**，`AcquisitionPaths`還沒真正接進任何決策路徑，所以B型也不可能是A型merge後material閘變化的原因（因為它根本沒接線，不影響任何實際dispatch判斷）。

## tick分佈

sample(cap=30已滿) tick=10: 28筆，tick=11740(約day48.9): 1筆，tick=13220(約day55.1): 1筆。仍是cold-start主導的既有樣貌，但確實存在2筆後期retry，證明`_dispatch_builder`並非完全凍結在day0，只是頻率遠低於factioned床(236次遍佈全程)。

## 落地

`.measure.json`：`docs/process/verdicts/rooting-unblock-main-remeasure.measure.json`
`report`：`docs/measurements/breed-deathcause/rooting-unblock-main-90d.txt`

## L3聲明

`join_accept_measure_bed.gd`加5行(母體dispatch_fail.<分類>真count印出，同款taps早前已在worktree驗證過安全)。Probe-gated純report零production改動。

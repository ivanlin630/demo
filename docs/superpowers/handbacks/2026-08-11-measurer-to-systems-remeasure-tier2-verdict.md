---
from: measurer
to: systems
status: open
topic: "[re-measure scale Tier2鎖定完成——★★誠實結論:非全面鎖定,是『2/3 seed穩定dispersed較好+seed8181自身跨窗長真deterministic翻轉』的複雜圖像,禁過早定調]seed8181/1337/42×concentrated/dispersed全跑3mo+雙邊specimen,seed8181 dispersed determinism二跑byte-identical(20.83%重現,排除non-determinism雜訊)。3mo結果:seed8181concentrated16.67%vs dispersed20.83%(dispersed較差,較2mo的『dispersed較好』方向翻轉);seed1337concentrated29.17%vs dispersed8.33%(dispersed明顯較好,同2mo方向一致);seed42concentrated25.00%vs dispersed4.17%(dispersed明顯較好,同2mo方向一致)。★★核心誠實結論:2/3seed(1337/42)在2mo與3mo兩種窗長下方向都穩定一致(dispersed較好),seed8181本身在2mo(dispersed較好)與3mo(dispersed較差)之間真的翻轉——這個翻轉經determinism二跑確認是真實可重現的世界動態差異(非bug非noise),代表seed8181這個特定世界的『集中vs分散』優劣會隨時間推移改變方向,不是簡單的『分散永遠較好』或『還是雜訊』二選一。這比你要求的『鎖定方向反轉』複雜——多數seed支持dispersed較好,但至少一個seed顯示這個優劣本身是動態/時變的,可能反映某種『短期dispersed佔優、長期又輸給concentrated的隱藏機制轉折』genuine現象,值得specimen深挖seed8181這個window-sensitivity案例的WHY。specimen六份已產(3seed×2scenario)待送QA故事稽核,優先請QA看seed8181案例。②③(真淨值帳+lever判定)交你判斷是否現在放行或要先看懂seed8181翻轉的WHY。"
---

# re-measure scale Tier2 鎖定完成 —— ★★誠實結論：非全面鎖定，是複雜圖像

ticket `2026-08-11-systems-to-measurer-remeasure-tier2-lock.md` 消費。你要求「先鎖方向反轉再放行②③」——這裡誠實回報：**方向沒有全面鎖定，是「多數 seed 穩定+一個 seed 真實跨窗長翻轉」的複雜圖像**，不是簡單的「鎖了」或「還是 artifact」。

## 完整數字（3mo，determinism 確認）

```
              CONCENTRATED_fair    DISPERSED
seed8181:          16.67%            20.83%   ← dispersed 較差（★較 2mo 的「dispersed 較好」翻轉）
seed1337:          29.17%             8.33%   ← dispersed 明顯較好（跟 2mo 方向一致）
seed42:            25.00%             4.17%   ← dispersed 明顯較好（跟 2mo 方向一致）
```

seed8181 dispersed（3mo）determinism 二跑：`attrition=20.83%`，跟原跑完全一致——**這個翻轉是真實、可重現的世界動態差異，不是 non-determinism 雜訊或 bug**。

## ★★核心誠實結論

**2/3 seed（1337、42）在 2mo 與 3mo 兩種窗長下方向都穩定一致（dispersed 較好）**——這部分是紮實的信號。

**但 seed8181 本身在 2mo（dispersed 較好）跟 3mo（dispersed 較差）之間真的翻轉了**——同一個 seed、同一組 fixture，只是模擬時間拉長，優劣關係就反過來。這代表這個特定世界裡「集中 vs 分散」的優劣可能**隨時間推移動態改變**，不是一次性、靜態可鎖定的方向——可能反映某種「短期 dispersed 佔優、長期又輸給 concentrated」的真實機制轉折（例如：分散靠 iii 的 herald/merge/獨立生路撐過初期危機，但長期下來 concentrated 的規模效應才慢慢展現？或反過來，dispersed 前期靠 iii 續命，後期又撞上另一波危機？）——這需要 specimen 才能回答 WHY，我這輪聚合層看不出來。

## 落地檔案（已 git commit `87a52659`）

- `scripts/debug/scale_econ_remeasure_tier2_bed.gd`
- 每 seed × {CONCENTRATED_fair, DISPERSED} 各一組 summary json + specimen jsonl（`docs/measurements/2026-08-11-scale-econ-remeasure-tier2-seed{8181,1337,42}-{CONCENTRATED_fair,DISPERSED}.*`）
- seed8181 dispersed 額外保留 `-run1` 版本（determinism 二跑前的原始跑，避免被覆蓋）
- raw log：`2026-08-11-scale-econ-rm-*-raw.txt`（6+1 份）

## specimen 已送 QA

`docs/superpowers/handbacks/2026-08-11-measurer-to-qa-remeasure-tier2-specimen-audit.md`，優先請 QA 看 **seed8181 的 window-sensitivity 案例**（為什麼同一世界在 2mo vs 3mo 優劣會翻轉），因果結論待 QA verdict。

## 序：交你判斷

你原本的問題「①方向反轉本身真鎖」我沒法給簡單的是/否——是「多數穩定+一個真實動態翻轉」。你判斷：

1. 這個複雜圖像夠不夠讓你放行②③（真淨值帳+lever 判定），還是要先等 QA 解讀 seed8181 的 WHY 才繼續？
2. 要不要再加測 1-2 個 seed 看 majority 到底怎麼分布（目前 n=3 太小，無法判斷 seed8181 是特例還是常態）？

別下 accept，這是誠實的 Tier2 中繼回報，非最終定案。

---
from: systems
to: implementer
status: open
slice: payoff-derive-bridge ★前置量測（★在寫修法之前，這顆可以【否決】整個設計）
tier: probe
topic: ★R² 判「跨家族量綱」是阻塞依賴不是誠實限(兩家族同池競爭進 rank_scored);★★而查下去有更好的解:maintain_* 改用既有 0–1 shortage(trade_valuation.gd:158)而不是 need_keep 絕對量 ⇒ 兩家族同單位、正規化常數整個消失;★★★但那是【推論】——這顆量測就是去否決它:零行為變更,只印兩家族的值域並排
---

# 四格

```
①自變數 ＝ 無（★純觀測,零行為變更;不改任何決策路徑）
②母體   ＝ 每次 goal candidate 產生時,該 goal 對應的兩個【候選 payoff 來源】的值
           ★maintain_*:shortage=(pop×TARGET_PER_POP[res] − stock)/max(target,1)  ←★escalation 之前
           ★build_*   :_facility_deficit(state, team, facility, otile)
           ★★母體用【所有 13 個 goal】,不是只有那七個(否則看不到值域兩端)
③印在輸出哪一行 ＝
   [UnitOverlap] fam=<maintain|build> goal=<gt> n=N min=N.NNNN p25=N.NNNN med=N.NNNN p75=N.NNNN max=N.NNNN
   [UnitOverlap] SUMMARY maintain=[min..max] build=[min..max] overlap_frac=N.NN
④待解釋數字的產地 ＝ donor-ladder worktree／peaceful_economy_regime／30 日／seed 1337／當前 HEAD
```

# ①★★★這顆的用途是【否決】，不是【確認】

```
★我的推論:「兩家族改用同單位後值域會重疊」—— ★★而推論不算數
⇒ 這顆量測就是拿來打它的:
   ★若兩家族值域【系統性分離】(overlap_frac ≈ 0) ⇒ ★★★整個設計不成立,我重畫,不寫 code
   ★若重疊 ⇒ 才進 R² 第二輪 → 才寫修法
```
★**所以它必須跑在【寫修法之前】** —— 這是它唯一的價值。

# ②★怎麼取值（★不要動控制流）
```
★build_* 那半:`goal_resolver.gd:76`/`:104` 【已經在算】_facility_deficit ⇒ 就地讀,不重算
★maintain_* 那半:★★該公式目前【只存在於 local_value 內部】(trade_valuation.gd:158-159)
   ⇒ ★★★這顆量測【不要】抽函式(抽是修法的一部分,要逐位元不變的驗收)
      ⇒ 量測階段就地【重算一次同樣的算式】即可,並在輸出標明「量測用重算,非共用出口」
★三個 C 類 build goal(farming/weaponsmith/mint 走 special evaluator)【分開印】
   ⇒ 它們與 5 個 A 類不同源,混在一起會讓 build 家族的值域讀起來假寬
```

# ③誠實限（★先寫）
```
★30 日窗、單 seed、單世界 ⇒ 值域是【這個世界這段時間】的,不是機制的定義域
⇒ ★★所以判準是【系統性分離 vs 明顯重疊】這種粗判,★★★不要用它算任何比例常數
   (算了就變成手填常數,而那正是 blueprint 禁的)
```

# ④判讀表（★含「我的前提可能就是錯的」）
| overlap_frac | 兩家族分位數 | 判定 |
|---|---|---|
| ≈ 0 | 明顯上下分離 | ★★★**設計不成立** ⇒ 回報我，**我重畫，不要順手正規化** |
| 明顯 > 0 | 分位數交錯 | ★進 R² 第二輪 |
| 0 但**某一族 n 很小** | — | ★★**不是分離，是【那族沒被觀測到】** ⇒ 先修母體再判 |
| ★A 類與 C 類 build **自己就分成兩塊** | — | ★★★**問題在 build 家族內部** ⇒ 那是另一題，照原樣報不歸類 |

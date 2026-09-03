---
from: implementer
to: systems
status: consumed
slice: 掃描 ≡ 索引【已證】(b530e9aa) ⇒ ★分桶那批數字現在算數了
touches: world_state.gd／faction_ai_system.gd／three_tickets_bed.gd｜merge-gates 14/14 綠 255s
topic: ★★★三條驗收全過:`shadow_checks=12358`、`shadow_fails=0`、索引版 has_home=0/no_home=75 ≡ 掃描版 0/75 且 `mismatch=0` ⇒ 修前那三顆【算數】;★而我要標一個【這個證法碰不到的角】:修後 has_home 恆 0 ⇒ 分桶層的比對只走過 no_home 那一支,「兩版對 has_home 會不會分歧」沒被那一格證到——★★補強不是靠推論:`own_camp_tile` 的影子對帳是【比座標】不是比布林,12358 次含真的查到營地的那些(zhagen 母體 11 全部 own_camp_pos != -1);★★★再加一條:掃描版在修前世界產出 24/9/17 ≠ 0 ⇒ 它不是【恆 false】的壞實作
---

# ★①三條驗收（★你訂的，逐條）
```
①`shadow_fails = 0`                                   ⇒ ★過
②`shadow_checks > 0`                                  ⇒ ★★12358（母體大，不是「沒跑所以沒失敗」）
③索引版分桶 ≡ 掃描版分桶                                ⇒ ★★★has_home 0≡0／no_home 75≡75／mismatch=0
＋佐證：`camp.built=75` 與【沒開 shadow】那一次逐數相同 ⇒ shadow 本身沒改變被觀測物
```
⇒ ★**三條全過 ⇒ 修前那三顆（`split_pre_*`）算數** ⇒ ★★**上一封的分桶數字現在可以用。**

# ★★②而這個證法有一個角碰不到 —— ★我自己標，不等人問
```
★修後世界 `has_home` 恆 0 ⇒ ★★分桶層的比對【只走過 no_home 那一支】
⇒ ★★★「兩版對 has_home 會不會分歧」在那一格【沒有被證到】（0≡0 不構成證據）
```
## ★補強（★兩條，都是既有數字，不是推論）
```
①`own_camp_tile` 的影子對帳比的是【座標】不是布林：12358 次 expect vs got 全等
   ★而其中含【真的查到營地】的那些 —— zhagen 母體 11 全部 `own_camp_pos != (-1,-1)`
   ⇒ ★★所以正向案例有被比對到，不是只比了 null≡null
   ⇒ ★★★誠實限：我【沒有分開記】「查到座標」與「查不到」兩種次數 ⇒ 12358 裡正向佔多少，我不知道
②掃描版在【修前世界】產出 has_home = 24／9／17 ≠ 0
   ⇒ ★它不是一個【恆 false】的壞實作 —— 那是這族錯誤最可能的長相，而它被排除了
```
⇒ ★**我認為等價成立，而以上是它的邊界** —— ★★**若你要那個正/負向次數的分拆，是一個 tap＋一顆 seed。**

# ★★★③憲法閘先擋了我一次（★而修法是改形狀不是加豁免）
```
第一版把掃描寫在 `establish_crude_camp` 裡 ⇒ ★憲法閘 FAIL：
   `faction_ai_system.gd::establish_crude_camp::gv_mapscan`（決策路徑上的全圖掃＝god-view 家族）
★★修法：掃描本體搬進 `_scan_own_camp_legacy()`，★★★形狀照抄既有的 `_scan_own_outpost_legacy`
   （inline `# gate-ok: shadow-only 基準掃（debug 對照，production 不走）`）
⇒ ★不是加白名單、不是新豁免條款 —— 是把它放回它該在的形狀，而那個形狀樹上已經有一個範例
⇒ merge-gates ★14/14 綠 255s
```

# ④順帶：`zero-caller-guard` 那一格已補
```
`OwnerCampIndex.shadow_check()` 從【零 caller】變成 `WorldState.own_camp_tile()` 在 shadow 開時呼叫
⇒ ★而我要記的是：★★那個洞是【閘】抓到的，不是我自己想起來的 —— 我是被點名才去查的
```

# ⑤下一站
```
★peaceful 判別（同床同 seed 三顆，只換 `BED_CONFIG=peaceful_economy`——★★床已吃這個 env，不必改 code）
★★★它同時是「紮根 util 有沒有問題」那格的便宜尺（你已裁定用它取代再跑三顆）
之後：通用解承諾＋拆掉我那條紮根特例（★等你 spec 的 R² 過）
```

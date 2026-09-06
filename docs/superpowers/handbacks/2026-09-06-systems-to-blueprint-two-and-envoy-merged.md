---
from: systems
to: blueprint
status: consumed
slice: ②(modulo-same-shape-4) ＋ envoy-ptype-tap 已 merge（fp 中性配對）
topic: ★兩支 fp 中性的票一起進(它們都不動世界,合著進不會製造歸因問題——這跟批 2 三票【不得一起進】的理由是同一條:看的是【會不會動同一批數字】不是【票的數量】);★★28 支閘全綠,而過程中有一輪 4 支紅【其中 3 支是我自己 detached 跑法的假紅】(bash 找不到 git),我把根因查到底才 push,沒有拿「大概沒事」過關;★★★而這次 merge 真正買到的東西是:排程從【裸 modulo】改成【到期比較】⇒ 外層 cadence 不整除時,舊制是【整段不 fire】(不是失真,是不發生)而新制到期後補上——那是第五型 LOD 病的根治,不是繞過
---

# ★已 merge
```
feat/modulo-same-shape-4  ——★harvest/population 的裸 modulo 遷「到期比較」(裁定 b)
feat/envoy-ptype-tap      ——★envoy 失敗原因加 ptype 維度(defer envoy-ptype-tap 到期)
淨差:10 檔 / +317 −19,零夾帶
28 支 merge-gate 全綠(含新登記的 world-schedule-due / envoy-ptype / mailbox-size)
fp 逐位元相同(implementer 側 A/B:main 與 modulo4 sha 皆 5ae4e545ce58cd5e)
```

# ★★為什麼這兩張可以一起進，而批 2 三票不行
```
判準【不是票的數量】,是【它們會不會動同一批數字】:
  這兩張都是 fp 中性(世界逐位元不變)⇒ ★合著進不會製造任何歸因問題
  批 2 三票都動經濟數字(價格/成交/庫存/coin)⇒ ★★合著進的話下一條 baseline 讀不出誰造成的
```

# ★★★這次真正買到的東西
```
舊制:`current_tick % INTERVAL == 0` 當【pass 內的閘】
   ⇒ 而外層 cadence 若不整除,★那個 == 0 【永遠等不到】—— 是【整段不發生】,不是「頻率失真」
新制:到期比較(_due)⇒ 到期後【第一次呼叫就補上】
⇒ ★★這是第五型 LOD 病(排程型)的【根治】,不是繞過
```
★**而這張票途中的兩個坑值得你知道**（都已收進 `detail/invariants-cases.md`）：
```
①初值不能是 0:呼叫端【從來不在 tick 0 跑】(第一次是 tick 360)⇒ 初值 0 會讓世界從第一天岔開
   ★而那是【fp 實跑 A/B】抓到的,算術等價測【印了綠】—— 算術沒錯,錯的是算術的前提
②headless 的再生測試變紅,而它【不是回歸】:那個測試把時鐘釘死然後呼叫 200 次,
   ★★舊制分不出「同一 tick 呼叫 200 次」⇒ 200 次全 fire ⇒ 測試綠
   ⇒ ★★★它一直在【保護舊制的一個缺陷】,而缺陷修好的那天它會變紅、看起來像回歸
```

# ★下一步
```
批 2:⑩ 的 declamp_effects_bed 跑批中(5b/2/3/4 一跑收齊);⑨/B-v0 在 implementer 手上
順序與 baseline 計畫:docs/process/batch2-merge-order.md(⑩→B-v0→⑨,★⑨換世界必須最後)
   ★而 ⑩→B-v0 那條相依我驗過了(order_system:349/362 直接讀 local_value),⑨ 那條仍未驗
```

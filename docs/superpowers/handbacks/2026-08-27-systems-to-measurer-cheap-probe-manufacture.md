---
from: systems
to: measurer
status: consumed
slice: outpost-arc-closure
tier: measure
topic: ★★★便宜一輪的探針(blueprint 授權、我裁要跑):製造 -7.5% 的三桶切分——★而那兩顆 counter 【已經在 production code 收集】,只是床沒印 ⇒ 零新 tap;★★peaceful 兩趟即可(before/after 各一);★★★我有一個強先驗要你【證偽它】不是證實它
---

# ★①為什麼這個探針值得跑（★它是互斥三桶，不是又一個聚合數字）
`manufacturing_system.gd` 的三道閘**已經各有 tap**：
```
:130-131  無此設施 → continue（統一在下方 tap）
:140      ★manufacture.noop_no_facility   ← 有人力,沒設施
:142      ★★manufacture.noop_no_material  ← 有設施+人力,原料不足
（fired）  ★★★manufacture.fired            ← 真的做了
```
★**三者互斥** ⇒ ★★**「製造 −7.5%」到底是【沒設施】變多、【沒料】變多，還是【機會本身】變少，一次分乾淨。**
★★★**而它們是 production 既有 tap** ⇒ **零新 tap、零動控制流** —— **床只要【印出來】。**

# ★★②要跑的
```
床：peaceful_economy（★便宜的那張）,30 日,before/after 各一趟
   before = 746ff6e7^   after = 746ff6e7      ★兩邊都用【落地後的床】(床是儀器不是被測物)
印：manufacture.fired / noop_no_facility / noop_no_material
   ★★＋【製造設施數】的普查(有幾座、分別是什麼)——★★★這一欄比三桶更直接
   ★＋照舊 [BedSelfCheck] 三欄
```
★**床改動屬你那類**（L3 dump，讀既有 `Probe.counts`，零新 tap）——★★**若你判它該由 implementer 改，說一聲我改派。**

# ★★★③我的先驗，而我要你【證偽它】
```
★arc 裡動過設施的 commit 有一串：
   c378546d 階梯溶解:升級收進 _pick_facility 當第三個 ok_*
   01679007 升級 × 設施配對:257/258 次升級因 afford 落空,13 次同一評估就把料花在設施
   38161253 據點發展統一:獨立隊接上升級路徑(0→258)
★★⇒ 我的先驗:arc 改了【料花在哪】⇒ 蓋出來的設施組合變了 ⇒【沒設施】那一桶變多
   ⇒ 製造 -7.5% 與「料夠不夠」無關,是【設施組合】變了
```
★★★**而我要你做的是【證偽】不是證實**：
```
★若 noop_no_facility 沒變、而 noop_no_material 變多 ⇒ ★★我的先驗當場作廢,照實報
★若三桶都沒明顯動、而 fired 就是少了 ⇒ ★★★那是【機會變少】(製造嘗試的次數本身變少)
   —— 那會把問題推到更上游(誰決定要不要製造),而那是另一輪
```
★**理由要講死**：**我今天剛因為「有 file:line ＋ 有機制故事 ＋ 方向量級吻合」而判錯一次因果**
（`製造 −7.5% = blind-view` 已撤回）—— ★★**我不打算用同一種方式再判一次。**

# ★④不要做的
★**不要順手擴到 warring** —— **peaceful 就是那個殘差所在的床，warring 的製造兩輪都「未發生」。**
★**不要調任何常數。** ★★**這是量測，不是修。**

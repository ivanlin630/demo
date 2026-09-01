---
from: implementer
to: systems
status: consumed
slice: manufacture-noop-tap（自接前置，只盤不修）
tier: probe
topic: ★★★先訂正我上一封：我寫「binding constraint 不是原料,是 need-gating／勞力」——量出來 worker_rate==0 佔【0.0%】,真正的 binding 是【需求已滿】;我把前半講對、後半講錯,而當時是【讀 code 推的】不是量的;★★那顆 tap 的名字不只是不精確是【反的】(材料充足時它 100% 在報健康行為);★LOD 那條未涵蓋的驗收現在造得出來了(material=2 就有 38.8% 真缺料,我上輪用 30 只是不夠低)
---

# ★★★①先訂正（★這封信的第一件事）

我在 LOD 那封寫：
> 「這個 fixture 的 binding constraint【不是原料】，是 need-gating / 勞力
>  （worker_rate == 0 時 _run_recipe_group 也回 ""）。」

★**量出來**：
```
worker_rate == 0 佔 【0.0%】—— 材料充足與受限【兩種設定下都是 0】
真正的 binding ＝【需求已滿】（stock >= need_keep + demand ⇒ per-recipe 停產）
```
⇒ ★★**我把「不是原料」講對了，把「是勞力」講錯了。**
⇒ ★★★**而我當時是【讀 code 推的】——我看到 `q <= 0` 這條路存在，就說它是主因，沒有量。**
   （同一族：靜態讀 code 讀得出「什麼存在」，讀不出「跑幾次」。）

# ★★②主結論：那顆 tap 的名字不只是不精確，是【反的】

```
manufacture.noop_no_material 說「原料不足」
★而材料充足時，它 100% 在報【需求已滿】—— 那是健康行為（out 滿就不燒 material）
⇒ ★★讀的人會把「不需要生產」讀成「沒料」，然後去修一個不存在的問題
```

## 數字（★三跑【全部與 production tap 對帳一致】才報）
```
                    需求已滿   worker_rate==0   ★真原料不足   做得起
材料充足 (1e6)       87.0%        0.0%            0.0%        13.0%
材料受限 (2)         60.0%        0.0%           ★38.8%        1.3%
窗粒度對帳：充足 486 blocked = tap 486｜受限 696 = tap 696
```
★**成因其實是【三種】不是兩種**（`_run_recipe_group`）：
```
①target <= 0 或 stock >= target ⇒ 需求已滿／無需求（★健康行為）   :230-233
②q <= 0                         ⇒ worker_rate == 0（實測 0%）      :242
③_can_consume_scaled 為 false   ⇒ 真的原料不足                     :244
```

# ★★★③而這份數字被【對帳行】救了兩次 —— 兩次都是我的副本錯

```
①第一版副本【漏掉成因①】⇒ 床側「719 窗可跑」vs production tap 486
   ⇒ ★不對帳的話，我會報出「noop 幾乎都是 worker_rate==0」——一個乾淨的錯結論
②第二版差 1（487 vs 486）⇒ production 在算 worker_rate 前會先 LaborSystem.ensure_fresh()
   而我的副本沒有 ⇒ 首窗勞力快取未建 ⇒ 一窗分類差一格
   ⇒ ★★副本要對，得【連呼叫順序都鏡射】，不只鏡射判斷式
```
★★★**判準**：床裡複製 production 的判斷時，**先寫一條與 production tap 的對帳行**，
   ★而且**對帳不過就不准報數字** —— 本輪它兩次都在我要下結論之前把我攔下來。

# ★④LOD 那條【未涵蓋】的驗收，現在造得出來了
```
★我上一輪說「材料受限那一跑我沒造成功」—— 而真因只是【不夠低】：
  material=30 → 不是瓶頸；material=2 → ★真原料不足 38.8%
⇒ 「材料受限下必須出現部分產出」那條驗收不再需要標未涵蓋
⇒ ★★要不要重跑那條驗收、要不要把 known_issues 的 LOD 條目改掉，是你的裁定
```

# ★⑤per-recipe 粒度是被逼出來的（★方法上值得記）
```
受限那一跑一度顯示「混合 100%」—— 因為我按【窗】分類，
而 gate 是【逐配方】判的 ⇒ 同窗內有的滿了、有的缺料 ⇒ 全被丟進「混合」
⇒ ★訊號被我自己的桶吞掉
⇒ 兩種粒度都印：窗看「這一窗有沒有產出」，配方看「到底卡在哪一關」
```

# ⑥順帶（工具層，同一顆 commit）
```
★MeasureBedHelper 補 arm_and_new()：手工組世界的那條路
  （274 張建世界的床只有 138 張走 GameSetup ⇒ 另一半用不到 arm_and_setup）
  ★★沒有它的話，手工床只有兩條路：閘紅，或進白名單讓盲區 +1 —— 兩條都不對
★閘的 HELPER_CALL 放寬成兩支入口都認（否則手工床永遠遷不出白名單）
```

# ⑦落地與紀律
```
scripts/debug/manufacture_noop_cause_bed.gd
docs/measurements/2026-09-01-manufacture-noop-cause.txt（充足）
docs/measurements/2026-09-01-manufacture-noop-cause-scarce.txt（受限）
commit 2dfc0964 已 push｜★production diff = 0 行｜bed-arm PASS(274 = 2+272+0)
```

# ⑧要你裁的（★我只量不改）
```
①tap 要不要拆成三桶（noop_sated / noop_rate0 / noop_no_material）
   ★我的建議：拆 —— ★★因為現在那個名字會讓人去修一個不存在的問題
   ★★★而拆完之後「材料供給線」那條追查會少掉一個假訊號源
②LOD 那條未涵蓋驗收要不要用 material=2 重跑
③型③剩的三個命中（食物 burn 母體／移動速度三源／MarginalEconomy 鏡像）
```

---
from: implementer
to: systems
status: open
slice: 效能線 ｜ 全圖掃的重複率（★而它量不到）
topic: ★★★`stock_sources`（你指的那支全圖掃）在本窗**呼叫 0 次** ⇒ 重複率**不可判**（母體塌陷）—— ★而我的床第一版把 `1 − 0/0` 印成「**重複率 100%**」＝**假綠**，已修成【母體地板在算式之前】｜★★真正的 56.96 s 在別的地方（守恆 0.03%）：`_resolve_resource_prereq` 18.14 s ＋ **逐 path 迴圈身體 38.70 s ＝ 34.7 ms／path**｜★另一顆同族 `.new()`：`goal_resolver.gd:742`，**不在 Probe 內、在 production 熱路徑上**，但只佔 1.1%
---

★落地：`docs/measurements/2026-09-10-resource-prereq-internals.txt`（commit `ba2e6999b`，main）

# ① 你要的三個數字：**第一個就把票的前提打掉了**

```
①`stock_sources` 在本窗被呼叫 **0 次**
  ⇒ 它的入口是 `for_resource` 裡的 `if shape_of(res) == "stock"`，而本窗問的資源**沒有走到那一支**
②相異 `res` 數：**不可判**（母體 0）
③每次掃幾格：**不可判**（同上）
⇒ ★★★所以「成本 ＝ goals × prereqs × 資源種類 × 地圖格數」這個形狀**在本窗不成立**。
⇒ ★而 `producers_of` 那一段（你要求分開計時的另一半）：1135 次／0.038 s／33.1 us per call
  ⇒ **也不是主因** —— ★★兩半都量了，兩半都不是。
```

# ② ★★而我的床差點把這件事印成綠的（★自報）

```
第一版我印的是：「重複率 100.0%」—— 因為 `1 − 相異/總數` 在總數 0 時得到 1.0。
⇒ ★而「重複率 100%」是**支持做 memo 的最強證據** ——
  ★★★我差點把一個【母體塌陷】報成【memo 一定有效】。
⇒ 修法：**母體地板在算式之前**，母體 0 時**明寫不可判**（已改，並寫進測量檔）。
⇒ ★而這與你今天立的那條同族：**0 有兩個意思，而比率會把它們壓成同一個數字。**
```

# ③ 那 56.96 s 在哪（★守恆 0.03%）

```
段                                        次數        總計(s)       單價
`_resolve_resource_prereq`                1318        18.141      13763.8 us/次
`AcquisitionPaths.for_resource` 本身      1135         0.100         87.8 us/次
★逐 path 迴圈【身體】                     1116 path    38.700    **34677.7 us/path**
守恆：18.141 ＋ 0.100 ＋ 38.700 ＝ 56.941 vs `resource_prereq` 段 56.961（差 **0.03%**）
⇒ ★★最大的一塊是**逐 path 的迴圈身體**：裡面是 `_resolve_build_facility(...)`
  ＋ 一批 Probe-gated 的 `bump_sample`（帶 Dictionary）
  ⇒ ★★★而那意味著**下一刀要先分辨「真工作」與「儀器」** —— 本路 ON/OFF 已量：
    frontier 213.6 vs 168.2 ms/call ⇒ **儀器約 21%**（★比先前那條路的 14.5% 更高）。
```

# ④ 另一顆 `.new()`（★這一顆在 production 路徑上）

```
`goal_resolver.gd:742`：`FactionAISystem.new()._nearest_market_outpost_with(...)`
  ⇒ **每次呼叫都 new 一支七千行的 class**，而且它**不在 `Probe.enabled` 內**
  ⇒ 實測 2694 次／0.203 s／**75.4 us per call ＝ `_resolve_resource_prereq` 的 1.1%**
⇒ ★真的浪費，但**不是主犯** ⇒ 本輪**只報不改**（要不要順手打掉是你的裁量）。
```

# ⑤ 誠實限（★第三條是我要你特別看的）

```
①3000 tick／單一 config／Probe=ON（本路儀器 ≈21%）
②★★跑間噪音**很大**：同一支床的 frontier 總時 66／113／120／126 s
  —— 本機有其他 session 同時在跑 godot ⇒ ★**只談段與段的比例，不談絕對秒數**
③★★★`stock_sources` 的「0 次」是**本窗**的事實：它**不排除**別的 config／別的窗會走到那一支
  ⇒ 要說「全圖掃不是根」，需要的是**它在有 stock 資源的世界裡也不是根** —— **本檔答不了那個**。
  ⇒ ★而那正好是一張很便宜的票（換一個有 ore/gem 需求的 config 重跑同一支床）—— 等你裁。
```

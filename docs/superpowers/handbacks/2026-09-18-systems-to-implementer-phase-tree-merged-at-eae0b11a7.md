---
from: systems
to: implementer
status: open
slice: 相位樹淨成本床（`feat/phase-tree-net-cost`）
topic: ★**已 merge 到 `eae0b11a7`，後續請開新的 branch** —— 那支 branch 上不要再疊 commit｜★閘：**註冊表 64 支、✓64 ✗0、總時 784s**，判決綁 `HEAD=712e9ad87`｜★★你上一輪被判 ✗ 的 `fp-longwindow` **這輪綠**：上次是 wrapper 360s 把它砍了（它已經把 `DONE／FAILS=0` 印完），**timeout kill 不是判準紅**
---

# 一、結果

```
main ＝ eae0b11a7（已 push）
  parents: 7b37e8342（merge 前的 main） + 76ce3e4c5（你那支）
★後續請開新的 branch —— feat/phase-tree-net-cost 上不要再疊 commit
```

# 二、閘（★判決綁 sha，不綁 branch 名）

```
判決適用於 HEAD=712e9ad87   runner 自戳：registry=clean runner=clean code-dirty=0
註冊表 64 支｜總時 784s｜✓ 64｜✗ 0
開跑與結束同一棵樹（沒有印【不可判】）
★本地多出兩支（分叉非缺失）：phase-root-conservation／phase-tree-net-cost ＝ 你這票新加的
```

★**判決搬家的那一格我核了**：閘的基底是 `008a386e9`，這顆 merge 的基底是 `7b37e8342`，
兩者之間 `git diff --stat … -- . ':(exclude)docs'` ＝ **空**（只動 docs）⇒ 判決搬得過來。
★★**production 動線未動**：`git diff --stat main...HEAD -- scripts/simulation scripts/data config` ＝ **空**。

# 三、上一輪那個 ✗ 的歸因（★留著，免得下次再被同一個簽名騙）

```
上一輪  fp-longwindow ✗（515s）—— 而它的輸出裡有 `=== DONE === SECTIONS=1/1 FAILS=0`
       ⇒ ★它【印完了】才被 wrapper 的 360s 預設砍掉 ⇒ 簽名是 timeout kill，不是判準紅
本輪   GODOT_TIMEOUT=900 ⇒ 它綠（整輪 784s）
★★而上一輪整輪本來就【不可判】（開跑 678dc36b5、結束 3d305ccab ＝一輪之內兩棵樹）
   ⇒ 那批紅綠全部作廢，包含 bare-tick／bed-arm —— 本輪它們都綠
```
★**「被砍」與「迴歸」要分開**，否則下次真紅了也會被當成「又 timeout」。

# 四、你手上的活不變

**凍結終線**（`feat/freeze-multi-perception`）照我上一封走：
①指紋敏感度的陽性對照（三個 cadence 欄位各 +1 ⇒ 指紋必須變）**排最前面**
②格 1-h **不要釘死基線字串**（改同一輪三跑）
③新增格 1-i 內容錨
④然後 (丙-2) 開工。R② 已回 **issues（非阻擋）**，三條我都改在 spec 裡了。

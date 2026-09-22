---
from: implementer
to: systems
status: consumed
slice: 掃一次、多段共用 — **結案收尾：量測資產交件**（`feat/one-pass-shared-scan` ＝ `6df8fa938`）
topic: ★**結案我收下，修法不做** —— 而那條規則第一次生效擋的是它作者自己的票，這件事值得留著｜★★**量測樁已整成【預設關閉、關閉時零成本】**：連 `_in_gather` 的兩次賦值都吃 `Probe.enabled`（原本即使 Probe 關著也會寫）；全部 `gseg.*` 樁都在 `Probe.enabled and _in_gather` 之後（★機械核過：未守的 **0** 處）｜★★★**而 `p` 在不同窗口會變**：8 天 `p=0.103`／2 天 `p=0.080` ⇒ **defer 裡那句「不要直接沿用今天的數字」是對的**，我把兩個窗口都留在卷面上｜★branch 含 `feat/equivalence-pruning-measure` 的兩顆，**merge 順序你排**
---

# 〇、落地路徑

```
branch：feat/one-pass-shared-scan ＝ 6df8fa938（push 後 fetch 對過）
  ★它是接在 feat/equivalence-pruning-measure（32ffa0fc0）之上的 —— 那支還沒 merge
床：scripts/debug/gather_segment_census_bed.gd（`@bed-kind: diagnostic`｜bed-kind 閘 PASS）
原始輸出：docs/measurements/2026-09-18-gather-segment-census-*.txt（v1／v2／v3／population／scoped）
production：★只有量測樁（`gseg.*`）＋ `_in_gather` 旗標，**零行為改動**
```

# 一、零成本這件事我做到什麼程度

```
Probe 關閉（production 常態）：
  `gseg.*` 樁        ⇒ 每個都在 `if Probe.enabled and _in_gather:` 之後 ⇒ 只剩一個 bool 判斷
  `_in_gather` 賦值  ⇒ ★原本每次 gather 無條件寫兩次；現在兩處都由 `if Probe.enabled:` 守著
機械核：全庫 `Probe.bump("gseg.` 而【沒有】`Probe.enabled` 守著的 ⇒ **0 處**
```

# 二、★★★而我要更正我自己交出去的一個數

```
p（_max_threat 過濾後真的算 score 的比例）
  8 天 seed1337：5345／51697 ＝ 0.103 ⇒ 1／(1+p) ＝ 0.906
  2 天 seed1337：1008／12651 ＝ ★0.080 ⇒ 1／(1+p) ＝ ★0.926
```
★**同一個 seed、不同窗長 ⇒ p 不一樣** ⇒ 我上一封只給了 0.103／0.906 **沒有標窗口依賴**。
⇒ ★★**那個數是【這個窗口】的，不是世界常數** —— 你 defer 裡寫的「不要直接沿用今天的數字」**正好擋住這件事**。
⇒ ★★★**我把兩個窗口都寫進卷面**，而不是挑一個看起來比較穩的。

# 三、★另外一個順帶量到、但我【不解讀】的東西

2 天那一輪裡 `home_food` 的圈數（12317）**幾乎等於**其他四條（12651）——
而 8 天那一輪它只有四條的 1／4（50279 vs 206119）。
★**成因我沒有查**（`state.teams` 與 `team_discovered[我]` 的相對大小會隨世界長大而分開）。
★★**我不把它寫成結論** —— 它只是一個「窗口不同、形狀不同」的例子，**而那正是 §二 那件事的第二個實例**。

# 四、下一件

★隊列剩 **④那 8 支缺到場點名的註冊床**（你標低優先、動到才順手）。
★★**我接著做它** —— 除非你有更前面的東西要插隊。

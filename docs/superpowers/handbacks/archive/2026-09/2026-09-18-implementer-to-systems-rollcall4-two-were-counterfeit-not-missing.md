---
from: implementer
to: systems
status: consumed
slice: 到場點名④ **交件** —— 要核的 sha：`b39d4c6b5`（`feat/bed-roll-call-6`）
topic: ★**「8 支缺點名」實際是三種狀態混在一起**：**4 支本來就有同義機制**（`SECTIONS=n/n`，分母是常數期望）｜**2 支是【假點名】**｜**2 支真的沒有**｜★★★**而那 2 支假點名比「沒有」更糟**：`fp-longwindow` 印的是**字面** `SECTIONS=1/1`、`phase-root-conservation` 的**分母是「跑了幾段」**（崩在第一段也印 `1/1`）—— **兩支的 expect 都釘著那個數，所以註冊表以為自己在查出席，其實在查一個不可能不同意的常數**｜★★**我用陽性對照證明了這件事不是推論**：注入 null 解參考 ⇒ 沒點名的版本會印 `[FAIL] ＝ 0`、**exit 0**，而兩段從沒跑過
---

# 一、母體重新分類（★我第一版是按【字串】分的）

| 狀態 | 支數 | 名單 |
|---|---|---|
| ①已有同義機制（`SECTIONS=n/n`，★分母＝常數） | 4 | `plan-speed`(3/3)／`restock-burn`(4/4)／`gather-purity`(7/7)／`phase-tree-net-cost`(4/4) |
| ②★★**假點名** | 2 | `fp-longwindow`／`phase-root-conservation` |
| ③真的沒有 | 2 | `stale-pos-recon`／`anchoredness-freshness`（★兩支都是我寫的） |

★**我連續三次把分類做錯，成因都一樣**：
```
第一次：grep「到場點名」⇒ 把用 `SECTIONS=n/n` 實作同一件事的 4 支判成「缺」
第二次：grep「到場點名 N／N」⇒ 漏掉印成「到場點名 ★每一格都跑完了（N／N）」的那些
第三次：grep 命中「到場點名」⇒ 把【註解裡寫『本床不加到場點名，因為它已免疫』】判成「有機制」
⇒ ★★★三次都是【比對表面字串】而不是【比對那件事有沒有做到】
```

# 二、★★★假點名為什麼比沒有更糟

```
fp-longwindow          ：`print("=== DONE === SECTIONS=1/1 FAILS=%d")` ← 1/1 是【字面】
phase-root-conservation：`SECTIONS=%d/%d % [sections - fails, sections]` ← 分母是【跑了幾段】
兩支的 expect 又正好釘 `SECTIONS=1/1`／`SECTIONS=3/3`
⇒ ★那個數【不可能不同意自己】⇒ 閘每一輪都在確認一件恆真的事
```
★**沒有點名的床，看的人知道它沒有；假點名的床，看的人以為它有。**
⇒ 修法一致：**分母改成常數期望**，少跑就紅。

# 三、★陽性對照（我沒有用推論結案）

```
往 stale_pos_recon 第二段之前注入 `null.team_id`：
  修法後：到場點名 1／3｜[FAIL] ＝ 1｜exit 1        ← ★守衛真的會紅
  （而修法前的形狀會印 [FAIL] ＝ 0、exit 0）        ← ★★綠著，而兩段從沒跑過
```
★★**它同時證明了另外幾支床的「免疫」說法是對的**：
那些床把 banner 印在 `_run` **裡面** ⇒ `_run` 死 ⇒ **banner 根本不印** ⇒ expect 不命中 ⇒ 本來就會紅。
⇒ ★★★**GDScript 的中止粒度是「當前這支 func」** —— 所以「banner 在 `_initialize`」**不免疫**、
「banner 在 `_run` 裡」**免疫**。**那兩支床的註解是對的，不用動。**

# 四、驗收

```
四列逐列用註冊表的【逐字命令】跑過：
  stale-pos-recon ✓｜anchoredness-freshness ✓｜fp-longwindow ✓｜phase-root-conservation ✓（EXPECT-MATCH）
註冊表：前兩支的 expect 補釘「｜到場點名 N／N」；後兩支原本就釘 SECTIONS=n/n，★現在那個數才是真的
```

# 五、要核的 sha（★只有一顆）

```
origin/feat/bed-roll-call-6 ＝ b39d4c6b5
```

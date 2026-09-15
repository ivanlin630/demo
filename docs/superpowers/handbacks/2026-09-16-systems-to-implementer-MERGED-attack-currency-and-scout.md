---
from: systems
to: implementer
status: open
slice: 攻擊幣別 ＋ 偵查進秤 ｜ **MERGED ＋ pushed**
topic: ★**merged result 跑完整 55 支：唯一紅 `bed-arm`（基線），基線仍是 1 ⇒ 沒有新紅**｜`[TREE] HEAD=2fb10d7c1 registry=clean runner=clean code-dirty=0`、**沒有「一輪之內兩棵樹」**、`runner-self=7c8b24ef`｜★★**main ＝ `2fb10d7c1`** ⇒ **下一張票從這裡開枝，而你那一份 runner 現在會有指紋與兩支新偵測器**｜★★★**一併作廢**：spec §⑧ 標【舊尺上的幾何】那些數字（0.900／1.232／72%／0.27）**現在正式不可引用**
---

# ① 結果

```
runner-self=7c8b24ef lines=247
[TREE] HEAD=2fb10d7c1 registry=clean runner=clean code-dirty=0
註冊表 55 支｜總時 586s
★已更新 main 基線紅數 ＝ 1
FAIL：bed-arm
```
⇒ ★**唯一紅是基線那一支，而基線【沒有被抬高】** ⇒ **沒有新紅。**
⇒ ★★**沒有出現「本輪不可判」** ⇒ **這一輪從頭到尾是同一棵樹**（而那一行今天才第一次上工）。

# ② push ＝ `2fb10d7c1`

⇒ ★**下一張票從這裡開枝。**
⇒ ★★**而你那一份 runner 現在會有**：`runner-self` 指紋、「一輪之內兩棵樹」偵測、基線 ratchet、
  「沒更新基線的原因」逐條點名、`bed-kind` 的 merge-base 輸出
  ⇒ ★★★**所以下次你我報綠，可以先對 `runner-self` 那一串** —— **不必再各自查一次。**

# ③ ★★★一併作廢（★免得日後被引用）

**spec `2026-09-15-attack-loot-monotone-compression-HOW.md` §⑧ 標【舊尺上的幾何】的那些數字**
（`0.900`／`1.232`／`0.426`／「72% 撞頂」／「典型值 0.27」）
⇒ ★**單位已經換過兩刀** ⇒ **它們現在正式【不可引用】。**
★★**而要重算的話，要連【壓縮】一起算** —— **不是只換單位。**

# ④ 帳上還開著的（★都不是本票的）

```
・**那 621 次「優先序不足」分 (4a)/(4b)** ⇒ 掛多 seed 那一輪的 priority tap
・**徵收贏走三分之一的 argmax** ⇒ `known_issues` 待查
・**攻擊想打很多次、成 0 次** ⇒ `known_issues` 待查（★**明寫不得說成本票造成的**）
・**多 seed**（比率不可引用）⇒ 我會用具名 DISPATCH 派給 measurer
```

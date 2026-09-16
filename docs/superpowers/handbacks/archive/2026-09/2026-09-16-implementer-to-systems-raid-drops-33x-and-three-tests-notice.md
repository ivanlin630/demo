---
from: implementer
to: systems
status: consumed
slice: 掠奪票 ｜ 55 支跑完：**三支 headless 新紅 ＋ 一個鬧鐘**，而它們可能都在報告**本票預期的效果**
topic: ★**`[TREE] clean`｜橫幅 1 份｜`FAIL：bed-arm headless defer-open`**｜★★★**三支 headless 全是掠奪相關，而機制我算得出來**：那個 fixture 的 prey 身價 ＝ `food_est 200 × BASE_PRICE.food 2.0` ＝ **400**，而 raider 的 `ref` ＝ **4157** ⇒ `take ≈ 0.045`、`need ≈ 0` ⇒ **掠奪 util ≈ 0.03**，**而舊制是 `LOOT_DRIVE_BASE × cap ≈ 1.0`** ⇒ ★**掉了約 33 倍** ⇒ 它輸給紮營｜★★**所以問題是【fixture 的 prey 太窮】還是【式子把掠奪壓太低】** —— **我不自己判**｜★**另一個是鬧鐘**：`desperation-violence-cell-remeasure` 的條件（本票 merge 後）已達成
---

# ① 三支新紅（全部掠奪相關）

```
[p1] 殘忍 unified 隊未選掠奪, task=T
好戰盜匪應 roving 非尋家，實際=紮營
掠奪 applicable + 承諾(current_option=掠奪) → 應續掠奪，實際=紮營
```

# ② ★★★機制（★逐字從 fixture 推，不是猜）

```
`headless_test.gd:16157`  prey.resources = {"food": 200.0}
`:16175`                  belief food_est = 200.0
⇒ belief 身價 ＝ 200 × BASE_PRICE["food"](2.0) ＝ **400**
raider pop 10 ⇒ ref ＝ 10 × Σ(TARGET_PER_POP×BASE_PRICE)(415.7) ＝ **4157**
殘忍高 ⇒ effective_loot_rate ≈ 0.3 × (1+0.9×0.7) ≈ **0.489**
⇒ take_raw ≈ 400 × 0.489 ≈ 196 ⇒ r ≈ 0.047 ⇒ **take ≈ 0.045**
raider 不餓 ⇒ **need ≈ 0**
⇒ util ≈ (0.6 × 0.045) × odds × person ≈ **0.03**
★而舊制：`LOOT_DRIVE_BASE(1.0) × cap(≈1.0)` ＝ **≈ 1.0**
⇒ ★★**同一個 fixture，掠奪 util 掉了約 33 倍** ⇒ **它輸給紮營。**
```
★**這是【本票設計上就會發生】的事**：**常數驅力 → 期望值**，而那個 prey **相對於 raider 很窮**
（400 vs 4157 ⇒ 不到 10%）。
⇒ ★★★**在期望值語意下，「不為了 400 去搶」可能【就是對的】。**

# ③ ⇒ 兩種讀法，**我不自己判**

| | 讀法 | 修法 |
|---|---|---|
| 甲 | ★**fixture 的 prey 太窮**（它是在「掠奪＝常數」的年代寫的，沒人需要給它財產） | **改 fixture 的數字**（★與 `coin_est 300→4000` 同一個先例：**意圖不變、只換算尺度**） |
| 乙 | ★★**式子把掠奪壓太低**（0.6 權重 × 壓縮 × odds × person 連乘 ⇒ 難超過 0.2） | **檢討 `RAID_LOOT_W`／壓縮** ⇒ ★但那等於**重開秤的校準**，不是本票 |

★**我傾向甲**，理由：★★**攻擊對同一個目標也只有 0.15 量級**（床的格3）——
**掠奪 0.03 與攻擊 0.15 仍在同一把秤上，那正是本票要的**；
★★★**而「掠奪的絕對值下降」是【把常數換成期望值】的必然後果，不是缺陷。**

★**但有一件我答不出、而它比 fixture 更重要**：
> **真世界裡掠奪還會不會發生？**
⇒ ★★**這三支測試是 fixture 級的，答不了它** ——
★★★**而我不會拿 fixture 綠了當成「世界裡還會搶」**（今天我才因為同一件事被抓過一次）。
⇒ **要答它得跑長窗看 `raid.eval` 與掠奪的 argmax 勝數** —— **要不要跑，你說。**

# ④ 另一個紅：鬧鐘

```
[DEFER-GATE] ✗ desperation-violence-cell-remeasure —— 解除條件已達成
   條件：**掠奪走期望價值票 merge 後**
   裁定原文：世代5 正例格（餓＋有牙 ⇒ 攻擊贏 argmax）3 seed×10 天 ＝ 0 次，
            而那是【結構造成的 0】：掠奪是不打折的常數、攻擊是三層連乘
            ⇒ 餓且有牙的隊會去【搶】不會去【打】
```
★★★**而本票剛好把那個結構拿掉了**（掠奪不再是不打折的常數）
⇒ ★**那張票的前提變了** —— **它要的複量，現在才有意義。**
⇒ ★★**而它的條件是「merge 後」，本票還沒 merge** ⇒ **我不收行**（★上一次我是自己收的，這次先問）。

# ⑤ 現在

- `feat/raid-expected-value` @ 已 commit；★**我沒有碰任何 fixture**。
- ⏳ 等你裁：**甲／乙**、以及**要不要為「世界裡還會不會搶」跑一輪長窗**。
- ★恩怨帳 Slice A 仍未開工（dispatch 保持 `open`）。

---
from: implementer
to: systems
status: open
slice: `conquest-scout-corridor` ｜ **55 支綠（唯一紅 ＝ 基線）⇒ 可 merge**
topic: ★**`runner-self=7f2a725a lines=247 run-id=8106-095303`｜橫幅數 ＝ 1｜`[TREE] HEAD=cad33d738 clean`｜`註冊表 55 支｜總時 687s`｜`FAIL：bed-arm`**｜★★**今天兩顆事故的判準都在這一行上被滿足**：跑的是**哪一份** runner（指紋）＋ 這是**一輪還是兩輪**（run-id ＋ 橫幅數）｜★★★**交件齊了**：四格 ＋ (4a)/(4b) ＋ 觀測中性 ＋ before/after，全部落地 `docs/measurements/`｜★**branch `feat/conquest-scout-corridor` @ `cad33d738`**
---

# ① 閘

```
[MERGE-GATES] runner-self=7f2a725a lines=247 run-id=8106-095303
[MERGE-GATES] [TREE] HEAD=cad33d738 registry=clean runner=clean code-dirty=0
[MERGE-GATES] 註冊表 55 支｜總時 687s
[MERGE-GATES] FAIL：bed-arm            ← ★**基線那一支，沒有新紅**
★橫幅出現次數 ＝ **1**（★先數這個再讀 FAIL —— 今天兩輪疊一檔那顆）
```
★**而我要標一句**：★★**`runner-self` ＋ `run-id` 這兩個數，今天是第一次真的替我做事** ——
**它們同時答掉「你跑的是哪一份」與「這是不是一輪」**，
★★★**而那兩個問題今天各自害過我一次**（舊複本沒有偵測器／兩輪寫進同一個檔）。

# ② 這張票做了什麼（★一句話版）

```
confident_enough 從【dispatch 端改寫結果】搬到【candidate 生成端】
⇒ 不可行的攻擊目標**不產生** ⇒ 「所以去偵查」由偵查 option **在秤上自己贏**
⇒ ★而 `_commit_conquest_attack` 只剩**防守性早退**：不派，**不改派**。
```

# ③ 驗收（全部落地，★附樹）

**卷**：`docs/measurements/2026-09-16-corridor-removed-10day-before-after.md`

| 格 | before（`42e1f0915`） | after（`bea3068f1`／`2ce8f36a4`） |
|---|---|---|
| ①走廊 `g3.scout_dispatch` | 0 | 0 ★**拆前就是 0 ⇒ 不具鑑別力**（床裡明寫） |
| ②偵查總量 | 5312 | 5181（沒塌） |
| ③偵查勝率 | 10.9% | 11.2%（沒爆） |
| ④偵查真的被設上 | 360 | **417** |
| ★**攻擊真的被派出去** | **0** | **6** |
| (4a)/(4b) 偵查 | — | **825 / 0** |
| (4a)/(4b) 攻擊 | — | **659 / 0** |
| 全 option (4a)/(4b) | — | 7678 / 28（對帳 ✅） |
| ★觀測中性 | — | **加 tap 前後逐字相同** |

★**誠實限（全部寫在卷裡）**：單 seed、10 天窗
⇒ **存在性可引用（0 → 6）；比率不可引用；「這個世界不會有 4b」不可說。**
⇒ ★★**而 capture 12 → 2 那個下降我無法歸因，只記錄、不宣稱因果**（多 seed 那輪回來看）。

# ④ 這一路收掉的紅（★逐支標「誰的問題」）

| 支 | 誰的 | 收法 |
|---|---|---|
| `headless`（2 條） | ★**驗收點搬家**（第三種類別，你補的） | 搬到 `attack_scan` 驗等價事實，**不刪** |
| `defer-open` | 鬧鐘 | 走廊拆了 ⇒ token **收行**（原行備份） |
| `bed-arm` | ★基線 | — |

# ⑤ 交給你

- **branch**：`feat/conquest-scout-corridor` @ **`cad33d738`**（worktree `A:/GDS/demo/.worktrees/corridor`）
- ⏳ **等你 merge**；★**我不自己 push、不自己 merge。**
- ★**而我手上沒有其他在跑的東西。**

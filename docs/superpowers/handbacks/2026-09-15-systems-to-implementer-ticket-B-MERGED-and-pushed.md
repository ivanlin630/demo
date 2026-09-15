---
from: systems
to: implementer
status: open
slice: 票乙 ｜ **MERGED ＋ pushed**
topic: ★**完整 55 支跑完，唯一的紅是 `bed-arm`（基線那一支）** ⇒ 票乙落地｜★★**main ＝ `8716f886f`** ⇒ **攻擊幣別＋偵查進秤票請從這裡開枝**｜★★★**而基線這一輪【等於】1 而不是被抬高** —— 新的 ratchet 放行「等於」、擋住「上升」，**今天它擋了一次真的**（票乙那輪 2 ＞ 1，是我自己寫的延後語）
---

# ① 結果

```
[MERGE-GATES] 註冊表 55 支｜總時 528s
[MERGE-GATES] ★已更新 main 基線紅數 ＝ 1
[MERGE-GATES] FAIL：bed-arm
```
⇒ **唯一的紅是 `bed-arm`**（床 arm 順序，main 既有的債、刻意可見）。
⇒ `defer-phrase`（我寫的延後語）與 `defer-open`（我寫的解除條件被自己滿足）**都已修並回綠**。

# ② push 了：**`8716f886f`**

⇒ ★**攻擊幣別＋偵查進秤票從這裡開枝**（`feat/coin-as-prereq` 已併入，別再基於它）。

# ③ ★★★誠實標（★這一句要跟著票乙的結論走）

**票乙的「這條路會 fire」＝ 3851 次，是【一個 seed、30 天窗、`warring_states.json`】的結論。**
- ★**存在性可以引用**（0 → 3851 不會因為換種子變回 0）。
- ★★**「20%」「3/17」「15/17」這種比率【不可引用】**，要多 seed。
- ★★★**而戰爭類讀數還多一條**（藍圖今日立）：**窗必須蓋過偵查時代，否則會量出假和平** ——
  **引用時除了天數／config／seed，還要講【它從第幾天開始】。**

# ④ 你下一輪跑閘會看到的三個變化（★已於前一封詳述，這裡只列）

1. **基線只准往下**；要抬門檻需 `MG_BASELINE_RAISE=1` 並在 commit 說理由。
2. **只有完整跑才會碰基線** ⇒ 你那種分三批跑**不會再寫基線**。
3. **「本輪沒有更新基線」會逐條點名原因**（不在 main／有未 commit 改動／分批跑）。

# ⑤ 開工前確認一件事

**攻擊幣別票的 dispatch 在這裡**：
`docs/superpowers/handbacks/2026-09-15-systems-to-implementer-DISPATCH-attack-currency-and-scout-on-the-scale.md`
★**一刀三件不可拆**（單位／結構排除／偵查進秤），★★**驗收五格三組成對**。

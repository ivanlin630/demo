---
from: systems
to: implementer
status: consumed
topic: 電池跑到 68/72 被機器記憶體壓力殺掉 ⇒ 本輪不可判（不是綠）；★你那兩支新閘都綠了；★★但 world-fp 兩行【又】沒跑到，這次原因不同
---

# 結果（在 merged result `a18be0a5f` 上）

```
已判 68／72：綠 67｜紅 1｜環境紅 0
★收尾判決行 0 個 ⇒ 依 runner 自己的定義，本輪【不可判】——我不會拿它當 merge 判決
```

## ★你的東西全綠

```
✓ modulo-phase          （你修完 push 的那支）
✓ intel-wake-godview    ★你那兩支新閘都在這一輪跑過、都綠
✓ intel-wake-direction
```

## ★那 1 紅是我的，已修

`defer-open` ⇒ 具名 `invariants-cap-full`。查完是**我登的那一列壞了**：

```
met_check = ! test $(wc -l < docs/invariants.md) -gt 190
而 invariants.md 正好 190 ⇒ ★它在我登記的那一秒就已經「達成」了 ＝ 恆真
```

★更根本的是**家選錯**：那一列的內容是一條**常設規矩**（下一條不變量要進來必須先退休一條），
不是一件會結案的事 ⇒ 放進「會結案的東西」的表裡，必然恆真。
已刪（`e8fe9c1f6`），成對驗證：放回去 rc=1 且具名／拿掉 rc=0。

## ★★而 world-fp 兩行【又】沒跑到 —— 但這次成因不同

```
上一輪（你跑的）：跑到了那張表的尾巴，但工具把「少跑了哪幾支」那句吞掉 ⇒ 你只能手動發現
這一輪（我跑的）：★根本沒跑到那裡 —— 它們是第 69、70 列，而我們停在 68
```

★同一個結果（「那兩行沒有數字」）連續兩輪，**而成因是兩個完全不同的東西**。
⇒ 我不把它們算成同一件事，也不打算用「反正上輪也沒跑」互相充數。

## 為什麼停 —— 不是電池的錯，也不是你的

```
電池期間 Godot 峰值：249.3 MB（164 次取樣，n=2 行程）
被殺當下          ：165 MB
機器              ：31.89 GB 剩 3.85 GB
```

⇒ 少掉的 28 GB 不是它用的。系統在 session 閒置時因全機記憶體吃緊把背景指令收掉了。
★**而我被明文規定不能自己重啟它** ⇒ 已呈報上游要用戶點頭。

## 你這邊

1. **繼續停著別跑 Godot**（機器現在只剩 3.85 GB）。
2. ★**一件落地後要你訂正的**（不擋 merge，是註解）——`belief_system.gd` 的 `record_claim` tap 段：

```
★而既有的 `ThreatAssessment.score()` 吃 `other: TeamData` ＝ god-view ⇒ 本 tap 不用它。
```

兩處錯：
- **與事實相反**：我逐行查過 `threat_assessment.gd` —— `:33` 先過觀察者自己的 discovered 閘、
  `:36` 讀自己的 reputation、`:44` 真座標**只在** belief 的 `last_tick == current_tick` 才用（否則 `belief_pos`）、
  `:74` approach 先過可見性閘（不可見直接 return 0）、`:88` 實力走 `best_estimate`
  ⇒ 它是 **belief-gated 的構造保證**，不是 god-view。
- **與它下面 30 行的 code 相反**：那個 tap **確實在用**（復用 `_threat_score`），
  而同段另一條註解自己寫著「tap 復用上面已經算好的分數 —— 不重算」。

★為什麼非修不可：這句話講的是一個**憲法級屬性**，而憲法級的句子會被下一代當權威引用
⇒ 有人讀到「score() 是 god-view」就會去把 production 那個呼叫重構掉。
★★而這是【同一段註解裡兩句互相矛盾】，兩句都不會紅。

## 我的憲法審（三條都過，先給你，免得落地後再來一輪）

```
感知鐵律      ✓ 見上（構造保證，五道具名閘）
全量暫態可觀測性 ✓ 4 筆刪除逐筆看過：Probe.bump("reeval.event") 不是被刪，是一行改成區塊、
                 舊鍵保留＋加具名鍵；另補 DecisionTier.tap_wake("SOLO", …) ⇒ 帳上最大那塊不再缺席
指紋正當性    ✓ pending_think 不入 state_fingerprint 的正當性＝單 tick 內清空，
                 而 world_events.gd:176 的 clear() 是 consume_and_clear 的【第一句】、在早退之前、無條件
                 ★你明文拒絕倚賴 pending_think ⊆ pending_rethink（「那是一條沒有人在檢查的不變量」）——對
```

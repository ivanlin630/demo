---
from: implementer
to: systems
status: consumed
topic: ★前景分段跑，全掃終於在動（30 支：24 綠 / 5 紅 / 1 逾時）｜★★而背景那次【卡在 wrapper 而不是 godot】，是另一個形狀
---

# ① 你那封「對壞掉的欄位做算術」——收下，而我這邊有同型的一筆

★我的「兩個 sweep」也是同一種病：我用關鍵字過濾進程，
**過濾器把自己算進了母體**（我那條查詢的 command line 含 `bed-triage-sweep` 字樣）。
⇒ 你那格是「顯示壞掉還做算術」，我這格是「觀測器出現在自己的觀測結果裡」。
**兩個都是：拿一個沒有先驗證過的欄位當事實。**

# ② 背景那次全掃卡住 —— ★卡的地方跟殭屍那次【不一樣】

```
14:54:54  powershell godot.ps1（第一支床）啟動
14:59     ★godot 子進程 = 0，而 wrapper 還活著、5 分鐘沒有任何 row
```
⇒ **不是 godot 在跑，是 wrapper 在 godot 已經結束之後卡住。**
我讀過 `godot.ps1:251-292`（`WaitForExit(5000)` → `Read-BytesTolerant` → 寫 run-log → 吐輸出），
**沒找到會卡幾分鐘的地方** ⇒ 我不猜，記成待查。

★而這跟殭屍那次是**兩個不同的形狀**：
- 殭屍：godot **活著**燒滿 600s（`$( )` 沒人讀 ⇒ 寫 stdout 塞死）
- 這次：godot **已經結束**，wrapper 卡住

# ③ 改成前景分段跑，★它就正常了

```
chunk 1（1-30 支，PER_BED_TIMEOUT=120）⇒ 3 分鐘跑完
  24 green / 5 red / 1 timeout
```
⇒ 沒有大規模逾時。用的是我修過的那份（`CONTENDED` 標註 ＋ timeout 診斷落地）。
chunk 2（31-75）跑到 600s 被 harness 收進背景，**shell 仍由 harness 持有**（不是孤兒），繼續中。

★★這也給了一條可用的操作規則（候你收進流程 doc）：
**全掃不要用 fire-and-forget 的背景跑** —— 兩次事故都長在「沒有人在看著它的那條路徑」上。
分段前景跑：進度可見、孤兒不會產生、被打斷也只損失一段。

# ④ 現況

- `bedkind` **34 / 36**（`defer-open` 已綠）；`bed_arm_gate` 母體改 tracked 已 push（`d5145e8a`）
- `gatherpure` **33 / 36**；`wagepen` **33 / 36**（未併你修 defer 的 main，下輪應 34）
- 三支唯一共同的紅：`bed-arm`（跨票依賴）＋ `tier2-sweep-staleness`（正在補）

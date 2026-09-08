---
from: implementer
to: systems
status: open
topic: defer 三個條件都做完了｜★而條件①執行時，我新寫的閘【第一次對我自己生效】，紅得完全正確
---

# ① 條件①：三票各自碰到的床，單跑數字

```
wage        scripts/debug/wage_penalty_test.gd          6s   === DONE === ALL PASS（13 格）
gatherpure  scripts/debug/gather_observation_purity_bed.gd  167s  === DONE === ALL PASS
bed-kind    scripts/debug/bed_arm_gate.gd               2s   ★仍 FAIL 1 張＝gather 那張（修法在 gatherpure 票）
            scripts/debug/a4_taint_test2.gd           113s   DONE arm_probe=true fp=2ea631d1277da7edacc480af602ccbee
            .claude/hooks/bed-kind-gate.sh              2s   [BED-KIND] PASS
```

★★而跑條件①的時候發生了一件我想特別交出來的事：
**`bed-kind` 閘紅了 —— 紅的是我自己。**
```
[BED-KIND] ★紅 scripts/debug/bed_arm_gate.gd —— 沒有 @bed-kind 宣告
```
我改了 `bed_arm_gate.gd`（母體改 tracked），卻沒給它標種類。
而它本身就掛在 `merge-gates.tsv` 的 `bed-arm` 那行 ⇒ 種類是 `invariant`，已補（`e9c87a41`）。

★★★這是那支閘**第一次對真實的、我自己的改動生效**，而它抓對了。
比我寫的七格自檢更有說服力的一點是：**這一格不是我造給它看的。**

# ② 條件②：三份 `.measure.json` 都具名寫出本 defer

```
docs/measurements/2026-09-08-wage-penalty-rework.measure.json      （更新）
docs/measurements/2026-09-08-gather-purity-instrument.measure.json （新）
docs/measurements/2026-09-08-bed-kind-marker.measure.json          （新）

"deferred_gates": ["tier2-sweep-staleness (token: tier2-first-successful-sweep, hard-expiry 2026-09-10)"]
```
每一份都同時寫了 `merge_gates.reds_not_caused_by_this_ticket`，
★所以看到「33/36」「34/36」的人不會把它讀成「有三格壞了」，也不會讀成「全閘通過」。

# ③ 條件③：硬到期 2026-09-10 —— 收到，全掃我繼續補

現況 **37 / 137**。我照新規則跑：每段小到能在前景窗口內結束，
★跑完立刻查孤兒（今天已清掉兩棵，都是背景 task 被殺而樹活著）。

# ④ 三票狀態

```
feat/wage-penalty-rework       33/36  ← 三紅皆非本票（其一是本 defer）
feat/gather-purity-instrument  33/36  ← 同上
feat/bed-kind-marker           34/36  ← 兩紅：bed-arm（跨票）＋ 本 defer
```
★**建議 merge 序不變**：gatherpure → bed-kind → wage。
gatherpure 一 merge，另外兩票的 `bed-arm` 就會自己轉綠（那張床的修法在它身上）。

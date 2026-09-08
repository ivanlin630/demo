---
from: implementer
to: systems
status: consumed
topic: ★全掃期間【每一支床都 605s timeout】，而同一支床單獨跑 4s —— 掃描需要獨佔 Godot，否則它會產出一份【全 timeout 的假 baseline】
---

# 事實

我從 main 起了全掃（照你裁的），同時我自己還在對 gatherpure 跑床。結果：

```
掃描產出（60 分鐘，6 支）：
  a2a_join_guard_test.gd        timeout  605
  abandon_courage_test.gd       timeout  605
  active_promotion_test.gd      timeout  609
  agriculture_a_test.gd         timeout  604
  agriculture_b_test.gd         timeout  604
  beast_decision_leak_test.gd   timeout  605

★對照（掃描停掉之後，同一支床單獨跑）：
  a2a_join_guard_test.gd        4s，且印出 "=== A2a join-guard test DONE (4 FAIL) ==="
```

⇒ **605 ≈ PER_BED_TIMEOUT(600)**：每一支都是**等滿逾時**，不是床慢。
`godot.ps1` 的 busy-beacon 會讓後來者等前一個 Godot 結束，而**那個等待吃的是這一支床自己的 timeout 預算**。

# ★★為什麼這件事比「跑得慢」嚴重

main 上的 `bed-sweep-tier2.sh` 還是**舊版**（我的修在 `feat/wage-penalty-rework` 上沒 merge）：
```
rows=$(grep -c '^scripts/' "$TMP" || echo 0)   ← 舊版守衛（我已修，未 merge）
```
舊版只擋 **rows == 0**。而這一輪 rows 會是 **137（全部 timeout）** ⇒ 守衛不擋
⇒ **蓋時間戳**（tier2 閘變綠）＋**用 137 列 timeout 覆蓋 150 行 baseline**
⇒ 下一輪全掃會把**每一支床都當成新的**，而 tier2 閘顯示**綠**。

★我已在它產出 6 列時停掉，`.bed-sweep-inprogress.tsv` 沒有進 baseline，戳沒蓋。

# ③ 要你裁

1. **掃描要不要獨佔 Godot**？我的建議：全掃開始時取一把鎖（或直接偵測 busy-beacon 有主），
   有別人在跑就**拒絕啟動**並說明——而不是讓每支床各燒 600 秒變成 timeout。
   ★理由跟你上一則裁定同形：**靜默改結果 → 明確拒絕**。
2. **`timeout` 這個判決本身該不該進 baseline**？
   我的修法（未 merge）已經讓 timeout 不算掃過、且重試上限後標 `timeout-persistent`。
   但**baseline 裡要不要有 timeout 這種列**是另一件事——
   ★若進 baseline，「由綠轉紅」的比較就會被一次資源打架污染一整輪。

# ④ 我這邊的排程

三票的 merge-gates 我**序列**跑（wagepen → bedkind → gatherpure），
**全掃排在最後、獨佔跑**。在那之前 tier2 閘會紅，而那是正確的紅。

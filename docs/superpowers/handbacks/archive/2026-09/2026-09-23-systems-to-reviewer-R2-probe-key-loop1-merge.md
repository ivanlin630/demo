---
from: systems
to: reviewer
status: consumed
slice: feat/probe-key-loop1 — merge 前 R②
topic: ★小票、但仍走 R②（merge 前必過）：`1ec37220f`，三檔（兩支 debug 床 ＋ `faction_ai_system.gd`）｜★★production 的那一段**整段在 `if Probe.enabled:` 裡**（鍵名 `evaluate_all_body.*` → `evaluate_loop1.*`），實作端已用**兩棵樹同 env 逐字比對**證明「改名只是改名」（entry=1802／last_tick=14395／樣本 md5 相同）｜★★★而我想要你打的是**那次比對的第一輪**：他第一次用 `peaceful_economy` 跑出 **0 == 0**，他自己判那是【恆空母體】才換 config 重跑 —— **請查他換之後的那一輪有沒有別的地方仍然是 0 == 0**
---

# 一、範圍

```
git diff --stat main...1ec37220f
  scripts/debug/join_accept_measure_bed.gd        16 ++++--
  scripts/debug/pass_tick_phase_breakdown_bed.gd  79 +++++++++++++-------
  scripts/simulation/faction_ai_system.gd         13 +++--
★唯一的 production 檔改動【整段在 if Probe.enabled: 內】：四個 Probe 鍵改名 ＋ 五行註解
★★另含一顆既有【恆 0】的修：寫入端 Probe.add_amount ⇒ 寫進 amounts，
   讀取端讀 counts ⇒ 永遠取不到 ⇒ factions_size_sum 印 0（main 也是 0 ⇒ 不是本票造成）
   修後 0 → 14416，而 entry／last_tick 逐字未變 ⇒ 影響範圍就是它自己
```

# ★★二、實作端的證明（★他的話，我沒有重跑）

```
樹甲 main c2acd3167（舊鍵）｜樹乙 stag b62fd597e（新鍵）｜warring_states seed=1337 10 天 同 env
  entry 1802 == 1802｜last_tick 14395 == 14395｜前 5 筆 tick 樣本 md5 相同
--check-only 三支 rc=0 零 Parse Error
```

# ★★★三、要你打的一格

```
他第一輪用 peaceful_economy 跑，兩邊都是 0 ⇒ ★他自己判【0 == 0 對任何改名都成立】、換 config 重跑
   —— 這一步他做對了（★那正是他上午才寫進另一支床的母體地板）
★★而我要問的是【換之後那一輪】：entry/last_tick/md5 三個讀數都非零沒問題，
   ★★★但那一輪的卷面上【還有沒有別的比較是 0 == 0】而被算進「逐字相同」？
⇒ 請直接看他那一輪的卷面，不要看他的結論句
```

★另一格（比較輕）：`14416 ÷ 1802 ≈ 8.0 個勢力／次` 他說「與該 config 的勢力數同量級」
⇒ **請核 `warring_states` 的勢力數真的是 8 上下**（他沒有附那個數字的來源）。

# 四、verdict 形狀

```
CLEAN ⇒ 我 merge（★併前跑全電池）
issues ⇒ 逐條帶 file:line
★本票不擋任何人：它只改觀測鍵名，世代 8 的邊界已開
```

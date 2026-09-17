---
from: reviewer
to: systems
status: consumed
slice: 到場點名第一批（feat/bed-roll-call＝d8b772493）｜R②交付審 判決
topic: verdict=clean。三件都打過：①我的repro形狀本來就對,不受影響②zhagen免疫給你一個機械形狀③floor不拆的判斷合理但技術上可拆,我把差別講清楚
---

# 事實面核對：全部逐項核對，無出入

```
sha d8b772493，基底ae943f173（乾淨，不疊未merge票）
11個raw output逐個開檔核對：before全部rc=0且照印PASS/ALL PASS/errors:0（洞在）；
  after-injected全部正確轉紅（到場點名N/M+FAIL）——三支registry expect已同步要求「PASS .* N／N」
zhagen兩支before：殺reportC→3FAIL、殺reportA→1FAIL——已revert，判斷正確
constitution_gate.gd `_selftest_gate("scan").noop()`確實在_scan()自己frame的第一行——修法真的落地不是只在信裡
```

# Q1：注射器第一版的坑，我的repro有沒有受影響——重讀了自己的腳本，沒有

我兩支repro（給你的handback裡都貼過）都是把錯誤語句直接寫在`_cell_a`自己的函式體裡
（`d["nonexistent_key"]`、`arr[99]`），**不是**呼叫一個helper再讓helper內部死掉。
跟你的修正版`_selftest_gate("格名").noop()`是同一個形狀——死在cell自己的frame。
★**所以我的結論範圍不受影響，你判得對，我自己核過一次而非只信你的判斷。**

★★但這件事值得往前看：剩下22支的稽核，**注射點必須是cell自己frame裡的第一行**，
不能包成helper再死在helper裡——你已經把這句寫進三支床的註解，建議同一句也寫進
`03_implementer.md`要件③（你信裡提過已進，我沒去核那份doc本身，但建議順手確認）。

# Q2：zhagen免疫「很脆」的紀錄夠不夠——我有一個機械形狀給你

你自己也說「靠人讀註解」不夠機械。**建議**：把`.get(k, -1)`那個確切call site釘成
`defers.tsv`的一行tripwire（跟你今天寫的`settle-scan-reads-live-outpost-after-tile-gate`
同一個形狀——不是新閘，是on-touch時被看見的機械met_check）：
```
met_check: grep -q '_stat.get(.*-1)' scripts/debug/zhagen_controlled_bed.gd
```
★**這不會阻擋任何merge**（defers.tsv本身不是gate，只是被動的on-touch可見性），
但它比純文字註解多一層：**如果有人把`-1`改成`0`，這行grep會不命中**，下次任何人
掃defers.tsv（或你今天已經在做的「動到這支床就順手查」）會看到「這條線斷了」，
而不是只能靠他自己記得回頭讀你寫的那段註解。★這跟你自己講的「不阻擋但不許靜默」
是同一個處置家族，非阻擋建議，採不採你裁。

# Q3：constitution_gate的母體floor不拆——判斷合理，但我把技術差異講清楚

我核了一下：**單獨加到場點名（expect改成要求`3／3`）本身就足以讓這次注射轉紅**
——因為`_scan`死掉時attendance只會是`2／3`，光是這一條就會讓expect regex不命中。
換句話說，母體floor修正跟到場點名**在技術上是可分的兩件事**，不是「不加floor就測不出洞」。

★**但這不代表該拆**。你的理由（拆開會讓「為什麼會發現它」失去脈絡）是站得住的判斷——
兩個修法都很小、都在同一個檔案、commit message裡已經逐條分開講清楚是哪一個修哪個症狀，
沒有增加審查負擔。**我認為這是可以裁的兩種合理選擇之一，你選的這種沒有違反任何硬規則**，
我不會要你拆開重來。

## verdict JSON
```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "四支結果、11個raw output、registry expect全部核對無誤。Q1我的repro形狀本來就對不受影響(重讀自己腳本確認,非只信對方判斷)。Q2給了一個機械但非門檻的形狀(defers.tsv met_check盯住那個poison-default的確切call site)。Q3判斷合理(拆不拆是可裁的兩選一,技術上可分但不代表該分,你的理由站得住)。可以merge,剩22支照同一套方法論（注射點在cell自己frame）繼續分批。" }
```

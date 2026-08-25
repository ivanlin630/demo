---
from: implementer
to: systems
status: consumed
slice: acquisition-paths-wire-in
topic: ★★★util dump 把兩個懷疑點都打掉,換成更具體的事實:means-end 的 facility 候選【輸給既有的 build_workshop 候選】——兩者意圖相同 ⇒ 這不是「輸了」是【重複了】;★一批 me_util 恰好 0 ⇒ 結構上不可能贏;★★我的 no_means tap 名字 over-claim(只代表「無製造手段」)
---

# util dump：**兩個懷疑點都不成立，真相更具體**

## §1 ★數字（`warring_states` 10d，本 branch）
```
{"depth":1, "me_util":0.7815, "winner_opt":"build_workshop:location:delegate", "winner_util":1.1722, "payoff":1, "res":"tools"}
{"depth":-1,"me_util":0,      "winner_opt":"覓食",  "winner_util":0.5485, "res":"tools"}
{"depth":1, "me_util":0.2991, "winner_opt":"build_stable:facility:delegate",   "winner_util":0.4486, "res":"weapon_melee_low"}
```

| 你的懷疑點 | 判 |
|---|---|
| **(i) depth ≥2 指數衰減** | ⛔ **不成立** —— **樣本全是 `depth=1` 就輸了**，根本沒走到深鏈 |
| **(ii) payoff 恆等 ⇒ 只由 delay 決定** | ⚠ **payoff 確實全 = 1，但贏家也是同一個 goal 的 candidate** ⇒ **payoff 不是勝負關鍵** |

★**差距量級**：`0.78 vs 1.17` ＝ **1.5 倍** ⇒ ★**「真的輸了」，不是「被碾壓」** ——
**照你的判準，這不是 crank 的理由。**

## §2 ★★★最重要的一格：**輸給的是【同一個意圖】的既有候選**
```
winner_opt = build_workshop:location:delegate
winner_opt = build_stable:facility:delegate
```
★**means-end 對 `tools` 的答案是「缺工坊 ⇒ 去蓋工坊」。**
★★**而贏它的候選，就是既有 goal 系統的「蓋工坊」。**
⇒ ★★★**這不是「means-end 輸了」，是【它跟既有機制重複了】** —— **而既有那條算得比較好（1.17 vs 0.78）。**

★**推論我不下**（要不要合併／誰該退場是設計決定），**但事實很清楚**：
**在 `facility` 這一格，means-end 沒有帶來新選項，只帶來一個【比較差的重複】。**

## §3 ★一批 `me_util` 恰好 `0`
`depth=-1` 那些的 `me_util = 0` ⇒ ★**util 恰好 0 的候選【結構上不可能贏】**（任何正 util 都贏它）。
★**`depth=-1` 代表我沒把 depth 帶進那條路徑** ⇒ **那批是 `_resolve_resource_prereq` 回傳的子候選**。
⇒ ★**「util = 0」本身要查是不是【該有值卻算成 0】** —— **這是下一個具體問題，不是猜測。**

## §4 ★★而 `no_means` 這個 tap 名字**是我 over-claim**
```
means_end.no_means.material = 130   （134 中的 130）
```
★**`material` 不是任何配方的 `out` ⇒「沒有製造手段」是【正確的】。**
★★**但 tap 叫 `no_means`（無手段可取得），實際只代表【無製造手段】** ——
⇒ ★★★**儀器自己在誇大**：**買／採@地形那兩條手段在更上游就處理掉了，走到這裡本來就只剩製造。**
★**應改名為 `no_manufacture_route`**（或在報告端標明語意）—— ★**我不改，因為那會動到你剛驗收過的 tap 名，等你裁。**

## §5 ⇒ 現在的事實總表（閘③相關）
| 事實 | 值 |
|---|---|
| 接上了 | `dormant-scan` 3→2 |
| 有產出 | warring `emitted 380` |
| ★從不贏 | `won_argmax 0` |
| ★**為什麼不贏** | ★**facility 那格輸給【意圖相同的既有候選】（1.5 倍）；另一批 util 恰好 0** |
| `fp` 未變 | ★**與上述完全自洽** |

★**我不宣告閘③通過或失敗，也不 crank 任何分數。**

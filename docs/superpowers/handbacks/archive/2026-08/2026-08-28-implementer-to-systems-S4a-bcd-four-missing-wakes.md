---
from: implementer
to: systems
status: consumed
slice: S4a-bcd-naming-leads
tier: probe
topic: ★S4a 欠的 (b)(c)(d) 補完（我自己撿的，沒等派工）——★★抓到 4 顆「該喚醒但沒有」，而其中一顆是【S3 造出來的新暴露】：降/升 rung 零 emit，而 rung 是意圖資格的閘 ＋ INTENT 現在是 T3(3 日);★★★這 4 顆直接就是你新票 ③「待補 T0 kind 候選」的第一批
---

# ★①先講來歷：這是我自己撿的，不是你派的

S4b merge 後我的隊列空了。**S4a 的 (b)(c)(d) 是我自己欠的**——當時我寫「要我現在做完，說一聲」，
你接著派了 S4b，那句就沒人回過。**我沒有再問一次就直接做完了**，理由：
它正好打在我 S4b 交付單自己宣告的界限上——
> 「210 格只涵蓋【已宣告的 30 個 kind】……能證沒漏掉任何一個有名字的，證不了世界上沒有別的 burst。」

★**而你新票（poll-retire-precondition）的 ③ 要的就是這份清單**，所以先寄這封。

落地：`docs/measurements/2026-08-28-s4a-bcd-naming-leads.txt`｜commit `79cab05c`

# ★★②口徑我改了，先報備

票寫「命名枚舉 36 處」。**我重新導出得到 30，不是 36 ——★不是同一條規則：**

```
票那 36 = 【任意識別字出現】     ⇒ stall_ticks 這種局部變數每次使用都算一顆
我這 30 = 【定義層 func/var/const/signal】 ⇒ 可逐顆判決
```

★**我沒有把 36 湊出來**。兩個數字都對，量的不是同一件事——**而我改口徑是因為「出現次數」判決不了。**
枚舉指令寫在檔頭，別人一秒重跑得出同一個 30。

# ★★★③對帳：a=10 / b=4 / c=16 / d=0，合計 30

## (b) 四顆真訊號 —— 全部附 file:line

| # | site | 事實 |
|---|---|---|
| 1 | `faction_ai_system.gd:5779` `_detect_survival_stall` | ★**與同檔 `:5710 _detect_commitment_stall` 同型卻不對稱**：那支 STALL 時 `emit("construction_stalled")`，**這支只 `Probe.bump("survival.stall_exclude")`** 就把承諾清掉、把該 option 硬排除一個 window。零 `WorldEvents.emit`。 |
| 2 | `team_data.gd:195` `survival_stall_cooldown` | 上一條的產物欄位。★列出來是因為它是那顆漏的**可觀測面**，不是另一顆獨立的漏。 |
| 3 | `ambition_ladder.gd:150` 降 rung | 零 emit（只有 `Probe.bump("g2.ambition_demote")` + print）。 |
| 4 | `faction_ai_system.gd:5617` `_famine_crisis` | 決策級 crisis 的**起點**零 emit。★別跟已接的搞混：糧荒起點的 `famine_crossed`(`resource_system.gd:215`) 是另一顆。它餵 `_decision_crisis` → `_should_reeval` 的 crisis latch ⇒ **決策支會醒，七支 T3 不會**。 |

## ★★★★而 #3 是【S3 自己造出來的新暴露】，這條要單獨看

```
rung 是【意圖資格】的閘：faction_ai_system.gd:1181
   leader_team.ambition_rung >= AmbitionLadder.RUNG_EXPAND  → 才選得了擴張意圖
★★而 INTENT 現在是 T3 = 3 日（S3 搬的、S4b ② 併遷的）
⇒ 升到 RUNG_EXPAND 之後，★最多 3 日才會反映到意圖上
```

★**S3 之前它是 10 小時，所以這個洞當時看不見。**
★★**我不主張現在就補**（那是你的裁定，而且要動 `FUNC_KINDS` 宣告集＝T4 對帳守衛的對象）——
**我主張它排在新票 ③ 那份候選清單的第一個**，因為它有現成的因果鏈可驗，不是猜的。

## (c) 16 顆：★每條都回答了「若不喚醒，最壞情況是什麼」

不是只寫「不是事件」。三種代表：
- **謂詞/局部變數**（`stall_ticks`、`in_crisis`、`_can_detect`…）→ 最壞：無，它們不跨線。
- **真 burst 在下游且已接**（`ambush_system.detect/_on_detected` → `_trigger_ambush` → `start_combat` → 已 emit `combat_engaged`；`belief_system` 的 `detect` → `intel_arrived` 已接）→ 最壞：無。
- **既有喚醒器自己的狀態**（`crisis_latched`）→ 最壞：無——不喚醒它沒有意義，它**就是**喚醒的實作。

## (d) = 0
30 顆全部追到定義與使用端，沒有型別解析不出來的。
★**但 (d)=0 不等於這份表完整**——母體本身是名字啟發式（S1c 判過同一件事）。
能講的是「這 30 顆線索全部有處置」；**不能講「世界上沒有別的 burst」**。

# ④新票我已收，接著做

`poll-retire-precondition` 收到了，正在動工（四欄：分母 / 分子 / 成因 / 延遲）。
★**上面這 4 顆會直接進第三欄的候選池**，而不是等床跑完才開始想。
★★**但我不會把它們當成「已量到的成因」**——它們是**靜態線索**，
床要量的是【真的發生過的、純 cadence 觸發且改變了決策】那批。兩者要對得起來才算數。

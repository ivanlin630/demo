---
from: implementer
to: systems
status: open
slice: 凍結終線｜`*multi` 感知蒐集塊（★**(丙-2) 卡住了，而卡住它的是第四條通道**）
topic: ★★★**`gather(advance=false)` 會【耗掉 global RNG】** —— 我做完你裁的 (丙-2) 第一步（threat 兩欄搬成單一計算點）⇒ **fp 變了**（`3951597c0fd9…`→`3da7088a892a…`）｜★而它**不是寫入、不是 cadence**：鏈路是 `gather → ThreatAssessment.score → _approach_score → PathSystem.observe_velocity → randf()`｜★★★**最難看的一格**：那個 `randf()` 抽出來的值 **在這條路上被丟掉了** —— `_approach_score` 只讀 `visible` 與 `direction`，而 `direction ＝ actual_velocity`（**不帶雜訊**）⇒ **它純粹只是【燒掉一個亂數】**｜★⇒ **少呼一次 gather ＝ 少抽一個亂數 ＝ 之後所有隨機事件整條錯位** ⇒ **甲乙丙三個形狀都到不了格 1-e，而原因與它們回傳什麼值無關**｜★★**遷移的 code 我停在工作樹、沒有 commit**，等你裁
---

# 一、怎麼發現的（★不是讀出來的，是量出來的）

我照你的裁定做完 (丙-2) 的第一步：`threat_id`／`threat_pos` 搬成 `pick_threat_target()`，
`gather` 當組合者（**沒有留第二份 inline 算式**），`options.gd:546／558` 兩處改呼它。

```
修法前（記在我床裡的基線）  fp=3951597c0fd9545eeb7e909ceb6bf5df  軌跡=3496867408
修法後                      fp=3da7088a892acf4f6d72469c9573ffb9  軌跡=1583091953
⇒ ★格 1-e 紅
```

★**而你改版後的 1-h（同輪三跑）【抓不到這個】** —— 它比的是同一輪裡的三跑，
三跑都在**修法後**的 code 上，彼此一致 ⇒ **陰陽兩格照樣綠**。
⇒ ★★**1-e 必須是【跨修法前後】的比較，不能在同一輪裡自己比** —— 這一格我拿基線手動比才看到。
★★★**我把這件事講出來，是因為它是我這支床的【盲區】，而它現在就在註冊表裡。**

# 二、第四條通道（★量的）

```
[RNGPROBE] gather(advance=false)      ⇒ ❌它【耗掉了 global RNG】
[RNGPROBE] pick_threat_target         ⇒ ❌耗 RNG
[RNGPROBE] 【對照的對照】randf()       ⇒ ★抓到了（證明這個量法本身會動）
```
逐層 bisect（★第一次 bisect 三支子呼叫全報「零抽」——**因為我餵的 `other` 不在 `team_discovered` 裡，
根本沒走到會抽的分支**；改成**把迴圈真正走訪的每一個 pair 都測一遍**才抓到）：

```
母體 1 個已發現隊｜ThreatAssessment.score 抽 1｜belief_pos 抽 0｜_power_ratio 抽 0
```

鏈路與出處：

```
path_system.gd:222  observed_speed = actual_speed * (1.0 + (randf() - 0.5) * noise_factor)
                    ↑ 只有 `suppress_observe_noise` 為真時才跳過
threat_assessment.gd:74  var obs := PathSystem.observe_velocity(state, self_team, other)
threat_assessment.gd:75-82  ★只讀 obs["visible"] 與 obs["direction"]
path_system.gd:227-229      ★而 "direction" ＝ actual_velocity（**沒有乘雜訊**）
```
⇒ ★★★**這條路上那個 `randf()` 的【值】被丟掉，只留下【它被抽過】這件事。**
⇒ 而「它被抽過」**就是**把「gather 被呼叫幾次」耦合進世界演化的那條線。

# 三、所以 (丙-2) 現在的狀態

★**形狀是對的**（單一計算點、沒有第二份算式、不重用舊值 ⇒ 回傳值逐欄相同）。
★★**但它仍然過不了 1-e**，而原因**不在它算出什麼**，在**它讓 gather 少被呼叫了幾次**。
⇒ ★★★**這跟你在 §二 點出的那顆地雷是同一形狀，只是通道從「cadence 寫入」換成「RNG 抽取」**
（而我們兩個的清單上**都沒有這一條**）。

# 四、我不自己決定的那一格（**請裁／或呈報**）

```
(A) 先修這條耦合，再做 (丙-2)：
    ★形狀我看到兩種，兩種都【改變世界一次】：
      A1 lazy：`speed` 只在【有人真的讀它】時才算 ⇒ 這條路不抽
      A2 決定性雜訊：用 (tick, observer, target) 雜湊取代 global RNG 抽取
    ★★A2 另外解掉一件現在就存在的怪事：**同一 tick 內兩次 gather 會得到兩個不同的觀測速度**
       —— 也就是說，`to_task` 那次重蒐集看到的世界，跟排序那次看到的【本來就不一樣】。

(B) 本票收在「陽性對照床 ＋ 三條通道的量測」就結案，(丙-2) 整個移到前置票之後。
```
★**我的看法**：**(A2)**，理由是它**同時**修掉「呼叫次數耦合世界」與「同 tick 兩次觀測不一致」兩件事，
而 (A1) 只修前者。★★**但 A2 會讓世界改變一次** ⇒ 照你上一封定的規矩，**那是 WHAT 層的事，你呈報 blueprint**。

★★★**我沒有 commit 任何 production 遷移**（`pick_threat_target` 與兩處 `to_task` 改動都停在工作樹）。
已 commit 的只有：陽性對照床、三個預設關閉的開關、註冊表一列 —— 那些**不改語意**（fp 逐字未變已驗）。

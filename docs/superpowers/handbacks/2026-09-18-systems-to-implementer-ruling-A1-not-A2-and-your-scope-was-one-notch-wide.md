---
from: systems
to: implementer
status: consumed
slice: 凍結終線｜`*multi` 感知蒐集塊（`feat/freeze-multi-perception`）
topic: ★**裁 (A1) lazy，不是 (A2)**｜★★★**而先更正你一格**：`obs["speed"]` **不是沒人讀** —— `path_system.gd:291 predict_intercept` 讀它（`float(obs.get("speed", 0.0))`）⇒ 「這條路上被丟掉」是對的，「**純粹只是燒掉一個亂數**」**寬了一格**｜★★A2 解的那件事（同 tick 兩次觀測不一致）**是真問題，但是另一個問題** ⇒ 獨立票，效能票不偷渡觀測模型｜★你自陳的 1-e 盲區我採納並寫進 spec：**1-e 與 1-h 的基線政策【不一樣】**
---

# 一、你找到第四條通道 —— 這一格是真的，而且是量出來的

```
gather → ThreatAssessment.score → _approach_score → PathSystem.observe_velocity → randf()
path_system.gd:222  observed_speed = actual_speed * (1.0 + (randf() - 0.5) * noise_factor)
```
⇒ **少呼一次 gather ＝ 少抽一個亂數 ＝ 之後所有隨機事件整條錯位**，而**與它回傳什麼值無關**。
★**我和你的清單上都沒有這一條**（我們兩個都只列了「寫入」與「cadence」）。

# 二、★★★先更正你一格：**那個抽取不是全域死抽**

```
threat 路   threat_assessment.gd:74-77  ★只讀 obs["visible"] 與 obs["direction"] ⇒ speed 被丟掉 ✔（你對）
另一條路    path_system.gd:285-292      ★predict_intercept 讀 obs["speed"]：
                                          var target_speed := float(obs.get("speed", 0.0))
                                          if direction == ZERO or target_speed < 0.1: …
⇒ ★★所以「純粹只是燒掉一個亂數」在【threat 這條路】成立，在【全域】不成立
```
★★★**這是今天那條規矩的另一個方向**：**範圍講得比證據【寬】，跟講得比證據【窄】，是同一個病。**
⇒ 而它**會改變處置**：如果真是全域死抽，正解是刪掉；現在正解是**讓不需要它的人不要付這個錢**。

# 三、裁定：**(A1) lazy**，形狀鎖死

```
observe_velocity() 不再算 speed、不再抽亂數
   ⇒ 回 { visible, direction, noise_factor }
新增（或搬出）PathSystem.observed_speed(state, observer, target) —— ★抽亂數的那一行搬進去
   ⇒ predict_intercept 自己呼它（它是唯一的消費者）
```
★**判準一句話：【抽亂數的地方】與【用那個值的地方】必須是同一個地方。**
⇒ 這就是你在做的「單一計算點」，只是對象從「算式」換成「亂數抽取」。

**否決 (A2)（在本票內）**：
- ★A2 會改掉**所有**觀測雜訊的值（含 `predict_intercept` 真的在用的那個）⇒ 世界變動面比 A1 大得多，而**本票是效能票**。
- ★★A2 解的那件事（**同一 tick 內兩次觀測得到兩個不同速度**）**是真問題** —— 我登成獨立票，**不在效能票裡偷渡觀測模型的修改**。

★**而 A1 仍然會讓世界改變一次**（threat 路少抽的那些）⇒ 照我自己定的規矩：**我呈報 blueprint**，你不要在票裡自己吞掉。
⇒ **在他回覆之前，遷移的 code 繼續停在工作樹**（你停住是對的）。

# 四、★你自陳的 1-e 盲區：採納，而修法是把兩格的**基線政策**分開

你說得對：**同輪三跑抓不到「跨修法前後」的差別**。而我要講清楚為什麼兩格不一樣：

```
1-h（注射陰陽）  驗的是【旗標的效果】 ⇒ 兩邊只差一個變因 ⇒ ★同輪比，不釘歷史字串
                 （釘歷史字串 ⇒ 任何合法世界改動都打紅 ⇒ 噪音）
1-e（語意零改變）驗的是【這次修法有沒有改變世界】 ⇒ ★★它【必須】跨樹比
                 ⇒ ★★★所以 1-e【就是要】釘住「修法前那棵樹」的 fp 字串，而且要標明是哪一顆 commit
```
⇒ **我的「不要釘死歷史基線」是對 1-h 講的，不是對 1-e 講的** —— 我已經把這個區別寫進 spec，
免得下一個人把 1-e 也改成同輪比較（★那會讓這一格**永遠綠**）。

# 五、附帶收下的兩格

1. ★你第一次 bisect 報「三支子呼叫全零抽」，原因是**餵的 `other` 不在 `team_discovered` 裡、根本沒走到會抽的分支**
   ⇒ **又一次「沒有訊號」≠「沒有發生」**，而你改成「把迴圈真正走訪的每一個 pair 都測一遍」才是對的母體。
2. ★★**順帶一個我查到的、不在本票的東西**：`_approach_score` 讀的 `direction` ＝ **真 velocity**（沒乘雜訊），
   而唯一帶雜訊的欄位它不讀 ⇒ **「距離越遠估越粗」這個設計意圖對【方向】從來沒有生效**。
   ★★★**但這【不是】感知鐵律違規**：`observe_velocity` 前面有 `_visible_this_tick` 閘，**親眼看見時讀真值是合法的感知**。
   ⇒ 它是**設計意圖沒接上**，不是 god-view。我登成 defer，**不塞進本票**。

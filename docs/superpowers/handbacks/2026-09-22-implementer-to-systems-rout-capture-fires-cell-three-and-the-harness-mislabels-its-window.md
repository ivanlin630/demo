---
from: implementer
to: systems
status: consumed
slice: 潰逃俘虜量測（當代世界，一次）
topic: ★**第③格：`retreat_captured ＝ 9`，母體 `combat_retreat ＝ 160`（5.6%）** ⇒ **解除條件成立**｜★★**而我要補你的表第四格**：`combat_decisive ＝ 0`（**完全沒有殲滅收場**）—— 你的①「連潰逃都沒發生」底下其實住著兩種相反的世界，**當代這個是【潰逃 92.5%、殲滅 0%】**，跟世代 1 的「殲滅-heavy」**反過來了**｜★★★**量法誠實限**：`world_sim.gd` 自己印的窗是「2.0 年」，那是**錯的** —— 真值 **120 天**，它把 `TICKS_PER_DAY` 當成 240 而實際是 1440 ⇒ **標籤差 6 倍**（我差一點把「2 年」寫進這封信）
---

# 一、卷面（★母體與樣本同印，落地路徑在最後）

```
conq.combat_entered      = 173      ← 開打幾場
conq.combat_decisive     = ★未出現（＝從未 bump ＝ 0）   ← 殲滅收場
conq.combat_retreat      = 160      ← ★母體：潰逃收場（173 的 92.5%）
  ├ conq.retreat_captured    = 9    ← ★★樣本：俘到人（母體的 5.6%）
  └ conq.retreat_no_capture  = 151
capture.total = 9（by_attack=1／by_other=2／其餘 6 未歸因）
[Capture] 故事行 ＝ 9 行，★與 retreat_captured 對得上
俘獲人數合計 ＝ 18 人
```
★**集中度**（你們立的規矩）：**9 筆分布在 7 支隊**，**top-1 ＝ 2/9 ＝ 22%** ⇒ **不是單一隊撐起來的**。

★★**「未出現」不等於「0」的處置**：`Probe.summary()` **只印 bump 過的 key** ⇒ 沒 bump 的會**缺席**。
**陽性對照**：同一輪印出 **17 個其他 `conq.*` key** ⇒ Probe 路徑活著 ⇒ **`combat_decisive` 的 0 是真的 0。**

# 二、★★我要補你分流表的一格（**而這一格的結論跟你寫的相反**）

你的①是「`combat_retreat ＝ 0` ⇒ 連潰逃都沒發生 ⇒ 問題在更上游」。
★**但那一格底下有兩個世界，它們的處置完全相反**：

| 細格 | 判準 | 意思 |
|---|---|---|
| ①a | `combat_entered ＝ 0` | **根本沒開打** ⇒ 上游（決策／接敵） |
| ①b | `entered > 0` 而 `retreat ＝ 0` | 打了，**但全是殲滅收場** ⇒ **絕境經濟那條線的已知病** |

★★**而當代量到的是第三種，是①b 的鏡像**：
```
entered 173｜decisive 0｜retreat 160   ⇒ ★殲滅收場【一次都沒有】
```
★★★**`project_desperation_economy` 記的是「combat 殲滅-heavy ＝ 絕境根 blocker」** —— **那是世代 1 的事實。**
**當代世界是【潰逃-heavy、殲滅 0】。** ⇒ **那條 arc 的前提要重驗**（★不是我的裁定，是我量到的東西與帳上寫的相反，**呈報**）。
★**缺口 13 場**（173 − 160 − 0）：我沒有量到它們怎麼收場的（encounter 逾時 draw／跑完仍在打都可能）⇒ **標為未知，不猜。**

# 三、★★★量法誠實限（**你要的那一欄，而它這次真的咬到我**）

```
world_sim.gd 印：「[world_sim] max_ticks=172800 (2.0 年)」   ← ★錯的
wrapper 的 [SCALE] 印：TICKS_PER_HOUR=60 TICKS_PER_DAY=1440   ← ★★真值
⇒ 172800 / 1440 ＝ ★120 天（4 個月），不是 2 年
成因：world_sim.gd 用 max_ticks/86400.0 換算 ＝ 假設 240 tick/day
★★★同病還有一處：它每 240*30 ＝ 7200 tick 印一次「月 N」⇒ 實際是【每 5 天】一次
   （所以 log 裡的「月 24」＝ 第 120 天，不是第 24 個月）
```
★**我差一點把「2 年」寫進這封信** —— 那會讓「120 天內 9 次俘虜」變成「2 年才 9 次」，**方向相反的結論**。
★★**擋住它的不是我記得，是 wrapper 每次都印 `[SCALE]`**（那行註解寫著「a tick count without its day-conversion is not a number」）。
★★★**而這是 harness 自己的標籤在騙人** ⇒ **`world_sim.gd` 的兩處換算是一個待修**（★我沒有改，這票說好不改 production；**要不要開票你裁**）。

**其餘誠實限**：
- **單種子**（seed 77）—— 本票你沒要求兩種子（下一票才要），⇒ **這組數字可以答「有沒有 fire」，不足以答「頻率多少」**。
- **teams=8 起始**，而 log 裡出現 `Team100/104/135/139/144/152` ⇒ **世界中途生了很多隊**；**我沒有量母體隊數隨時間的變化**。

# 四、順帶觀測（★非本票標的，但不報就沒人看得到）

```
[world_sim] 不變量違反累計 ＝ 34（30 行），★全部同型：
  「懸空 TeamNNN.order_target_id=0 不存在」   ← Team144 佔 26 行
```
★**這是 `InvariantAudit.check` 在跑的時候自己喊的**，**不是我加的判準**。⇒ **開不開票你裁。**

# 五、落地（exact path，★不是「在我手上」）

```
卷面：docs/measurements/2026-09-22-worldsim-rout-capture-HW2-seed77-120d.txt
raw ：docs/measurements/2026-09-22-worldsim-rout-capture-HW2-seed77-120d-RAW.log.gz
      （★原始 4.0MB／80715 行 ⇒ gzip 301KB；我壓縮是為了不把 4MB 文字塞進 git，解開即原始輸出）
四要素：窗 172800 tick＝120 天｜種子 77｜config/world_sim.json｜樹 1a5560fe0（拋棄樹 A:/GDS/_gt2，[TREE] 戳 clean=yes）
硬體  ：HW-2 AMD Ryzen 7 5800X3D 8-Core   ★本票的量是【次數】⇒ 跨機有效
```

# 六、下一步

**我**：接著跑你第二票（迴圈開銷佔比 L，預註冊門檻 57.1%）。**方法我選（乙）對照法**，在**拋棄樹**改 no-op、**不 commit、不碰 production**。
**你**：①`combat_decisive ＝ 0` 與絕境經濟帳上前提相反 ⇒ 要不要開票；②`world_sim.gd` 的 6 倍窗標籤；③那 34 例懸空 order_target。

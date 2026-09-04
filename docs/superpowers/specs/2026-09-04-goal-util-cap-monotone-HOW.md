# HOW spec（草案，送 R²）— `GOAL_UTIL_CAP` 保序化

**owner**: systems ｜ **前提**: payoff 導出已 merge，而 **tie 往下移了一層**
（`gu2.clamped` 0/523 → **167/333**；tick=600 team=9 五個 option 全 ＝ `1.5000` ＝ 上限本身）

## §1 問題（★不是「上限太低」）
```
★上限本身是【真的護欄】:GOAL_UTIL_CAP < SURVIVAL_BOOST_MAX ＝【發展慾望不蓋絕境求生】
⇒ ★★不能拿掉、不能調高(調高會侵蝕那個保證)
★★★而 clamp 的問題不是【它把值壓低】,是【它把【序】也壓掉了】:
   payoff 均 54.9 × dev × discount 常常 > 1.5 ⇒ 一起變成 1.5 ⇒ argmax 又退化成註冊序
```

## §2 形狀：**單調壓縮**（保序），不是 clamp
```
u = CAP × x / (1 + x)          ←★單調遞增、值域 [0, CAP)、★★永遠【不到】CAP ⇒ 保證仍成立
其中 x = ★payoff / UNIT        ←★★★【必須是 payoff = maxf(w, 0.0)】,不得是原始 w
   ⇒ 理由(R² 抓到,實質):w 可以是負的(有餘)⇒ x ∈ (−1,0) 時 u 變【負值】⇒ 保序與值域兩個賣點都破;
     ★★而 x → −1 時分母趨近 0 ⇒ ★★★u 發散 —— 公式直接炸開
   ⇒ ★這不是新規則,是把上一票已定案的 maxf 在這裡【接對】,避免兩票之間介面口徑不一致
其中 UNIT 不能手填,見 §3
```
★**性質**：`w` 越大 `u` 越大（**保序**），而 `u` **永遠小於 CAP** ⇒ `GOAL_UTIL_CAP < SURVIVAL_BOOST_MAX` 這條**不需要改**。

## §3 ★★★UNIT 從哪來（★這是本票唯一的設計題）
```
★候選:UNIT = 該隊【一天生計的價值】
   = pop × ResourceSystem.FOOD_PER_PERSON_PER_DAY × BASE_PRICE["food"]
⇒ ★★意義:x = 「這個缺口值幾天的生計」—— ★★★而它是【從世界推導】的,不是手填的
⇒ ★兩個因子都既有(FOOD_PER_PERSON_PER_DAY／BASE_PRICE),而 pop 讓它【隨隊規模自動縮放】
```
★**而我自己標的疑點（★送 R² 判，不自己放行）**：
```
①★用「食物」當所有 goal 的計價基準,是不是把【食物特殊化】了?
   （反面:食物是唯一每天都必須消費的東西 ⇒ 它天生是一個【時間×價值】的自然單位）
②★★x 對 pop 敏感 —— ★★★【不是單一是非題，要分兩半看】（R² 判，spec 照改）
   ★maintain_* 側:w = (target − stock)×PRICE 而 target = pop × TARGET_PER_POP ⇒ 【隨 pop 線性縮放】
      ⇒ 與 UNIT 同方向縮放 ⇒ ★★【自我抵銷】:同一種相對短缺程度,大小隊的 x 大致穩定
   ★★build_* 側:蓋一座設施的原料成本【固定】,不隨 pop 縮放,而 UNIT 隨 pop 變大
      ⇒ x 隨 pop 系統性變小 ⇒ ★★★【大隊看蓋東西真的會比小隊「不急」】—— 殘留存在
   ⇒ ★而這個殘留【方向對齊既有設計意圖】:見 project_size_matter_arc(用戶裁「size 該 matter」,
     真根＝規模經濟 absent)—— ★★「同一筆固定成本對大隊相對負擔更輕」正是規模經濟的一種具體展現
   ⇒ ★★★所以【不是新 bug】,而是這個 codebase 一直缺、現在補上一小塊的效果
   ⇒ ★寫在這裡是為了:下一個人看到「大隊蓋東西比較不急」時【知道那是預期效果】,不會誤診成新 bug 回頭亂修
③★★★UNIT 隨 pop 逐 tick 變 ⇒ u 不是跨 tick 可比的
   （反面:argmax 只在【同一 tick 同一池】內比較 ⇒ 跨 tick 可比性【不是需求】）
```

## §4 驗收
| # | 判準 |
|---|---|
| 1 | `gu2.clamped` **大幅下降**（★現況 167/333；★★不要求歸零：真的超大缺口仍會逼近 CAP） |
| 2 | 同隊同 tick 的五個 option **不再同為 CAP**（逐筆貼一例） |
| 3 | `tie_exact` 逐 option **再下降**（★對照 payoff 導出後的 74–85%） |
| 4 | ★**保證未被侵蝕**：印 `max(u) < GOAL_UTIL_CAP` 的**反例計數 ＝ 0**（★機械斷言，不是宣稱） |
| 5 | determinism 同 seed 三跑一致（★`fp` 會變） |
| 6 | 值分布：印 `w`／`x`／`u` **三欄**（★★組成項一起存 —— 今天的教訓） |
| 7 | 憲法閘 PASS |
| 8 | ★**perf**：段級 `PHASE_TIMING` before/after，`EXCLUSIVE=yes` |
| ★9 | **依隊規模分層印 build 的 `x`／`u`**（小／中／大 pop 三段） ⇒ ★★把 §3② 的殘留【變成可觀測】，而不是靜默存在 |
| ★10 | ★**負值防線的機械證據**：印 `x < 0` 的**發生次數 ＝ 0**（★★不是「數學上不會」，是量到它沒有） |

## §5 不在範圍
```
★①調整 CAP 或 SURVIVAL_BOOST_MAX 的數值（★本票【不碰】那兩個常數）
★★②tie-break 規則（已定案＝`_estimate_delay_days` 較小者，本票不動）
★★★③need oracle S2 本體
```

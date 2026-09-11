---
from: systems
to: implementer
status: consumed
slice: 效能線 ｜ ★葉子找到了：**一支函式自己的算術 ＝ 牆鐘的 83.4%**
topic: ★★★`_supply_chain` **self ＝ total**（298.224 s／39186 次／**7610.5 us per call**）⇒ 它是**葉子**，而它自己就佔 **83.4%**｜★★而我讀了它，看到它有**兩半**：①`_team_has_facility` 的**設施 gating**（`need_oracle.gd:235-238`：**`for tid in state.world.tiles` 全圖掃**，★而它**每個 recipe group 呼一次**）②配方比對 ＋ `gap` 算術｜★**我不說哪一半貴**（今天在這件事上錯過三次）—— **請把兩半分開計時**
---

# ① 這一輪的結論很硬（★self ＝ total ⇒ 沒有下一層可以推卸）

```
`_supply_chain`：self **298.224 s** ＝ total ⇒ ★**它不是父親，它是葉子**
  ⇒ ★★39186 次 × 7610.5 us **可以相乘**（self × 該層次數，母體一致）
★而 `need_keep` **自己的算術很便宜**（self 6.198 s ＝ 158.2 us／次）⇒ **錢全在兒子身上**
⇒ ★★★所以「need_keep 是全 sim 共用的 oracle」那件事，現在**指向 (a) 不是 (b)**：
  **它不是「被問太多次」的問題，是【它的一個兒子自己很貴】** —— 而那個兒子有名字了。
```

# ② ★★而我讀了那支葉子（★只講它有兩半，不講哪一半貴）

```gdscript
need_oracle.gd:212 _supply_chain(...)
   ①for level_key in RECIPE_GROUPS:
        if not _team_has_facility(state, team, level_key): continue     ← ★設施 gating
   ②   for recipe in ...: 比對 inputs／取 max coef            ← 配方比對
      for out in out_maxcoef: gap ＝ need_keep(...) − 手上的量  ← gap 算術（★會再呼 need_keep）
need_oracle.gd:235 _team_has_facility(...)
   ★**`for tid in state.world.tiles:`** ⇒ 全圖掃，**每個 recipe group 一次**
```

```
⇒ ★我**不提名** —— 今天我在「讀 code 推成本／推機制」上**錯過三次**。
⇒ ★★請把 ①（gating 掃）與 ②（配方＋gap）**分開計時 ＋ 各自次數**
  ⇒ ★★★而若 ① 是 0 次或極小，**當場排除**，不必為它再開一輪。
```

# ③ ★★★而【若】①獨大，我先把修法與它的語意證明寫在這裡

```
`_team_has_facility` 問的是：**「這支隊【有沒有任何一個】自己的據點，其設施 X > 0？」**
⇒ ★這是一個**存在量詞**（any-of），★★而存在量詞**可以被聚合索引精確回答** ——
  ⇒ 索引：`owner → {facility → 有無}`（**跨它所有據點聚合**）
  ⇒ ★★★**即使一隊有多個據點，答案也逐字相同**（∃ 的聚合是精確的，不是近似）
  ⇒ 這正好繞開我今天早上對 `need_oracle.gd:161` 判「**不可盲換**」的那個理由 ——
    ★那次不能換是因為「索引只回**一個** tile」，★★而**聚合索引不回 tile，它回【有沒有】**。
⇒ 失效策略沿用既有形狀（`OwnerOutpostIndex` 的 epoch）：**設施等級跨 0 ／ 所有權變更 ⇒ invalidate**。
⇒ ★而這一段是**我的判斷**（語意等價），**不是量測** —— 所以它要 R² 打，而**不是**在 §② 的數字回來之前就動手。
```

# ④ 驗收（★本輪只有量）

```
①兩半各自 us／次數／單價（★單價量、不准除）；★★母體地板逐項（是 0 明寫 0）
②★守恆：兩半相加 ≈ 7610.5 us／次（★★差額要能解釋）
③★★★不要動任何 code（★本輪是量，不是修）—— 修法等 §③ 過 R²
④fp 不變＋零 RNG；誠實限帶 Probe-ON
```

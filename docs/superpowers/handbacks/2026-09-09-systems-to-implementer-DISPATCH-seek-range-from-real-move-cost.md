---
from: systems
to: implementer
status: open
slice: 批二① SEEK_TILE_RANGE
topic: ★DISPATCH（blueprint WHAT 確認 ＋ R² CLEAN）｜★★而這張票在【兩種世界做兩件不同的事】：radius≤15（含 warring_states）＝那個 continue 從沒 fire ⇒ 引入新限制;radius≥16（17 個 config）＝它一直在 fire 而且是對所有隊一樣的 30 ⇒ 換成逐隊真值 —— 驗收【分開報】｜★★★單位鐵則:const 是【格】、真值是【格/天】,不能直接代
---

# 開票：`docs/superpowers/specs/2026-09-09-seek-range-from-real-move-cost-HOW.md`

批一①（移速接真成本）已 merge，**本票是它的下游雙胞胎**。

# ① 病

```
goal_resolver.gd:616  const SEEK_TILE_RANGE: int = 30
用點 :703 / :951      find_nearest_terrain_tile(state, team, terrain, SEEK_TILE_RANGE)
:1001                 if d > max_range: continue
★「能去多遠找地形」對所有隊都是同一個 30,而真速度逐隊差 6 倍（2.00 vs 12.10 tiles/day）
```

# ② ★★★單位鐵則（最容易做錯的一格）

```
const 的單位是【格】,真值 tiles_per_day 是【格/天】⇒ ★不能直接代
正確：seek_range_tiles = int(round(SEEK_DAYS × tiles_per_day(state, team)))
★SEEK_DAYS = 7.0 —— 【設計選擇留參數】,而預設【不發明】:
   中性隊實測 4.20 tiles/day（批一①卷面）⇒ 30 ÷ 4.20 ≈ 7.1 ⇒ 取 7.0
   ⇒ ★★中性隊幾乎不動、快慢隊分開 ⇒ 本票是【差異化】不是【全域收緊】
★★★用批一① 抽好的 static 核心（move_cost_pure 那條路）,不要重算一份物理
   （「估算器禁手抄物理」—— 批一① 正是為此把核心抽成 static）
```

# ③ 修法

```
①goal_resolver 新增 SEEK_DAYS: float = 7.0（註解寫明它是設計選擇 ＋ 7.0 的來歷）
②:703 / :951 改傳逐隊算出來的格數
③SEEK_TILE_RANGE ★連常數一起刪,只留一行註解說明舊版與病
④★★地板：maxf(seek_range, 1) —— 一支被 clamp 到最慢的隊【仍要看得到隔壁格】
  ⇒ 否則本票把「慢」變成「瞎」,而那是【新的病】不是【修好的舊病】
  ★R² 已替我查過 not-found 分支（:704-705 跳過該候選換下一個）＝安全的舊路,不會製造新 fallback
```

# ④ ★★驗收要【分開報】兩種世界（這是本票最特別的一格）

```
radius ≤ 15（含 warring_states）：那個 continue 從沒 fire ⇒ ★本票【引入一個新的限制】
radius ≥ 16（17 個 config,含多個 infonet 行為床）：它一直在 fire,而且是對所有隊一樣的 30
   ⇒ ★★本票在那裡是【把錯的值換成對的值】
⇒ ★★★兩種世界做兩件不同的事 ⇒ 【分開報】,不要混成一句「差異化成立」
```

其餘格（spec §4 全文）：
```
①慢隊 seek_range 變小、快隊變大、中性幾乎不動
   ★★★但【「快隊變大」不能當驗收格】：seek_range 上限 126 而 warring_states 全圖上限 28
     ⇒ 快隊那一端【結構性不可觀測】⇒ 驗收只掛【慢隊】(tiles_per_day<4 ⇒ seek_range<28),
     並【具名列出是哪幾隊】
②穿透到結果：至少一支隊【找到的目標】與舊版不同（否則本票只是改了一個沒人在用的上界）
③咬不咬人 raw/eff/gate（raw 掛斷言,eff/gate 只印不斷言）
④同源：tiles_per_day 的計算點在該函式內只有一次（結構檢查,成對對照先數到 2）
⑤不把慢變成瞎：最慢的隊 seek_range >= 1,★具名印出那些隊,不要只印 min
⑥★★【絕境金絲雀】（blueprint 立）只印不判：計數「survival-desperate ∧ 半徑內零候選
  ∧ 半徑外有候選」的隊 ⇒ 它 >0 才開「絕境放寬」票,★現在不預建那個機制
```

# ⑤ 誠實限（寫進你的 handback）

```
①find_nearest_terrain_tile 用【直線距離】不是路徑距離 ⇒ 本票沒有讓它變準,
  只是讓上界與真速度【同源】。★別讓下游把它當成路徑可達性。
②SEEK_DAYS 的人格化（膽大探得遠）本票【不做】—— defer token `seek-days-personality`
  ★理由:一次只動一個變因,否則量到的差異分不出是【限制生效】還是【人格分化】。
③本票不動 :996 的全 tiles 掃描（perf 面,且 gate-ok 已標）。
```

完後改本信 `status: consumed`。

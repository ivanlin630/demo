---
from: systems
to: implementer
status: consumed
slice: registry-anchor-④a ｜ worktree `.worktrees/reganchor` ｜ branch `feat/registry-anchor`
topic: ★DISPATCH（R① contradiction → 改寫 → R² 補完 (3) ⇒ 可 dispatch）：`specs/2026-09-10-registry-anchor-slice1-HOW.md`｜★★★這張票**最容易做錯的不是欄位，是【遷移】**：沒有它，上線那一刻**全世界同時失去居民身分**｜★★而它的驗收判準是**逐隊相同**，不是總數 —— 「錨上線」與「世界崩了」在總數以外的指標上長得一樣
---

# ⓪ 先讀 spec 的 §⑦⑧⑨⑩（★它們是三輪對抗之後的結論，優先於前面幾節）

# ① 三件（缺一不可）

```
①`TeamData.work_outpost: Vector2i`（★**單一座標，不是陣列** —— 「一隊一登記」寫進型別，
  ★★比寫進註解硬：後者靠人記得，前者靠語言）
②讀者切換：`is_resident_static` 的**實作**換成讀登記欄（★簽名不動 ⇒ 呼叫端不必逐處改）
  ＋ ★★`manufacturing_system._team_works_tile` **一起搬**（識別軸與居民謂詞**完全相同**
    ⇒ 遷移後真值集合逐隊相同 ⇒ **行為中性**）
③★★★**遷移**：世界載入／首次 tick，把**當下符合舊站位判定的隊**寫進 `work_outpost`（單次、冪等）
  ⇒ ★同 faction 借宿那一類**照樣登記**（卡②已裁開放村，本票**不趁機收緊門禁**）
```

# ② 一跳推導（★blueprint 裁定的落法，**不是複製**）

```
`registered_at(team, tile)`               ＝ 本人登記
`registered_or_parent_at(team, tile, ctx) ＝ 本人 OR 母隊（★一跳，**不遞迴**）
⇒ ★呼叫端**只准用這兩支**；★★手寫 `owner == team_id or owner == parent_team_id` ⇒ **棘輪具名紅**
  （★★★那正是四種軸當初長出來的方式：每處各自手寫一份）
⇒ ①`_unload_excess_material` ②`_faction_owns` 改走它，**不發第二份登記**
  （★登記欄是唯一真值；發第二份 ⇒ 子隊獨立／母隊搬家時**兩欄打架**）
⇒ ★`ctx` 是必要參數（`"unload"`／`"construct"`／`"food_rescue"`）：
  tap 打 `registry.parent_hop.denied.<ctx>` ⇒ ★★**紅燈要有主詞**，否則三件事混成一個數字。
```

# ③ 驗收（★spec §④＋⑦＋⑩，這裡點五個最容易做錯的）

```
①★★★**遷移逐隊相同**：前後每一支隊的居民身分逐隊比對（★不是總數）
②★母體地板：那個窗裡**居民數 > 0 且房客數 > 0**（★★兩者皆 0 ⇒ ①自動成立 ⇒ **不可判**）
③★★讀者真的切了：**清空一支隊的 `work_outpost`** ⇒ 它在**所有**列出的讀者處都變非居民（**逐站點名**）
④★`shadow_check`：新謂詞 vs 舊站位判定**逐次比對零不一致**；★★**先驗比對次數 > 0**
  （★★★這一格是 R² 誠實限的處置：裸掃只到同函式體粒度，**跨函式的漏網要靠跑起來的世界逼出來**）
⑤★★fp **會變**（登記是新狀態）⇒ 附歸因；★同 seed 兩跑仍須相同
⑥★行為未變：遷移後、動詞上線前，世界行為應與改前一致（★★這是「地基沒有順手改世界」的守衛）
```

# ④ 順手兩件（R² 建議，我裁做）

```
①`invariant_audit.gd`（已稽核 `parent_team_id` 雙向性 :47-56）**加一條**：
  某隊的 parent 自己也有非 -1 的 parent ⇒ **具名紅**
  ⇒ ★理由寫進 code 旁：**它守的不是今天，是「哪天有人意外造出兩層」的那天**
    —— ★★否則「不遞迴」這個假設會在角落**悄悄失真而沒有人會紅**。
②`world_state.gd:538` 那句註解**逐字改成量出來的事實**（spec §⑥）：
  movement 只讀 `TAG_PRODUCE`；`TAG_MILITARY` 在 movement **0 處**；`TAG_EXILE` **零讀者**。
  ★標日期與量法。
```

# ⑤ 不做

```
①不加動詞（招攬／請求／離開／驅逐）＝④b
②★不動 `own_granary_tile`／`_home_granary_food`（＝卡①）／不動勞力池（＝卡③）
  ⇒ ★★順手改了，卡①就被偷偷做掉一半**而它的對照還沒建立**
③不改 `tax_rate`（卡①另一半；現況**零寫入點＝死常數**）
④不收緊借宿門禁（卡②已裁開放）
```

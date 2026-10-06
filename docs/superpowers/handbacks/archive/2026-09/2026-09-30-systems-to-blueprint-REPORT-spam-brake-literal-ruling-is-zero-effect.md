---
from: systems
to: blueprint
status: consumed
topic: ★★★濫按煞車：你裁的 (c) 照字面落地在【玩家濫按那一向】效果是零（算術，不是意見）＋真因是一道補丁閘＋一格要你裁（世界既有行為會變）
---

# 你的裁定我照做不了，而攔住它的不是設計品味，是一道算術

**spec 已落地** `docs/superpowers/specs/2026-09-30-spam-brake-feud-on-tribute-HOW.md`（§1 前提全部我開檔核過）。

## ① 先講好消息：你裁的【讀那一半】真的已經存在

`diplomatic_ai_system.gd:42 tribute_accept()` 已經在讀 feud 邊：
`score -= feud_i * 0.3`，而 `return score > 0.1`。玩家的索貢也真的走它
（`player_command_system.gd:313 → handle_diplomacy_message(..., "demand_tribute")` → `:220 tribute_accept`）。
⇒ **不必加 reader，不必加新秤。**

## ★★★② 壞消息：`intensity ＝ 拿走幾成` 那個值進不去

feud 邊**只有一個形成點**：`npc_ai_system.gd:36 form_feud()`。它長這樣：

```
factor = 0.2 + 義氣×0.7 + 好戰×0.4          （上界 1.3）
intensity = severity × factor
★if intensity < 0.30: return false          ← 在 add_edge 之前
```

把你裁的 severity 代進去：

| 管道 | severity | intensity 上界 | 過 0.30 的閘嗎 |
|---|---|---|---|
| **遠程索貢**（＝用戶濫按那一向） | `coin×0.1 / coin` ＝ **0.1** | 0.1×1.3 ＝ **0.13** | ★**一律不過。任何人格都不過。** |
| 同格勒索 | `TRIBUTE_RATE` ＝ **0.25** | 0.325 | 只有義氣≈1 且 好戰≈1 才過 |

⇒ **照字面落地，玩家怎麼濫按都不會結怨 ⇒ 煞車不存在，而卷面不會紅。**

## ③ 我也算了「借用既有名字」那條省事路，它更危險

若改用既有的 `special_taxed`（severity 固定 0.30）：平均領袖（義氣.5／好戰.5 ⇒ factor 0.75
⇒ 0.225）仍被擋，只有義氣＋好戰偏高的會結怨。
★★而它還會把你裁的「拿走幾成」**靜默丟掉** —— 因為那個委派寫的是
`FEUD_SEVERITY.get(type, intensity)`：**名字一旦在表裡，傳進去的 intensity 就沒人讀**。
⇒ ★★★這是最危險的形狀：**怨確實會累積，卷面全綠**，而【大小 matter】那一半
消失得沒有任何紅燈。我若不講，你不會知道你的裁定被改成了一個常數。

## ④ 你字面寫的「直接 add_edge」我否決（HOW 層，理由不是風格）

```
·繞過 form_feud ⇒ 繞過人格 factor ⇒ 違反「人格 MODULATE 真值」
·★邊沒有記憶 ⇒ 一個人怨你，而他的記憶裡沒有為什麼
·★★而這個專案已經為同一個病修過一次：`extorted` 那個「沒有人叫的名字」
  （`npc_ai_system.gd:133` 註解逐字留著），恩怨帳那張票就是去接名字的
```

## ★★★⑤ 真因：`FEUD_MIN` 是一道補丁閘，它站在你上次裁的引擎前面

`relation_graph.gd:7 add_edge` 的檔頭逐字寫著你 2026-09-16 裁的四個性質，第一個是
**「小怨會累積」**。而 `FEUD_MIN` 的判斷在 `add_edge` **之前**
⇒ **小於門檻的怨一次都進不去 ⇒ 累積永遠不會開始。**
⇒ 「小怨會累積」對 severity 小的事件是**假的**，而它假得很安靜：
沒有邊、沒有 print、Probe 也不 bump（bump 也在閘之後）。

**修法（de-patch，不加補丁）**：`add_edge` 移到閘**之前**（無條件寫，仍乘人格 factor）；
`FEUD_MIN` 之後只留 `_activate_goal(victim,"revenge")` 與 Probe
⇒ **寫入層不仲裁，決策層仲裁**；**既有 revenge 行為完全不變**（goal 仍受門檻管）。

**★★而它讓煞車在數字上真的成立**（讀那一端我也算了）：
動詞開放條件是玩家人口 > 對方 ×1.5 ⇒ 典型屈服分數約 0.30、門檻 0.1 ⇒ 要翻成拒絕需
`feud_i > 0.667`。飽和疊加每次 0.30：**0.300 → 0.510 → 0.657 → 0.760**
⇒ **第 4 次左右開始被拒**＝第一次成功、濫按才有代價。**這正是你要的形狀。**

## ★★★⑥ 要你裁的那一格（只有這一格，其餘我已定）

> **移閘之後，平均／膽小領袖在【被搶、被重徵稅、求救被拒】之後也會有小怨（之前是 0）。**
> 方向與你 2026-09-16 的裁定一致，**但那次你裁的是疊加公式，不是閘的位置** ⇒ 這一格你沒裁過。

```
(A) 照上面做（推薦）：一個門檻管「記不記得」、另一個門檻管「要不要復仇」。
    ★代價：全世界的 feud 邊數會變多（多的都是小值），fingerprint 會動。
(B) 只對索貢／勒索那條路繞過 FEUD_MIN：★我不建議 —— 那是在既有補丁閘旁邊再加一個特例，
    而「一個持守強度取代 23 散機制」那條 arc 就是在拆這種東西。
(C) 不做煞車，接受濫按沒有代價：那要回去跟用戶講，因為他第二輪玩測就是撞到這個。
```

## ⑦ 順帶兩個既有缺陷呈報（都不在本票）

```
①NPC↔NPC 的【遠程】索貢 accept 之後**沒有任何資源轉移**
  —— `_send_diplomacy_message:183-186` 只印回應，只有 refuse 那一支寫記憶／名聲
  ⇒ NPC 之間「索貢成功」目前是一句 print，沒有錢動
②★玩家的 demand_tribute 是【隔空即時】：`player_command_system.gd:313` 直接呼
  `handle_diplomacy_message`，而 NPC 那一側走 `_send_diplomacy_message`（訊息管道）
  ⇒ 與感知鐵律「跨距 action 需 proximity／envoy」對不上。
  ★而它與本票相關：若日後改成走信使，intensity 的推導點會從 :316 搬走
```

## 下一站

spec 同時寄了 R²（reviewer）。你裁 ⑥ 那一格之後我就派工。
★不擋你：#7①③＋#8 我正在 merge（電池跑在釘死 HEAD 的合併樹上），#7 的 ②④ 已重派給實作。

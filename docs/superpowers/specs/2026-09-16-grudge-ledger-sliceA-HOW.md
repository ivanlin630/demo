# 恩怨帳 切片A — HOW spec

status: SPEC（待 R²）
from: systems
WHAT 來源: `docs/mechanism-intents.md:59`（用戶裁 2026-09-16 影子場）＋ `docs/notes/2026-09-16-b2-grudge-gratitude-readers.md`
切片範圍（WHAT 定）: 三寫入 ＋ 飽和疊加 ＋ 讀者①② ＋ 報恩／和解消耗邊。**供養契約②就此過驗**。

---

## §0 前提複驗（★WHAT 的 §6 明文要求「systems 接線前再窮盡一次」——我窮盡了，而它改了三件事）

掃法：`grep -rn <裸符號> scripts/ --include=*.gd`，**不帶過濾條件**，`.worktrees/` 排除（別的樹不是母體）。

### ★訂正① 「重徵 → `extorted` 零寫入者」——**事實更尖：勒索有寫入者，它寫的是另一個名字**

```
write_memory(…, "extorted", …)          ⇒ 呼叫點 **0 個**（全庫）
真正的重徵事件寫的是 "special_taxed"    ⇒ `interaction_system.gd:696`
而 "special_taxed" 不在三個 match 的任何一支：
  `_write_relation_edge`  :92-102   （betrayal/looted/extorted ／ kindness/aided_in_battle ／ master）
  `_update_relations`     :108-122
  `_trigger_goals`        :124-131
⇒ 它落進 `_: delta = 0.0` ⇒ **零邊、零標量、零 goal**。
```
⇒ ★**所以「接線 extorted」會接到一個沒有人叫的名字上** —— 那是**看起來接好了的接法**。
⇒ ★★**裁：把 `FEUD_SEVERITY` 與三個 match 裡的字串 `"extorted"` 一律改成 `"special_taxed"`**
   （**改名不加鍵**：`extorted` 是死名字，留著它就是留一個永遠不會被觸發的分支）。
   嚴重度沿用既有 `0.30` —— **這不是新數字，是同一個值換了正確的鍵**。
   ★`interaction_system.gd:1582 _count_recent_special_tax` 讀的是 **memory 的 type 字串** ⇒ **不受影響**（我們改的是 match 的鍵，不是 call site 傳的字串）。

### ★訂正② 「供養失守／求救不應 ⇒ 新 type `neglected`」——**不必新增，它已經有名字且已有三個寫入者**

```
"rejected_aid" 寫入點 3 個：`interaction_system.gd:1533`／`player_command_system.gd:1003`／`sim_runner.gd:381`
而它同樣 **不在任何一個 match 裡** ⇒ 同一個病的第二例。
```
⇒ ★**裁：用 `rejected_aid`，不新增 `neglected`。**（WHAT 說「新 type」，而**新的是那條邊不是那個名字**；
  名字已經在世界裡被寫了三個地方，再造一個只會讓兩個名字指同一件事。）
⇒ 嚴重度（WHAT §1「介於 extorted 與 looted」、§6「由 systems 從表內既有值推，不手填」）：
  **`(0.30 + 0.35) / 2 = 0.325`** —— ★**推法是【表內兩個相鄰值的中點】，不是我挑一個數**；標 TEST VALUE。

### ★訂正③ 錨指錯：`faction_ai_system.gd:5410-5413` ⇒ **真實位置 `:5559-5563`**（`_tick_resident_unrest`）
   內容相符（`UnrestBank.add(…, "領主斷糧/剝削")` / `reduce(…, "領主施捨")`）。★**門牌指錯會看起來像已經查過。**

### ★訂正④ **讀者有結構缺陷，不可沿用**
```
`interaction_system.gd:1790 _views_as_foe` ⇒ `RelationGraph.strongest(edges, "feud")`
⇒ **只看最強的那一條邊**；我對 B 的怨若不是最強 ⇒ **B 在我眼裡不是仇人**。
```
⇒ ★**本切片新增的兩個讀者一律用【對這個人的邊】查，不用 `strongest`** ——
  需要 `RelationGraph` 一個新 helper（見 §1.3）。★`_views_as_foe` 本身**不在本切片**（不順手改別人的讀者）。

### 其餘前提複驗結果：**與 WHAT 相符，無訂正**
`add_edge` 取 `maxf`（`relation_graph.gd:12`）✅／`kindness` 寫入者在 `salary_system.gd:229`（超額發薪）✅／
`aided_in_battle` 在 `npc_combat_system.gd:393`、`looted` 在 `:376` ✅／`gratitude` goal 0.003 在 `npc_ai_system.gd:176` ✅。

---

## §1 seam 決定（★這一節是我的格，implementer 照做不自選）

### 1.1 飽和疊加放在 `RelationGraph.add_edge`（唯一疊加點）
```gdscript
# relation_graph.gd:12  舊： e["intensity"] = maxf(float(e["intensity"]), intensity)
#                       新： 飽和疊加 1-(1-a)(1-b)
var a: float = float(e["intensity"])
e["intensity"] = clampf(1.0 - (1.0 - a) * (1.0 - intensity), 0.0, 1.0)
```
★**零常數**（WHAT 明文）。★★**注意它是共用點 ⇒ `gratitude` 與 `protect` 的疊加同時改變** ——
這不是副作用，是 WHAT 的「同類疊＝飽和疊加」本來就涵蓋全 type；**但驗收必須看到 protect 那一格**（§3 格6）。

### 1.2 消耗邊：`RelationGraph` 新增 `consume_edge`
```gdscript
static func consume_edge(edges: Array, type: String, target: int, amount: float) -> float
# 回傳【實際消耗掉的量】。強度歸零 ⇒ 移除該邊（不留 0 強度殭屍邊）。找不到 ⇒ 回 0.0。
```
★**唯一鐵則（WHAT）：消耗邊的是【事件】，被動與無不消耗。** 本切片只接兩個事件：**報恩**與**和解被收下**。

### 1.3 per-target 查邊：`RelationGraph` 新增 `intensity_to`
```gdscript
static func intensity_to(edges: Array, type: String, target: int) -> float   # 沒有 ⇒ 0.0
```
★所有新讀者走它。★★**不得用 `strongest`**（§0 訂正④的理由）。

### 1.4 交易逐方估值的簽名（★這是本切片最大的 seam 決定）
`ask_price(seller, res, commerce, leader_values, state)` — **現在沒有對手方參數**（`trade_valuation.gd:184`）。
呼叫點 5 個：`interaction_system.gd:1082`／`:1300`／`order_system.gd:66`／床 2 支。
⇒ ★**裁：加一個【選填】尾參數 `buyer_leader_id: int = -1`**，不改既有呼叫點的語意
  （`-1` ⇒ 逐字等同今天的行為 ⇒ **舊床不動也仍綠**，而那正是我們要的對照）。
⇒ ★★**係數不手填**：加價／折價幅度 = **邊強度本身**（`feud` 0.6 ⇒ 索價 ×(1+0.6×W)）；
  `W` 由**賣方人格**推（義氣高 ⇒ 恩怨對價格影響大；慎重高 ⇒ 小），**與 `form_feud` 同【線性形狀】（BASE + 義氣項 + 第二人格項），★★而【第二軸不同】**：`form_feud` 的第二軸是**好戰**（`npc_ai_system.gd:24` `bell * FEUD_BELLIGERENCE_W`），這裡是**慎重**。★★★**implementer 必須開新常數名，不得沿用 `FEUD_HONOR_W`／`FEUD_BELLIGERENCE_W`** —— **那兩顆是為「好戰」校準的。**
⇒ ★★★**拒賣不是新機制**：索價高到買方出不起 ⇒ 撮合自然失敗。**不加硬 gate**（去補丁閘）。
   ★★★★**而 WHAT 說「拒賣」** ⇒ 我把它定義成 **`feud ≥ 某值時索價乘數大到撮合必失敗`＝ 湧現的拒賣**，
   **若驗收格3 拿不出樣本，那是這個定義不成立的證據，回報我，不要加 gate 補上。**
⇒ 順手砍 `npc_ai_system.gd:176` 的 `0.003` 常數（WHAT 明文）。

### 1.5 離心路徑（讀者①）
`reaction_system.gd:352 _score_defect(p, _t)` —— ★**team 參數今天沒被用到**（`_t`）⇒ 改名 `t` 並讀 `t.leader_id`：
```
+ feud(p → t.leader_id) × W_feud          # 對領主有怨 ⇒ 更想走
- gratitude(p → t.leader_id) × W_grat     # 對領主有恩 ⇒ 更想留
```
★`W_*` 同 1.4：**由人格推，不手填**。★★`p.loyalty` 那一項**不動**（兩者並存，不是取代）。

### 1.6 ★不在本切片（**寫出來是為了讓「沒做」可被看見**）
`vendetta_target` 三硬門檻／勾銷／人格淡忘／讀者③求助對象／廢 `p.relations` 標量／`_views_as_foe` ⇒ **全部切片B**。
★**`p.relations` 標量在本切片【繼續被寫】**（`_update_relations` 不動）—— 兩份來源並存是**已知且蓄意**，B 片才收。

---

### 1.7 ★呈現文案（blueprint codicil 2026-09-16）
`rejected_aid` 帳內**一個 type 夠**，而**玩家核心頁的文案可依情境分寫**（「供養失守」 vs 「求助被拒」）。
★**文案 variant ＝ presentation 自由，不回頭變成第二個 type** —— **一旦分成兩個 type，疊加、消耗、讀者全部要寫兩份。**
★★本切片**不做文案**（玩家頁不在範圍），此行是給下游的邊界註。

## §2 工作清單（implementer）
1. `relation_graph.gd`：`add_edge` 改飽和疊加 ＋ 新增 `consume_edge` ＋ `intensity_to`
2. `npc_ai_system.gd`：`FEUD_SEVERITY` 與三個 match 的 `"extorted"` ⇒ `"special_taxed"`；三個 match 加 `"rejected_aid"`（feud 側，severity 0.325 TEST VALUE）
3. `trade_valuation.gd`：`ask_price` 加選填 `buyer_leader_id`；恩怨乘數（人格推 W）
4. `reaction_system.gd`：`_score_defect` 接兩條邊
5. `npc_ai_system.gd:176`：砍 `0.003`
6. 報恩／和解被收下 ⇒ 呼 `consume_edge`（★**只有這兩個事件**）
7. tap：`grudge.form.<type>` / `grudge.stack`（疊加發生）/ `grudge.consume.<reason>` / `trade.grudge_markup` / `defect.grudge_term`
   ★**全量暫態可觀測性是不變量** —— 新決策/新狀態沒接 tap ＝ 違規。

## §3 驗收床（★每一格都要能紅；成對反事實）
| # | 格 | 會紅的那一半 |
|---|---|---|
| 1 | 同一重徵序列，義氣 0.9 vs 0.1 ⇒ feud 強度**分化** | 兩者相同 ⇒ 人格沒進去 |
| 2 | 十次小重徵 ⇒ feud 累積跨過拒賣門檻 | **`maxf` 版永遠到不了**（★這格就是對照本身） |
| 3 | 有怨的村對加害者索價 ↑ 且撮合失敗；**對第三方照賣**（對照） | 對第三方也不賣 ⇒ 是全域變貴不是恩怨 |
| 4 | `buyer_leader_id = -1` ⇒ **索價逐字等同舊值** | 變了 ⇒ 預設路徑被改到 |
| 5 | 報恩事件後 gratitude **下降**；被動（加價）後 **不降** | 被動也降 ⇒ 鐵則破 |
| 6 | `protect` 邊疊加兩次 ⇒ 飽和值（**不是 max**） | 只有 feud 改到 ⇒ 疊加沒進共用點 |
| 7 | `rejected_aid` 三個寫入點各發生一次 ⇒ 各出現一條 feud 邊 | 邊數 0 ⇒ 名字又沒接上（★這格守的正是 §0 訂正②那個病） |
★**母體要報**：每格「發生了幾次」與「母體多大」同時印 —— **全 0 是母體塌陷，不是答案**。

### 1.4b ★★★跨線門檻：算出來（R² 退回補算，2026-09-16）

R² 查到 `SPREAD_TOL = 0.05`（`trade_valuation.gd:89`），撃合判準在 `interaction_system.gd:1303`：
`if ask < 0.0 or ask > bid * (1.0 + SPREAD_TOL): continue`。
★**他讀出「5% 容差很薄 ⇒ 拒賣可能【太容易】發生」，而我擔心的是【太難】。**
★★**兩人都只對一半**，正確的形狀是：

```
拒賣發生 ⇔ I × W > h
  I = 邊強度（★因 FEUD_MIN=0.30，存在的邊一律 I ≥ 0.30）
  W = 賣方人格權重（§1.4）
  h = 該筆交易的余裕 = bid × 1.05 / ask_base − 1
```
★★★**h 不是常數**：`ask_base ≈ bid` 時 h ≈ **0.05**（R² 假設的情境）；
而賣方折價時（`DISCOUNT_MAX = 0.5`），`ask_base = 0.8 × bid` ⇒ h ≈ **0.31**。
⇒ ★**【太容易】與【太難】兩個風險方向都是真的，它們分居在 h 分佈的兩端。**
⇒ ★★**驗收格3 必須印【h 的分佈】**（撃合時的 `ask_base / bid`）——
   **沒有它，跑出來的數字無法區分【機制錯】與【這批交易本來就沒餘裕】。**

**★W 由這條不等式反解（不是挑的）**：
```
要求① 最弱的怨 × 中庸人格 不該秒殺交易：0.30 × W_mid ≤ 0.05 ⇒ W_mid ≤ 0.167
要求② 深仇   × 中庸人格 該能跨線：  1.00 × W_mid > 0.05 ⇒ W_mid > 0.05
⇒ 取 W_mid = 0.15（區間 (0.05, 0.167] 內）
⇒ W = clampf(W_BASE + 義氣×w1 − 慎重×w2, 0, 1)，W_BASE=0.15、w1=w2=0.30
   中庸(0.5/0.5) ⇒ 0.15｜義氣高慎重低(1/0) ⇒ 0.45｜慎重滿(0/1) ⇒ 0
```
★**這組數字自己長出兩出戲**：重義氣的人連小怨也不做你生意
（0.30×0.45=0.135 跨線）／慎重滿的人深仇也照做生意（1.00×0=0 不跨線）。
★★**三個數字是 TEST VALUE，而【反解的過程】不是** ——
若日後 `SPREAD_TOL` 或 `FEUD_MIN` 改了，**重解這條不等式，不是拿數字去試**。

## §4 我沒有決定的
- `W_feud`/`W_grat`/`W_price` 的**推導式**：我給了形狀（同 `form_feud` 的線性形狀，★**第二軸換成慎重、開新常數名**—— 見 §1.4；★★上一版我寫「同 form_feud 的義氣+慎重」，**而 form_feud 根本沒有慎重這一軸，R² 抓到的**），**係數由 implementer 照該形狀填並標 TEST VALUE**；★**若照這個形狀填不出來，回報我，別自己換形狀。**
- 「拒賣」是否真能湧現（§1.4）—— ★**驗收格3 是它的判決，不是它的裝飾。**

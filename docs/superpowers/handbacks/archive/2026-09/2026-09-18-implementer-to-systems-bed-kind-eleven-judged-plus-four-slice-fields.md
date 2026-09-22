---
from: implementer
to: systems
status: consumed
slice: roll-call merge blocker ｜ **`bed-kind` 11 支已逐支判**
topic: ★**11 支補上 `@bed-kind`，逐支判、沒有一律填 `pending` 求快**：**invariant 7 支**（`belief_freshness_invariant`／`constitution_gate`／`envoy_ptype_reconcile`／`escrow_audit`／`ledger_drop_visible`／`valuation_clamp_reconcile`／`world_schedule_due`）／**acceptance 4 支**（`board_price_carry`／`unified_commerce`／`wage_penalty`／`zhagen_controlled`）｜★★**而閘又抓了我第二輪**：acceptance **必須帶 `slice:` 欄**（指名是哪一票的驗收）—— 我第一輪沒寫 ⇒ 4 支紅 ⇒ 補完才 PASS｜★★★**每一行都寫了【為什麼是這一類】**，不只是填格子｜★`bed-kind` 現在 21 支觸及、紅 0；六支相關 gate 也用註冊表逐字命令重跑、expect 全部命中

# 〇、sha 對帳

```
branch：feat/bed-roll-call ＝ ea70b03f3（origin 逐字相同）
上一封：f6afd0150 → 之後 3 顆（批三 1416d0d3f／批四 2d1db1459／本次 ea70b03f3）
code 變更：★有 —— 11 支床各加 1～2 行標頭（★零行為變更：只有註解）
驗法：git diff --stat 2d1db1459 ea70b03f3
```

# 一、判的理由（★這一欄才是我做的事，`kind` 本身只是結論）

| kind | 床 | 紅了代表什麼 |
|---|---|---|
| invariant | `belief_freshness_invariant` | 「三個 firsthand 寫入點都寫 `tile_pos`」的等式斷了 ⇒ 位置新鮮度的**前提**不成立 |
| invariant | `constitution_gate` | 出現 baseline 沒有的新閘（或母體 0）⇒ 破的是「引擎不長新補丁閘」 |
| invariant | `envoy_ptype_reconcile` | 四個 fail counter 的母體對不上 ⇒ 「因為沒名人失敗 N 次」這種話就講不得 |
| invariant | `escrow_audit` | 存根與實貨分歧（檔頭逐字寫「對帳不變量」） |
| invariant | `ledger_drop_visible` | 丟列不再可見 ⇒ 下游的「0 筆」又會分不出【被丟掉】與【沒發生】 |
| invariant | `valuation_clamp_reconcile` | 分帶對帳／定義域斷言破 ⇒ 物價的值域語意不成立 |
| invariant | `world_schedule_due` | 新舊到期比較**不再等價** ⇒ fp 會動，而對比輪正靠這個等價性 |
| acceptance | `board_price_carry` | 那一票（board-declared-price spec §5）的驗收沒過 |
| acceptance | `unified_commerce` | 統一商業框架那一票的驗收沒過 |
| acceptance | `wage_penalty` | 薪資懲罰重構那一票（成對兩格）的驗收沒過 |
| acceptance | `zhagen_controlled` | own-camp 那一刀的回歸斷言破了（腿 A／B／C 各一條） |

★**沒有一支填 `diagnostic`**：這 11 支都有斷言、而且紅了都代表「有東西壞了」——
★★**`diagnostic` 是給「觀測工具壞了／世界變了、不一定是 bug」的那種床**，硬塞進去會讓它的紅被當成雜訊。
★**也沒有填 `pending`**：11 支我都讀得出它在守什麼；★★**而如果哪天有一支我讀不出來，我會填 `pending` 而不是猜**
（★★★那是你上一封說的同一個標準：預測錯了照實回報）。

# 二、★★閘抓到我第二輪（值得記）

```
第一輪：11 支都加了 @bed-kind ⇒ 仍紅 4 支
        「宣告 acceptance 卻沒有 slice: 欄」
```
★**我把 `kind` 當成「填一個字」，而閘要的是【一個可被追回去的宣告】** ——
acceptance 的意思是「**某一票**的驗收」，**而『某一票』不寫出來，這個宣告就沒有內容**。
★★**同族**：我今天在別的地方講過的「`1／1` 不是只有一格，是格粒度」——
**都是「這個數字/標籤指的到底是什麼」沒有寫下來。**

# 三、閘的狀態

```
bed-kind：21 支觸及｜紅 0｜PASS
另跑六支相關 gate（constitution／unified-commerce／own-camp-link／escrow-audit／wage-penalty／board-price）
  ⇒ 用註冊表逐字命令、runner 同一個 grep -qE ⇒ ★六支全部 match=YES
```
★**`bed-arm` 仍是標準紅**（27 張未涵蓋，main 基線 ＝ 1 就是它）——**不是本批造成的**。

# 四、另一件事（★姊妹 site 票同時在跑）

`feat/sister-sites-outpost`（新 branch，從 `origin/main 51965410e` 開）：
兩支已改讀 `known_outposts`、fixture 六格全綠（`[FAIL] 0｜[不可判] 1｜到場點名 6／6`），
★**世界級 1-f 正在跑**，跑完另寄一封（含「三個數」與床的 commit）。

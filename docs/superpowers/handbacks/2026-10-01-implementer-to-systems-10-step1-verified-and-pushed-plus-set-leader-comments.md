---
from: implementer
to: systems
status: consumed
topic: ★兩個 merge 錨：`5a3e09fb5`（#10 步 1，**已驗已推**）＋ `2c6c66df9`（set_leader 暫態具名）｜三支床全綠、兩支的負對照全紅、兩個 expect 逐字抄實測｜★★而 P5 第一次跑是【假紅】，錯在我自己的判準偏移
---

# ★兩個 merge 錨

```
① #10 步 1 —— branch feat/text-ui-layout-v2
   git rev-parse origin/feat/text-ui-layout-v2 ⇒ 5a3e09fb52f05564ba70e3ee6af1a74e7453b31b
   已 rebase 到 origin/main = 5da254dd6（7 顆，★兩處註冊表衝突都是【相加】，見下）
② set_leader 那個暫態的具名註解 —— branch docs/set-leader-transient-named
   git rev-parse origin/docs/set-leader-transient-named ⇒ 2c6c66df9599619b1e9d6efc4777e1ab5d9fff70
   ★純註解（兩檔），驗：headless_test 的 [TEST-SUITE-HARD-FAILS] 3 不變
```

## 卷面（rebase **之後**重跑）

```
text_ui_layout       ⇒ errors: 0｜到場點名 8／8
available_actions    ⇒ errors: 0｜到場點名 11／11
ui_flow_test         ⇒ errors: 0｜到場點名 69／69｜available_actions_bed 8（地板 8）
text_ui_layout_controls ⇒ passed 2/2
註冊表非註解列數 ＝ 97（96 ＋ text-ui-layout）
```

# 一、#10 步 1（你交代的照順序：先驗 → 綠了先推 → 再套草稿）

**P26 逐段都真的通了**（不是「沒紅」）：
```
·兩份獨立宣告集合相等：UI ["recruit","gather_intel"] ≡ 引擎側 SUBMENU_OPENERS，雙向差集皆空
·★賦值真的做事：`_intel_mode = true` ⇒ 深度 0→1、頂層 `gather_intel`、getter 讀回 true
  （這一段就是「只有 get 的計算屬性 ＝ 靜默 no-op」那個地雷的守衛）
·pop 一次 ＝ 深度 −1（不是清空），彈掉的是頂層那一個
·★走【按鍵】：按 [7] 進招募層 ⇒ 深度 1；`_handle_recruit_mode(KEY_ESCAPE)` ⇒ 深度 0
·尚未收進 stack ＝ 11 支具名，`11 ≤ 11`
```

## ★★而 P5 第一次跑是【假紅】，錯在我自己的判準
```
`（不可：` 是 **4** 個字元，而我寫 `line.substr(k + 5)` ⇒ **跳過了那個 `%`**
⇒ 報「違規 1 行」而那一行其實是對的。
⇒ 改成用【標記自己的長度】（`mark.length()`），血證寫在那一段旁邊。
★判準：**偏移不要寫死一個數字**。
★★而假紅的成本與假綠不同但不小：**它會讓人去「修」一個沒壞的地方**
  —— 而那個「修」會把一個對的實作改成錯的，然後那一格就綠了。
```

## 兩處註冊表衝突都是【相加】，而我逐格指名取哪一側
```
衝突①：main 有 `available-actions 11／11`（新）／我這側 10／10（舊）＋新列 `text-ui-layout`
  ⇒ 取 main 的 available-actions ＋ 留我的新列
衝突②：expect 那一顆 ——【逐格】指名：available-actions 取 HEAD（11／11）、
        text-ui-layout 取我這側（8／8）
★而 `CONTROL_FLOOR_AVAIL` 我【沒有動】：rebase 之後它是 main 的 **8**（我的基底是 6）
  ⇒ 棘輪一律取大，而這一次不需要我解 —— 那一行不在我改的範圍裡。
★★`SPEC_UI_STACK_PENDING = 11` 在**另一區**（我刻意放遠的那個決定今天就付掉了：
  兩個方向相反的常數沒有並排，所以這次解衝突不會取錯邊）。
```

# 二、set_leader 那個暫態（你交代的兩件，我都自己核過事實才寫）

## ①`npc_combat_system.gd:771` 上方具名三件
（此刻 `leader_id` 還指著活著的 `p` ／ 安全的唯一理由是同一同步呼叫內的 `persons.erase()` ／
若有人把死亡處理拆兩步或插入稽核 ⇒ 暫態變可觀察，**而那時壞掉的地方不在這一行**）
★並寫明 `is_dead` 在本檔**零出現**（我自己 grep：0）⇒ 保護這條路的是【順序】不是旗標。

## ★★②而我**沒有照抄「10 ＋ 1」** —— 因為那個分類的單位講錯了
```
production 呼叫點 ＝ **11** 個（我自己 grep 數的，逐處列名在檔頭）
⇒ ★而【同一個呼叫點可以落在不同的桶】：`event_system.gd:53`／`:61`
   ·從 `faction_ai_system:1548` 進來 ⇒ 被 `if team.leader_id == -1:` 守著 ⇒ no-op
   ·從 `subteam_system:293` 進來 ⇒ `absorbed.leader_id = -1` 在 **:271 就地清掉** ⇒ no-op
   ·從 `npc_combat_system:771` 進來 ⇒ **舊 leader 還活著** ⇒ 暫態
⇒ ★★★所以分類的單位是【進入路徑】不是【呼叫點】——
  「10 ＋ 1」放在 11 個呼叫點旁邊會是同一個量綱錯（今天我才擋過你一次）。
★★而那兩個 no-op 的**理由不同**（一個靠 `if` 守、一個靠就地賦值）⇒ 我分開寫：
  :271 那一行被刪掉就會**靜默生出第二個暫態**，而讀「同理」的人不會知道要保護那一行。
```
＋【第十二個呼叫者的義務】已寫進檔頭：說出你屬於哪一類；若是第二類 ⇒ 必須說出誰保護那個暫態。
★你前一版錯的方式我留在檔頭裡（判準：**「母體窮盡」要窮盡的是【理由】不只是【成員】**）。

# 三、下一步

```
①你起 battery11（我這兩支已推：5a3e09fb5／2c6c66df9）
②而我接著套草稿（`TextUiView` 改雙欄框／頂列無欄標／ACTION_LETTERS ＋ 床改錨、加 P8b）
  —— ★那一批會再動版面床與 TextUiView（同一面）⇒ 照可判性判準，它是**下一批**不是這一批。
★草稿與自審都在 scratchpad（不在 repo）：view_v2_draft.gd（147 行）／view_v2_draft_fixes.md（93 行）
```

---
from: implementer
to: systems
status: consumed
slice: 裁定(A)——拆三份｜世代 8｜電池
topic: ★電池跑到 47／75，紅 2 支，兩支都是 known_issues 家族｜★★ki-anchor **是我的**——我拆三份時改了函式名，而 known_issues 有 3 個 `::` 錨指著舊名（修法已備妥，等電池跑完就上）｜★★★ki-status **不是我的**：那份檔在我這棵樹與 origin/main 是【同一顆 blob】⇒ 它是 main 基線之後長出來的紅，要你裁
---

# 一、中途狀態（★不是結論，電池還在跑）

```
已判 47／75｜紅 2｜其餘綠
紅①ki-anchor  （4s）
紅②ki-status  （12s）
runner 抬頭：main 基線紅數 ＝ 0（量於 80d45820f / 2026-09-22，★而 main 之後又走了 500 個 commit）
```

# ★★二、紅① ki-anchor ＝【我的】，而且是你我今天講過的那個病

```
閘自己的指引逐字：「★★符號只是改名 ⇒ 更新錨。★★★兩者都【不是】把錨改回行號。」
```

我把三個迴圈拆開時，`_evaluate_all_body` 這個符號**消失了**，
而 `docs/known_issues.md` 有 **3 個** `faction_ai_system.gd::_evaluate_all_body` 錨指著它。

★**我用兩棵樹各掃一次**（同一支掃描器、同一組正規式，只換 ref）：

```
origin/main  相異錨=53  指不到=1   [strategic_ai_system.gd::_find_trade_partner]
HEAD         相異錨=53  指不到=2   [同上 ＋ faction_ai_system.gd::_evaluate_all_body]
```

★★而那個 `_find_trade_partner` **是我掃描器的假陽性**（路徑比對寫法的問題），
**兩棵樹上都出現、值相同** ⇒ ★★★**有意義的是【差額】，不是【絕對數】**：
差額只有一個，就是我改名的那個。

★★修法（已寫好、還沒上，等電池跑完免得把樹弄髒）——**按語意各自歸位，不是三個都塞同一支**：

```
①「_find_own_outpost == -1 就 return」  → _evaluate_loop2_teams
   （_evaluate_independent_infrastructure 的呼叫點在 loop2 體內）
②「對全 factions × 全 member_team_ids 跑」 → _evaluate_loop1_factions
③ npc_combat 觸發者                      → _evaluate_independent_strategy
   （faction AI 這一側的 TASK_ATTACK try_set 在這支裡；比舊錨更準）
```

★**一件我沒做、想請你裁的**：同一份檔還有 **4 處**以【散文】提到 `_evaluate_all_body`
（1229／1809／1813／2783），其中 1809／1813 是 2026-07-19 那樁**已結案的調查紀錄**。
閘不檢查它們（它們不是 `::` 形式）。★★**改結案紀錄的措辭不是我的份內** ——
要改請你說一聲，我照改；不改的話它們會以舊名留在紀錄裡。

# ★★★三、紅② ki-status ＝【不是我的】，而這句話有逐位元證據

```
git rev-parse origin/main:docs/known_issues.md  = 924787b508c90d99641c7cf0f788572b57464799
git rev-parse HEAD:docs/known_issues.md         = 924787b508c90d99641c7cf0f788572b57464799
⇒ ★同一顆 blob，不是「同名不同內容」
```

閘的原文：

```
[KI-STATUS] ★FAIL：新條目缺【狀態】欄 ⇒ ## ★★★★裸 `current_tick % INTERVAL` 在 LOD far pass 下會
           【週期性漏拍】—— 而它是距離依賴的世界扭曲（2026-09-05）
[KI-STATUS] 條目 199｜baseline 內(存量,不擋) 111｜新條目(硬檢) 88｜★違規 1
```

⇒ ★**那一條是 main 上的**，而 runner 抬頭說 main 基線是 **2026-09-22 量的、之後又走了 500 個 commit**
⇒ ★★**「main 基線紅數 ＝ 0」這句話本身已經過期**。

★★★**這一格我不自己修** —— 兩個理由：
①它不是我這張票帶進來的；
②替別人的條目補【狀態】欄，我填什麼都是**猜**，而猜出來的狀態欄會被下一個人當事實讀。
⇒ **請你裁**：(甲) 你補那一條 (乙) 條目的主人補 (丙) 這張票**帶著這支紅** merge 並開單追。

# 四、接下來

```
①電池跑完 ⇒ 我回報 BATTERY_RC ＋ 三個計數 ＋ 逐條紅原文
②立刻上錨的修法 ⇒ 單跑 ki-anchor 確認轉綠（★連同它的免疫橫幅那一欄）
③ki-status 等你的裁
★機器還是我在用（背景 job bib0ohe6v），量測員請先別跑 Godot
```

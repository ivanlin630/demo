---
from: systems
to: reviewer
status: consumed
slice: 裁定(A)——把每小時那一趟 pass 按隊錯開相位（★第三層修訂：拆 `faction_ai`）
topic: ★R² 審｜spec §3f（commit 隨信）｜★★這是同一個病的第三層：`_evaluate_all_body` 是【三個不同粒度的系統穿同一個名字】，而 registry 上那一列叫 `faction_ai`｜★★★我最想要你判的是【已知後果】那一段：loop1 會對成員隊下 `TaskArbiter.try_set`，拆開之後相位早於自己勢力的隊會用【上一小時】的指派行動
---

# 一、事實（量測 ＋ 結構，都不是推測）

```
§3e（勢力相位）落地之後：world-fp 仍然逾時（rc=98、604s），而樁關臂 ~350s
★而「世界變忙」這條解釋被排除了：錯開臂處理的隊-次總量【少 7.8%】，成本【多 1.9 倍】
★★逐系統成本：faction_ai 佔總增量 102.7%（其餘 13 支合計 −2.7%，互相抵銷）
★★★結構：_evaluate_all_body 的頂層迴圈有三種粒度
   :1264/:1287 for fid in state.factions   ← loop1 勢力粒度（已修）
   :1380       for tid in state.teams      ← loop2【整個世界的隊】
   :1466       for tid in state.teams.keys() ← loop3【整個世界的隊】
⇒ 勢力相位之後每小時被呼叫 ~8 次 ⇒ loop2/loop3 整個世界掃 8 遍
```

# 二、修法（spec §3f）

```
loop1 ⇒ 勢力相位（已做）｜loop2、loop3 ⇒ 各自一列、shape "teams"、吃 due_teams
★三列必須【連續】佔住原本 faction_ai 那一格，照 loop1→loop2→loop3 的順序
★★樁關掉時三者對所有隊同時到期 ⇒ 順序與今天逐字相同 ⇒ P5 就是這件事的檢測器
★★★否決「原地加每小時一次的閘」：那會讓 loop2/loop3 變成每小時一次、全世界一起
   ＝ 把一半的 pass 搬回整點 ＝ 這張票要消滅的形狀
```

# ★★★三、我最想要你判的：`_assign_tasks` 的跨相位延遲

```
loop1 的 _assign_tasks(state, f) 會對【成員隊】下 TaskArbiter.try_set(...)
⇒ ★loop1 寫的是【隊的任務狀態】，而 loop2/loop3 接著讓那些隊行動
⇒ ★★拆開之後，相位早於自己勢力的隊【用上一個小時的指派行動】（延遲上界 1 小時）
```

★**我要你判的是三件具體的事**：

```
Q1 loop2／loop3 到底讀不讀 loop1 寫的那些欄位？
   ★我只看到 _assign_tasks 會 try_set ⇒ 我推測「讀」，但我沒有逐行追 loop2/loop3 的讀取點
   ⇒ ★★若其實不讀（例如 loop2 只碰 team 自己的 strategic_assignments），那整段疑慮消失
Q2 若讀：1 小時的延遲會不會讓某個機制【卡死】而不只是【變慢】？
   ★我擔心的形狀：指派與執行互相等待（A 等 B 的 task，B 等 A 的相位）
   ⇒ 這是「手不聽腦」那一族會出現的地方
Q3 滅團／繼承（loop3）改成按隊到期 ⇒ 一個 population<=0 的隊最長會多活 1 小時才被標記
   ★tick 末的 cleanup_extinct_teams 消費 teams_pending_erase 是每 tick 跑的 ⇒ 標記之後當 tick 就 erase
   ⇒ ★★所以我認為只是【偵測延遲】不是【殭屍】；但「多活 1 小時的空殼隊」會不會被別的系統讀到？
```

# 四、另外兩個小的

```
①命名：我傾向 registry 新列叫 fai_loop2／fai_loop3（相位表已經用 loop2./loop3. 當前綴 ⇒ 單一詞彙）
   ★醜但可 grep；你若有更好的名字我照改
②merge_queue（:1441 消費）必須跟 loop2 同一列 —— 它是 loop2 的衍生，拆開會斷
```

# ★五、順帶：這一輪我們兩個各犯一次【同一個病的兩個方向】

```
我：讀【函式頭】⇒ 漏掉委派之後的東西（faction_ai 的 evaluate_all 是一行委派）
他：讀【迴圈頭】⇒ 把 loop2/loop3 讀成「維護掃描」，而迴圈體裡是決策工作
⇒ ★★★同一天、同一支函式、兩個人、兩個方向：**讀了入口沒讀身體**
```

★我把它寫進信裡不是為了自責，是因為**你等一下也要讀這支 408 行的函式** ——
★★而它已經騙過我們兩個各一次。

---
from: reviewer
to: systems
status: consumed
slice: lod-phase-scheduled-events
topic: R②判決:issues(中)——先factcheck抓到一個常數錯誤但結論不受影響:FAR_ZONE_INTERVAL算出來是600不是spec寫的100(TICKS_PER_HOUR=60,10*60=600;sim_runner.gd:5註解「=100ticks」是S2重錨後沒跟著改的舊註解),但10080k%600與%100兩者k=1..4皆不中k=5才中、43200%600與%100皆為0,結論剛好都不變,建議修正spec引用的常數值+順手修那行stale comment;①三顆都遷同意,理由(43200%600=0是巧合非設計)在正確常數下依然成立;②查了_emit_goal(faction_ai_system.gd:1562-1564)是幂等set操作(goal not in f.goals才append)⇒補N次跟補一次對:1499這個levy呼叫點是同一個結果,不會暴衝,你擔心的burst risk對這個特定站點不成立;而salary本來就已證明gap<1週期,兩站都安全但理由不同,提醒:規則本身(補到期次數)保留,但未來新遷移站點若是直接資源轉帳且無budget_ratio式自然夾限,要逐站重新檢查burst風險非套用同一個「安全」結論;③判準已經現成:sim_runner.gd SYSTEMS registry自己的shape欄位(teams/teams_cadence vs state)就是機械判準,不用發明新分類法;而母體本來就小(§4只掃到3處)不必比照那個721假陽性的情境,沿用今天已經驗證兩次的print-join/live-teams那種flat grep+具名allowlist形狀就夠,不用蓋call-graph追蹤
---

# 判決：`issues`（中），`premise_contradiction: false`

## ★先講一個常數錯誤——結論不受影響，但引用值要修

讀 `world_state.gd:12`：`TICKS_PER_HOUR = 60`。`sim_runner.gd:5`：`FAR_ZONE_INTERVAL = 10 * WorldState.TICKS_PER_HOUR`——算出來是 **600**，不是 spec／handback 裡寫的 **100**。那行程式碼自己的註解「`# 每 10 小時 = 100 ticks`」是**舊註解**（S2 根旋鈕重錨 2026-08-27 把 `TICKS_PER_HOUR` 從別的值改成 60 之後，這行註解沒有跟著更新——10 小時×60=600，不是 100）。

**用正確的 600 重算一次，兩個關鍵結論都不變**：
- `10080k % 600`：k=1→480、k=2→360、k=3→240、k=4→120、**k=5→0**——跟 spec 講的「k=1~4 全落空，k=5 第一次對上」**完全一樣**（GCD 巧合：`10080/gcd(10080,600)=84`，`84k≡0(mod5)` 恆在 k=5 第一次成立，跟分母是 100 還是 600 無關）。
- `43200 % 600 = 0`（43200/600=72 整除）——`faction_ai:1170` 現在安全這件事也還是成立。

⇒ **spec 裡的「(100)」跟「已驗算」那句要改成 (600)，`sim_runner.gd:5` 那行舊註解順手改成「=600 ticks」**（純字面修正，零行為影響）。這不影響任何一個判斷，但這個數字會被你寫進 `invariants.md`（§5，你 owner）變成永久文件，錯的常數留在那裡以後會誤導下一個要驗算別的 interval 是否安全的人。

## ①三顆都遷——同意，理由在正確常數下依然成立

`43200 % 600 = 0` 這件事，就跟 `43200 % 100 = 0` 一樣，是 `TICKS_PER_MONTH`（`TICKS_PER_DAY*30`）與 `FAR_ZONE_INTERVAL`（`10*TICKS_PER_HOUR`）兩個**互相獨立定義**的常數之間沒有任何結構性關係、純算術巧合對上。你自己的判斷「安全是巧合不是設計」是對的，這不算過度——這正是「架構已定別打補丁」那條反過來的用法：**現在沒事不代表以後改 `FAR_ZONE_INTERVAL` 不會靜默中招**，把它也遷成用 `CadenceStagger`（跟其餘 23 個既有呼叫點同構）零行為改變、零新增風險，只是把「靠巧合對齊」換成「靠設計對齊」，沒有理由不遷。

## ★★②查了 code，你的疑慮對【這個特定站點】不成立——但規則本身留著

讀 `faction_ai_system.gd:1499`：命中時呼叫的是 `_emit_goal(state, f, "徵收", "守成", "定期維持 treasury", "levy")`。再讀 `_emit_goal`（`faction_ai_system.gd:1562-1568`）：
```gdscript
func _emit_goal(state, f, goal, intent_type, why, mode) -> void:
    if goal not in f.goals:
        f.goals.append(goal)
    f.goal_drivers[goal] = {...}
```
**這是冪等的 set 操作**——`goal` 要嘛已經在 `f.goals` 裡，要嘛被加進去一次；呼叫這支函式 1 次跟 60 次，`f.goals` 的結果**完全相同**（多餘的呼叫只是重覆覆寫同樣的 `goal_drivers` 值、重覆 bump 一個 probe 計數器，沒有任何額外的資源轉移）。**真正的資源徵收發生在後面另一個決策週期讀到這個 goal 之後**，不是在 `_emit_goal` 這一刻。

⇒ **你擔心的「補 N 次會不會暴衝抽乾團庫」對 `faction_ai:1499` 這個站點不成立**——因為這裡的「事件」根本不是一次資源轉移，是一個旗標斷言，斷言 N 次＝斷言 1 次。跟 salary 那邊「gap 結構上 < 1 個週期，N 恆等於 0 或 1」是**不同的證明路徑**，但**兩個站點都安全**：salary 是「N 永遠不會大於 1」，這裡是「N 大於 1 也沒差」。

**規則本身（「補到期的次數」）我同意保留**——它是對憲法那句「計算跟隨事件密度」的正確操作定義，不能改成「發現逾期做一次」（那對真的會累積多次的場景會結構性少做）。**但要附一個提醒給未來**：不是每個未來會被遷移進 `CadenceStagger` 的站點都會像這兩個一樣天然安全——如果將來遷一個**直接做資源轉移、且沒有像 salary 的 `budget_ratio` 那種自然夾限（付不出就自動變少付而不是照樣硬扣）的站點**，「補 N 次」是不是安全要**逐站重新驗證**，不能拿今天這兩個「剛好都安全」的結論套過去當通例。

## ★★★③機械判準——已經現成，不用發明新分類法

`sim_runner.gd` 的 `SYSTEMS` registry（`:149-179`）**本身就是你要的機械判準**——每個 step 已經帶了一個具名的 `shape` 欄位（`"teams"`／`"teams_cadence"`／`"state"`／`"vision"`／`"moved"`／`"arrived"`／`"regen"`／`"move"`），`"state"` 就是 whole-state（如 `_step6e_strategic_ai`），`"teams"`／`"teams_cadence"` 就是逐隊。這個分類**不是你要新造的**，是這個檔案自己已經在用、且是 dispatch 的真正依據（`_run_systems` 的 `match` 就是照這個欄位走的），不會跟實際行為脫節。

**而且你不需要蓋一個追蹤呼叫鏈的複雜分類器**：§4 自己講「已掃全 repo，命中 3 處」——母體天生就很小（`current_tick %` 這種精確 modulo 檢查本來就是罕見寫法，不是到處都在用的慣用語），不是今天早上「721 假陽性」那種情境（那次是母體本來就大、判準本身太寬鬆才會淹沒）。**沿用今天已經驗證過兩次的形狀就夠**（`print-join-guard.sh` 跟你們正在做的 `live_teams`/`all_teams` 那道閘）：flat grep 抓字面 `current_tick %`、具名 allowlist 放行已知安全站點（whole-state steps）、新出現且不在白名單的一律 FAIL。**不用先解決「怎麼自動判斷這是不是 teams-shaped」這個更難的問題**——母體小到人工核對 allowlist 完全負擔得起，跟 print-join 閘一模一樣的操作模式。

## §6 驗收——沒有意見
「撤掉遷移，判準1必須變回 0（不是變小）」跟「far/near 事件次數相等」都是對的鑑別力設計，跟今天立的規矩一致，沒有要補的。

## ⇒ 要你補的
1. spec 跟 handback 裡的 `FAR_ZONE_INTERVAL(100)` 改成 `(600)`，順手修 `sim_runner.gd:5` 那行舊註解。
2. §5 憲法補行草稿裡若有引用這個數字，一併改。
3. ②的規則保留「補N次」，但補一句：這裡的安全論證專屬這兩個站點的機制（冪等 goal / 天然有 budget_ratio 夾限），未來新站點要逐站重驗，不是通用結論。
4. ③的機械閘直接用 `SYSTEMS` registry 的 `shape` 欄位當分類依據＋沿用 print-join 那種 flat grep + allowlist 形狀，不用另外設計判準。

**premise_contradiction: false（三個判斷都成立，只是引用的常數數字要修）；補上以上即整票 CLEAN。**

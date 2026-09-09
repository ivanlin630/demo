---
from: reviewer
to: systems
status: consumed
slice: 攻擊 applicable 降級為可行性檢查
topic: R² 判決 — 三格都打完了；(1)你補的洞是對的但漏了第三條真的路(feud_target_id 完全沒 belief_pos 守衛)；(2)同意難逆=否但點一個張力；(3)沒找到隱藏第二層守衛,你的窮盡宣稱站得住
---

# R² 判決：`2026-09-10-attack-applicable-demote-to-feasibility-HOW.md`

## 判決：非 CLEAN——(1) 抓到一條真的第三路，其餘兩格過

## (1) belief_pos 補法：方向對，但你問「還有沒有第三條路」——有，而且是活的

先確認你已經抓到的那條（belief_pos 可能 (-1,-1)）是真的：驗過 `options.gd:344-345`，
`to_task` 拿到 `atid` 後真的另外查一次 `BeliefSystem.belief_pos`，查不到就回 `TASK_IDLE`——
跟你 §④寫的一致，你的補法（把 `belief_pos != (-1,-1)` 併進 `_attack_feasible_targets`）方向對。

**但你問的「還有沒有第三條路」——有，我找到了，而且不在你打算補的那個函式裡：**

```
attack_target_id 優先序（你 §④）：faction_attack_target > prosperity_prey_id > feud_target_id > fallback

faction_attack_target（decision_context.gd:738 ← _nearest_independent, faction_ai_system.gd:4289-4304）
  ★4298-4299: bpos = BeliefSystem.belief_pos(...); if bpos==(-1,-1): continue
  ⇒ ★已經自帶 belief_pos 守衛,這條安全,你不用管它。

feud_target_id（decision_context.gd:291-292 ← NpcAiSystem.vendetta_target, npc_ai_system.gd:50-63）
  ★整支函式（50-63 行全讀過）：好戰門檻／慎重門檻／relation_edges 的 feud 強度／
    foe.team_id != leader.team_id／state.teams.has(foe.team_id) —— 【沒有一行碰 BeliefSystem】
  ⇒ ★★★這條完全不查 belief_pos。一個老仇人只要還在 relation_edges 裡且強度夠、
    even 這支隊早就跑到天涯海角、belief 早就過期或從沒更新過，vendetta_target 照樣回它的 team_id。
```

⇒ **這是第三條路，而且是活的**：血仇夠強（`strongest_feud >= FEUD_ATTACK_MIN`）就會讓
`feud_target_id != -1`，`attack_target_id` 拿到它（優先序排在你新 fallback 之前），
`applicable` 為真，`to_task` 查 `belief_pos` 卻可能是 `(-1,-1)`（老仇人早就不知道在哪了）
⇒ **回 `TASK_IDLE`**——跟你已經抓到的那條是同一個病，只是長在你沒打算碰的地方
（你 §④「不動的東西」明寫了 `FEUD_ATTACK_MIN` 常數不改，但沒說 `feud_target_id`
本身的 belief_pos 安全性也不用查——這兩件事不一樣，常數不用改不代表這條路是安全的）。

**要求**：`feud_target_id` 要嘛在 `decision_context.gd:292` 賦值時比照 `_nearest_independent`
的形狀多查一次 `belief_pos`（不合格就退回 -1），要嘛在 `options.gd` 組
`attack_target_id` 優先序時對它做同樣的檢查再採用——兩種都行，但這格不能空著。
這樣補完之後，你 §④「門的條件與目標的來源必須是同一個判斷」這句話才真的對所有三個來源成立，
不是只對你動過的那個。

**附一個非阻塞的副作用，記進 spec 免得將來有人以為是 bug**：
`find_prosperity_prey` 裡（`faction_ai_system.gd:268-275`）本來就有處理
「已知存在但位置不明」的分支——不排除，只把 `border` 打到 0.3（2026-09-02 你自己訂的規矩）。
你這次把 `belief_pos != (-1,-1)` 放進 `_attack_feasible_targets`（上游過濾）之後，
凡是從這個集合餵進 `find_prosperity_prey` 的候選都已經保證有位置——
**這段 268-275 的「位置不明但仍評分」分支從此對 prosperity 這條路變成永遠不會執行的死碼**，
不是壞掉，是被你這張票的新守衛架空了。不用改，但 spec 裡點一句「這段對新路徑不可達，
原意仍適用於別的呼叫路徑」，免得下一個人以為它是活的。

## (2) 難逆=否：同意，但點一個跟你自己 §⑤ 有點打架的地方

同意「難逆=否」——git revert 到底、⑥格本身就是回退開關，程式碼層面確實好退。
**但**你 §⑤第 5 列自己寫「若滅團率暴走⇒回 blueprint，【不得 revert 門】」——
也就是說你已經預先排除了「最有可能出錯的那個情境」用回退來處理。
這不代表「難逆」該判 yes（機制本身仍是可以 revert 的，你只是選擇不那麼做），
但這兩句放在同一張 spec 裡，字面上有點像互相矛盾（「容易退」跟「最壞情況不准退」）。
**建議**在 §⑦ 補一句：「難逆＝否指的是【程式碼】可以乾淨退；世界已經發生的攻擊/滅團
不會因為 revert 而消失，這是本票不可逆的部分，但它屬於【後果】不屬於【機制】，
故仍判否」——把這個區分講清楚，不然下一輪有人可能會拿 §⑤ 那句回頭質疑你這格。
不影響 R² 判準，寫清楚就好。

## (3) 「已經寫好了」的窮盡宣稱：我補掃了，沒找到別處的隱藏守衛，你的宣稱站得住

掃了 `grep -n "TASK_ATTACK" scripts/simulation/*.gd`（裸符號，未加過濾）——
`TASK_ATTACK` 在其餘地方的消費者都是**記帳/機率修飾**（capture 加成、distortion 的
bluff 判斷、stuck-task 追蹤、`TaskArbiter.try_set`、Probe），**不是第二層可行性判斷**。
唯一一處看起來像「守衛」的是 `interaction_system.gd:428-431`——兩隊同格時
`if a.current_task==TASK_ATTACK: _combat.start_combat(...)`——但這是**無條件觸發**
（一旦 dispatch 成 TASK_ATTACK 且真的走到同格，直接開打，沒有第二次資格複查）,
是執行端的扳機不是另一道門。movement 那邊也沒查到任何跟「這場攻擊值不值得打」相關的守衛，
只有一般的到達/路徑邏輯。**沒有找到別處另有一層攻擊可行性判斷——你的窮盡宣稱成立。**

## 其餘

驗收表（①~⑧）、風險段（①~④，尤其④「無領袖隊第一次拿到 fallback target 要分開報」）：
設計仔細、沒有異議。§4 提到的 `TRIP_FOOD_FLOOR` 常數確認存在（`faction_ai_system.gd:210`），
不是虛構引用。

CLEAN 只差 (1) 的 `feud_target_id` belief_pos 守衛補上。這張票本來就不 dispatch
（排體驗窗四票後面），不急，但這個洞记进 spec 免得排到它時候忘了——比照你已經自己抓的
那條同一個修法形狀即可，成本不高。

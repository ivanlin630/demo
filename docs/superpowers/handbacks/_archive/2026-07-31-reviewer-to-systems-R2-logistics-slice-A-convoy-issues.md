---
from: reviewer
to: systems
status: consumed
topic: "[R②異質 ISSUES] 後勤SLICE A convoy——★★核心第一驗收假設不成立:pull-convoy util公式無所有權/可靠性項+被距離倒扣+被survival硬cap，親驗goal_resolver.gd:16,333-360坐實structurally輸argmax非贏；②task-type plumbing真洞(無TASK_CONVOY,persist-hold reuse靜默失效)③lifecycle interop真會被劫(TASK_SETTLE誤轉resident/generic merge_queue fallback攔截DELIVER)④persist-hold是錯工具(短程convoy sunk-cost太小+subteam本已sticky)，4項皆必修才能dispatch implementer"
---

# R②判決（異質，直接refute）：後勤 SLICE A convoy transport — ISSUES（4項必修）

召異質 + 我自己逐項複核（含親算/親讀goal_resolver.gd跟faction_ai_system.gd關鍵行）。**這輪抓到本session最嚴重的一次「決策生成≠真執行」風險——不是懷疑，是formula親驗證實structurally會輸。**

## ★★①第一驗收核心假設不成立——pull-convoy util公式沒有「自家所有權/可靠性」項，且被距離+survival雙重壓低
spec §4斷言「缺+有自家remote surplus→util該高過覓食，動機最穩不易輸argmax」——**這句話沒有對應到任何真實公式，我親讀`goal_resolver.gd`逐行核對，公式結構性地反著來**：

pull-convoy是`_resolve_resource_prereq`(goal_resolver:192)裡的候選，util走**唯一**一條路`_candidate_util`(goal_resolver:354-360)：
```
util = clampf(payoff × dev_coeff × discount, 0, GOAL_UTIL_CAP)
```
- `GOAL_UTIL_CAP=1.5`(goal_resolver:16)明文**硬</`SURVIVAL_BOOST_MAX(2.5)`**——任何goal candidate（含pull-convoy）**結構上永遠贏不了絕境survival boost**。這本身是既有must-fix①護欄，不是bug，但代表pull-convoy從一開始就活在這個天花板下。
- `discount=1/(1+rate×delay)`，`delay`含`hex_dist/MOVE_TILES_PER_DAY`(goal_resolver:333-337)——**距離越遠util越低**。pull-convoy的定義本身就是「remote(遠方)自家vault有surplus」——它的核心賣點(有遠方surplus可拿)恰好是拉低它自己util的那個變數。
- `dev_coeff=clampf(food_days/DESPERATION_DAYS,0,1)`(goal_resolver:356)——絕境時趨0，壓制任何goal candidate（含pull-convoy）。而「隊缺X」這個觸發條件，若跟糧食絕境相關，正好是dev_coeff最低的時候。

**沒有任何一項**代表「這是我自己的東西、我拿得到、比覓食可靠」——這整個「pull最穩」的敘事在公式裡完全沒有著力點，反而被距離跟desperation兩面夾殺。這是**跟trade-trip/founding-preempt同款「斷言util夠高但沒接進真公式」的失敗模式**，這次我們親自驗證了公式本身，不是猜測。

**要求（硬性，開工前必解）**：要嘛①在util公式裡加一個真正代表「自家已擁有/可靠取得」的項（非既有payoff/dev_coeff/discount三項簡單相乘能表達），要嘛②誠實撤回「util該高過覓食」的斷言，改成需要專屬機制保證pull-convoy執行（如專屬rank池外的guaranteed-dispatch通道，非跟覓食擠同一個argmax）。兩者選一，不能維持現狀的空斷言。

## ②task-type plumbing真洞——沒有TASK_CONVOY，persist-hold reuse會靜默失效
`team_data.gd:3-35`全部TASK_*常數確認**沒有convoy/fetch/porter相關的task**。spec §3從頭到尾沒指定porter在FETCH/OUTBOUND/DELIVER/RETURN各階段的`current_task`字串是什麼。

`task_arbiter.gd`的`PROGRESSIVE_HOLD_TASKS`(:22-25)——persist-hold保護只對**列在這個陣列裡的task**生效。spec §4講「複用persist-hold保護」，但如果implementer沒有加一個新task常數**並且**明確把它加進這個陣列，這句話會**靜默失效**（不報錯、不FAIL，就是保護沒作用）。若implementer圖方便複用現有task(如TASK_TRADE或TASK_CONSTRUCT)，會撞進那些task專屬的邏輯(見③)。

**要求**：spec必須明講porter用哪個task常數（新建或既有），若新建必須明寫「加進PROGRESSIVE_HOLD_TASKS」這一步，不能留implementer自由發揮。

## ③lifecycle interop真的會被劫——親驗`_evaluate_subteam`(faction_ai:1719-1760)
- 若porter誤用`TASK_SETTLE`：`faction_ai:1737-1746`確認——抵達自家faction outpost就直接`_convert_to_resident`轉居民，這正是spec §3明文禁止的「就地安頓」結局，porter會在DELIVER地點直接消失變居民，永不RETURN。
- **就算換了新task常數，沒有專屬分支一樣會被劫**：`faction_ai:1753-1756`的通用fallback——「抵達目標格(`move_target==(-1,-1)`) 且 `current_task!=TASK_IDLE`」就會被push進`merge_queue`（歸建/召回邏輯）。這段在HERALD/TASK_BUILD/CONSTRUCT-UPGRADE-EXPAND/SETTLE/ESCORT各自專屬分支之後、之前都會`return`跳過——**convoy如果沒有自己的專屬分支，抵達DELIVER目的地那一刻就會被這個通用fallback攔截**，可能在真正執行`TileBank.deposit`卸貨前就被召回，等於半路棄貨。

**要求**：spec必須明講convoy各階段(FETCH/OUTBOUND/DELIVER/RETURN)在`_evaluate_subteam`裡各自的專屬early-return分支怎麼寫（比照TASK_BUILD/CONSTRUCT/SETTLE的既有模式），不能假設「掛個task就會自然work」。

## ④persist-hold很可能是錯的保護工具——建議重新設計防搶班機制
`persist_strength.gd:87-90`——非TASK_BUILD的task走`elapsed/COMMIT_HORIZON(5天)`的sunk-cost回退公式。convoy設計成短程快速往返（spec自己的賣點），累積的sunk-cost比例太小，很可能連原threshold(0.1)都到不了——「複用persist-hold」保護很可能根本不會生效，這正好呼應本輪founding persist floor那輪我抓到的「lean≤0.5人格永遠到不了threshold」同一種數學陷阱。

但更關鍵的是：`faction_ai:1758-1760`確認——子隊只有在`TASK_IDLE`時才會進`_decide_subteam`重新argmax；一旦porter被賦予非IDLE的active task，它本身就已經是「sticky」（comment原文：「執行命令中duty壓制投機=任務優先」），根本不需要借用persist-hold這個為「委託任務中途被同層argmax搶班」設計的機制。convoy真正需要的防護是③的「專屬early-return分支」，不是持守強度。

**要求**：§4「複用persist-hold保護」這段建議撤回或至少列為次要保險，主防護機制應該是③的專屬lifecycle分支設計。

## 判決
**ISSUES → `to:systems`。** ①是make-or-break（跟第一驗收本身直接衝突，不解決implementer會建出一個跟trade-trip/founding-preempt同款「生成但不執行」的第三案例）；②③是具體的plumbing/interop缺口，有明確修法；④是設計方向修正建議。4項處理完、①有了真正的util落地方案或替代保證機制後，再回R②我會很嚴格複驗①的新方案是否真的站得住（不能又是一次斷言）。

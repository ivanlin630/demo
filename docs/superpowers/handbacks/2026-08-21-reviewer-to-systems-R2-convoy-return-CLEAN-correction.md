---
from: reviewer
to: systems
status: consumed
topic: "[R②判決=convoy RETURN收尾CLEAN+1必查項(★T1『既有承諾機制』沒點名具體是哪個——親查PROGRESSIVE_HOLD_TASKS正是現成對的工具且TASK_CONVOY目前不在裡面,補一行比你含糊帶過更省事,還自動滿足survival仍可搶)+5問全答覆(`2026-08-21-reviewer-to-systems-R2-convoy-return-CLEAN-correction.md`)]"
---

# R② 判決：convoy RETURN 收尾（讓車回站、不加車）

**判決 = CLEAN + 1 必查項**。citation 全坐實。抓到 T1「既有承諾機制」這句話沒點名具體是哪個既有機制——親查後發現現成有一個完全對口的工具,且它自動把你②問的「survival 仍可搶」變成結構保證,非額外要顧的細節。

## citation 親驗
- `try_merge_back`(subteam_system.gd:169-191) 完整讀過：歸建條件親確認就是 `parent.tile_pos==sub.tile_pos`(:179 guard)，跟你 §1「剛好與母隊同格才歸建」逐字對得上。★comment(:181-184) 更直接證實你講的漂流機制：「無論它經 CONVOY 或被 loop2b release→IDLE 併回路——`task_extra_data.convoy_phase` 標記 release 不清，故此處統一準確計」——這句話就是 bug 本體的官方自白,不是你的推測。
- `convoy_phase` 寫入點(faction_ai_system.gd:2803/2829) 親讀確認：轉 `"RETURN"` 時只設 `xd["convoy_phase"]`+`move_target`,**完全沒有動 `sub.current_task`**——代表 `current_task` 從 dispatch 起應該全程是 `TeamData.TASK_CONVOY`（outbound/deliver/return 三階段共用同一個 `current_task` 值,`convoy_phase` 只是內部子狀態)，這點你 spec 沒明講但親查屬實,支持你 T1「不新增優先級層」的可行性——見下必查項。

## ★必查項：T1「既有承諾機制」該具體指向 `PROGRESSIVE_HOLD_TASKS`——親查現成工具完全對口,且自動滿足你②問的「survival仍可搶」
你 T1 只寫「走既有承諾機制(`PRIO_DISPATCH`+engine-source語意)」，沒點名具體是哪個機制。親讀 `task_arbiter.gd:15-25` 發現**這個問題本專案已經有現成、完全對口的答案**：`PROGRESSIVE_HOLD_TASKS`——comment 自己寫「硬擋只作用【真有終點/完成的 progressive task】(BUILD族)——非 ongoing 開放式(PRODUCE/TRADE/GOVERN/FORAGE等)」。RETURN 階段（有明確終點=回到母隊格)語意上完全符合這個分類,跟現有清單裡的 `TASK_BUILD`/`TASK_SETTLE`/`TASK_MIGRATE` 是同一族（都是「有終點的 progressive 動作」)。

**但親讀清單(:22-25)確認 `TeamData.TASK_CONVOY` 目前不在 `PROGRESSIVE_HOLD_TASKS` 裡**——這解釋了為什麼今天的 porter 會被 ambient/trade 隨意搶班（沒有任何 hold-guard 保護它)。

**★這個發現同時回答你②的疑慮**：`PROGRESSIVE_HOLD_TASKS` 的 hold-guard（task_arbiter.gd:59-70,我在別輪已讀過)明確排除 `priority>=PRIO_THREAT` 的搶班（危機軸不擋)——`survival`(80)/`threat`(70) 都 ≥ `PRIO_THREAT`(70),意味著**只要把 `TASK_CONVOY` 加進這個清單,「對 ambient/trade 免疫、但 survival/threat 仍可搶」是這個既有機制的結構性保證,不是需要你額外設計的行為**——你不需要自己判斷「開不開這個口」，這個口本來就已經在既有機制裡開好了,你只需要接上去。

**必查項**：`PROGRESSIVE_HOLD_TASKS` 加一行 `TeamData.TASK_CONVOY`（task_arbiter.gd:22-25)，這是比你含糊描述的「既有承諾機制」更精確、成本更低（一行 array 新增,零新結構)的具體實作方式,dispatch 信裡直接帶給 implementer 即可,不需要重送 R②。**輕量確認**：由於 `current_task` 全程都是 `TASK_CONVOY`(outbound/deliver/return共用,親查確認),這個保護會覆蓋整趟行程非只 RETURN 段——你自己的證據顯示 outbound/deliver 今天沒有這個漂流病,多這層保護對它們無害（只防不必要搶班,不強制任何新行為),不需要額外拆分。

## 五問逐條答覆
**① 禁瞬移交割，母隊已滅要不要例外**：不需要例外——你自己 T3 已經給了母隊已滅情境一個**不需要瞬移的一致答案**（貨留在 porter 身上、porter 轉獨立、發失敗事件)，這條路徑根本沒有「要把貨瞬移去哪」的問題（沒有目標可瞬移),T3 已經涵蓋,不必在 §2 開洞。維持絕對禁令。

**② survival 仍可搶會不會讓 porter 又漂走**：見上必查項——用 `PROGRESSIVE_HOLD_TASKS` 實作的話，這不是一個「要不要開口」的設計選擇，是這個既有機制**本來就這樣設計**（危機軸不擋)，你的判斷方向（不鎖死、讓引擎秤)是對的,而且用現成工具比自己另外設計一個「有條件的鎖」風險更低（既有機制已經被本 session 這麼多輪審過,行為可預期)。

**③ k 值定死還是留給實作**：留給實作+測量後填,跟你這輪自己在生育曲線/EWMA那幾份 spec 已經確立的模式一致（曲線/門檻常數先留 TEST VALUE、靠量測校準,不憑空給)。這條風險有界——k 抓太小=porter 過早被判失敗（false 失敗事件,成本是多一次不必要的獨立轉換)、k 抓太大=真卡住的 porter 拖久才被抓到（成本是漂流期拉長,但已經比今日的「永遠不判定」好)。兩邊都不是災難性錯誤,靠測量調整是合理路徑,不需要這輪定死。

**④ gate 7 可執行性**：親讀後發現這條比你想的更好處理——`_transfer_proportional_assets`/`_merge_into`（我剛讀的 subteam_system.gd:169-199)本身已經只從 `try_merge_back` 呼叫、而 `try_merge_back` 本身已經被 :179 的 `parent.tile_pos==sub.tile_pos` 守衛擋住——也就是說**現有唯一的資產轉移路徑本來就已經結構性同格限定**，你這輪 T1-T3 的設計（RETURN 承諾態+回不去轉獨立)也沒有新增任何轉移呼叫點。**建議把 gate 7 從「review 逐行確認」改寫成更機械的負斷言**：「這個 diff 沒有新增任何 `ResourceBank`/資產轉移類呼叫,唯一轉移路徑仍是既有 `try_merge_back`」——這比人工逐行讀更容易勾選、也更難漏（diff 掃描找新增的轉移呼叫比自由心證的「有沒有瞬移感覺」更明確)。

**⑤ 我漏了什麼**：必查項那條就是。另外一個**輕量觀察**：你 gate 2 用「`convoy.drop.inflight_convoy` 佔比下降」驗證 throttle 鬆綁效果——這個 Probe 名稱聽起來是既有 tap（你沒特別列在前提裡),dispatch 信裡順手確認一下這個 tap 現在確實還在記,不是舊名字已經漂移的殭屍 tap（本 session 已經抓過幾次「常數名字聽起來對但實際沒接上」的案例),非阻塞、只是順手心防。

## 結論
**CLEAN → 可 dispatch**。★必查項（`PROGRESSIVE_HOLD_TASKS` 加 `TASK_CONVOY`,把 T1「既有承諾機制」的模糊描述變成具體、成本最低的一行改動,且自動滿足②的 survival 開口需求)請 dispatch 信裡帶給 implementer,不需重送 R②。④建議把 gate 7 改寫成負斷言式的 diff 檢查而非人工逐行 review,其餘皆非阻塞。

地基 KEEP。

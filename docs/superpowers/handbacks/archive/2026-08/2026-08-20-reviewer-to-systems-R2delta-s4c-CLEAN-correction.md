---
from: reviewer
to: systems
status: consumed
topic: "[R² delta 判決=settlement §4c CLEAN+2必查項(write_memory重用污染relations字典+L0decay掛點無founder欄位可讀)+5項答覆(`2026-08-20-reviewer-to-systems-R2delta-s4c-CLEAN-correction.md`)]"
---

# R² delta 判決：settlement §4c 結果反饋迴路（建點結局→選址記憶）

**判決 = CLEAN + 2 必查項（§4c build 內必修）**。「零新管道」的核心宣稱親驗**不完全成立**——`write_memory` 不是純 append 函式,重用它會有副作用；另外掛點①(L0 decay)親查**目前沒有資料可回答「誰的失敗」**。兩條都不難修,但要求 dispatch 前定案。

## citation 親驗
- `harvest_system.gd:36-39`（`_decay_l0_camps`）：`camp_ticks_left<=0 → camp_level=0` 逐字對得上。
- `faction_ai_system.gd:1985`（`relocate_abandon`）：`OutpostOwnerBank.set_owner(cur_tile,-1,"relocate_abandon")` 對得上,且**這條有清楚 actor**（`village`/`village.leader_id` 就在函式參數裡,寫「棄村隊自己的 leader」語意乾淨）。
- `outpost_system.gd:354-356`（`upgrade_level` 完工）：對得上。
- `npc_ai_system.gd:65-74`（`write_memory` 簽名）：對得上,但**深挖函式 body 抓到問題**（見必查項①）。
- 小訂正（非阻塞）：spec 引用「`join_rejected` 款」在 `decision_context.gd:530`，親查該行是 `absorb_yield` 邏輯,真正的 memory-scan pattern 在 **`:553-561`**（`for _m in ldr.memory: if type=="join_rejected" and subject_id==... and tick-window...`）。行號漂移 23 行,不影響判斷（pattern 本身確認存在），dispatch 信裡順手訂正即可。

## ★必查項①（★最重要）：`write_memory` 不是純 memory-append，重用會污染 `p.relations`
親讀 `write_memory` 完整 body（npc_ai_system.gd:65-74）確認它連呼四件事：`p.memory.append(...)` + `_trim_memory` + **`_update_relations`** + `_trigger_goals` + `_write_relation_edge`。親讀 `_update_relations`(:92-106) 逐行確認：**不管 `type` 認不認得，只要 `subject_id != -1` 就無條件執行 `p.relations[subject_id] = clampf(cur + delta, -1.0, 1.0)`**（未列入 match 的 type 走 `_: delta=0.0` 分支，delta 是 0 但**寫入本身不會被跳過**）。

親 grep 全 codebase 現有 8 處 `write_memory` 呼叫（faction_ai/interaction/diplomatic/npc_combat/player_command/salary_system）確認：**每一處 `subject_id` 傳的都是真實 person/team id**（`host_id`/`old_owner_id`/`collector_id`/`lord_bid`/`target_id`/`winner.leader_id`/`escort.leader_id`/`team.leader_id`）——即使某些既有 type（`join_rejected`/`enemy`/`benefactor`…）也不在 `_update_relations` 的 match 清單裡走 delta=0 分支，那個「污染」是**良性**的：`p.relations[真實的某人id] = 0.0` 仍然是一筆有意義的「對某人中立」記錄。

**你這輪計畫傳 `subject_id = tile_id`（`x*1000+y`）**——這是**地點**不是人。照現在的 `write_memory` 原樣呼叫，會在 leader 的 `p.relations`（人際關係字典）裡寫入一筆 `p.relations[5010] = 0.0` 這種**假關係記錄**（關係對象是一塊地不是一個人）。`_trigger_goals`/`_write_relation_edge` 兩者對未列入的 type 是安全 no-op（match 無 default 分支），**只有 `_update_relations` 這一條會真的寫壞東西**。這不是 tuning 問題，是資料語意錯位——任何未來讀 `p.relations.keys()` 假設全是有效 person/team id 的程式碼（UI 顯示交情列表、`state.persons.get(rk)`/`state.teams.get(rk)` 查找、平均關係值統計…）踩到這筆假 key 可能 null-deref 或悄悄算錯。

**必查項**：不要原樣呼 `write_memory`。改法二選一（我建議 (a)，改動面最小、不動共用函式）：
- **(a)** 加一個**專用薄函式**（如 `write_site_memory(p, type, tile_id, tick, intensity)`），內容只做 `p.memory.append(...) + _trim_memory(p)`，**跳過** `_update_relations`/`_trigger_goals`/`_write_relation_edge`（這三者對地點語意本來就不該套用——地點沒有交情、沒有復仇/感恩目標）。真正做到「複用既有 memory array + trim」而不誤用「複用整包 interpersonal side-effect」。
- **(b)**（若你想保留單一入口）在 `_update_relations` 開頭加一個型別白名單 guard（只對已知 interpersonal type 才寫 `p.relations`），但這動到共用函式、8 個既有 caller 都要重新確認不受影響，成本比 (a) 高，不建議。

## ★必查項②：L0 decay 掛點目前沒有「founder 是誰」的資料可讀——spec 前提未 grounded
spec §2 T1（spec:25）：「L0 decay：若該 tile 有可辨識的建者（camp 期間 owner/founder team 仍存活）→ 寫其 leader」——**親 grep `tile_data.gd` 全檔確認 `camp_level`/`camp_ticks_left` 是僅有的 L0 camp 相關欄位**（:20-21），**沒有任何 `camp_owner`/`camp_founder_team_id` 一類的欄位**記錄「誰在經營這個 L0 營地」。`_decay_l0_camps`(harvest_system.gd:31-39) 本身也是**純 tile sweep**，函式簽名裡完全不帶 team/leader 參數，結構上**現在就是讀不到「誰的失敗」**——不是我漏找，是這個資料真的不存在。

這條比你自己點名的②(self-knowledge 邊界/founder 換人)更前面一步：換人的問題是「知道是誰但不確定該不該記給TA」，這裡是「連知道是誰都做不到」。**必查項**：dispatch 前二選一定案：
- **(a)** 加一個最小欄位（如 `tile.camp_team_id: int = -1`，在 `faction_ai_system.gd:4770` `camp_level=1` 起建那行旁邊順手寫入,decay 時讀它、找到活著的隊就寫其 leader、找不到就跳過）——這是新增一個 tracking 欄位，**技術上不是「旋鈕」**（不是可調參數）但**確實是新 plumbing**，跟 spec §0「零新管道」的字面主張有落差，建議 spec 誠實承認這條、非藏在既有欄位帶過。
- **(b)** 照系統你自己說的「寧可漏寫不可錯寫」精神，**L0 decay 這個失敗掛點直接砍掉，只留 `relocate_abandon`**（後者有乾淨 actor，親驗成立）——範圍縮小但零新欄位、零風險。**注意**：L0 decay（紮營沒撐過絕境撐到紮根）大概率是這個反饋迴路最常見的失敗案例（相對 relocate_abandon 少見），砍掉這條可能讓整個 §4c 迴路的「有效樣本量」大幅降低、實務上很少真的餵到選址 util——這是取捨，不是我能替你們裁，但要求誠實面對這個 trade-off 非默默丟掉。

我沒有偏好強推哪個,但要求 dispatch 信裡把這條交代清楚（選 (a) 就承認多一個新欄位、選 (b) 就承認迴路覆蓋率降低），不要讓 implementer 自己碰壁才發現資料不存在。

## systems 5 審點逐條答覆
1. **掛點選得對嗎（capture 算不算失敗地）**：同意你的判斷=**不算**。被 capture 奪走是「打輸了」不是「選址錯」，甚至常常是「這地方太好才被搶」——語意上跟「這裡撐不起工期/棄置」是相反的訊號，硬塞同一個 `site_failed` 桶會混淆兩種完全不同的因果。不需要新增這個掛點。
2. **self-knowledge 邊界（founder 換人/離開）**：親查後這條比你以為的更根本——不是「換人」的問題，是**現在連追蹤 founder 這件事本身都沒有資料底**（見必查項②）。你「寧可漏寫不可錯寫」的直覺是對的方向，這正是必查項②裡 (b) 選項的精神。
3. **記憶隨人不隨團**：支持你標 intended。這跟本 arc 一路的 self-knowledge 紀律一致（`corvee_site`/`join_rejected` cooldown 都是掛在 person 不是 team）；leader 換人頻率高會讓反饋迴路生效率下降是真的，但那是**誠實的湧現代價**——制度記憶（團層級）本來就是你自己劃進 §4 界外的下一 arc，這裡不該偷渡團記憶進來繞過那條線。
4. **TTL 30 天量級**：合理。選址是一季一次量級的低頻決策，30 天（一季）跟決策頻率同量級，比 `JOIN_REJECT_COOLDOWN`(2天，社交互動天天發生) 長一個數量級是對的方向；沒有既有精確錨可比對，但這是 TEST VALUE 本來就該之後量測調，不阻塞。
5. **掛進既有選址 util 語意混雜**：這條疑慮方向合理但影響小——「地力好不好」跟「我上次在這失敗過」本來就是**同一個「這地方值不值得」判斷的兩個獨立輸入**，跟 `_inflow_est` 裡地力（terrain/harvest_factor）與規模（pop_mult）本來就疊在同一個數字裡是同款做法（那邊也是好幾個獨立物理因子疊乘成一個分數，沒人說語意混雜）。不需要新 term 線，你的判斷正確。

## 結論
**CLEAN → §4c 可 dispatch**，但★必查項①②（write_memory 重用副作用 + L0 decay founder 資料缺口）**必須在 dispatch 信裡定案交代**，非留 implementer 碰壁才發現。其餘 5 審點皆同意你的方向判斷。

地基 KEEP。

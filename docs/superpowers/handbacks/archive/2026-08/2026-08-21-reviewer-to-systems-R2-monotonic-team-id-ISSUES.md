---
from: reviewer
to: systems
slice: monotonic-team-id
status: consumed
topic: "[R②判決=team_id永不重用 ISSUES非CLEAN(★親grep發現全站7份獨立_next_team_id實作全部同款max(id)+1 bug,spec只點名subteam_system.gd一處——修完只堵1/7個出生口,其餘population/manpower/reaction/event_unrest_split/game_setup/recruit_tutorial六處production呼叫點原樣繼續重用id)+②稽核清單本身沒漏但前提要先補這條(`2026-08-21-reviewer-to-systems-R2-monotonic-team-id-ISSUES.md`)]"
---

# R② 判決：team_id 永不重用（單調遞增）

**判決 = ISSUES（非CLEAN、非halt——方向全對，但修的範圍只有 spec 自己講的 1/7）**。你自己說「這刀真正的工作量在稽核不在計數器」——親查後發現**計數器本身也沒做完**，這個發現比稽核清單漏項更優先，必須先處理。

## citation 親驗：`subteam_system.gd:345-350` 坐實，★但親 grep 全站發現另外 6 份一模一樣的獨立實作
`_next_team_id`(subteam_system.gd:345-350，你標:346-351差1同函式)`max(existing)+1` 逐字確認。

**★但親 grep 全 `scripts/simulation/` `func _next_team_id` 發現總共 7 份獨立實作，全部同款 bug**：

| 檔案 | 行號 | 邏輯 |
|---|---|---|
| `subteam_system.gd` | :345-350 | `max_id=-1;for tid in teams: if tid>max_id...;return max_id+1`（你 spec 唯一點名的） |
| `game_setup.gd` | :434-438 | 同款（`m=-1`起） |
| `event_unrest_split.gd` | :118-123 | 同款（`max_id=0`起，起始值差異不影響 bug 本體） |
| `manpower_system.gd` | :228-233 | 同款 |
| `population_system.gd` | :78-83 | 同款——★這是 `_create_overflow_team` 用的那個,我上輪審 §4b 擴點/overflow_split 才剛讀過這條路徑,production 常態會走到 |
| `reaction_system.gd` | :412-416 | 同款 |
| `recruit_tutorial.gd` | :29-32 | 同款 |

**七份全部逐字比對確認是同一個 `max(state.teams 現存id)+1` pattern 的獨立複製體**，全部寫入同一個 `state.teams` 命名空間（`team.team_id=`/`new_team.team_id=`/`nt.team_id=`/`ot.team_id=`/`sub.team_id=` 逐一確認)。

**後果**：spec §2 只講「`_next_team_id` 改讀它」，若只改 `subteam_system.gd` 這一份（你 §1 唯一點名的出生口)，**其餘 6 個 production 呼叫點（population overflow spinoff／unrest split／manpower captive 相關／reaction 觸發建隊／game_setup 初始生成／tutorial recruit)照樣用舊的 `max(id)+1` 邏輯**——這些路徑產生的隊伍**id 依然會重用**，你這輪要修的「兩條命被縫成一條假故事」問題**在 6/7 的出生口完全沒被動到**。而且會有一個新風險：**局部 max-scan 版跟全域單調計數器版並存**，兩套邏輯同時活著，未來要嘛靠人記得永遠只用其中一套（你自己在①點名的「記得在每個地方註冊」那族老毛病，這次是**產生端**版本,不是消費端版本),要嘛哪天漏改一處又是同一個病復發。

**必查項（優先於§3稽核清單、必須先做）**：這輪的「改產生器」要覆蓋**全部 7 個**，非 1 個。**建議**：與其在 7 個檔案裡各自把 `max(...)+1` 換成 `state.next_team_id`（讀值),不如**收斂成一個共用函式**（例如 `WorldState.consume_next_team_id()`,比照 `next_beast_id` 現有「呼叫端直接 `state.next_beast_id -= 1`」那種單一動作模式)——7 份獨立實作本身就是未來會再犯同型錯誤的結構性風險,這輪順手收斂掉,比只把 bug 內容從「重用」換成「7 處各自維護一個理論上該同步但物理上分開的計數概念」更乾淨。

## ①「改產生器」理由夠不夠支撐 fp 改動：方向對，但你的成本估計因為上面那個發現而低估了
你說「一次改產生器,三處消費端同時解掉」——**這句話現在要訂正成「七次改產生器（或一次收斂成共用函式),三處消費端才會真的同時解掉」**。方向判斷本身**仍然正確**（消費端複合鍵那條路「每新增一個讀者就要再記得一次」的風險評估沒有錯,而且我這次發現的「7份獨立產生器」恰好是同一種病的產生端版本,更加深了你「別再靠人記得」這個論點的說服力)——**但修改範圍/工作量估計要重新報**,不能用「動一處」的成本去支撐這個會動 fp 的 production 改動,實際是動七處（或收斂成一處新函式+七處呼叫改法)。這個修正後的成本仍然值得做,只是要如實報,不能低估。

## ②§3 稽核清單六項：本身沒有遺漏，但要加一條「產生器覆蓋完整性」當前置項
親覆核你列的六項（連續/緊湊假設、上界假設、`max(id)`語意依賴、存檔載入、負區段相撞、fp intended-change)——**這六項本身涵蓋消費端會踩的雷,沒有找到第七類消費端假設**。但**這六項的稽核價值建立在「id 真的永不重用」這個前提成立之上**——若只修好 1/7 個出生口,你花時間去稽核「假設id連續的地方」這件事本身雖然仍有意義（那些消費端假設無論如何都該查),但**稽核出來後修正的東西無法通過 gate 3（三處消費端失真消失),因為另外 6 個出生口還在製造重用的id**。**建議把「7個產生器全部指向同一計數器」升格成§3 第0項（在六項之前),當作其餘六項稽核有沒有意義的前提檢查**。

## 附帶（前輪帳目再訂正）
`try_set`/T1 inert 理由第二次訂正（結構上碰不到→設計上就讓行)：合理,跟你這輪一路的透明訂正紀律一致,沒有異議。

## 結論
**ISSUES → 補「7個_next_team_id全部收斂/改讀同一計數器」的完整範圍後重送 R②**（不需要重跑 R①,前提事實不變,只是範圍認知要修正)。§3 六項稽核清單本身沒有遺漏，但要在六項之前加一條「產生器覆蓋完整性」當前置檢查，否則後面六項稽核做完也驗不出「id永不重用」這個核心宣稱。

地基 KEEP。

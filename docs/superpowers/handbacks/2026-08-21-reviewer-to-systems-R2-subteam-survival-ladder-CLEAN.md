---
from: reviewer
to: systems
slice: subteam-survival-ladder
status: consumed
topic: "[R②判決=在途子隊入求生尺 CLEAN+1措辭必查項(①survival-only解讀忠於WHAT範圍認同,但gate3『T1死線變活的』要拆成兩句精確講——survival-override方向真的活、routine-block方向仍結構性打不到因為routine本來就沒人嘗試對子隊搶班,別重演convoy那輪的over-claim②親查faction_id/leader_id/is_subteam三個耦合風險點皆確認正確處理,coupling風險低③5%回報門檻合理)(`2026-08-21-reviewer-to-systems-R2-subteam-survival-ladder-CLEAN.md`)]"
---

# R② 判決：在途子隊入同一把求生尺

**判決 = CLEAN + 1 措辭必查項**。citation 全坐實。①方向認同但抓到一個措辭精確度問題（直接跟你們這輪一路在修的「over-claim」病同型)，②親查耦合風險確認低，③門檻合理。

## citation 親驗
- `faction_ai:761-762`（子隊走 `_evaluate_subteam`）/ `_evaluate_subteam` 對移民/BUILD/CONSTRUCT/UPGRADE/EXPAND/CONVOY 逐一早退——跟我上輪讀 convoy 那份時的認知一致，這次你擴大範圍到全部在途類型，親讀確認每個都是同款早退模式，坐實。
- `PROGRESSIVE_HOLD_TASKS`(task_arbiter.gd:22-25) 內容 BUILD/CONSTRUCT/UPGRADE/EXPAND/SETTLE/MIGRATE+CONVOY——跟 `_evaluate_subteam` 早退的 task 集合逐一比對**完全對上**，你「兩塊拼圖已經在位」的觀察精準。
- `state.consume_next_team_id()`(subteam_system.gd:60) 親確認已經是新版——monotonic team-id 那刀已經落地在這個檔案裡，不是還在等。
- `faction_id` 繼承：親讀 `state.set_team_faction(sub, parent.faction_id)` 在 subteam_system.gd 三個 dispatch 路徑（:97/135/162)都有——子隊會正確繼承母隊 faction，這個潛在耦合點沒問題（見②)。

## ①「survival-only」解讀：忠於WHAT範圍，但 gate 3 措辭要拆成兩句精確講
WHAT 原文（「子隊入同一把求生尺=完整絕境階梯…非瀕死→投靠單招」）**列舉的五個階段（趕路歸隊/買糧/覓食/乞食/投靠)全部是 survival 類選項,沒有一個是 routine（貿易/外交/野心)**——你選 survival-only 評估忠於這個範圍,不是縮小解讀,認同。

**但**：gate 3 寫「T1 從死線變成活的、要在帳上明寫」——**這句話目前是一個會被誤讀成比實際更廣的宣稱,要拆成兩句精確講**：
- **survival-override 方向**：真的會活（求生選項贏了、`try_set` 真的打進 `≥PRIO_THREAT`、hold 讓行)——這條你這輪直接證明得到,寫「活」沒問題。
- **routine-block 方向**（hold 擋住 ambient/trade 搶子隊班)：**這條在你這輪修完之後仍然是結構性打不到**——因為 `_evaluate_subteam` 對 BUILD/CONSTRUCT/CONVOY 等仍然只跑你這輪新加的 survival-ladder 評估,**routine 選項本身從來沒有機會被嘗試**（§5 你自己明寫不開放子隊做 routine 決策)。沒有嘗試就沒有東西需要被擋,這半條 T1 的「活」**在這輪修完後依然不成立**。

這正是你們這一串 slice（convoy T1/gate4/gate8)已經栽過、後來自己在 §6 帳目訂正裡承認過的同型問題——**「這個機制形狀對口」不等於「這條路真的被走到」**。要求 gate 3 明確拆成上面兩句,只認 survival-override 那半為「活」,routine-block 那半照實寫「仍不可達（子隊不評routine是設計如此,非缺陷)」——避免這輪帳目又要在下一份 delta 裡二次訂正。

## ②耦合風險：親查三個候選點，皆確認正確處理，風險判斷=低
你自己點名的疑慮（ctx建構假設parent存在？子隊缺少solo才有的欄位？)——親查三個最可能出問題的點：
- **`faction_id`**：見上,三處 dispatch 路徑皆正確繼承母隊 faction,不會有「子隊faction_id=-1(預設值)但實際屬於某勢力」這種資料不一致。
- **`leader_id`**：`sub.leader_id = sub_leader_id`(subteam_system.gd:67)真人 leader,有 `skills`/`values`,求生選項讀 leader 人格（野心/求生欲等)不會拿到 null。
- **`is_subteam`**（decision_context.gd:165/193)：既有欄位,由 `team.parent_team_id!=-1` 算出,目前只用來擋 `STRATEGIC_SELFINIT_SET`（建設/佔村這類戰略級選項)——親讀 `options.gd` 確認**求生類選項（覓食/乞食/紮營/返家補給/併入)全部標 `survival`/`passive_survival`,沒有一個在 `strategic_selfinit` 集合裡**,代表既有的子隊排除閘**不會誤傷**你這輪要開放的求生選項,子隊可以正常吃到它們。

三點都查完沒發現破綻,**耦合風險判斷=低**。這條是我推理驗證,建議 gate 1（階梯真的有多階)那個合成床**除了 convoy 外也順手拿 BUILD/CONSTRUCT 型子隊各跑一次**（不只 gate 4 的「至少一族有樣本」,gate 1 的多階驗證也一起做),用實測補一道我推理沒覆蓋到的死角保險。

## ③ perf 5% 回報門檻：合理
這是「要先講」非「必須低於才過」的回報型門檻，跟本 session 一路的「照實報、不准調參數湊」紀律一致——faction_ai 已是熱點不代表新增評估就不能做,只代表要誠實報數字讓人判斷值不值得,5% 當「值得特別討論」的分界線不算嚴苛也不算隨便,認可。

## §3 留帳設計：走既有 belief/relation 管道，方向認可
「差額寫進母隊對該子隊leader的belief→信任/聲譽後果」沒有新造評價系統,是既有機制的自然延伸,跟你這輪一路「別再造第二套物理上分開的東西」的紀律一致,沒有異議。

## 結論
**CLEAN → 可 dispatch**。★必查項：gate 3 拆成「survival-override 真的活／routine-block 仍不可達」兩句精確講,dispatch 信裡帶給 implementer 即可、不需要重送 R②。②耦合風險親查確認低，建議 gate 1 順手多跑一個非-convoy 子隊樣本當保險。③門檻合理。

地基 KEEP。

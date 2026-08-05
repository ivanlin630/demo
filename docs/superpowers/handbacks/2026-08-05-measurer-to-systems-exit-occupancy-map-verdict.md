---
from: measurer
to: systems
status: open
topic: "exit-occupancy-map verdict:★★g3.betrayal在rep床本身0次fire——NOT dominant driver(跟你code-read假說相反,我上輪的confound是我自建P4 fixture的特定人格值組合觸發,非rep床本身現象)。rep床(seed2024 45天)真實出口map:generic chokepoint事件=1(真faction membership變化只1次!),reason-tagged=6(defect1+uprising_B_exile5),但追log發現5次uprising_B_exile裡有4次是同一隊Team5對自己重複開火(day15/18/24/38,每次print old_owner=自己=已經是independent),只有day~早期第1次uprising real+day35 Team3那1次是可能的genuine新增exit——★★核心code-level發現:_evaluate_uprising(faction_ai_system.gd:4536)沒有faction_id!=-1前置閘(跟defect在event_faction_defect.gd明確有此檢查不同),導致已經independent的隊還會重複觸發整段uprising流程(含跟其他隊的鄰格恐懼cascade等副作用)——這是真實code gap,建議加閘。真實genuine faction membership loss只有1次(Team5經defect,跟generic chokepoint數字1完全吻合)。無disband_cascade/無第5條路。落地1檔已ls/wc驗證。已回systems handback:2026-08-05-measurer-to-systems-exit-occupancy-map-verdict.md，別下accept，g3.betrayal非rep床dominant driver(反駁假說)+uprising缺faction_id閘是具體code修復候選，交systems判HOW scope"
---

# exit-occupancy-map：★g3.betrayal 非 rep 床的 dominant driver（反駁假說）+ uprising 缺 faction_id 閘（具體 code gap）

## 做法

Rep 床（`config/infonet_faction_rich_rep.json`，collapse 那床，seed2024，45天）。在 4 個已知出口的 call site（`diplomatic_ai_system.gd`(g3.betrayal)、`faction_ai_system.gd`(uprising Path A/B)、`faction_ai_system.gd`(defection-eval Path B/C)、`event_faction_defect.gd`(defect)）+ `disband_faction` 的 cascade 直接欄位寫路徑 + `clear_team_faction` 本身（generic chokepoint）都掛了 temp 診斷 tap。

## ★★核心發現一：g3.betrayal 在這個 rep 床**完全沒 fire**（0 次）

```
g3_betrayal 詳細樣本：（空）
```

**跟你 code-read 假說（g3.betrayal 是 early/dominant driver）相反**——在**這個實際 collapse 的 rep 床**裡，g3.betrayal 一次都沒觸發。**我上輪 exit-attribution 看到的 `[Diplomacy]背叛` confound，是我自己另建的 P4 fixture（`infonet_cohesion_p4.json`）用的特定人格值組合（低信義0.34+特定野心/慎重比例）意外撞到 betrayal 的門檻，不是 rep 床本身的現象**——這是我自己上輪沒講清楚的地方，這輪確認：**g3.betrayal 不是 rep 床崩壞的驅動因子**。

## ★★核心發現二：真實 faction membership 變化只有 1 次，其餘是同一隊重複空觸發

```
generic chokepoint 事件總數=1
reason-tagged 事件總數=6（defect:1件 day0、uprising_B_exile:5件 days=[15,18,24,35,38]）
```

`generic`（真的經過 `clear_team_faction` 且當下 `faction_id != -1`）只有 **1 次**，但 `reason-tagged` 顯示 6 筆——追 raw log 找到原因：
```
[Faction] Team5 脫離勢力0          （defect，真實的第一次、唯一一次membership變化）
[Uprising B] Team5 流亡（求生=0.90，old owner=Team5）   ← ×4（day15/18/24/38，old_owner=自己=早就independent）
[Uprising B] Team3 流亡（求生=0.60，old owner=Team3）   ← ×1（day35，old_owner=自己=同樣早就independent）
```

**Team5 的 4 次「Uprising B 流亡」都是對著一個已經 independent 的自己重複開火**（`old owner=Team5` 自己，代表這隊已無外部勢力歸屬）——這些是**空觸發**（`clear_team_faction` 呼叫時 `faction_id` 早就是 `-1`，`generic` chokepoint 正確地沒把它們算進真變化，但 `_evaluate_uprising` 卻一直重新跑整段流程，包括鄰格恐懼 cascade 等副作用）。

## ★★具體 code-level 發現：`_evaluate_uprising` 缺 `faction_id != -1` 前置閘

`faction_ai_system.gd:4536`：
```gdscript
func _evaluate_uprising(state: WorldState, team: TeamData) -> void:
	if not _is_resident_team(state, team): return
	if team.current_task in [TeamData.TASK_REVOLT, TeamData.TASK_HOLD]: return
	if team.current_task in SURVIVAL_TASKS: return
	var avg_loy: float = _avg_named_loyalty(state, team)
	if avg_loy >= 0.2: return
	if team.unrest_turns < 60: return
	...
```
**沒有任何一行檢查 `team.faction_id == -1: return`**——對照 `event_faction_defect.gd:6-8`（defect 的 `check()`）：
```gdscript
func check(state: WorldState, team: TeamData) -> bool:
	if team.faction_id == -1:
		return false
```
**defect 有這道閘、uprising 沒有**。這解釋了為什麼一個早就 independent 的隊會在往後 20+ 天內反覆重新觸發整段「起義」流程（含 print、cascade 恐懼通知鄰格、取消施工等副作用，即使 `clear_team_faction` 本身因為已是 -1 而正確 no-op）。**這是一個具體、可修的 code gap**（建議加 `if team.faction_id == -1: return` 到 `_evaluate_uprising` 開頭，鏡射 defect 的既有寫法）。

## 補地圖：無第 5 條路、無 disband_cascade

`disband_cascade` 樣本=0（本輪沒有因為別隊離開導致自己 faction 解散而被連坐清空的情況——rep 床這輪唯二涉入的 faction 從沒有到 2 個以上成員過，沒有觸發 disband cascade 的條件）。**4+1（cascade）條已知路徑之外，沒看到第 5 種**。

## ★真實出口總結

- **defect（1 次，Team5，day0）**——唯一真正造成 faction membership 變化的事件，跟 `generic` chokepoint 數字（1）完全吻合。
- uprising（Team3 1次 + Team5 4次空觸發）——**Team3 那 1 次也需要進一步確認**：其 `old owner=Team3`（自己）同樣暗示它在 day35 之前可能已經不在任何真實 faction 底下（跟 T0-T3「founding never establishes」既有已知問題一致——這幾隊從頭到尾可能就沒真正組成過 faction，`_evaluate_uprising` 對它們的觸發同樣是空的）。

## 落地檔案（已 ls/wc 驗證存在）

- `docs/measurements/2026-08-05-exit-occupancy-map.txt`（721行，完整跑 log + reason 分類 + g3_betrayal 樣本區塊）

## 清理狀態

- `world_state.gd`/`diplomatic_ai_system.gd`/`event_faction_defect.gd`/`faction_ai_system.gd` temp 診斷 tap 皆已 `git checkout --` 還原確認乾淨。
- temp `config/infonet_faction_rich_rep.json`（借測）+ `exit_occupancy_map_bed.gd` 已刪除。
- 跑本工單期間發現 worktree 有另一 session 的未 commit 檔（`scripts/debug/g3_betrayal_bond_test.gd`），未觸碰。

## ★誠實淨判

- **g3.betrayal 不是 rep 床 collapse 的驅動因子**（0 fire）——反駁 code-read 假說，我上輪的 confound 是我自己 fixture 特定人格值組合的產物，非 rep 床通例。
- **真實 faction membership 損失只有 1 次**（Team5 defect），其餘 5 筆 reason-tagged 事件裡有 4-5 筆是對已經 independent 隊伍的**空觸發重複**——根因是 `_evaluate_uprising` 缺少 `faction_id != -1` 前置閘（具體 file:line 已給，鏡射 defect 既有寫法即可修）。
- 無第 5 條路、無 disband cascade。

別下 accept。HOW extension scope 建議：①加 `_evaluate_uprising` 的 faction_id 閘（清掉空觸發雜訊，cheap win）②g3.betrayal 本身不需要因為這輪的假說去動它（它在 rep 床沒有涉入）③T0-T3 是否真的從未組成過 faction，值得跟既有「founding never establishes」問題一起看，非本輪新問題。交你們判。

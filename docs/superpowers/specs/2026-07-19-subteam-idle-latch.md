# spec：subteam-idle-latch 根治（手不聽腦第 3 種）

> 層級：L2（1 行 gate 排除 + 逐 sibling measure）。off main 980e0b1c+（transition merged 後）。優先 HIGH（手不聽腦 mini-arc，quality bar「沒有隊伍能坐著/掙扎落空地餓死」）。
> 來源：QA 抓 6 隊（62/71/73/79/84/90）→ systems code-locate → measurer trace CONFIRMED。root=`faction_ai:1727`。known_issues「subteam-idle-latch」。[[手不聽腦 mini-arc]] 第 3 種。

## 病象（measurer 坐實 @9a915fe7）
6 隊 `food-ok 2.5-4.58 + committed=覓食 + would_succeed=true 卻 task=idle，reason=subteam`。team73 血證：停 forage tile (26,9)，parent (25,6)，每 ~100-200t 抵達即被召回。drop 計數 **ARRIVE_MERGEQ 337 ≈ LOOP2B_RELEASE 346（1:1 振盪指紋）**。

## root（補丁閘坐實）
`_evaluate_subteam`（`faction_ai_system.gd:1727`）：
```gdscript
if sub.move_target == Vector2i(-1, -1) and sub.current_task != TeamData.TASK_IDLE:
    merge_queue.append(sub.team_id)   # 抵達目標格 → 歸建（lifecycle）
    return
```
**把「覓食 subteam 抵達 forage 目的地（move_target 清 -1）」誤當「歸建抵家該 merge」** → merge_queue → loop2b（`:761`）parent 不同格 → `release` → IDLE → 下 cadence 再派覓食 → 已在 tile 秒到 → 再 release。**THRASH，覓食從不在 tile 執行 → 食物流不進 → committed=覓食 卻 idle 坐死。**

= 補丁閘（機械 lifecycle gate pre-empt 引擎覓食決策）。覓食是「到目的地工作」語意（該留 tile 覓食），非「回母團」。1727 一律送 merge_queue。

## ★v2 重設計（blueprint SEND-BACK 後）：閉合供給環，非只拆 merge
> **v1（1 行 `not in SURVIVAL_TASKS` 全排除 merge）= 換位置錯誤**：治好 thrash-死**但引入 terminal-sticky**——forager 永久卡 forage 囤 200-2000 food-days **不交母團** → 破食物供給環 → seed42 0→10 famine regression（measurer 追到 forager-detach→母團失覓食貢獻→餓死鏈）。**不是 net 進步，是換一種餓死**（thrash-死→hoard 卡+母團餓死）。∴ 拆 merge 不夠，需**閉合供給環**。

**供給環機制（坐實）**：forager 覓食 `collect_resources`（`resource_system:46`）per-day 累積 `forage_today`→食物；歸建 `try_merge_back`（`subteam_system`）`ResourceBank.add(absorber,...)` = **交糧給母團**。∴ 1727 blanket 即時 merge 其實是**（粗糙的）交糧機制**，v1 拆掉它=拆供給環。

**v2 修：1727 對 survival-work 的 merge 改「食足 or 母團缺糧才 merge（交糧），否則留 tile 覓食」**：
```gdscript
if sub.move_target == Vector2i(-1, -1) and sub.current_task != TeamData.TASK_IDLE:
    if sub.current_task in SURVIVAL_TASKS \
            and not (_forager_sated(sub) or _parent_needs_food(state, parent)):
        return   # 未食足 且 母團不缺 → 留 tile 繼續覓食（不 merge，不 thrash，food 累積）
    merge_queue.append(sub.team_id)   # 食足/母團缺糧/非-survival → 歸建（交糧 deliver）
    return
```
- **未食足+母團不缺 → 留 tile 覓食**（不即時 merge=不 thrash，`collect_resources` 累積 food）。
- **食足 or 母團缺糧 → 歸建 merge**（`try_merge_back` 交糧給母團=閉合供給環）。
- `_forager_sated`：`_survival_food_days(sub) >= FORAGE_SATED_DAYS`（TEST VALUE，攜糧夠多值得回交）。`_parent_needs_food`：`parent != null and _survival_food_days(parent) < PARENT_LOW_DAYS`（TEST VALUE，母團缺糧→即使沒滿也回交）。
- **非 thrash-抑制補丁**：這是把「即時 merge」改「條件 merge（交糧時機）」——forager 覓食工作、食足回交，供給環閉合。sated 後歸建移向 parent（食足→forage util 低→不 re-forage→不 thrash）。

## ★v3 重設計（blueprint 結構 scope 後）：連續母團監看 + orphan-forager
> **v2（sated-gated 條件 merge）仍不足**：measurer 查 seed1337 v2 惡化（6→10）= **真結構洞非 cascade**。`_parent_needs_food` 召回檢查在 `move_target==-1` 分支內（只 forager 駐 forage tile 才查）→ **旅途中 forager 完全不監看母團** → 母團垂危時出門的 forager 召不回；死案例 forager 已吃飽（food 10-11）卻救不了（交糧太慢）。∴ 需**連續監看**（不等駐點）。

**v3 兩結構修（併同 spec，blueprint 裁）**：
1. **連續母團監看召回（主）**：foraging subteam **每 tick（旅途中也查，不等駐點/不等 sated）**監看母團——母團 `<PARENT_LOW` **立即掉頭歸建交糧**。位置＝`_check_discipline` 後、position-branch 前：
```gdscript
if _check_discipline(state, sub): return
# ★v3 連續母團監看（foraging subteam，不等駐點——補 v2 只駐點查的結構洞）
if sub.current_task in SURVIVAL_TASKS:
    var parent: TeamData = state.teams.get(sub.parent_team_id)
    if parent == null:
        _orphan_forager(state, sub)   # ★orphan：母團死/缺席 → 轉獨立（見下）
        return
    if _parent_needs_food(state, parent):
        merge_queue.append(sub.team_id)   # ★母團垂危 → 立即掉頭歸建交糧（loop2b 移向 parent→抵達 merge）
        return
# （以下 position-branch：v2 sated-gated merge 處理「駐 forage tile 食足→交糧」正常路）
```
2. **orphan-forager**（parent 缺席/死亡）：轉獨立（沿用 discipline_fail 現成路 `state.detach_subteam(sub) + remove_tag(TAG_SUBTEAM) + TaskArbiter.release(sub)` → 下 tick 跑獨立戰略/faction，不再無限囤糧）：
```gdscript
func _orphan_forager(state, sub) -> void:
    state.detach_subteam(sub); state.remove_tag(sub, TeamData.TAG_SUBTEAM, "orphan_forager"); TaskArbiter.release(sub)
    print("[SubAI] Team%d 母團缺席 → orphan 轉獨立" % sub.team_id)
```
- **v2 sated-merge 保留**：position-branch 的「駐 forage tile + 食足 → 歸建交糧」正常路不變（連續監看是 in-transit 補洞，非取代 sated 路）。
- **gate-tune 排 v3 結構修之後**（blueprint 裁）：SATED=10/PARENT_LOW 可能仍偏，但**結構洞補完才是純參數敏感度**——v2 已證純調參數不堵召回洞治標不治本。結構+orphan 落地後若殘留才 gate-tune。

## ★terminal-sticky = 真 blocker（訂正 v1 reviewer/implementer 的 non-blocker 判斷）
reviewer R²v1 標 terminal-sticky「非 blocker，measurer 順帶量」、implementer 照 dispatch——**訂正**：blueprint+measurer 坐實 terminal-sticky = **真 blocker**（破供給環 famine regression 有清楚因果，非模糊聚合）。教訓歸「症狀vs根/以為修好其實換位置」（memory [[feedback_symptom_vs_root_retry]]）。**v2 必含供給環才 accept**。

## WHAT（blueprint SEND-BACK 已定）
blueprint **接受 subteam 獨立覓食，但要求交糧回母團**（供給環閉合）——非禁覓食。v2 供給環正是此意。

## 驗收
- **TDD**：①覓食 subteam 抵達 forage tile（move_target=-1）→ **不進 merge_queue**（`current_task in SURVIVAL_TASKS` 排除）→ 留 tile → 覓食執行、食物累積、無 thrash。②mission task（如 TRADE，非 SURVIVAL_TASKS）抵達 → 仍 merge_queue（不破 lifecycle）。③歸建（_decide_subteam:1787）路不變。
- **★sibling 驗**：CAMP/BEG/JOIN/RETURN_HOME subteam 抵達目的地——確認排除後行為對（CAMP 留紮營✓/BEG 乞食✓；JOIN 抵達 join target 由 _decide 執行✓；RETURN_HOME 抵家 resupply 非被召 parent✓）。若某 sibling 排除後卡別的態→measure flag。
- **gate** constitution PASS / **headless** 0 new(baseline 3) / **determinism** 2 跑 byte-identical。
- **measure**：seed1337 6 隊（62/71/73/79/84/90）不再 idle-latch、覓食食物流進（committed=覓食 subteam ARRIVE_MERGEQ↔RELEASE 振盪消失）；42/4201 無 regression；subteam 正常 lifecycle（mission 完工歸建）不破。
- **★供給環閉合 must-pass（v2 核心，真 blocker）**：修後 forager 食足→歸建**交糧給母團**（`try_merge_back` food 進 parent）→ 母團失覓食貢獻的餓死鏈消。**seed42 famine 0→10 regression 必回 0**（v1 引入的，v2 必治）。terminal-sticky（forager 永久囤糧不交）**必消**：forager food_days 不無限累積（食足即歸建交糧），囤糧 200-2000 food-days 現象消失。
- **★無 re-thrash**：sated 後歸建移向 parent、food 足→不 re-pick forage→不回到 thrash（measurer 驗 ARRIVE↔RELEASE 振盪 + 新的 sated-歸建 路都不振盪）。
- **★v3 連續監看 must-pass**：**seed1337 v2 惡化（6→10）回落**（旅途中 forager 監看母團垂危→掉頭交糧→母團不再召不回餓死）；死母團案例（forager food 10-11 卻救不了）消。
- **★v3 orphan must-pass**：parent 死/缺席的 forager **轉獨立不無限囤糧**（囤 200-2000 food-days 現象在 orphan 路也消）。
- **★整體 must-pass（blueprint re-measure）**：seed42 famine→0（v2 目標）+ seed1337 不惡化（v3 目標）+ orphan 消 + 手不聽腦維持 0 + 6 隊解 + 無 re-thrash。gate 值（SATED/PARENT_LOW）待結構修落地後才 tune（現調無意義）。

## 排序
HIGH。off main 980e0b1c 後 HEAD。R² 必過（重點審 SURVIVAL_TASKS 排除不破 mission-merge lifecycle + sibling 行為）→ dispatch。

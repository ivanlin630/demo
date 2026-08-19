---
from: reviewer
to: systems
status: consumed
topic: "[R² delta 判決=settlement §4a CLEAN+1必查項(zombie construction 風險)+4項議定答覆(`2026-08-20-reviewer-to-systems-R2delta-s4-CLEAN-correction.md`)]"
---

# R² delta 判決：settlement §4 戰略蓋點 engine 化 + de-scaffold

**判決 = CLEAN + 1 必查項（correctness-blocking，§4a build 內必修）**。前提/citation 全親驗坐實，方向正確；但深挖到 to_task 實作細節時抓到一個具體 race，非設計方向問題。

## citation 親驗（全坐實，無 citation 錯）
- `_evaluate_l0_settle`：faction_ai_system.gd:4777 定義、:838 唯一 caller — 親 grep 全 `scripts/` 確認零其他 production caller（僅 `settlement_s2b_test.gd` 8 處測試直呼）。
- constitution 2 站：`constitution_baseline_v2.txt:77-78` 逐字確認皆指向 `_evaluate_l0_settle::taskarbiter` / `::threshold`，且 baseline 檔本身 comment 早已寫「呈 systems R² ratify baseline 75→77」——這兩站從 S2b 那輪起就已標記等這輪拆，非新發現。親數 `grep -c "^scripts"` = 77，77→75 算術對得上。
- 現行 hard gate 親讀：:4806 `if food_days < L0_TO_L1_CORVEE_DAYS: return`（threshold 站）+ :4819 `TaskArbiter.transition(...)`（taskarbiter 站）— 兩站定位精準。
- `options.gd` REGISTRY 現況面（42/155/192）親讀全對得上（建設/併入/紮營三 entry 逐欄核對）。
- `_find_unowned_farmable_tile`(4727) / `_evaluate_outpost_takeover`(5242, 3天timer, caller :894) 親確認存在、非杜撰。
- `check_overflow_for_team`(population_system.gd:24) 親讀確認**真無條件機械**：overflow>0 立即 advisor 帶走或 `_create_overflow_team`，零決策層 check（坐實「碎裂機械源」定性）。
- `write_memory`(npc_ai_system.gd:65)、`MarginalEconomy._inflow_est`(marginal_economy.gd:15)、`ctx.idle_labor`(decision_context.gd:37)、`persist_strength._safe_factor`(persist_strength.gd:91) — 皆親 grep 確認真實存在，**零新旋鈕**對這幾個引用成立（§4b 提前查，不留到 §4b 才炸）。

## ★①de-scaffold 正確性 + 引擎單源 dispatch 追蹤 → 抓到必查項
親讀 `_decide_unified`(faction_ai_system.gd:2474-2520) + `TaskArbiter.try_set`(task_arbiter.gd:49-79) 完整鏈確認**單源 dispatch chokepoint 真實存在**（:2575 `TaskArbiter.try_set(state, team, td["task"], tgt, DecisionOptions.priority_for(opt), "unified")`）——2 站方向正確，會真的收斂成這一處，非搬去別站。`priority_for`(options.gd:432-437) 對非 survival/threat 的 opt 預設回 `PRIO_DISPATCH`，跟舊 `_evaluate_l0_settle` 用的優先級一致，這條零新常數。

**★但親讀 `try_set` 完整 body 發現它會真的失敗**（非只是理論上）：combat_target 鎖(:51-52)、crisis-released 免疫窗(:56-58)、`PROGRESSIVE_HOLD_TASKS`+persist_strength 高於 `PERSIST_HOLD_THRESHOLD`(:64-70)、以及非 idle 且新優先級不高於現優先級的一般搶班失敗——這些都是**真實會 return false** 的路徑，不是穩贏。

對照舊 code：`_evaluate_l0_settle` 在 4813-4818 **無條件寫** `tile.construction_target`/`construction_ticks_left`/`construction_team_id`/`team.corvee_site`，然後才呼 `TaskArbiter.transition`——但這安全，因為函式**入口已硬擋非 idle**(:4782 `if team.current_task != TeamData.TASK_IDLE: return`)，idle 隊幾乎不可能踩上面那些失敗路徑（combat_target 通常伴隨非 idle task、crisis 免疫窗跟 IDLE 通常不撞、priority 0 也不會觸發 progressive-hold guard），**舊碼的「先寫後 transition」隱含安全前提=入口已鎖 idle**。

spec §4a 的新 `applicable`（spec:26）：「站自己 L0 + `outpost_level==0` + `construction_team_id==-1` + 非玩家」——**沒有 `current_task==IDLE` 這條**。而 `_decide_unified` 對**每個 unified 隊每 cadence 都重評**(:2476 `_should_reeval` 只節流頻率，不限 idle)，代表**非 idle 隊**（例如正在 `駐守`/`建設`/`TRADE`，同樣是 `PRIO_DISPATCH` 優先級）**也可能被評到 `紮根` 且 argmax 選中它去試 dispatch**。此時走的是 spec:28 描述的路：**`to_task` 內直接寫 `construction_target` 等（`不再自呼 transition`，改靠引擎後續呼 `try_set`）**——但 `to_task` 在 :2520 就被呼叫、寫入副作用**發生在 `try_set` 判定成敗之前**（:2575 才呼 try_set）。若 `try_set` 因上述任一 guard 返回 false（例如該隊 persist_strength 高卡在別的 progressive task 上），**副作用已經落地：tile 被標記 `construction_team_id=該隊`、`construction_target` 已設，但該隊 `current_task` 從未真的變成 `TASK_BUILD`**。

`_tick_construction`(outpost_system.gd:272-297) 掃格上 `current_task==TASK_BUILD` 的隊當 `active_team`；找不到時只在 `state.teams.get(construction_team_id)==null`（隊已死）才清 orphan——**隊還活著、只是 task 對不上**，不觸發清理，直接落 `無施工隊在格，暫停`（:297），且 `紮根` 自己的 applicable 要求 `construction_team_id==-1`（spec:26）→ 這格從此對 `紮根` 再也不 applicable、對其他要蓋點的隊也一樣卡（`outpost_level>0 or construction_team_id!=-1` 判斷會擋，比照舊碼 :4804 同款判斷）。**= 一個沒人在蓋、也沒人能接手的 zombie 工地**，永久卡到有外部機制清它（目前只有「隊死亡」這條清理路，隊沒死不會清）。

**必查項（§4a build 內必修，非留 follow-up）**：二選一（我建議 (a)，成本最低、風險輪廓等同舊碼）：
- **(a)** `紮根` 的 `applicable` 加回 `ctx.team.current_task == TeamData.TASK_IDLE`（跟舊 `_evaluate_l0_settle` 的入口守衛同語意）——把「這條路只对 idle 隊考慮」的隱含安全前提**顯式寫回 applicable**，非丟給引擎泛用重評路徑,`try_set` 失敗機率跌回舊碼等級（幾近零）。
- **(b)**（若 systems 想保留非 idle 隊也能被 `紮根` 考慮的彈性）改兩段式：`to_task` 只回傳 `{task, target}`（不寫 tile），實際 `construction_target`/`construction_ticks_left`/`construction_team_id`/`corvee_site` 寫入**移到 `_set_ok==true` 之後**的一個小 commit-hook（比照 `td.has("combat_target")`/`td.has("social_target")` 那種「try_set 成功後才處理額外欄位」的既有 pattern，:2586-2589 就是這款先例）。
- **TDD 補一項**：「非 idle 隊（正做別的 progressive task、persist_strength 高）+ 站自己 L0 空地 + `紮根` 進 ranked → try_set 失敗 → tile `construction_target` 仍為空/`construction_team_id`仍 -1（無 zombie 殘留）」。目前 §4a TDD 清單(spec:31)四項都沒覆蓋這條路徑。

## ★②hard gate→util 的過頭判斷：不需保留 applicable 物理下限，但 gate 項要真測
方向支持**維持 util 非 hard gate**（呼應本 arc 一路 de-patch 紀律，[[feedback_patch_gate_first]]/[[feedback_genuine_value_not_crank]]）。理由：ETA≫food_runway 時 util→0，argmax 只在**這是當下最佳選項時**才選中它——瀕餓團通常同時有 覓食/乞食/併入/返家補給 等 survival-class option 在場且它們的 util 隨絕境**升**（`desperation_entry_threshold` 框架），紮根的 util 隨絕境**降**，兩條曲線本來就該在瀕餓區交叉，架構上不需要額外物理下限去「保證」不選——保證交給 §3 gate 項「瀕餓不開工（util 過濾非門檻）」的**真實量測**去驗證，非再加一道 applicable 硬線（硬線=走回頭路,違反 §0 命門自己定的「禁硬門檻回潮」）。**但這條是 empirical claim,不是 by-construction**——要求 §3 gate 項這條真的跑（非只信 util 曲線形狀推論），且量測要包含「isolated 隊(附近無 join host/無 forage tile,紮根事實上是唯一非零選項)瀕餓時是否仍會低 util 選中它然後餓死在工地」這個邊界情境，非只測一般情境。

## ③零新旋鈕：親驗成立
`MarginalEconomy._inflow_est`/`ctx.idle_labor`/`persist_strength._safe_factor` 三個 §4b 要用的既有量皆親確認真實存在(見上)。§4a 本身沒引用任何新常數（`L0_TO_L1_CORVEE_DAYS` 沿用既有）。零疑慮。

## ④overflow 決策化保底降級：建議 margin-based 優先於純 delay
純時間延遲（N 天）的問題：**跟溢出量級無關**——小超額(1-2人)和大超額(難民潮式暴增)用同一延遲,決策層來不及反應時大超額情境傷害更大。建議**用 margin（`population > cap × 系數`,如 1.15）取代或疊加純 delay**：小溢出留給決策層(擴張 option)慢慢解、只有真的滾到顯著超額(結構性=決策層明顯沒接住)才機械介入。若擔心「決策層永遠沒接住」的極端情況(bug/卡死),margin 本身仍會隨 population 持續成長最終跨過門檻觸發,不需要額外時間備援。**具體係數留 systems/blueprint 定**,我只給方向判斷:margin 優於純 delay。

## ⑤反饋迴路禁永久黑名單：設計方向健全,要求具體衰減公式進 TDD
self-knowledge(自己 leader memory)+ 零新管道(複用 `write_memory`) 這兩條零疑慮。**要求**:weight 衰減/有效期具體公式(同 `join_rejected` cooldown 精神)**寫進 §4c spec 本體**而非留給 implementer 憑感覺挑常數——沿用本 session 一路「HOW 階段須 machine-demonstrate bounded 非留白讓 implementer 猜」的標準必查項慣例。

## ⑥替代同秤「1人碎片蓋不如投」湧現性:方向可信,留 §4a gate 驗證即可
可行性帳(ETA vs food_runway)對 1 人隊而言 ETA 會拉長(工期公式若跟人力反比,人越少 ETA 越長)、util 隨之走低;`併入`option 對絕境隊本來就有独立高權重路徑(§HOW-6 `join_drive`)。兩條线独立算出、非人為對撞,**结构上支持湧現說法成立**,不需要 WHAT 再加額外項。§3 gate 已列「替代同秤(1人碎片選投靠>紮根)」為驗收項,這條足夠,不用我再加要求。

## 結論
**CLEAN → §4a 可 dispatch**，但★必查項(zombie construction race)**必須在 §4a build 內解決**（建議走 (a) 方案,成本最低）,非 build 後才補。其餘 5 議定點提供方向判斷,不阻塞 dispatch。§4b/§4c 沿用 spec 排程,§4b 開工前之前既有量已驗證真實存在,無需重驗。

地基 KEEP。

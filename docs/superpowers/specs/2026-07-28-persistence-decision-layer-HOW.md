---
type: spec-draft
owner: systems
topic: 持守統一 decision-layer HOW 架構（R①收窄後子集）
status: draft-骨架（重掃+scope done；公式細節+slice 待 post-compact 完整化+R²）
---

# HOW 架構 spec（draft 骨架）：持守統一 decision-layer

> R① CONTRADICTION 收窄後（blueprint 調 WHAT 2026-07-28）：本 arc = **決策層 flat bonus 家族 → 沉沒成本+人格加權**，progressive-only，危機/階層/FLEE 排除。執行層/跨層共讀 = 獨立 arc（用戶 fork 等 blueprint）。**此檔骨架先記 proceed 進度（blueprint GO 別空等）；公式細節+plan/slice 待 post-compact 完整化（重工別滿 context 跑，means-end 樂觀低估血證）→ R²。**

## 1. scope（重掃坐實，5 核心項）
本 arc subsume 這 5 決策層 commitment/hysteresis 機制（全「committed 情勢未變黏住」=同類 rank 偏置）：
| 機制 | file:line | 現值 | 套的動作 |
|---|---|---|---|
| COMMANDER_COMMITMENT_BONUS | faction_ai:39 (用:910) | flat 0.15 | 戰略意圖(征服/建國) hysteresis |
| FOUND_COMMITMENT_BONUS | faction_ai:46 (用:1244) | flat 0.15 | 建國意圖 hysteresis |
| SOLO_COMMITMENT_BONUS | faction_ai:87 | flat 0.15 | SoloAI 日常 task 慣性 |
| COMMITMENT_BONUS | decision_engine:6 (用:88,173；current_option 寫 faction_ai:1837/1984) | flat 0.3 | 引擎 rank current_option 承諾慣性 |
| survival_committed_stall | faction_ai:3660+ | 情境(8天×人格+relief) | survival option 無進展耐性 |

## 2. 排除（重掃確認，非本 arc）
- **危機/急迫 axis**（反持守/守命，留原樣）：PRIO 階層/combat_lock/emergency_guard/CRISIS_FLOOR_override/SURVIVAL_RECOVER_DAYS。
- **非 commitment**：MERCHANT_TRADE_BONUS(:20 trade 偏好)/TERRAIN_BUILD_BONUS(:2913 地形適性)。
- **非 progressive**：FLEE(開放無終點)/TRADE·FOUNDING 一次性 timeout。
- **27 不齊補**：礦山建造豁免求生(:3451 famine grace，閘地形+資源=危機 axis 排除)。
- **執行層/跨層共讀**：COMMITMENT_BONUS 寫回 + try_set 重寫 + ~29 call site + cadence 新鮮度 = 獨立更大 arc（用戶 fork）。

## 3. 模型（方向，公式細節 post-compact）
**持守強度 = 人格加權(沉沒成本 + 前瞻價值)，取代 flat 0.15/0.3**：
- **沉沒成本**（往回看）：committed 動作已投入/進度越多越黏。**固執/恆心人格權重高**=死硬完成者。
- **前瞻價值**（往前看）：離完成/回報越近 util 越高。**務實/機會人格權重高**=靈活轉換者。
- **人格→沉沒vs前瞻混合比**（哪些 value 偏沉沒/前瞻，如 慎重/固執→沉沒、貪婪/機會→前瞻）= post-compact 定。
- **progressive-only gate**：只套有進度/終點動作（build/upgrade/campaign/戰略意圖有達成度）；開放式（FLEE）不套。

## 4. 憲法對齊
- utility weigh 非 scripted（持守=rank 偏置權重，非寫死 edge）。
- 人格 WEIGH 不 GATE（人格調沉沒/前瞻混合比=權重，非硬類別閘）。
- 非硬鎖（latch 反例，util 偏重永不凍世界）。

## ★執行層持守（用戶裁乙定案，真架構 build——重掃坐實規模）
investigator 重掃補齊（2026-07-28）坐實規模「真 build 如 means-end 新子系統」，**非收既有**：
- **A) TaskArbiter 83 call site**（try_set/transition/release，faction_ai 39 + interaction 15 + outpost 8 + player_cmd 6 + sim_runner 3 + subteam 1 + movement 2；★blueprint 估 ~29 **遠低估**）——重寫「整數 tier → 持守-aware」影響面。★核心比較點 `task_arbiter.gd:38 try_set`（整數 tier 嚴格大於）+ `:65-78 engine self-replace` = 真改點；83 中多是 release（清 task，未必改）——**slice 要先分「哪些 call site 真需傳持守值/改比較」vs「純 release 不動」**。
- **B) 34 持守機制**（27 已知 + 7 表外：decision cadence 新鮮度/consistency coeff/survival boost/threat boost/same-need fallthrough/idle-filler/beggar restore）——subsume 範圍比 27 大。
- **C) COMMITMENT_BONUS 零欄位寫回坐實**（decision_engine:88/173 只 rank 迴圈浮點加成，team.current_option 寫但非 u 值，task_arbiter 零引用）= R① 兩層無共讀通路確認 → **執行層要建寫回通路（真 build）**。cadence 新鮮度落差 3 點（COMMITMENT 讀 cadence 1日 vs current_option 可能舊 / timeout 每 tick vs goal cadence / crisis_immunity 2日 vs cadence 1日 double-immunity）。
- **危機 axis 排除確認**（B 表中 combat_lock:1/crisis_immunity:2/famine_grace:3/PLAYER 豁免:5/… 屬急迫非持守，留原樣）。

## ★設計原則（blueprint 提醒 2026-07-28，HOW 自主但守）
- **持守-aware = 加維度非砍 PRIO**：try_set 比較加「持守強度」維度，**不砍現有 PRIO 整數 tier 階層**——危機 axis（COMBAT/SURVIVAL/THREAT）仍硬階層守命、留原樣。持守只在**同 tier 內/非危機軟選擇**當 tiebreak 偏置，危機一律 tier 勝（背水一戰=危機 axis+人格，不受持守影響）。
- **別破現有仲裁**：83 call site whole-system-first（整個建完當 whole 才 measure，別邊改邊 patch）。slice **切細**（83 大面 → 先分「真需傳持守值/改比較」vs「純 release 不動」，逐 slice 當真 build）。
- **latch 反例守約束**：util 偏重永不硬鎖凍世界（本場 latch 血證）。

## 4. 持守強度公式（核心）
```
persist_strength(team, action) =
    personality_mix(team) 加權於 [ sunk_cost_term(action) , prospect_term(action) ]
```
- **sunk_cost_term ∈ [0,1]**：已投入/進度佔比。construction=`(BUILD_TICKS - construction_ticks_left)/BUILD_TICKS`；戰略意圖=達成度；campaign=已行進/總距。★**progressive-only**：只有進度/終點的動作有此項；開放式（FLEE）= 無此概念 → persist_strength=0（走既有 timeout）。
- **prospect_term ∈ [0,1]**：離完成/回報距離的反比（越近越高）。construction=同 sunk 的鏡像（剩越少越高）；trade run=離目標市場距離。
- **personality_mix**：人格決定兩項權重比（**weigh 非 gate**）。固執/恆心/慎重 → sunk 權重高（死硬完成者）；務實/機會/貪婪 → prospect 權重高（靈活轉換者）。mapping 用既有 `team.leader.values`（如 `固執`/`慎重`→sunk、`貪婪`/`機會`→prospect），線性混合、非硬類別。
- **clamp**：`persist_strength ≤ PERSIST_CAP`，且 `PERSIST_CAP < 危機 axis 量級`（危機永遠可打斷，非硬鎖——latch 反例避開）。

## 5. 兩層讀取 + 寫回通路
- **決策層寫**：rank cadence 時算 `persist_strength(team, team.current_task/option)` → **寫 `team.persist_strength` 欄位**（新欄，TeamData）。取代 5 個 flat COMMITMENT bonus 的來源（bonus-collapse）。
- **執行層讀**：`TaskArbiter.try_set`（:38）讀 `team.persist_strength`。
- **★新鮮度解**：`persist_strength` **隨進度事件更新**（construction tick 倒數時、抵達時），非只 cadence——sunk/prospect 是進度函數，進度變就重算（cheap，純算術）。避免 cadence(1日) vs 執行層(每tick) 落差。

## 6. try_set 持守-aware 仲裁（★門檻式，R² 訂正 new_util 來源）
★**R² 抓到**：`try_set` 簽名只有 `priority:int`、**無 util 浮點值管道**，原 pseudocode 的 `new_util` 沒來源。**選門檻式**（不比兩 util、不新增參數、自洽 §7「call site 不改」）：
```
try_set(new_task, new_prio):
    if 危機 axis（new_prio 或 current.task_priority ≥ PRIO_THREAT）:
        用現有整數 tier 嚴格大於（守命，persist 不介入）  # 背水一戰=危機 axis+人格
    elif 非危機 且 current task 是 committed progressive 動作（persist 適用）:
        # ★門檻式：committed 動作 persist 高 → 擋非危機搶班（不需 new_util，只讀 team.persist_strength）
        if team.persist_strength > PERSIST_HOLD_THRESHOLD:
            return false   # 別被搶，完成 committed 優先
        # persist 不足 → 落回現有整數 tier（可被搶）
        用現有整數 tier 嚴格大於
    else:
        用現有整數 tier 嚴格大於（原行為，非 committed progressive 不受影響）
```
- **為何門檻式 > new_util 比較**：try_set 的搶班者 util 已在決策層 argmax 算過（贏家才來搶）；try_set 只需判「當前 committed 動作黏不黏得住」——`persist_strength`（人格加權）**單邊門檻**就夠，且**人格自然分化**：務實人格 persist 低 → 門檻低 → 易被搶（靈活轉換）；固執 persist 高 → 難搶（死硬完成）。**不需 new_util、call site 不改**（§7 自洽）。
- **`PERSIST_HOLD_THRESHOLD`** = 常數（TEST VALUE，slice 調）；`persist_strength ≤ PERSIST_CAP < 危機量級`（危機永遠過 tier）。
- 危機 tier **原封不動**（combat_lock/crisis-immunity guard 全留、在 persist 判斷之前）。
- **latch 反例避開**：persist 是**單點門檻擋一次搶班**（return false），**非 skip reeval 硬鎖全世界**——被擋的搶班者下 tick 照常再評、危機照打斷、世界照演化（不凍世界）。★關鍵差異：latch 是「施工隊自己 skip 決策」凍死；此門檻是「別的隊搶不走 committed 隊」但 committed 隊自己照跑決策、完成/危機就釋放。

## 7. 83 call site 分類（whole-system-first，別破仲裁）
- **真改點（少）**：`task_arbiter.gd:38 try_set`（加非危機持守比較）+ `:65 self-replace`（同層加持守）+ 決策層 5-6 處寫 `team.persist_strength`（bonus-collapse）+ 進度事件更新點（construction/movement）。
- **不動（多數）**：83 中大量 release（清 task，持守不介入）+ try_set/transition call site 本身（它們呼 try_set，改在 try_set **內部**讀 persist_strength，call site 不必逐個改）。
- ∴ 真改面 << 83（核心 = try_set 內部 + 決策層寫回 + 進度更新），但**行為影響面 = 全部**（whole-system-first：整個建完當 whole measure）。

## 8. slice（切細、當真 build、每 slice R²）
- **Slice 1（決策層 bonus-collapse，增量、可獨立驗）**：新 `team.persist_strength` 欄 + 公式 helper（sunk+prospect+人格）+ 5 commitment bonus 改讀它（決策層 rank 偏置）。progressive-only gate。驗：隊照人格黏著（死硬完成率高/務實轉換），無 thrash，**世界不凍**（latch 反例回歸）。
- **Slice 2（執行層寫回 + 新鮮度）**：決策層寫 persist_strength + 進度事件更新（construction/movement）。驗：persist_strength 隨進度真更新、新鮮度落差消。
- **Slice 3（執行層 try_set 持守-aware）**：try_set 非危機加持守比較（危機 tier 不變）。驗：committed 非危機動作不被輕易搶、危機仍即時打斷、背水一戰保住、世界不凍。
- **Slice 4（A1 手不聽腦收）**：committed builder（TASK_BUILD 施工中）persist_strength 高 → 執行層不被非危機 util（外交/貿易）搶（A1 stall 根修，但**用 persist 偏置非 latch 硬鎖**）。驗：**A1 forest founding `construct.complete_build > 0` 真完工**（execution-verified，specimen-off/aggregate）+ 世界不凍。
- 每 slice R² + whole-system-first（整個建完當 whole 才 measure，別邊建邊 patch）。

## 9. 憲法對齊（複核）
- **utility weigh 非 scripted**：persist_strength 是 rank 偏置權重，非寫死決策 edge。✓
- **人格 WEIGH 不 GATE**：人格調 sunk/prospect 混合比 = 連續權重，非硬類別閘。✓
- **非硬鎖（latch 反例）**：persist 是 util 偏置、危機永遠可打斷、世界照演化——永不凍世界。✓
- **危機 axis 排除**：PRIO 階層/combat_lock/crisis 全留原樣，持守只在非危機軟選擇。✓

## TODO（R² → plan → implementer）
- [ ] R②（異質框外，尤其驗：persist 公式對否、try_set 加維度不破現有仲裁、latch 反例真避開世界不凍、83 分類真改點少）。
- [ ] personality→sunk/prospect mapping 細節（哪些 values、線性係數）。
- [ ] plan（executing-plans）→ implementer（Slice 1 起，逐 slice R²）。
- [ ] 沉沒成本量化（各動作「已投入/進度」怎麼取：construction_ticks 已耗/戰略意圖達成度/…）。
- [ ] 前瞻價值量化（離完成距離）。
- [ ] 人格→混合比 mapping（哪些 value 權重）。
- [ ] progressive-only gate 判準（哪些動作有進度/終點）。
- [ ] 5 項 subsume 接線（統一 helper 算持守強度，5 處 call 改讀它）。
- [ ] 成功判準（隊照人格堅持/轉換、無 thrash、無凍世界）。
- [ ] plan/slice → R²每slice → implementer。

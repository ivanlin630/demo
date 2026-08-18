# settlement S2b：L0→L1 工期（建點 = viability 過濾）（HOW / systems）

status: DRAFT→R²（2026-08-18）
owner: systems（HOW）← settlement design §2 + S2 HOW spec §2b
溯源：S2a MERGED（L0 營地階梯、interim pop+81.4%）→ S2b 補 L0→L1 工期（紮根=數天勞力、付不付得起=viability 湧現過濾）。

## §0 命門（HOW 守、grounded 驗證後）
- **★複用既有 construction spine 非新造**（延伸統一）：`_tick_construction`(outpost_system:272、`construction_ticks_left-=max(pop,1)` 每 tick)→`_complete_construction`(:315)。**`_complete_construction` 已有 `"crude_camp"` action 分支**(:361-369)=玩家紮營完工路、**已做 L1-founding**（set outpost_type/`outpost_level=1`/`set_owner("construct")`/food cap 40/PRODUCE|MILITARY tag）。∴ S2a「移除」的 L1 邏輯**其實還在此 player 路**——S2b **wire NPC L0→L1 走此既有完工邏輯**、非重寫。
- **禁 crank / 禁死常數**：工期常數單旋鈕（TEST VALUE）、viability=付得起工期物理湧現（瀕餓建不成=零硬門檻）。
- **感知鐵律**：L0→L1 決策讀腳下自家 L0（proximate 合法、team 站自己 camp）；跨距目標=S1b belief 既有（本 slice 是站定後紮根、非旅行）。
- **守恆**：完工 food cap 抬非送即時糧（既有 :362 註「絕不送即時糧」原則守）。

## §1 現況（grounded 驗證、負斷言先 wc-l 後宣）
- **construction spine 存在**：`_tick_construction:272`（driver）、`_complete_construction:315`（completion match action）。`"crude_camp"` 分支:361 完工設 L1+owner+food+tag。`"build"`:327/`"upgrade_level"`:350/`"upgrade_facility"`:354 其他 action。
- **S2a 後 NPC 無 L0→L1 路**：`establish_crude_camp`(faction_ai:4711) 現只建 L0（camp_level=1、無 outpost_level/owner）；舊瞬間 L1 已移除 → **NPC 目前站 L0 後無晉 L1 機制**（本 slice 補）。
- **busy-preemptible**(faction_ai:402-416) 存在（工期中斷複用、不新發明）。
- ★**負斷言待 implementer 確認**：`construction_target` 的 NPC 設定點——玩家經 PlayerCommandSystem、NPC founding 經 `_dispatch_builder`(goal_resolver:452 派子隊)。**L0→L1 in-place（非派子隊、team 站自己 L0 紮根）的初始化點 = 本 slice 新增的最小 wire**（不改 founding 子隊路）。

## §2 Task（TDD、每 task 跑 headless 驗）
### T1：NPC 建點決策（L0→L1 initiation）
- **新「建點/紮根」決策**：team 站自己 L0（camp_level=1、腳下 tile）+ viable → 設腳下 tile `construction_target={action:"crude_camp"(複用) or "camp_to_l1", type:(civ/mil by leader 好戰/野心), level:1, owner:team_id}` + `construction_ticks_left = L0_TO_L1_CORVEE_DAYS × TICKS_PER_DAY`（單旋鈕 TEST VALUE）+ current_task=建設（in-place、team 自己施工非派子隊）。
- **決策落點（延伸非新求解器）**：接既有 camp/settle 決策族（如 camp_drive 的「紮根」延伸 or settle option）——**R² 查是否冗餘**（跟既有 founding option 重疊？in-place L0→L1 vs 派子隊 founding 是不同 case：站定升級 vs 遠方建新）。
- **TDD**：①站自己 L0 的 viable team → 設 construction_target level:1 + ticks_left ②非站 L0 / 瀕餓不 viable → 不啟工期。

### T2：工期推進 + 完工晉 L1（複用 spine）
- **工期**：既有 `_tick_construction` 推（`ticks_left-=pop`）；期間 current_task=建設、不覓食=機會成本。
- **完工**：`_complete_construction` 走 `"crude_camp"`(或新 action) → 既有 set `outpost_level=1`+`set_owner("construct")`+food cap+tag。**★S2b 擴充**：完工**清 `camp_level=0`+`camp_ticks_left=0`**（L0 消融進 L1、非殘留雙態）；升居民 tag（勞力池從 L1 起=S2a 界線落實）。
- **TDD**：③工期 tick 推進 ticks_left 遞減 ④完工→outpost_level=1+owner+camp_level 清 0+居民 tag（勞力池納）+ fp 反映。

### T3：工期中斷 = busy-preemptible（既有）
- L0→L1 工期中 current_task=建設 → 壓境「能傷你」威脅 busy-preempt 打斷(:415)；中斷→工期暫停/作廢（construction_ticks_left 保留 or 重置=TEST VALUE、R² 議）。
- **viability 湧現過濾**：瀕餓團工期中餓死/被 preempt→建不成 L1（正確湧現、零硬門檻）；健康團付得起。
- **TDD**：⑤工期中壓境威脅→busy-preempt 打斷、L1 未完 ⑥瀕餓團工期中餓死→建不成（L0 decay 或 team 亡）。

## §3 gate（measurer bounded、綠才 merge）
1. **L0→L1 真通端到端**：站 L0 viable team → 工期 → 完工 L1（outpost_level=1、camp_level 清、居民 tag、勞力池納）。
2. **viability 過濾湧現**：健康團建得成、瀕餓碎片建不成（付不付得起工期=物理、非硬門檻）；founding L1 量恢復（S2a interim 0→S2b 有 viable L1）但**非** spam（碎片仍 L0 transient）。
3. **複用 spine 不冗餘**：走既有 _tick_construction/_complete_construction、camp_level 完工清乾淨（無雙態）。
4. **不破**：determinism（工期純狀態+既有 spine）、S1 reclaim/S2a L0/47 guard 不受影響、constitution 綠。
5. fp intended-change（L0→L1 工期路=行為變）。

## §4 界外
- 農業產糧本體=§3 農業 slice（S2b 後）。
- L2/L3 升級（既有）、軍事選址、植林=界外。

序：R² 審此 HOW → CLEAN → S2b plan → dispatch（base post-S2a main）→ gate → merge → 農業。地基 KEEP。

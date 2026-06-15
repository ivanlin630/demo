# 路線圖 + 已知問題解方

> 建立：2026-06-15 | 來源：progress.md + known_issues.md 彙整 + P3 審計
> 用途：跨 session 的前瞻規劃。每完成一塊回填 progress.md，解掉的 issue 標 ✅ 移回 known_issues.md。

---

## 現況（2026-06-15）

- **世界層已達「合理」**：2 年×4 config 無荒謬全滅、pop≠0、戰鬥/貿易≠0、coin_eq=0。W5 latch 大修後機制全活。→ **不再追 NPC 完美化**。
- **玩家迴路 = Kenshi 下而上生存**。階段1（開局生存）整套完成（狩獵唯一/野獸戰鬥/伏擊/絕境多元生存/SoloAI 尋家）。
- **UI 翻新進行中**：P1 API 暴露 ✅ / P2 chrome ✅ / B3 玩測批修 ✅ / B4 成員管理 ✅ / **交易 offer-builder ✅（2026-06-15 merge）**。
- **P3 全動作覆蓋**：spec + plan 已寫（`2026-06-15-p3-action-coverage`），**待子 session 實作**。
- **ui_flow harness** 已有：headless 實例化 TextUI + 注入 + 驅動 + 斷言。

---

## 路線圖（依序）

### 🔴 近期（完成 UI 可玩性，當前 arc 收尾）

| # | 項目 | 狀態 | 備註 |
|---|---|---|---|
| 1 | **P3 全動作覆蓋** | plan ready | 子 session 接 `2026-06-15-p3-action-coverage.md`。完成後 6 孤兒動作全可達 → 對稱性閉合 |
| 2 | **GUI run-verify 清償** | ⬅ **最高槓桿** | 見下節「run-verify 債」。~13 個「修了但沒視覺確認」item。**策略：能進 ui_flow harness 的轉自動回歸，剩真視覺項一次玩測批驗** |
| 3 | **U16 地圖迷霧** | 已根因未修 | axial→offset 投影錯。**需與使用者看輸出互動迭代**（視覺，無法 headless 驗）。獨立 task |

→ 1+2+3 做完 = 階段1 真正可玩（玩家經 UI 跑完整生存迴路 + 動作對稱）。

### 🟠 中期（玩法深化）

| 項目 | 待 spec? | 解的問題 |
|---|---|---|
| **量測 tune 階段1 TEST VALUES** | 否 | loot 偏高(130)/SoloAI 投靠占比低/FORAGE·BEAST·AMBUSH 數值。一次一變因 |
| **階段2 招人成幫** | 是 | 玩家迴路下一階。recruit_anon/recruit_named 已有後端，需玩法包裝（為何招、招誰、養得起否） |
| **②深層目標錨** | 是（草案在 known_issues）| 接 dormant goal 系統，長弧（盜匪→建國）。**先量測 SoloAI 承諾慣性夠不夠再做**。極克制：一個慢變 goal 欄位+偏好加成，非規劃器 |
| **task 優先權仲裁（Spec A）** | 是 | current_task 被 5+ 系統互蓋。優先表已設計，待 reaction 收斂後實作 |
| **salary 欠薪後果** | 接 Bug2 | 見問題解方 |
| **NPC 勒索機制活化** | 是 | demand_tribute 現休眠(2026-06-15 量測 NPC 發起=0)。發起點 `try_proactive_diplomacy:68` 被早return+同格gate+方向反(弱勒強)三重掐死。要當壓力機制需:翻方向(強勒弱)+ 優先序重排 + 平衡。世界穩定不需要,僅在要「強權壓迫」玩法層才做 |

### 🟡 長期（系統擴張，世界已穩才碰）

階段3 據點 / 階段4 勢力 / mount 公庫系統 / 設施 B 期材料層 / 戰場 mount unit-level / named 升階 / 信用貨幣（勢力券）/ 新礦事件 / 戰俘處置 / 山村採礦換糧經濟。（細節見 known_issues.md「待 spec」表，優先序不變。）

### 🔧 技術債（隨手或專案）

- `faction_ai_system.gd` 2000+ 行拆檔（每次都改它，編輯可靠性受損）— 順手非優先。
- U9 圖形 Main.tscn reach-through raw WorldState — **TextUI 為主用場景時凍結**，只有復活圖形 UI 才需解耦。

---

## 已知問題解方（開放項，附建議解 + 工量）

### 高優先

**Bug2. salary 拖 coin 無下限**（經濟守恆破，新團永久赤字）
- **解**：`salary_system._pay_salary` 發薪前 clamp `coin >= 0`；不足額記「欠薪」→ 接 reaction（loyalty 降 / anon 補充停 / named 離隊機率）。
- **工量**：S（clamp 1 處）+ M（欠薪後果接 reaction，可獨立 spec「salary 欠薪後果」）。

**W4. 遊牧軍閥 leader 不駐留 → 建造卡**（tyrant/warzone 設施仍 0）
- **根因**：好戰 leader 永遠在外迎戰，from-never idle → 治理/建造觸發不到。
- **解（二選一，需 spec）**：(A) leader 強制週期回防（每 N tick 或公庫<門檻 + 無近敵 → 回家攢公庫）；(B) 建造資金改 faction 共同出資（不綁 leader 在地）。
- **工量**：M。建議 (A) 較貼現有「治理回家」路徑擴充。

### 中優先

**Bug5. DiplomacyAI demand_tribute 恆負**（強者不勒索，AI 過保守）
- **解**：調 caution 權重或 power_ratio 門檻使強者 score>0；對未變動局勢快取決策（同局每次重算同值是浪費）。
- **工量**：S。tune + 快取。

**Bug6. multi runner 不注入 command_schedule**（測試保真度：config schedule 全不觸發，放大 W1/W2 觀感）
- **解**：`game_sim_multi.gd` 比照 `game_sim_test` 補 `GameSetup.run_command_schedule_tick` + encounter 超時保護。
- **工量**：S。**快速勝利**，改善測試保真。

**Bug8. `_test_on_team_extinct_to_storage` 失敗（baseline）**（滅團食物未進公庫）
- **解**：查滅團資產路由為何食物沒進公庫（W6 修的是地圖外格路由，此為公庫分支）。**注意：prior 指示「勿動」此測試斷言本身** → 修的是實作使其符合斷言，先確認斷言語意正確。
- **工量**：S-M（需先 investigate）。

**Bug9. EncounterSystem player_id==-1 → anon 被當玩家**（latent）
- **解**：玩家判定加 `state.player_id != -1` 守衛。
- **工量**：S（~1 行）。**僅當無玩家情境需跑 encounter 才必要**（現 NPC vs NPC 走 npc_combat 迴避）。

**U16. 地圖迷霧 axial 投影錯**（見路線圖近期 #3）
- **解**：`text_map_renderer.render` 改正確 axial→offset 投影（`col = q + (r - (r&1))/2` 類）或累進列偏移，取代錯誤的「奇列縮排 2 空格」stagger。
- **工量**：M（視覺需逐步對照，互動迭代）。

### 低優先 / moot

- **U5 右側欄 / U6 圖塊資訊不完整 / U7 Camera 回正 / S4 人口分裂太快**：皆 **圖形 Main.tscn（main.gd/right_sidebar/bottom_bar）** 項。TextUI 為主用場景 → **凍結/moot**，text-UI 對應資訊已由 P1/P2 覆蓋。復活圖形 UI 才解。
- **W7 覓食 vs 乞食仲裁**：2 年實測穩，**留量測**。修需同步重整 3 個依賴測試語意。
- **W3 BREAKOUT/ENCIRCLE_DIST tune**：改 `min(N, map_radius)` 動態。隨地圖正式化再調。
- **D1 SoloAI 保護條件脆弱**（子隊分裂後 leader_id 可能失效）：加 player_id 直驗而非 leader_id。S。
- **A1 stdin stdout 污染 / A2 _max_timer 缺欄位**：工具/顯示細節，S。
- **U8 Members popup（圖形）/ U18 玩家武裝 anon**：U18 已由 B4 set_armed_anon_ratio 解，可標 ✅；U8 圖形項凍結。

---

## GUI run-verify 債（2026-06-15 自動回歸補完）

**狀態：所有 run-verify 項已自動回歸覆蓋（邏輯/flow 層）。** 剩純真視覺（顏色/版面/滾動渲染）集中一次玩測批清。

| item | 修了什麼 | 自動測 |
|---|---|---|
| U10 戰後凍結 | _refresh_ui 不 early-return + 戰果摘要 | ✅ ui_logic `_test_post_combat_hint` |
| U10b 全隊死→game-over | 結算偵測全滅 | ✅ headless game_over 系列 |
| U11/U11b 命中回饋戰報 | encounter_log channel + label | ✅ headless `encounter_log`（填值）|
| U12/U12b 交易誤判 | 被 trade offer-builder 取代 | ✅ ui_flow trade（舊 path 不再走）|
| U13/U13b 卸裝 + NPC 成員裝備 | [U] unequip + member equip | ✅ ui_flow `_test_member_equip_flow` |
| U14/U14b 進場數 + 自隊武裝 | 公式 assert + status armed | ✅ ui_flow `_test_armed_count_shown` + headless |
| U15 戰後按鍵閃退 | _input overlay 守衛 | ✅ ui_flow `_test_u15_overlay_input_guard`（2026-06-15）|
| U17 旗色 | 抽 `_unit_color` 按自/敵上色 | ✅ ui_logic `_test_unit_color`（2026-06-15）|
| U19 強制事件無選單 | _process 自動進 forced 模式 | ✅ ui_flow `_test_u19_forced_auto_enter` |
| U20 遠端 tribute spam | 同格 gate + cooldown | ✅ headless `_test_u20_proactive_same_tile_gate` + reject_cooldown（2026-06-15）|
| U21 選單>9 | _interact_page 分頁 | ✅ ui_flow `_test_u21_interact_paging` |

### 真視覺殘項玩測清單（一次跑遊戲批驗，無法 headless）

邏輯已自動鎖，以下只剩「實際渲染對不對」需肉眼：
1. **遭遇戰**：旗色實渲（玩家藍/自家綠/敵紅 U17）、戰報 label 滾動顯示（U11b）、戰後「按任意鍵離開/[J]收編」實顯（U10）、戰後按鍵不閃退（U15）。
2. **新面板實顯**：公庫 [K]（存/取兩欄+數量輸入）、outpost 蓋設施選單/棄置二次確認、faction [G]徵用比例+高比例二次確認、trade offer-builder 天平版面。
3. **互動選單**：recruit_anon/invite_settle 實際出現可選且成交（invite_settle L3 修後）。
4. **chrome**：P2 四區（已 run-verify ✓，順帶複查）。
5. **U16 地圖迷霧**：獨立互動修（見路線圖近期 #3），非此清單。

→ **run-verify treadmill 已止**：邏輯回歸自動化，肉眼項收斂成上面一張清單，一次玩測清完。

附帶風險（另議）：**`KEY_Q`→`get_tree().quit()` 在一般遊玩仍是危險綁定**（Q 也是直覺移動鍵）→ 建議改安全組合或移除確認。

---

## 給下個 session 的起手

1. 子 session 接 P3 plan（worktree `feat/p3-action-coverage`）。
2. P3 merge 後：盤 run-verify 債 → 能自動的補進 ui_flow_test，排一次玩測批驗清單。
3. U16 與使用者看地圖輸出互動修。
4. 之後轉中期（量測 tune / 階段2 招人）。

> **注意**：main 目前領先 origin 數個 commit（交易 + P3 spec/plan + 本 roadmap）。push 需使用者明示「push main」。

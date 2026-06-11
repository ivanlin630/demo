# Hand Back: Economy / Spam Fixes

Branch: `feat/economy-spam-fixes`（6 commits，f40aa41..d6d0f62）

## 實作摘要

| Commit | 檔案 | 變更 |
|---|---|---|
| f40aa41 (Task 1) | `salary_system.gd` | `_pay_salary` 先估總 payroll（named + anon），coin 不足算 `budget_ratio` 全員按比例減薪；coin 一律 floor 0；減薪時 unrest+1 + `[Salary] 減薪 N%` print |
| 4bb1bef (Task 2) | `strategic_ai_system.gd` | `_find_trade_partner` 加 `_tile_has_resident` check：outpost tile 上要有「生產」居民團才派 trader |
| 335ec47 (Task 3) | `team_data.gd` + `diplomatic_ai_system.gd` | 新欄位 `diplomacy_reject_cooldown: Dictionary`；`_send_diplomacy_message` 收到 reject/refuse 設 `REJECT_COOLDOWN = 7 天`；`try_proactive_diplomacy` 冷卻中 `continue` 換對象 |
| de69133 (Task 4) | `faction_ai_system.gd` | `_update_equip_order` target 計入已裝備武器（見下方根因） |
| 144f3dc (Task 4b) | `reaction_system.gd` | leader N1_flee/N3_defect 在 anon=0 時不再扣 population（見下方根因 2） |
| d6d0f62 (Task 5) | `skill_system.gd` | 刪 `"P3_recruit"` dead mapping；grep 確認 scripts/ 無其他殘留（僅測試斷言引用） |
| 各 commit | `headless_test.gd` | 新增 6 測試（Task1a/1b/2/3/4/4b）；更新 2 既有測試（trade partner 場景補居民團） |

### Equip churn 根因（Task 4，診斷結果）

兩層根因，皆非 print 問題：

1. **equip_order 振盪**（主因，game_sim_test 1014 → 9）：`_update_equip_order` 的 target 只看 storage pool，但裝備後武器離開 storage（equipment_system 扣 pool）→ 下輪 total 變小 → target 變小 → deficit<0 unequip 還回 pool → target 又變大 → 再 equip，每 2 tick 循環。修法：target 計算把 named 已裝備武器單位加回 total / 各 type pool。
2. **population 流失振盪**（殘餘，multi Team14 ×448）：leader N1_flee/N3_defect 走 `AnonTierSystem.kill_random` 路徑，但舊版**無條件先扣 population**；anon=0 時沒人真的走，pop 卻掉到 < named 數 → 非軍隊團 `guard_count = pop/2` 在 0↔1 振盪 → equip/unequip 循環。修法：kill_random 實際殺到人才扣 pop。

## 行為變化（multi 4 config × 90 天，baseline = main 084afdd）

| 指標 | Baseline | 實測 |
|---|---|---|
| min_coin | -57（warzone）/ -5（tyrant） | **0 / 0 / 0 / 0**（全 config ≥ 0）✓ |
| [Equip] 次數 | 1234（multi）/ 1014（sim_test） | **23（multi）/ 10（sim_test）**，單團最高 3 次 ✓ |
| 減薪 print | 無此機制 | 48 次（窮團隊緊縮）✓ |
| Diplomacy reject 連發 | 連發無冷卻 | reject 後 7 天靜默；Team0→Team1 110 次中 reject 僅 11（≈ 冷卻窗口上限）✓ |

註：accept 的重複 propose（如 propose_trade/accept ×99）不設冷卻，屬既有設計（成交不懲罰）。

## 驗證

- `headless_test.gd`：`=== DONE ===`，0 SCRIPT ERROR，全部既有 + 6 新測試通過
- `game_sim_test.gd`：90 天無崩潰，`ALL INVARIANTS PASSED (violations=0)`
- `game_sim_multi.gd`：4 config 各 21600 tick，0 SCRIPT ERROR，min_coin 全 0

## 連動風險

- `reaction_system.gd` pop 修正：任何依賴「leader flee 必扣 pop」的平衡假設會變——anon=0 的小團 pop 不再被 N1/N3 慢性磨損（之前 pop 會被吃到 1）。流亡小團存活率上升。
- `salary_system.gd`：coin 永不為負 → 之前靠負債檢測（`coin < 0 → unrest`）的路徑改為 `budget_ratio < 1.0 → unrest`，語義等價但觸發時機提前（發薪當下）。
- `_find_trade_partner` 變嚴 → trade 派遣次數下降，商隊 idle 時間變長（merchant config pop_final 28→29，無惡化）。

## 待主 session 確認

- 減薪 unrest 累積速度（每週發薪不足即 +1，是否過快）
- equip churn 根因 2 的處置：anon=0 時 leader N1「無人可走」改為 no-op，另一選項是讓 leader 本人帶裝備離團（語義更重，未採用）
- accept 重複 propose 是否也要 cooldown（現只 reject/refuse 有）

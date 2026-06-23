# Handback: P1 個體域 options（掠奪）

**Branch:** `feat/p1-individual-options`
**Date:** 2026-06-23
**Status:** 完成，待主 session merge

---

## 改檔清單

| 檔案 | 變更 |
|---|---|
| `scripts/simulation/decision/terms.gd` | 加 `LOOT_DRIVE_BASE` 常數、`loot_drive` eval、`loot` weight |
| `scripts/simulation/decision/decision_context.gd` | 加 `has_weak_prey: bool`、`weak_prey_pos: Vector2i`；gather() 呼叫 `_find_weakest_prey` |
| `scripts/simulation/decision/options.gd` | REGISTRY 加 `掠奪`、applicable() 加 `has_weak_prey` 守衛、to_task() 加 `掠奪` → TASK_LOOT + combat_target |
| `scripts/simulation/faction_ai_system.gd` | `_decide_unified` 套用 to_task 結果後加 combat_target 接線（`if td.has("combat_target"):`） |
| `scripts/debug/headless_test.gd` | 加 3 個 p1 測試函數 + 5 個 helper（_mk_unified_cruel_team, _mk_unified_meek_team, _mk_weak_prey_team, _p1_place_tile, _p1_set_belief） |

---

## Per-task 狀態 + Commit

| Task | 狀態 | Commit |
|---|---|---|
| T1: loot_drive term + loot weight + ctx 弱獵物 | PASS | `c4ce85e` |
| T2: 掠奪 option + combat_target 接線 | PASS | `002d852` |
| T3: believability 測 + world_sim 量測 | PASS | `ecdc5b2` |

---

## 測試結果

### Headless 全套
```
[p1] loot term/weight OK cruel=0.79 meek=0.12
[p1] loot option OK (raider→TASK_LOOT combat_target=902, meek→建設)
[p1] loot believability OK (hungry→覓食, not TASK_LOOT)
=== DONE ===
```
無 SCRIPT ERROR。

### Believability 驗證
- **殘忍/好戰 leader unified 隊 + 弱獵物 → TASK_LOOT，combat_target 正確設定** ✓
- **溫和 leader 同情境 → 選 建設（非掠奪）** ✓（meek weight=0.12 × 1.0 = 0.12 < 建設 util）
- **飢餓殘忍隊 + 野豬場 + 弱獵物 → 選覓食（survival_pressure≈11.7 >> loot 0.79）** ✓

### CoinAudit delta（守恆閘）
```
[CoinAudit] game_sim_test  delta=0.00
[CoinAudit] tyrant         delta=-0.00
[CoinAudit] merchant       delta=0.00
[CoinAudit] warzone        delta=0.00
```
守恆完整，四個場景 delta ≈ 0。

### Framework Validation S1-S6
```
S1 g2.faction_found=1       [PASS]
S2a g2.feud_formed=1        [PASS]
S2b g2.vendetta_trigger=1   [PASS]
S3 g3.scout_dispatch=1      [PASS]
S4 g3.ambush=1              [PASS]
S5 g1.mint=1                [PASS]
S6 g1.order_fulfilled=1     [PASS]
--- PASS=7  DORMANT=0 ---
```

---

## World_sim 2yr 量測

- **世界未崩潰**：`=== world_sim DONE ===` 完成 2yr（720 天）
- **掠奪 fire rate**：`[SoloAI] Team4 → 掠奪` 多次出現（Team4 是 non-unified solo 隊，舊路徑，符合預期——unified 隊無新掠奪 print）
- **unified 隊行為**：Team1（unified 生產隊）全程 `task=建設(p50)[unified]`，未見 unified 路徑觸發 TASK_LOOT
- **over-loot 風險**：本 world_sim 場景 unified 隊人格偏溫和，掠奪未在 unified 路徑 emergent fire。若需驗 emergent raider，須在 world_sim 設定殘忍 leader 隊（unseeded 隨機人格，本次未中）
- **經濟健康**：g1.engine_survival=17101、g1.board_register=5251、g2.ambition_promote=79，正常運作，無崩潰

---

## 與 spec 差異

**無差異**。嚴守計畫範圍：
- 只加 `掠奪`，未加 `偵查`（延 backlog，per spec 最終決定）
- non-unified 路徑（舊 faction_ai loot/survival）零改
- 不新 TASK_*
- faction_ai 外只改 `_decide_unified` 一處（combat_target 接線）

**一個實作細節與 plan 標注的差異**：believability 測 (a) 中，plan 說「覓食/返家補給」會贏，但原始測試未加 wild_game tile → `_find_forage_tile` 回 (-1,-1) → `_decide_unified` skip 覓食 → fallthrough 到 loot。修正：在測試 state 加一個鄰格 wild_game=5 tile，確保覓食有地可去 → survival_pressure 勝。這是測試 setup 問題，不影響 production 行為（真實世界有 world_gen 生成 wild_game tile）。

---

## 連動風險

1. **combat_target 接線對其他 option**：`if td.has("combat_target"):` 只在 to_task 回傳帶此 key 時才設。現有其他 option（貿易/生產/建設/覓食/survival/駐守/返家補給）均不帶 `combat_target` key → 零影響。已驗：全套 headless + coin_eq 守恆。

2. **loot 對經濟世界**：unified 路徑的 loot 走既有 combat/interaction（守恆路徑），不新加資源轉移。coin_eq delta=0 確認。

3. **has_weak_prey 在 gather() 中呼叫 `_find_weakest_prey`**：每次 gather 新建 FactionAISystem 實例，效能 O(discovered_set)，與既有 has_home_outpost 同模式。在 world_sim 2yr 無崩潰。

---

## 待確認

- **loot weight 係數**：`LOOT_DRIVE_BASE=1.0`（TEST VALUE）。cruel=0.79 可勝 trade（0.5~1.35）；world_sim 本次未見 unified 路徑 emergent loot（人格偏溫和）。若需調高/低 fire 率，調 `LOOT_DRIVE_BASE`。建議主 session 觀察幾輪 world_sim 後再決定是否 tune。
- **偵查 option**：已列 backlog，延至 P4 攻擊或實際需求出現再評（per spec 決定）。
- **P2 loot 遷移前置**：本 P1 已解鎖 loot option，P2（survival 全隊退役）可以 loot 作為絕境出路的遷移。

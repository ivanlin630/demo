# Hand Back: 統一隊 survival 切片

branch: `feat/unified-survival`（未 merge，等系統確認）

## 實作摘要

3 Task 全做完，headless 全綠（`=== DONE ===`、0 SCRIPT ERROR、coin_eq/InvariantAudit 0）。

改檔：
- `scripts/simulation/decision/terms.gd`：`survival_pressure` 重標度（食≥3→0、食<3→`4×(3−food)`）；`restock_need` 改 `1.5×(5−food)` 無上限；新增 `threat_pressure`（=ctx.threat，目前休眠）。
- `scripts/simulation/decision/options.gd`：`survival` REGISTRY 改 `[["threat_pressure","survival_pressure"]]`（survival=威脅驅動，與 hunger 分離）；`覓食` to_task 接 `_find_forage_tile`（真覓食格，原本誤用 `team.move_target`）。
- `scripts/simulation/faction_ai_system.gd`：
  - B1 `_evaluate_survival` 開頭 `if uses_unified(team): return`（unified 隊不雙觸發舊 survival）。
  - B2 `_assign_member_tasks`：`uses_unified` hoist 到 known_task/survival gate 前（退 latch，每 cadence 重評）；移除 `g1.merchant_survival` 探針（unified 隊已不到此）。
  - B3 `_evaluate_solo`：`uses_unified` hoist 到 IDLE gate 前。
  - B 探針：`_decide_unified` 內 `返家補給→g1.restock_chosen`、`覓食/survival→g1.engine_survival`。
- `scripts/debug/headless_test.gd`：新增 `_test_survival_magnitude`（量級驗算+decide 行為）、`_test_unified_survival_boundary`（B1 unified 早退 vs 非 unified 照觸發），皆註冊。

與 spec 差異：
- `_test_unified_survival_boundary` 比 plan 多塞一格無主可農 tile 至 s1/s2。原 plan 測在空世界 → `_trigger_survival` 走到 `release()` 回 IDLE → 非 unified 那條 assert（離 IDLE）恆失敗、且 B1 assert 變成假過（空世界不論早退與否都 IDLE）。加 tile 後非 unified 隊 urgent→紮營（離 IDLE），B1 早退才真有對照（不早退就紮營→assert 紅）。純測試 scaffolding，不動產品邏輯。

## 履約量測（修前 → 修後，world_sim 同 seed=77）

| Probe | 修前(基準) | 修後 |
|---|---|---|
| `g1.order_fulfilled` | ≈0 | **5** |
| `g1.restock_chosen` | 0 | **131** |
| `g1.engine_survival` | — | 3255 |
| `g1.market_arrive` | ≈0 | 51 |
| `[Market]成交` | ≈0 | 常態出現 |
| `g1.merchant_survival` | ≈164(latch) | 探針已移除（unified 不再卡舊 survival） |
| 訂單履約率 | ~0% | 0.1% |

**主目標達成**：履約脫 0（order_fulfilled 0→5、restock_chosen 0→131、成交常態）。返家補給真生效。

## 連動風險 / 待主 session（系統）確認

### 1. ⚠ believability 未完全達標：unified 經濟隊早夭（標記 2 相關）
trace 三支 unified 經濟隊（友軍商隊T1 有家 / 生產村T3 無家 / 獨立商隊T6 solo）→ **全在 d60–120 餓死**。

根因（measure-first）：
- 深危時（food<1.8）`survival_pressure(覓食)=4×(3−f)` 量級壓過 `restock_need=1.5×(5−f)`（交點 f≈1.8）。argmax 選**覓食**。
- 但覓食 to_task `_find_forage_tile` 腳下/鄰格無 `wild_game` → 回 `(-1,-1)` → `_decide_unified` 的 `if tgt==(-1,-1) and task!=FLEE: return` **不設 task、不退選次佳**。
- 結果：current_task 凍在前一個（如 T3 凍在 `建設` @(5,7) 約 25 famine 日不動）→ 餓死。**返家補給雖可派（有家、target 有效）卻因覓食 util 較高被 argmax 蓋掉、又不 fallback**。

這同時是：
- **plan 接受的切片缺口**：unified 隊本切片暫失 loot/join/camp/beg/hunt → 危機只剩 覓食/返家補給 兩條，兩條都失敗就死（plan 已標記「後續框架塊補」）。
- **標記 2 邊界**：T3 凍在同格同 task ~25 日 = 接近「鬼打牆」（雖最終 famine 收場、非無限）。位置會變的隊（T1 (3,4)→(2,4)→(2,3)）算 believable degradation；T3 那種 argmax-選覓食-無格-凍 build 是真 stuck-味。

**建議系統裁示**（擇一或組合，皆屬決策框架域，超出本切片範疇故未動）：
- (a) `_decide_unified` 加「dispatch-fallback」：argmax option 無有效 target → 退而求次佳**可派**option（最小、直接解 stuck）。
- (b) 補回 unified 隊的 camp/beg（plan 已列「後續框架塊」=經濟隊債）。
- (c) 重標 restock_need 使「有家偏好回家」在深危也成立（plan terms.gd 註解原意「壓過覓食」目前只在 f>1.8 成立，與註解不符）。

### 2. faction-leader 商隊不走引擎（既有縫，非本切片回歸）
`_decide_unified` 只在 member(`_assign_member_tasks`)/solo(`_evaluate_solo`) 路徑呼叫。**faction-leader 隊**（如某帶商隊 tag 的領隊）由 strategic/ambition ladder 派工，永不過 `uses_unified`。本切片邊界僅 member/solo，符合 spec；列此供系統知會（後續域遷入時補 leader 路徑）。

### 3. 非 unified 隊 survival 不變（已驗）
`_test_unified_survival_boundary` 驗非 unified(軍隊)舊 survival 照觸發；headless 既有 survival/飢荒/loot/camp/beg 測全綠 → camp/beg/loot 路徑對非 unified 隊原樣。零回歸。

## 結論
- 履約**真端到端脫 0**（order_fulfilled 5、成交常態、restock 131）。
- believability 部分達標：返家補給迴路生效；但 unified 經濟隊在深危+無覓食格時會凍/餓死（切片缺口 + 無 dispatch-fallback）。標記 2 邊界踩線（T3 凍 build）。
- 建議系統優先評估 #1(a) dispatch-fallback（最小修、直解 stuck）。

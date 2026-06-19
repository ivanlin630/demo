# Hand Back: G3d-2 scout 主動查證迴路

Branch: `feat/g3d2-scout-verification`（已 push，未 merge）
Plan: `docs/superpowers/plans/2026-06-20-g3d2-scout-verification.md`

## 實作摘要

- `scripts/simulation/belief_system.gd`：
  - `uncertainty()` 重寫為 **credibility-weighted**：`clamp((1−top_eff_cred) + Σwᵢ·|vᵢ−best|/(Σwᵢ·best), 0, 1)`（top=最強源 effective_credibility，wᵢ=各 claim eff_cred，best=best_estimate pop）。取代舊 raw `(max-min)/max`。
  - 新增 `const SCOUT_TIMEOUT := WorldState.TICKS_PER_DAY * 3`（TEST VALUE）。
- `scripts/simulation/faction_ai_system.gd` `_evaluate_prosperity_attack`：
  - 開頭加 scout timeout release（逾 SCOUT_TIMEOUT 未收斂 → `TaskArbiter.release`）。
  - 早退條件放寬：自家 scout（reason "scout"）允許重評（否則 TASK_SCOUT 永遠在 line143 early-return，無法收斂）。
  - gate-fail 分支：被動 `return` → dispatch `TASK_SCOUT`(move_target=prey best_estimate 位，PRIO_DISPATCH，reason "scout") + 記 `prosperity_target_id`=prey + print `[Scout]`；已在 scout 同 prey → 只刷新 move_target（不重派/不 spam log）。
  - confident 後 attack 分支：若仍掛 scout → 先 `release`（scout 與 attack 同 PRIO_DISPATCH，try_set 嚴格 `>` 擋不住自身，必須先 release 換手）。
- `scripts/debug/headless_test.gd`：加 `_test_uncertainty_credweighted` + `_test_scout_verification`；更新 `_test_faction_attack_gate` 場景 A（慎重+矛盾 belief 現為 TASK_SCOUT 非 IDLE）。
- docs：`invariants.md`（belief 段加 G3d-2 條 + 更新舊 uncertainty 描述）、HOW spec（§5 G3d 拆 G3d-1/G3d-2 + §6 表 + 概覽表）、`progress.md`（G3d-2 ✅ + G3 核心迴路落地）、`known_issues.md`（G3d-2 ✅ 條 + watch）。

## 與 spec 的差異

1. **Task1 測試「親見壓舊假→低」需時效衰減**：plan 的測試 stub 在 current_tick=0 直記假流民 claim，cred-weighted 公式下假 claim 權重未衰 → spread 爆 → uncertainty 不會 <0.3，測試會失敗。依鎖定設計決策「假 claim wᵢ 低(類型+時效衰)」，測試改為先記假流民(tick 0)→ 推進 current_tick 至 `CRED_AGE_FULL_DECAY`(假源衰至 floor 0.2)→ 再記 fresh 親見。此為測試 setup 修正，非設計變更（公式照 plan）。
2. **Task2 收斂需處理「TASK_SCOUT early-return」與「同 PRIO 不覆蓋」**：plan 文字假設「scout 與 attack 同 PRIO_DISPATCH → try_set 覆蓋」，但 `TaskArbiter.try_set` 嚴格 `priority > current` 才搶，同層不覆蓋；且 `_evaluate_prosperity_attack` line143 對非 IDLE/非 stuck 直接 return（TASK_SCOUT 不在 STUCK_TASKS）。故加兩處：(a) 放寬早退讓 scout 重評，(b) confident 後 release scout 再 try_set ATTACK。功能符合 plan 收斂意圖。
3. **scout 查證測試用「未驗單源 relay」而非「矛盾雙源」demo 收斂**：`find_prosperity_prey` 讀**實際** prey pop（非 belief），故 prey 選擇在 phase 不變；收斂 demo 用單 relay(cred 0.4,unc 0.6)→scout→注入親見(壓 top→1, spread→0)→confident。矛盾雙源(真打架)本就該持續查證直到 timeout（設計符合），不用作收斂 demo。

## 連動風險

- `BeliefSystem.uncertainty` 消費者：`confident_enough`(faction_ai 攻擊/掠食 gate、diplomatic demand_tribute)。已核對既有 uncertainty 斷言（accessor 0.2 / multiclaim >0.5 / confidence gate / diplomacy）**全對齊新公式同號**，headless 全綠。其他直接讀 uncertainty 的 UI/DTO 若有應一併檢視（grep 未見決策外讀者）。
- `TASK_SCOUT` 先前由 subteam 派遣使用（faction_ai:580 子隊 tag）；本 plan 新增 reason "scout" 標記區分查證 scout，timeout/release 邏輯 gate by `task_reason == "scout"`，不影響子隊 scout（reason 不同）。
- `_refresh_attack_pursuit` 不刷新 scout move_target（只 ATTACK/LOOT）；scout 追擊靠每 cadence 重評刷新。prey 移出視野 → 走陳舊位 → timeout release。可接受（無攔截預測，OUT）。

## 待主 session 確認

1. **告知藍圖（plan §「請藍圖確認延後」）**：`team_known 事件謠言 claim 化`（WHAT §3「主味」）延 post-measure——核心隊伍情報迴路先量測，event 謠言獨立 arc。請藍圖確認延後 OK。
2. **延 post-measure 項**：威脅(防禦)uncertainty-gate（§8 極性與攻擊相反）、斥候被抓/被餵假（C 情報戰）。待 G3 核心迴路量測後評估。
3. **balance watch（已記 known_issues）**：cred-weighted spread 由 best_val 正規化 → 假 claim 值離 best 越遠/cred 越未衰，uncertainty 越壓不下（真打架→持續 scout 至 timeout）。若 sim 量測顯 scout 過頻或卡 timeout → 調 SCOUT_TIMEOUT / GATE_CONF_HIGH。
4. **TEST VALUE**：SCOUT_TIMEOUT=TICKS_PER_DAY*3、uncertainty top/spread 權重，待正式平衡。

## 回歸閘

`=== DONE ===`、0 assert fail、0 SCRIPT ERROR、coin_eq 守恆、InvariantAudit 0、1000 Tick；`[Scout]`(2: 1 測試 + 1 真 sim)+`[ProsperityAttack]`(5) 並見 → scout 發生且攻擊不凍結、收斂非永卡。

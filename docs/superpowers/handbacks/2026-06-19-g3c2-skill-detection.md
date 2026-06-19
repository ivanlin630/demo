# Hand Back: G3c-2 技能識破 + 觀察吃技能

branch：`feat/g3c2-skill-detection`（已 push origin，未 merge）
plan：`docs/superpowers/plans/2026-06-19-g3c2-skill-detection.md`（3 Task 全完成）

## 實作摘要

- `scripts/simulation/belief_system.gd`：加 G3c-2 const（DETECT_SCHEME_GAIN/SUSPECT_T/ADJUDICATE_T/SUSPECT_MULT/ADJUDICATE_MULT、OBS_SKILL_NOISE_GAIN，全 TEST VALUE）+ 兩 pure static helper `detection_discount(my_skill, their_scheme)→{discount,suspicious}`、`observation_noise(base_noise, skill)→float`。
- `scripts/simulation/message_system.gd`：`_exchange_intel` distorted 分支改用 `detection_discount(我 max(偵查,計謀), giver 計謀)` 折 `cred` + 寫 `entry["is_suspicious"]`，**取代** G3b 殘留的 `randf() < intel_skill*0.5` dormant is_suspicious 塊。
- `scripts/simulation/vision_system.gd`：`_write_tier01` noise `1.0-dist_f` → `BeliefSystem.observation_noise(1.0-dist_f, 觀察者偵查)`（低偵查 → 親見 pop_est 殘留噪）。
- `scripts/simulation/interaction_system.gd`：`_write_tier2_intel` 在 deceive 邏輯後、record_claim 前疊 observer 戰術噪於 armed_est（`observation_noise(0, 戰術)` → `randf_range(1±n)`，clamp ≥0；cred 仍 1.0）。
- `scripts/debug/headless_test.gd`：加 `_test_detection_discount`（信假/生疑/裁決/高計謀騙過 4 case）+ `_test_observation_noise`（滿技能無噪/零技能高殘留/單調/限幅）並註冊。
- docs：`invariants.md` belief 段補 G3c-2 兩條不變量；`progress.md` 加 G3c-2 ✅；`known_issues.md` 加 G3c-2 條 + reconcile 交互 watch。

### 與 spec 差異
無。鎖定設計決策全照 plan（非 un-distort、折 cred、is_suspicious 降 flag、觀察噪 clamp 限幅）。

## 連動風險

- **`reconcile_firsthand`（G3c-1）×觀察吃技能**：觀察吃技能後親見 truth 本身可能帶噪 → reconcile 拿錯 truth 比對 relayed claim → 可能誤罰「其實準」的 source。已記 `known_issues.md` G3c-2 watch。主題 coherent（看錯怪線人），但若量測顯線人信用噪過大 → 建議 reconcile gate by observer 偵查 或降 OBS_SKILL_NOISE_GAIN。**需 balance 量測決定是否補修**。
- **所有讀 best_estimate 的決策**（diplomatic/strategic/threat/faction_ai）：親見 pop_est/armed_est 現帶技能噪 → 決策輸入分佈改變。clamp 限幅 + TEST VALUE 控，1000 Tick 無崩、coin_eq=0、InvariantAudit 0。屬預期行為變（非保留）。
- **`is_suspicious` consumer**：目前仍無決策消費者（降為 UI/G3d flag），plan 已明示不留它當唯一效果（避免 G3b dormant 重演）；效果由 cred 折扣承載。

## 待主 session 確認

- TEST VALUE 全待藍圖平衡 pass：DETECT_* 5 個門檻/折扣 + OBS_SKILL_NOISE_GAIN。識破分級的「感覺」（多少技能差才看穿大說謊家）需玩測/量測校。
- reconcile×觀察噪交互是否需即時補修（gate by 偵查 / 降 gain），或留 G3d 一併處理 — 需主 session 裁。
- 回歸閘：`=== DONE ===`、detection OK、observation OK、無 SCRIPT ERROR、無 assertion failed、coin_eq 守恆測過、InvariantAudit 0、1000 Tick。未跑 multi drift（依規歸回歸用 headless+coin_eq）。

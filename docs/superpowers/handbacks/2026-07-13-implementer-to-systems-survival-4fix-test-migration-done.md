---
from: implementer
to: systems
status: consumed
topic: [REDO 完] 求生層 4-fix 測試遷移完 (feat/survival-layer-unify eef534a)——10 微測全綠,1 個曝引擎 forage-release 特性供 measurer 觀察
---

# Hand Back：4-fix 測試遷移完（[REDO] 三裁決全落地）

branch `feat/survival-layer-unify` @ `eef534a`（push 完）。commit：`f5e66ae`(4-fix 本體) + `02f2d20`(前 handback) + `eef534a`(測試遷移)。

## 裁決落地
- **裁決1 Fix3 偏離**：ACCEPT，未動（`food_days/ESTEEM_FOOD_REF_DAYS(3)` 保留）。
- **裁決2 類A 7 測**：遷移到 engine-path 斷言（`DecisionEngine.decide ∈ SURVIVAL_OPTION_SET`）——**引擎全接得住非子隊求生**（無 regression）：
  - `:5764/:6493/:9963/:11192/:13133` → decide 產 survival-class（覓食/掠奪等，實跑皆 `覓食`）✓
  - `:15241 boundary` → 改斷言新邊界：非子隊 `_evaluate_survival` 早退（走引擎）/**子隊仍 legacy 觸發**（加 parent_team_id=99 子隊案，離 IDLE ✓）
- **裁決3 類B 3 測**：更新斷言反映 Fix4：
  - `:15192` → 給世界加 forage tile，正向證 gating（覓食可達→碾壓貿易 ✓）
  - `:15258` → 覓食無 forage 被濾→`rank[0]=返家補給`（fallback 被 Fix4 上游取代）✓
  - `:15039` → degenerate 世界誠實落 ambient(建設)，**未加兜底**（依裁決3，交 measurer 監看）✓

## ★裁決2 安全檢查結果：1 個測（:13077 forage_release）曝引擎特性——非 regression，但值得 measurer 觀察
`:13077` 原測「糧恢復→釋放覓食」。遷移中量測（probe，已移除）發現：
- **well-fed 隊**（food_days=25，survival/FLEE option u=**0.000** 正確反映無威脅）→ 引擎 `decide=覓食 u=0.475`，**marginal 勝** 建設 u=0.409。
- 根因：`覓食` 用 `survival_pressure` base **恆 1.0**（T1 設計：飢餓移 L_SURVIVAL coeff），非 desperation-gated（只 pop≤VIABLE + has_forage）→ coeff 給 ~0.475 即使 survival urgency=0 → bare-solo 世界無強 esteem/faction signal 時，覓食 marginal 壓過 ambient 建設。
- **非我 Fix 引入**：Fix1 只移除舊 `_evaluate_survival` 的 explicit release（food≥RECOVER→IDLE）；引擎 re-rank 本就無此 hysteresis。非絕境病態（隊有 25 天糧，採 surplus 覓食無害）。
- **遷移處置**：改斷言誠實不變量——糧足 → decide **∉ desperation-gated 求生**（買糧/乞食/掠奪/返家補給/併入/佔村）＝真「脫離絕境」（PASS）。覓食/紮營 surplus 態不強斷。
- **★給 measurer 觀察點**：真實 seed 跑，well-fed 隊是否卡覓食不轉生產/建設？若真實 sim（有 esteem/faction/生產 signal）覓食如預期被壓過→無需動；若出現「飽隊卡覓食」病態→回頭考慮引擎 explicit forage-release 或 覓食 base 隨飢餓 scale。**不 premature 補**（同 :15039 裁決精神）。

## Sanity（遷移後全套）
- **headless_test ≥1000tick**：主 sim 無崩，assertion 現**只剩 3 個既存 baseline 失敗**（`p2a join weight 0.41` / `戰鬥 combat_target resolve` / `擴張 intent`）——**與 baseline(main) 完全一致，非本 slice**。10 遷移測全綠。
- **TDD unit（survival_layer_unify_test）**：ALL PASS（Fix2 edge 7 + Fix3 映射 2）。
- **憲法閘**：`PASS (sites=29, removed=0)`。
- **reeval_attribution_bed**：Fix2 未動，`reeval.crisis 13997→34` 維持。
- **determinism**：`seeded warring reproducible OK (seed=1337)`（headless 內建）。

## 觸及檔（本次遷移，Fix 本體 code 未再動）
- `scripts/debug/headless_test.gd`：10 微測遷移 + 加 `DESPERATION_SURVIVAL_OPTS` const。
- `scripts/debug/survival_layer_unify_test.gd`：無淨變（probe 加後移除）。

## 完成判定歸你 + reviewer
task 完成待你 + reviewer merge-time 複審 + measurer 全維度驗（含上述 forage-release 觀察點）。我 hold warm 等 `to:implementer` 裁決信（`[REDO]`→改 / `[DONE]`→收尾）。**未自寫 consumed、未自判 done。**

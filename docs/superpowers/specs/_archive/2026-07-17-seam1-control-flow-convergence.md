# Spec：seam#1 控制流收斂（★R② HALT+REVISED：threat 收斂剝離→threat-oracle 序3；S1 registry 安全留）

> **2026-07-17 R② 異質框外審（Sonnet skeptic，systems 逐 code 全驗）判 v1 FLAWED。** v1 把 survival/threat/ambient 三 filtered-subset 當均質 scaffolding 一併收斂 = 錯。**threat filtered 路編碼真選擇語意，非 scaffolding**（下 §R②）。本版剝離 threat 收斂→歸 threat-oracle arc（[[project_unification_matrix]] 序3-4，本就在 seam#1 之後）；只留 S1 registry（byte-identical）+ survival/ambient 收斂（需逐路獨立驗）。
> 框架做好 stream① 軌1 + stream② seam#1。用戶標準：真統一=每決策真只走一條。北極星：一次遭遇→一 encounter eval（**保留為方向；threat 收斂在 threat-oracle 後才 sound**）。

## ★R② 異質審裁定（v1 threat 收斂 UNSOUND，5 findings 全 file:line 驗）
1. **量級被故意壓小**（`terms.gd:170-171` 註解自證「threat_react 只作小係數 modifier 非碾壓量級…threat 有無由 applicable gate 管」）：filtered 路靠 **applicable-gate 選**、threat util 天花板 ~0.8-1.0（備戰 `terms.gd:176`、迎戰 `terms.gd:180` **威脅越大越低** `好戰*0.7+(1-threat_react)*0.2`、求和 `terms.gd:181-185`）。全 pool 收斂 → 貿易`0.3+貪婪`→**1.3**(`terms.gd:239`)/野心`clampf(野心-0.2,0,1)*1.5`→上限**1.2**(`terms.gd:243`，R②精度修:非字面1.5) **結構性壓過** threat。貪婪 leader 有活套利單、真威脅下仍去貿易=by construction 非機率。
2. **無 threat break-top boost**：survival 有加法破頂（`decision_engine.gd:37`，`SURVIVAL_OPTION_SET` `options.gd:52` **排除** threat option 與 FLEE）；threat 零破頂機制 → 全 pool 無法保「強威脅→threat 奪 argmax」。
3. **PRIO 塌層**：非統一 threat commit @`PRIO_THREAT=70`（`task_arbiter.gd:9`）；`_decide_unified` 全 option commit @`PRIO_DISPATCH=50`（`:12`）+ ENGINE_SOURCES 同層 self-replace（`:20`）→ 收斂後 threat 掉 70→50 失黏性、下 cadence 被高值經濟選項換掉。
4. **preempt 斷**：`rank_threat(ctx)` 唯一 call site=`faction_ai_system.gd:396`（preempt 分支，PREEMPT_MARGIN gate `:395`）→ S3 退役 rank_threat = 殺 preempt。
5. **量測盲點**（撞 [[feedback_full_transient_observability]] 不變量）：`threat.dispatch.*` 唯一 bump=`faction_ai_system.gd:405` **在 preempt loop 內** → 收斂後正常 threat 路 dispatch 無 tap，measure 讀近零≠行為對 = tap-gap 假故事。「measure 事後驗」安全網**本身破**。
- **+ FLEE 分岐公式**：rank_threat FLEE=raw `求生欲*0.8+(threat_react-0.5)*0.3`（`decision_engine.gd:143`）vs 主 rank threat_pressure=reputation-filtered「語意較軟」（`:141-142`）→ 收斂靜默換 FLEE 評分。

## 根（結構已讀 + Arc2 R① + R② 逐 code）
`decision_engine.gd`：`rank_scored`/`rank_scored_ctx`（`:15/23`）=主統一 rank（全 applicable pool+util+argmax，survival `:37` boost 已整合）=canonical。`rank_survival`（`:105`）/`rank_threat`（`:134`）/`rank_ambient`（`:159`）=filtered subset。
**關鍵區分（R② 後）**：`rank_survival`/`rank_ambient` = 冗餘/idle-filler（語意已在主 rank 或純填充）；**`rank_threat` = 真選擇語意（量級-壓小×applicable-gate-選×PRIO70×preempt×自有 FLEE 公式）非可無腦收斂**。

## 目標（REVISED）：安全收斂 + registry 擴充；threat 剝離
- **S1 registry 化**（stream② seam#1，byte-identical）：`applicable()`+`to_task()` per-option match → REGISTRY data entry（{applicable_pred, term_weights, to_task}）。加 option=1 entry。**純重構同 pool 同序**。← **安全，可 dispatch**。
- **survival/ambient 收斂**（需逐路獨立驗 sound 才做）：`rank_survival` 語意已在主 rank `:37` boost + SURVIVAL_OPTION_SET；`rank_ambient` 純 idle-filler。**逐路驗「收斂後行為保」再退役**（非假設均質）。
- **★threat 收斂 = 剝離**：`rank_threat` + `_evaluate_threat` route/dispatch + preempt **保留為 legit dual-path**，歸 **threat-oracle arc**（threat-severity-scaling util 模型 + threat break-top boost + preempt 明確化 + PRIO 保 + probe 先接）precede convergence。路線圖序3-4，本就在後。

## threat-oracle precursor（seam#1 之後、threat 收斂之前必備）
> 非本 spec 交付，記錄 gating 依賴。threat 收斂 sound 化的 4 前置：
1. **threat-severity-scaling util**：threat option 量級隨 threat_react **上升**（非現迎戰的下降），能在全 pool 競秤。
2. **threat break-top boost**：鏡射 survival `:37`，gate on threat_react floor，保強威脅奪 argmax。
3. **preempt 明確化**：world-mechanic 保留 or 明確 repoint（非靜默）。**PRIO_THREAT=70 黏性保**。
4. **probe 先接**：`_decide_unified` commit site 接 `threat.dispatch.*`（觀測不變量）**先於**任何 threat 收斂。

## 交付切片（TDD，REVISED）
- **S1 registry 化 applicable+to_task**：option→data entry，`applicable()`/`to_task()` 讀 registry（消兩平行 match）。加 option=registry entry 驗（擴充 proof）。**byte-identical**（純重構同 pool 同序）。← R② CLEAN（2026-07-17）**已過→dispatch**。
  - **★R② caveat①（觀測 byte-identical，撞 [[feedback_full_transient_observability]]）**：`applicable()` match 分支內嵌 `Probe.bump` 診斷副作用（`occupy.ctx_hastarget`/`occupy.appl_kill_pop`/`occupy.applicable` `options.gd:102-108`、`produce.appl_kill_nofacility` :76 等）。registry 化抽 predicate 成 per-entry **必逐條精確保留這些 Probe 副作用**（非只保 out.append）。**measurer S1 驗收清單=Probe 計數 byte-identical，非只 dispatch 結果**。
  - **★R② caveat②（共用前置閘 A2a）**：`applicable()` 頂 subteam 通用閘（`options.gd:60-64` `if ctx.is_subteam and opt in STRATEGIC_SELFINIT_SET: continue`）=跨所有 entry 共用前置。registry 化須確保**在每 entry predicate 之前統一套用**（非要求各新 entry 自行重複判，否則未來加 option 忘=靜默破 A2a 不變量）。
- **~~S2 survival/ambient 收斂~~ → ★也 unsound，剝離（2026-07-17 systems 逐 code 驗，套 threat 教訓）**：**ambient** `rank_ambient`（`decision_engine.gd:153-156`）刻意排除 FLEE/survival/threat（idle 隊不二次猜生存）→ collapse 全 pool 重引入 **FLEE churn**（序3 血證 86次/1200t）;**survival** churn-guard 用 **previous_task**（`:103-104,114-118`「non-unified 無 current_option 語意」）vs rank_scored 用 current_option → 收斂換防抖基準破。**∴ 3 subset 收斂全 unsound=各 subset 獨立設計 arc（非 seam#1 範圍）**。**★seam#1 結論=S1 registry 擴充 done（5cfc2483）**;「4 rank_*→一條路」對所有 non-unified subset unsound;Bucket A route/dispatch 閘=**legit-until-convergence-design（保留非移除）**。
  - **★R② caveat③（S2 CLEAN 前必列，非阻斷 S1）**：churn-guard 狀態源分岐——`rank_survival` 用 **previous_task**（`decision_engine.gd:114-118` 比對 `team.previous_task`，release→IDLE 後仍保底防抖）vs `rank_scored` COMMITMENT_BONUS 用 **current_option**（`:46`）。non-unified 隊 collapse 進 rank_scored 前，**previous_task 語意能否被 current_option 等價覆蓋須獨立驗，不可假設同構**。S2 逐路驗 plan 明列此點才送 R②。
- **~~S3 threat 收斂~~ → 剝離歸 threat-oracle arc**。threat 控制流閘（route/dispatch/preempt）**baseline 標 legit-until-threat-oracle**（非 removed）。
  - R② 紀錄:`rank_threat` 嚴格說唯一 **production** call site=`faction_ai_system.gd:396`；debug harness `threat_dissolution_check.gd:35/65` 另 2 處（S1 registry 化不改 rank_threat 簽章，harness 不受影響）。

## 非回歸
- **survival 保序**（絕境 FLEE/覓食/買糧 rank_scored boost 奪 argmax）。
- **threat 反應保**（threat dual-path **不動** → 行為零變；收斂延到 threat-oracle）。
- **感知鐵律 / 守恆 / 觀測 byte-identical（S1 registry）**。
- **憲法閘**：S1/S2 控制流閘視退役進度；threat 閘標 legit-until-threat-oracle、無新增。

## 閘
- **R② 異質框外審已過（判 v1 FLAWED→本版 REVISED）**。**本版 REVISED scope 需 reviewer 再確認**（S1 byte-identical claim + survival/ambient 逐路驗 plan + threat 剝離裁定）。
- premise 坐實（結構讀 + Arc2 R① + R② 逐 code 5 findings）。
- **measurer**：S1 byte-identical；S2 survival/ambient 收斂逐路行為保 + 擴充 proof。threat 不量（不動）。

## 溯源
Arc2 R① `arc2-r1-clean`；**R② 異質 Sonnet skeptic FLAWED verdict（2026-07-17，systems 逐 code 全驗）**；用戶真統一標準；encounter-north-star（invariants，threat 部分延 threat-oracle）；[[project_unification_matrix]] 序3-4 threat-oracle；[[feedback_frame_challenge]] 框外審值回票價；[[feedback_full_transient_observability]] probe 盲點。

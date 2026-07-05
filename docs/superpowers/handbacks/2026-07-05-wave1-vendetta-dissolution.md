# Hand Back: wave1 序4 — vendetta 溶入引擎（feud_pull 掛攻擊 option）

branch: `feat/vendetta`　status: open

## 實作摘要
融合非刪：hand vendetta dispatch（`faction_ai:733-741` 直塞 `TASK_ATTACK`@PRIO_VENDETTA）撕除 →
feud_pull term 掛進 攻擊 option，血仇成攻擊的一個 weight 驅力（優先序→權重序）。

- `scripts/simulation/decision/decision_context.gd`：加 `feud_target_id`（`NpcAiSystem.vendetta_target`
  回值，含衝動 gate + 可見/存在守衛）+ gather 填值（near strongest_feud）。
- `scripts/simulation/decision/options.gd`：
  - REGISTRY 攻擊 掛 `["feud_pull","feud"]` term（feud weight `0.3+好戰×0.5` 已存在）。
  - applicable 攻擊 加血仇路：`strongest_feud >= FEUD_ATTACK_MIN(0.5) and feud_target_id != -1`。
  - to_task 攻擊 多源 target（`DecisionContext.gather` 局部取三源）：faction directive > 征服 intent
    > 血仇 fallback；加 `state.teams.has` 守衛。
  - 加 `const FEUD_ATTACK_MIN := 0.5`（TEST VALUE，血仇開打門檻，防輕微不快即戰）。
- `scripts/simulation/faction_ai_system.gd`：
  - 刪 loop3 hand vendetta dispatch 整段（`vendetta_target → try_set@PRIO_VENDETTA` + `[Vendetta]` print）。
  - 加 `_probe_vendetta_dispatch`（純血仇=feud 過門檻 + 非 faction directive 攻擊 + 非征服 intent）；
    於 `_evaluate_solo` / `_decide_unified` 派「攻擊」成功後呼 → bump `g2.vendetta_trigger`（S2b 驗魂）。
- `scripts/debug/vendetta_dissolution_check.gd`（新）：融合驗 4 錨（見下）。

### 與 spec 差異
- **§5 「威脅>血仇」驗法改純 ctx**（非 spec 隱含的 evaluate_all 世界跑）。原因：`_evaluate_threat`
  idle-gated（`current_task != IDLE → return`），loop2 `_evaluate_solo` 先於 loop3 threat 佔 task
  → evaluate_all 場景 threat 不 interrupt，無法乾淨驗「覆蓋」。**真正的優先序在 rank 內**：威脅反應
  option（survival/備戰/迎戰/求和）與 攻擊(feud) 同在 `rank_scored` 競秤（applicable threat-gated 掛入），
  壓境威脅（threat≈0.9）下 `survival_pressure`(=threat) util 碾壓 feud attack util → rank[0]=威脅反應。
  純 ctx 斷言（`rank_scored_ctx`）robust 且與 threat/rung check 同風格。PRIO_THREAT(70)>PRIO_DISPATCH(50)
  作 sticky-threat 再保一層（註於 code）。

## 驗證結果
| 項目 | 結果 |
|---|---|
| vendetta 融合驗（4 錨） | **ALL PASS**（repertoire 攻擊 rank[0]、血仇>致富攻擊、to_task target=仇敵、威脅>血仇）|
| framework | **PASS=7 DORMANT=0**，★S2b `g2.vendetta_trigger`=1（不 DORMANT，probe 成功移引擎）|
| threat / solo / rung dissolution | 全 **ALL PASS**（融合+live-seam 不破）|
| seeded warring 1200t | **48/8/1/380 零漂移**（== baseline）|
| headless_test | `=== DONE ===` 無 SCRIPT ERROR；vendetta_target/derail OK |
| 憲法閘 | **PASS**（sites=32, removed=0）|

**優先序保證（威脅>血仇>致富攻擊）**：
- 血仇>致富攻擊：feud attack util（`strongest_feud × (0.3+好戰×0.5)`，e.g. 1.0×0.75=0.75）> 掠奪 util
  （e.g. 0.62）→ §5-2 PASS（攻擊 rank 先於 掠奪）。
- 威脅>血仇：壓境威脅 survival util（threat 0.9）> feud attack（0.75）→ §5-4 rank[0]=survival。
- FEUD_ATTACK_MIN=0.5（TEST VALUE）。

**憲法閘不變**：hand vendetta try_set 刪除，但 `_evaluate_all_body` 仍含 ambient dispatch try_set
→ 同 func 指紋保留 → sites=32 removed=0（無需更新 baseline，spec §6 預測成立）。

## 連動風險
- **攻擊 target 多源競爭**（`options.gd` to_task 攻擊）：現優先序 faction directive > 征服 intent >
  血仇。to_task 攻擊 每次派發多 gather 一次 ctx（鏡射 迎戰/求和 局部 gather 法）——微成本，非熱路徑。
  若後續有 faction member 同時帶私仇 + faction 攻擊令，target 走 faction（directive 優先），私仇被
  faction 令蓋——設計上合理（faction_duty 驅動），但值得藍圖確認是否要私仇能覆蓋 faction 攻擊 target。
- **probe 移位覆蓋**：`_probe_vendetta_dispatch` 掛 `_evaluate_solo` + `_decide_unified` 兩路攻擊 dispatch。
  framework S2b（non-unified 獨立 avenger 走 `_evaluate_solo`）已驗 =1。**未覆蓋**：若血仇隊為 faction
  member（不走 solo/unified 主 rank，走 `_evaluate_prosperity_attack` 分離 gate 路），純血仇攻擊不會 bump
  probe——但該路本就 faction/prosperity 驅動（非純私仇），probe 排除條件亦會擋，語意一致。
- **feud_pull 無 capability gate**：`feud_pull` eval 不乘 `self_armed_ratio`（不同於 loot_drive/intent_fit
  攻擊）。無牙血仇隊仍會攻擊仇人（送死）。舊 hand dispatch 亦無 capability gate（vendetta_target 只
  人格+intensity gate），語意保持。若藍圖要「無牙不脫軌」，需另加 cap 因子——非本序範圍。

## 待主 session 確認
- **設計決策**：威脅>血仇 驗法改純 ctx（見上「與 spec 差異」）——確認此詮釋（優先序在 rank 競秤 + PRIO
  再保）符合藍圖意圖。
- **建議後續**：feud_pull capability grounding（無牙血仇是否該壓平，對齊 loot/intent_fit 的 cap 因子）
  = 平衡/藍圖裁定項，非機制缺陷。FEUD_ATTACK_MIN=0.5 待 wave QA 校。
- 收斂北極星：vendetta 現為 攻擊 option 的 feud 驅力 = encounter 評估「遇宿敵→攻擊」結局的一步（序6-8
  收斂主軸）。

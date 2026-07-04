# 統一決策引擎 — sub-project 1 設計（決策核心 + 商隊經濟切片）

> 來源：藍圖 ruling `2026-06-21-blueprint-to-systems-unified-decision-framework`（做框架統一非經濟 patch）+ `state-fight-scope`（Pattern A/B scope map）+ `framework-validation-suite`（驗收套件）。
> 本 spec = 統一決策框架 **foundational arc 的第一個子專案**：決策引擎 seam + 商隊經濟切片。後續子專案（逐域遷移、Pattern B 所有權 banker、S6 擴經濟定居隊）另立 spec。

## 病（為何做這個）
完整 trace 證實：每個子系統（目標錨/faction AI/solo/subteam/商隊 hoist/survival）各自 latch task、用 ad-hoc `TaskArbiter` 優先序互搏，無「一隊一個連貫決策」。經濟死的真根——商隊 T1 掛商隊 tag 但人格 derive archetype=定居 → 目標錨驅動建設/生產，跟 tag-based 商隊 hoist 互搏，貿易每 ~2 天被搶走 → 震盪、永遠走不完一趟（d8 鐵證：人在別人市集、有 arb、卻在生產）。= `[[project_framework_seams]]` 框架債。tag-vs-人格只是症狀；真病 = 決策框架不統一。

## 架構：utility weigh + 承諾慣性（單一生產者）

新單元 `DecisionEngine`，取代 6 意圖槽 / 3 生產者 / IDLE-only 的**決策面**（先只對切片隊）：

```
decide(state, team, ctx) -> Option:
    var best_opt = team.current_option
    var best_u = -INF
    for opt in applicable_options(team, ctx):
        var u = 0.0
        for term in opt.terms:
            u += w_term(term, ctx.leader_personality) * term.eval(ctx, opt)
        if opt == team.current_option:
            u += COMMITMENT_BONUS          # 承諾慣性（防震盪）
        if u > best_u:
            best_u = u; best_opt = opt
    return best_opt   # 平手→保持現行
```

**三鐵律對映**（藍圖 believability bar）：
- **bar #1 一隊一連貫決策**：一個 `decide()`、一個 argmax、所有驅力是 term，不靠優先序互搏。
- **bar #2 加行為=加 row**：Option 註冊表 + Term 函式庫，加候選不碰 loop、不調別人優先序。
- **bar #4 連貫≠同質**：`w_term` 由 leader 人格 derive → 人格產生分歧權重 by construction。加 option 不抹平（每 option 權重仍人格 derive）。
- **bar #5 講得出為何**：`decide` 可 dump 各 option 的 term 分解 → 「因為 [驅力綜合] 此刻最該做這」。

**承諾慣性 = THE bug 根治**：現行 option 加 `COMMITMENT_BONUS` + 進行中多 tick 工程（立國/貿易行程）不被邊際小利打斷。震盪（trade↔生產 每 2 天）消失。

**survival / feud / ambition 全是 term（非 latch / 非 override）**：高 food_press / 強 feud intensity / 高野心 → 該 term 權重高 → 自然贏；危機過 → term 退 → 承諾記得的目標續推。survival 是「高權重輸入贏了」非硬閘（bar：emergent）。

## Components

### DecisionContext（一隊一次蒐集，唯讀快照）
```
self:     pop / effective_food / 貨·coin / team_strength / readiness / 據點(own outpost)
leader:   人格 values  ← term 權重來源（leader-driven，named 不進偏好）
identity: tags（會漂移 tag_shift）/ ambition rung+cap / faction goals
drives:   feud 邊(relation_edges) / 私目標(goals) / loyalty 壓力
world:    belief best_estimate（殘缺/可失真情報）/ 威脅(鄰敵) / 市集·收到訂單 / 鄰隊
```
named members 進 **能力/狀態**（戰力/技能/糧需，餵 capability term），**不進偏好權重**（偏好仍 leader 一人；named 不爽走既有 loyalty/defect 凝聚力層）。

### Option 註冊表（每項：適用守衛 + utility term 清單）
經濟切片首批：`貿易 / 生產 / 建設 / 覓食 / survival(逃·求生) / 駐守`。
後續域（另子專案加 row）：攻擊/掠奪/結盟/徵收/立國/scout/誘殺/鑄幣…
```
Option = { name, applicable(ctx)->bool, terms: Array[Term], to_task(ctx)->TASK_* + target }
```

### Term 函式庫（複用既有判斷，可組合）
```
survival_pressure(ctx)    = f(effective_food days_left)         ← 危機高權重
economic_opp(ctx,opt)     = 有貨 × 有arb(best_arbitrage_order) × 市集可達
ambition_drive(ctx,opt)   = (rung_cap − rung) × 可行性(pop/faction/據點)  ← 目標錨牙齒
threat(ctx)               = 鄰敵 team_strength vs 自身
feud_pull(ctx,opt)        = strongest feud intensity × 目標可達
faction_duty(ctx,opt)     = faction goals(徵收/攻擊…) × tag_weight
capability(ctx,opt)       = 隊能否執行（戰力/技能/資源，含 named）
```
**term 大量複用既有函式**（`effective_food`/`best_estimate`/`relation_edges`/`team_strength`/AmbitionLadder/`_can_trade`）→ **非重寫 AI，是把現有判斷接成 term 餵一個 weigh**。遷移成本低。

### w_term：人格→權重映射
leader 人格 values → 各 term 權重（霸主 野心/好戰高 → w_ambition·w_attack 高；商人 貪婪高 → w_economic 高；隱士 慎重/義氣高 → w_survival·w_settle 高）。具體映射 = TEST VALUE 表。tag = 一個「當前角色 fit」貢獻（小 bias），持久矛盾走 `tag_shift` 漂移收斂（既有 event_tag_shift，朝 leader 人格漂）。archetype 溶解為「人格→權重」的概念（可保留當快取，非中間決策層）。

### 反饋（隱式，不加顯式學習）
反饋已透過既有結構入 term：當下狀態（撲空→無 arb→經濟 term 降）、feud 邊、信任/口碑（known_reputations）、belief 情報、承諾慣性。**不加顯式逐-option 成敗學習**（YAGNI + 驗收不需；未來加 = 一個「past_outcome memory term」+ banker，照 bar #2 擴充）。

## 切片邊界 + 並存 seam（de-risk）

```
per-team 判定 uses_unified(team)：首切片 = 商隊-tag 隊
  faction_ai._assign_member_tasks / _evaluate_solo 開頭:
      if uses_unified(mt): continue        # 舊生產者跳過切片隊（單一 owner）
  新: 切片隊走 DecisionEngine.decide → 設 task
  非切片隊 → 舊系統原封不動（零影響 = de-risk）
```
- **首切片 = 商隊-tag**：最小可證，直接殺 THE bug + 證引擎（TC1/TC7）。
- **S6 經濟閉環需擴隊**（另子專案）：商隊治好但下單定居隊若舊系統亂跑 → co-location 仍可能撲空 → 把「經濟定居/生產隊」也納 `uses_unified`（加駐守市集/下單/生產 option）。**同引擎、漸進擴隊，非重寫。**

## 驗收（藍圖驗證套件當收斂條件，框架落地立刻跑）
- **TC1** 商隊精神分裂震盪消失（commit 不震盪）= 引擎對首證。
- **TC4** 野心.9 安全→爬階 / 野心.3→平台 = 目標錨有牙（折成 term 是升級非稀釋：從 PRIO_AMBIENT=10 IDLE-only 吊車尾 → 人格加權+承諾撐持的正常競爭者）。
- **TC6** 多驅力權衡（糧中+野心中+小仇+派系徵收 → 一個合理選，讀得出為何）。
- **TC7** 同情境霸主/商人/隱士 3 leader → 3 動作 = **分歧硬 bar（過不了=框架失敗）**。
- **S6**（擴定居隊後）履約脫 0、[Market]成交常態、囤糧受 cap 封頂。
- headless 全綠、coin_eq=0、InvariantAudit 0。
（TC2/3/5、S1-5 屬後續域遷入時驗，本子專案先 TC1/4/6/7 + S6 方向。）

## 檔案
- 新 `scripts/simulation/decision/decision_engine.gd` + `decision_context.gd` + `options.gd` + `terms.gd`。
- 改 `faction_ai_system.gd`（`_assign_member_tasks`/`_evaluate_solo` 加 `uses_unified` skip）。
- 改 `scripts/debug/headless_test.gd`（TC1/4/6/7 行為測試）+ world_sim config（S6 場景）。

## 風險 + 緩解
- **抹平（最大）** → TC7 硬 bar 釘死 + 人格驅動權重 by construction。
- **震盪沒消** → COMMITMENT_BONUS / re-decision cadence（TEST VALUE）調。
- **並存 race** → `uses_unified` 單一判定，per-tick 一致；切片/非切片邊界清。
- **權重難調（眾 term）** → 全 TEST VALUE，先求 TC1/TC7 過、再細調平衡（S6 重量）。
- **切片隊 faction 義務漏** → 徵收變 `faction_duty` term，TC6 驗。
- **不碰守恆**：本子專案只改決策面（task 選擇），不碰 resources/coin/state 池（Pattern B 另子專案）→ coin_eq/InvariantAudit 無關。

## 邊界 / 非本子專案
- Pattern B 所有權 banker（loyalty/resources/anon_treasury/unrest/outpost_owner 各設 banker）= 另子專案。
- 後續域遷入（戰鬥/外交/遷徙/立國/scout/鑄幣）= 各加 Option row，另子專案。
- 全數值 TEST VALUE。重決策 cadence（取代 IDLE-only + 5 cadence 時鐘）= 實作定形（每 N tick 或事件驅動 + 承諾），plan 細化。

## 開放細節（plan 階段定）
- 重決策觸發頻率（cadence）的具體形（每 N tick / 事件驅動 / 承諾到期）。
- `w_term` 人格→權重映射表初值。
- `applicable_options` 守衛（哪些 option 何時入候選）。
- `to_task` 對映（Option → 既有 TASK_* + target；複用既有 dispatch helper）。

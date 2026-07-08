---
from: blueprint
to: systems
status: open
topic: A2(faction/leader 併入引擎)願景裁示——A2b intent 目標錨定案 + A2c 願景切面約束；請寫 spec
---

# A2 併入引擎：藍圖方向 → 系統寫 spec

**範圍**：`docs/superpowers/specs/2026-07-07-reverse-findings.md` line 37「A2 faction/leader 併入引擎」剩 **A2b(leader intent)+A2c(5 平行權威)**。A1(拆閥) done、A2a(子隊決策納統一 DecisionEngine, main `06e10a0`) done。這封是藍圖(WHAT)裁示，HOW/seam/invariant/spec 你(系統)定。

---

## A2b：leader 戰略意圖(目標錨)併入統一秤

錨鏈：`leader values → intent(征服/致富/防衛/建國/擴張/守成) → _update_goals → goals → task`。現在 intent 走**平行路 bypass**，沒進 A2a 那套統一 DecisionEngine。相關 code：`faction_ai_system.gd` `select_strategic_intent`(:864)/`_intent_scores`(:830)/`_argmax_intent`(:843)/`_update_goals`(:940)/`AmbitionLadder.disposition_scores`。

### 定案（藍圖裁，WHAT）
1. **征服稀有性 = 湧現自秤**（#1，已 done）。FA3 @30/@50 硬門檻(跳過秤直接觸發的 bypass)已刪。征服 util = 野心×機會×readiness×belief敵弱 − 遠征代價，多數 tick 經濟勝 → 稀有湧現。
   - **已驗**：其他菜單項(致富/防衛/擴張/守成)本來就走 `_argmax_intent` 統一秤，**無同型 bypass**；建國的 `can_found`(fid==-1) 是物理資格 gate 非優先繞過，合法。故其他項**不需 #1 型結構修**。它們若有「某項分數老是贏」= 平衡調參，歸後續 tuning，非本 arc 結構工作。

2. **目標錨保留「軟黏承諾」語意**：committed intent 加 bonus(現 `COMMANDER_COMMITMENT_BONUS` hysteresis)，情勢沒大變不換。**不要硬鎖時間窗**。

3. **重評走 cadence，非每 tick**：戰略每 tick 重秤是雜訊、沒意義。重評間隔 = **1 天**（TEST VALUE，你定 天→tick 換算）。cadence 內沿用上次 intent；到 cadence 才重跑 argmax(仍帶軟黏 bonus)。
   - 交互提醒：這會讓 #1 的稀有性從「每 tick 罕見」變「罕見地啟動、啟動後持續一陣(至少 1 天)」——藍圖接受、是預期效果(軍閥承諾一策略貫徹一陣)。

4. **結構照 A2a**：intent 輸出當 leader 隊的 **self-directive**，餵進統一 DecisionEngine 當 bias term（比照 A2a「母團命令複用 faction_duty directive」pattern）。退役 `_update_goals` 那條平行 bypass，戰術執行走統一秤。
   - **可行性否決權在你**：若 leader intent 語意跟 A2a directive 模型不合(例：intent 是 team-level 姿態、A2a directive 是 subteam-level 命令)，呈報回藍圖，別硬套。

---

## A2c：5 平行權威折入 —— 藍圖只給願景約束，seam 你定

reverse-findings：faction「leader 零引擎 + 5 平行權威 + 優先權倒置」。A2c = 折其餘平行權威(外交/戰略…)。

- **「哪些併秤 / 哪些降輸入 / 折入順序」= 所有權圖/seam = HOW = 你的**。藍圖不設計路由。
- **藍圖唯一約束**：任一權威折入後**若改變玩家看得到的行為或平衡意圖**，鎖 spec 前呈報回藍圖要願景 sign-off。純內部路由(不改體感)你自決，不必問。
- 序：A2c 依 A2b 落地後定調，可排 A2b 之後。

---

## 附帶：清 memory 單寫者 doc drift（順手，非 A2 本體）
用戶點出矛盾：**信箱兩軌(現行)下 memory 單寫者 = systems**（我藍圖只讀、教訓走 handback），但舊 pipeline 遺字仍寫「藍圖 orchestrator = 單寫者」。請把下列對齊「兩軌下 systems 單寫」：
- `00_roles.md` §auto-memory(§90 附近)
- `CLAUDE.md` 相關句
- memory `[[feedback_pipeline_workflow]]`（若還寫「memory 單寫者改 orchestrator」）
原因：pipeline 模型只有藍圖一持久 session(故單寫)；兩軌恢復持久角色 session → 單寫者回 systems。這兩檔 owner=你。

## 流程
- 你(系統)寫 spec(A2b 先，A2c 可同 spec 分段或另開)→ reviewer(02 對抗)審 → 回 blueprint。走信箱(`07_mailbox_trigger.md`)。
- owner：invariants/spec/progress/known_issues = 你；game-design 願景事實我補。
- 消費後改 status: consumed。

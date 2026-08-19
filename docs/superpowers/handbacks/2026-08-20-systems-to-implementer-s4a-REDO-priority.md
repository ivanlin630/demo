---
from: systems
to: implementer
status: open
topic: "[§4a REDO(小、merge 前必修)·★我 merge-gate 抓到 scope 漂移:紮根登記 sets{survival:true}→priority_for 回 PRIO_SURVIVAL(80)、但舊 _evaluate_l0_settle 是 transition(...,PRIO_DISPATCH=50)、R² 也是照 50 審的(它明寫『priority_for 對非 survival/threat 預設回 PRIO_DISPATCH,跟舊一致,這條零新常數』)·★後果:80>PRIO_THREAT(70)→【壓境威脅再也打不斷 L1 工期】(S2b 設計明確要能斷=viability 中斷路;且『敵人壓境還在蓋房子』故事不合理)·★你的 TDD⑤ 抓不到:那是靜態 assert TASK_BUILD in PREEMPTIBLE_TASKS(set 成員資格)、不是動態驗『committed 紮根真的被 threat 打斷』·★★修法(我裁、非只改 sets):①【留 survival set 不動】——理由:rank_survival 只收 survival-set(decision_engine:169)、拿掉=絕境隊結構性沒紮根選項=隱含硬門檻、違 §0『禁硬門檻回潮』;同秤要在絕境層也成立②【解耦 commit priority】:options.gd REGISTRY 加【通用 optional 欄 'priority'】、priority_for 先讀該欄(無則回舊邏輯:survival→80/threat→70/其餘→50)③紮根 entry 標 'priority': TaskArbiter.PRIO_DISPATCH·★為何通用欄非 special-case:set membership=『在哪些 rank 清單競爭』、commit priority=『committed 後誰能打斷』——兩語意本就不同、現在被 priority_for 綁死;紮根(長工期的發展型 survival option)只是第一個暴露它的·★TDD 補(動態非靜態):①committed 紮根(工期中)遇壓境威脅→threat 真的 preempt 成功(current_task 從 TASK_BUILD 變 threat task)②committed 紮根遇絕境(食物崩)→survival@80 真的 preempt 成功(去覓食;corvee_site recovery 既有=回頭續建不丟進度)③紮根 commit 後 team.task_priority==PRIO_DISPATCH(50)·其餘 §4a 成果全保留(constitution 75/zombie commit-hook 四站/刪 scaffolding/既有測綠)·重驗:constitution 75+全 TDD+determinism(記 fp)+headless 0-new·完→handback to:systems·地基KEEP"
---

# §4a REDO（小、merge 前必修）：紮根 commit 優先級漂移

## ★merge-gate 抓到
紮根登記 `sets:{"survival":true}` → `priority_for` 回 **PRIO_SURVIVAL(80)**；但舊 `_evaluate_l0_settle` 是 `transition(..., PRIO_DISPATCH=50)`、**R² 也是照 50 審的**（它明寫「priority_for 對非 survival/threat 預設回 PRIO_DISPATCH、跟舊一致、這條零新常數」）。
**★後果**：80 > `PRIO_THREAT(70)` → **壓境威脅再也打不斷 L1 工期**（S2b 設計明確要能斷=viability 中斷路；且「敵人壓境還在蓋房子」故事不合理）。
**★你的 TDD⑤ 抓不到**：那是**靜態** assert `TASK_BUILD in PREEMPTIBLE_TASKS`（set 成員資格），不是**動態**驗「committed 紮根真的被 threat 打斷」。

## ★★修法（我裁、非只改 sets）
1. **留 survival set 不動**——`rank_survival` 只收 survival-set（`decision_engine:169`）、拿掉=**絕境隊結構性沒紮根選項=隱含硬門檻**、違 §0「禁硬門檻回潮」；同秤要在絕境層也成立。
2. **解耦 commit priority**：`options.gd` REGISTRY 加**通用 optional 欄 `"priority"`**、`priority_for` **先讀該欄**（無則回舊邏輯：survival→80 / threat→70 / 其餘→50）。
3. 紮根 entry 標 `"priority": TaskArbiter.PRIO_DISPATCH`。
**★為何通用欄非 special-case**：**set membership=「在哪些 rank 清單競爭」**、**commit priority=「committed 後誰能打斷」**——兩語意本就不同、現被 `priority_for` 綁死；紮根（長工期的發展型 survival option）只是第一個暴露它的。

## ★TDD 補（動態非靜態）
①committed 紮根（工期中）遇壓境威脅 → **threat 真 preempt 成功**（current_task 從 TASK_BUILD 變 threat task）②committed 紮根遇絕境（食物崩）→ **survival@80 真 preempt 成功**（去覓食；`corvee_site` recovery 既有=回頭續建不丟進度）③紮根 commit 後 `team.task_priority == PRIO_DISPATCH(50)`。

其餘 §4a 成果**全保留**（constitution 75 / zombie commit-hook 四站 / 刪 scaffolding / 既有測綠）。重驗：constitution 75 + 全 TDD + determinism（記 fp）+ headless 0-new。完 → handback to:systems。地基 KEEP。

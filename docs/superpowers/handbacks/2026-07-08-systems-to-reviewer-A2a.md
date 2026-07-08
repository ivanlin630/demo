---
from: systems
to: reviewer
status: open
topic: A2a spec round-2——你兩點成立，藍圖裁定收尾(D6 明示接受移除+抗命 deferred;D3 引用改 leader-dispatch);核心設計不動
---

# A2a spec round-2 回覆（給 reviewer）

你這輪兩真疑點**都成立**，藍圖 round-2 裁定（`blueprint-to-systems-A2a-revise.md`，優先於 review 字面）：**核心框架設計（directive/faction_duty 複用、cadence gate、量測特判）你已確認查證屬實合理、無 premise 造假＝過了，不動**。只收尾兩點 + citation。逐點回：

## D6（mid-mission 投機叛逃移除，未走明示接受）→ 藍圖明示接受移除
你對——`_check_deviation` 是**執行任務中**（`current_task≠IDLE` 移動中，`1629-1631` 逐 tick）判「半路轉搶劫不脫離」，v2 改 active-transit sticky＝此分支移除，我上輪定性「超範圍」自行帶過，不合 review#1 攻擊窄化的「明示接受」標準。**已修**：
- spec D6 段加 **「藍圖明示接受移除」** 段（比照 review#1），三理由：①脫離出口保留（`_check_discipline` desert→獨立自由搶）②投機出口保留（idle 掠奪搬進 duty↔greed，loyalty-gated）③執行中 sticky=任務承諾+省效能+更紀律，合「紀律至上」。
- 殘留疑點段從「系統自認超範圍」改成「藍圖明示接受移除」。
- **加 future work（deferred 非遺漏）**：完整「**抗命**」行為（mid-mission 動態抗命/違令，非只脫離/idle 掠奪）延後另 slice。

## D3（invariant 引用文不對題）→ gate 保留，只改引用
你對——「立國=leader-level」（invariants:325）講 faction 建國（`create_faction`/`_declare_established`），跟 建設(TASK_BUILD)/佔村(TASK_ATTACK 奪據點)不同機制，引用不精確。但你也認底層顧慮站得住。**已修**（藍圖裁定 gate 保留，只換引用）：
- spec D3 引用改指 **既有 leader-dispatch settle 機制**：grep 重驗子隊建造/安頓現行**皆由母團/leader 派遣 pre-set task**（`faction_ai_system.gd:525 _dispatch_subteam_settle → :540 try_set TASK_SETTLE`、`:2292 dispatch TASK_CONSTRUCT`），**從未子隊 idle 自選**。gate＝防子隊納 rank_scored 後憑空多出「附屬單位自建據點」新路徑（違護欄「子隊生命週期不動」）。明示非借「立國」。

## citation drift
`_evaluate_solo` 現況 `:1724`（spec 誤寫 1749）→ **已改**。

## 驗了啥
- 純 spec（systems，不跑 godot、不寫 plan＝審過才寫）。**核心設計零改**（只 D6 段+D3 引用+行號）。
- **重讀當前 code 查證行號**（鐵律）：`_dispatch_subteam_settle:525`→`TASK_SETTLE:540`✓、`TASK_CONSTRUCT dispatch:2292`✓、`_evaluate_solo:1724`✓。

## 殘留疑點（呈報）
- 「抗命」完整行為 deferred（D6 future work 明記）＝已知缺口非遺漏。
- D3 gate 若實作發現太像子隊特例，備案＝`_decide_subteam` skip 該兩 opt（同 lifecycle 護欄）。
- `SUBTEAM_CADENCE`/`FACTION_DUTY_DRIVE` 對子隊量級＝TEST VALUE。

審過我才寫 plan → 實作。

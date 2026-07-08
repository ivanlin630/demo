---
from: blueprint
to: systems
status: consumed
topic: A2a revise round-2——藍圖裁定 D6/D3（核心設計已驗證，只收尾兩點）
---

# 藍圖裁定 round-2（★優先於 review 字面）

你上輪照方向改對了——review 已確認**核心框架設計（directive/faction_duty 複用、cadence gate、量測特判）查證屬實且合理、無 premise 造假**。核心過了。只收尾 review 剩兩點，別動核心。

## D6：藍圖明示接受「移除 mid-mission 投機叛逃」
- 現況 `_check_deviation` 的「執行任務中、不脫離、半路轉去搶劫」——**藍圖裁定：接受移除。**
- 理由（寫進 spec 的明示接受段，比照 review#1 攻擊窄化的處理）：
  1. **脫離（discipline_fail）保留** → 中途嚴重不紀律仍有出口（desert→獨立→自由搶）。
  2. **idle 掠奪保留**（搬進 duty↔greed 框架，loyalty-gated）→ 投機出口在。
  3. **執行中 sticky = 任務承諾 + 省效能 + 更紀律**，合「紀律至上」願景。
- spec 殘留疑點段：把「mid-mission 投機」從「系統自認超範圍」改成 **「藍圖明示接受移除」**（同 review#1 標準）。
- ★**加一句 future work**：完整「**抗命**」行為（mid-mission 動態抗命/違令，非只脫離/idle掠奪）**延後**，日後另 slice 補。這裡明記為 deferred，不是遺漏。

## D3：引用改指向（gate 保留）
- 建設/佔村 gate（子隊不自主自建據點）**本身對、保留**。
- 只改**引用**：別借 invariants「立國=leader-level」（那是 faction 建國、文不對題）。改指向**既有 leader-dispatch settle 機制**（grep 證實子隊建造/安頓現行皆由母團/leader 派遣 pre-set task：`faction_ai_system.gd:540` TASK_SETTLE、`:2292` TASK_CONSTRUCT）——gate = 防止子隊納 rank_scored 後憑空多出自主建據點路徑。

## 附帶
- citation drift：`_evaluate_solo` 現況在 1724（spec 寫 1749），順手改。

## 交付
改 spec：①D6 明示接受段（+抗命 future work 註記）②D3 引用改 leader-dispatch ③citation 行號。**別動已驗證的核心設計。**★重讀當前 code 查證行號。commit。

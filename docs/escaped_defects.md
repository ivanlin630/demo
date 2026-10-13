# Escaped Defects（逃逸缺陷 ledger）

> **定義**：用戶發現的任何問題=逃逸缺陷=流程事故。每筆立檔：哪層該抓而沒抓 → 補那層機器。
> **三層驗收鏈**（全綠才交付用戶）：①充足性閾值（帶分母的率 assert）②常駐漏斗（分階段轉化率回歸可見）③戲感審計（系統以觀者身分讀 default 世界流,統計唸成句子問怪不怪）。
> **承諾邊界**：湧現系統會出新型失誤;本制保證=**同類永不第二次**（每筆逃逸缺陷變一層機器）。
> 源：`handbacks/2026-07-04-blueprint-to-systems-qa-inversion.md`（R1-R6）。流程規則本體見 `docs/process/05_acceptance.md`。
> **ledger 管理者=驗收官（QA session，`04_qa.md` 第三職）**；系統/藍圖可 append 候選，判層歸 QA。

| # | 日期 | 缺陷（用戶原話/現象） | 該抓層 | 為何漏 | 補的機器 | 機器狀態 |
|---|---|---|---|---|---|---|
| 1 | 2026-07-04 | 「感覺沒有在貿易」——數百條訂單（想要）+供給在（可行）vs 成交 6/2 筆（沒發生）=**自我矛盾** | ①矛盾偵測 | 「Market fire ✓」當布林讀,沒做除法;病=矛盾非量小（判準修正 audit-explainability-bar） | ✅ 機器建成：`TRADE_CONTRADICTION_MAX` gate（merged）+ 常駐六站漏斗。**病本體半修**：主斷(timeout秒殺)修死成交 6→16/2→5,絕對矛盾率仍 0.71-0.76=殘因域外(LOD+carrier,已報藍圖)。「現綠=done?」=QA 判決題 | 🟡 機器綠·病未清（域外殘因移交藍圖+QA） |
| 2 | 2026-07-04 | 獸隊張貼收購武器訂單/對人宣戰（ticker 揭） | ③戲感審計 | 無人以觀者身分讀 default 事件流;probe 不會覺得「荒謬」 | ✅ 機器建成：`--obs-ticker-dump` TSV 落檔（merged）→ 世界句子審計素材就緒。缺陷本體（order/message 排除 beast）待修 | 🟡 機器綠·缺陷本體待 QA 判決後排修 |
| 3 | 2026-10-13 | 派出去的子隊看起來大多什麼都沒做（回饋 #2：安頓／建設整天空轉、覓食／巡邏／偵查立刻併回、待機自己去外交，甚至向玩家求和進貢） | ③戲感審計＋①矛盾偵測（「派了＋可行＋沒發生」） | 覓食被一律歸建（`faction_ai_system.gd:4126`）**2026-09-22 已由 measurer tap 量到**（`merge.forage_blanket_evicted`），只有計數器、沒人讀成矛盾；玩家派遣從沒有床走過「派完之後子隊做了什麼」。判決信 `handbacks/2026-10-13-qa-to-systems-subteam-dispatch-story-audit-VERDICT.md` | 待 systems 定：玩家派遣六任務 × 一天的「有產出或有結局行」斷言（QA 建議改造 `dispatch_task_at_foot_census` 成閘） | 🔴 缺陷與機器都還沒修 |

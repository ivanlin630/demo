# Escaped Defects（逃逸缺陷 ledger）

> **定義**：用戶發現的任何問題=逃逸缺陷=流程事故。每筆立檔：哪層該抓而沒抓 → 補那層機器。
> **三層驗收鏈**（全綠才交付用戶）：①充足性閾值（帶分母的率 assert）②常駐漏斗（分階段轉化率回歸可見）③戲感審計（系統以觀者身分讀 default 世界流,統計唸成句子問怪不怪）。
> **承諾邊界**：湧現系統會出新型失誤;本制保證=**同類永不第二次**（每筆逃逸缺陷變一層機器）。
> 源：`handbacks/2026-07-04-blueprint-to-systems-qa-inversion.md`（R1-R6）。流程規則本體見 `docs/process/05_acceptance.md`。
> **ledger 管理者=驗收官（QA session，`04_qa.md` 第三職）**；系統/藍圖可 append 候選，判層歸 QA。

| # | 日期 | 缺陷（用戶原話/現象） | 該抓層 | 為何漏 | 補的機器 | 機器狀態 |
|---|---|---|---|---|---|---|
| 1 | 2026-07-04 | 「感覺沒有在貿易」——數百條訂單（想要）+供給在（可行）vs 成交 6/2 筆（沒發生）=**自我矛盾** | ①矛盾偵測 | 「Market fire ✓」當布林讀,沒做除法;病=矛盾非量小（判準修正 audit-explainability-bar） | 貿易環軌 Task 3：`TRADE_CONTRADICTION_MAX` bed assert + 常駐六站漏斗率 | 🔨 in-flight（feat/trade-loop-ignition） |
| 2 | 2026-07-04 | 獸隊張貼收購武器訂單/對人宣戰（ticker 揭） | ③戲感審計 | 無人以觀者身分讀 default 事件流;probe 不會覺得「荒謬」 | ticker-dump（貿易環軌 Task 3-3）+ 系統世界句子審計成常規步驟（交付前必跑） | 🔨 in-flight（dump flag 同軌） |

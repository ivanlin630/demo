---
from: blueprint
to: systems
status: consumed
topic: "[doc 廢話 cut-list·我 fresh-eye 審+驗過·你套(process docs 你 owner)] game-design(我)line427 retelling 已自砍。process docs cut-list給你套。★我抓audit一盲點修正:cross-cutting去重別去『07』——新hook讓各角色/compact重讀『自己那格』,status-ownership/禁checkout是全角色規則,canonical家=00(唯一全角色都讀的脊椎)非07(系統專屬,別角色不讀)→去重成指向00非07,否則角色重讀看不到=漏。清楚cut照收:06 collapse tombstone/03b血證3×→1×+TODO musing/07_orch深節點細節移出compaction set/各stale struck-through+process-narration。"
---

# doc 廢話 cut-list（我 fresh-eye 審 + 驗，你套 process docs）

我當外部眼審（非系統自審=maker/checker）。game-design（我 owner）已自砍 line427 retelling。以下 process docs 你 owner，你套。

## ★先修 audit 一個盲點（重要，別照 audit 原樣做）
audit 建議「cross-cutting 規則去重到 canonical」——對，**但它挑的 canonical 家錯**：
- status-ownership 建議去 **07**、release-gate 去 **05**。**但新 hook 讓各角色 /compact 重讀「自己那格 doc」**（00_roles 導覽表 map role→doc）。**07 是系統專屬、別角色不讀**——status-ownership 是**全角色**規則，去重到 07 = 角色重讀時看不到 = 漏。
- **正解**：**全角色規則的 canonical 家 = `00_roles`（唯一所有角色都讀的共享脊椎）**。status-ownership / 禁原地 checkout → 精簡版留 00 當 canonical，各角色 doc 去重成「指向 00」。**topic 細節**（信箱機制）才留 07。release-gate 規則本體留 05（QA/measurer 讀 05）+ 00 一行。
- **判準**：這規則哪些角色 /compact 要看到? → canonical 放「那些角色都會重讀的最小共同 doc」（通常 00）。

## 清楚 cut（照收）
1. **06_pipeline_orchestration.md → 3 行 tombstone**（整檔作廢+作廢草案+未落 CLAUDE 草案=~65 行死碼，零 live 規則）。最大單一 win。
2. **03b_measurer.md（最肥 ~20-25%）**：71/22/7 血證 **3×→1×**（留 §可溯源協議）；砍 line65/67 兩段 TODO-musing（「非本輪動作」）；line177 status-ownership 去重（→指 00）。
3. **07_orchestrator_machine.md（~50%）**：節點契約表/落地步驟/狀態物件等深 impl 細節**移出「每 compaction 重讀集」**（機器少用，roles 不該每次重讀）→ 留 why-graph+node map，細節移他處或標「按需讀」。
4. **08 line81-87** 批次排程 status → 移 progress.md（非 workflow 規則）；line68 status 註。
5. **小 narration cut**：00:20 stale 舊模型 struck-through、02:38 self-flagellation、04:17-19 role-rename 舊敘事、04:99-112 dedup、03 checkout 去重（→指 00）。

## 已 tight 不動
01_architect / 05_acceptance / status/README。

## 注意（別誤砍）
- **TEST VALUE 註記（game-design:453/459 等）= live placeholder 標記，非廢話，勿砍**。
- 01 的 R① 判準 blood-proof（38-40）load-bearing，勿砍。

## 溯源
用戶「查全角色與工作流 md 有無廢話」;我派 fluff-audit agent + 修其 canonical 盲點（re-read hook 語境）;00_roles §文檔導覽 role→doc。

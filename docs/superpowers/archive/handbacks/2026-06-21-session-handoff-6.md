# Session 交接（2026-06-21 #6，系統 session）

> 給重開後新 system session（`$env:SESSION_ROLE='systems'; claude`）。承 #5（`2026-06-20-session-handoff-5.md`）。
> 本 session = **經濟 arc 深掘（6 層 plumbing）→ 揭真根=決策框架不統一 → 統一決策框架 foundational arc 啟動（sub-project 1 done）**。main 全綠、無未 merge、worktree 全清。

## 你是誰
系統(Systems, HOW)。owner = invariants.md / 流程docs / progress.md / known_issues.md / CLAUDE.md / docs/process/* / auto-memory(單寫者)。不碰 game-design.md(藍圖)。開頭讀 `docs/process/00_roles.md` + auto-memory(hook 注入) + 掃 `handbacks/` 的 `to: systems / status: open`。

## 本 session 主線（measure-first 逐層剝洋蔥）
1. **經濟 arc 6 層 plumbing 全 merged**：WS-2(市集pos+角色卡死)/WS-1(食物糧倉+硬上限)/WS-3(carry+馬車)/WS-2b(市集看板可見性)/WS-2c(food accessor)/WS-2d(旅途乾糧)。詳 `[[project_economy_arc]]`。
2. **但 world_sim 履約仍 0%** → 完整生命週期 tracer 揭**真根 = 商隊 tag-vs-人格目標錨矛盾**（震盪：tag 商隊 + 人格 archetype 定居 互搏，貿易每 2 天被搶走）。**教訓：經濟驗收必走 world_sim 不信密集 harness；measure-first 別憑零散探針下結論（撲空 92% 框架錯兩次）。**
3. **藍圖+用戶定：真根更深 = AI 決策框架不統一**（非經濟局部）→ 做**統一決策框架 foundational arc**，tag patch 全不做。詳 `[[project_unified_decision_framework]]`。
4. **統一決策引擎 sub-project 1 done**（merge `9c66a7e`）：`DecisionEngine` utility weigh + 承諾慣性 + 商隊切片。**TC7 分歧過**（霸主→建設/商人→貿易/隱士→駐守）、TC1 震盪消失。`scripts/simulation/decision/`。
5. **附帶修**：known_reputations dangling（systematic-debug，root=reconcile_firsthand 對死 source update_reputation 無 liveness guard，world_sim violations 556→0，merge `4e0a78b`）。

## 下一步（統一框架後續子專案，各另 brainstorm/spec/plan）
**驗收套件**：藍圖 `framework-validation-suite` handback（TC1-7 + S1-6 魂場景），每塊落地立刻跑。
| # | 子專案 | 重點 |
|---|---|---|
| **A** | **S6 擴定居隊進 uses_unified** | 最該先做——商隊治好了但下單定居隊還舊系統亂跑→co-location 撲空→履約仍 0。把經濟定居/生產隊納引擎（加駐守市集/下單 option）→ **履約脫 0**（經濟閉環真驗收 S6）。同引擎漸進擴隊，非重寫。 |
| **B** | 他域遷入 | 各加 Option row：攻擊/掠奪/結盟/徵收/立國/scout/誘殺/鑄幣。完整 TC7 攻擊分歧 + S1-5 魂場景在此驗。 |
| **C** | Pattern B 所有權 banker | loyalty/resources/anon_treasury/unrest/outpost_owner 各設 banker 收 delta、禁外部絕對 set。scope map 見 `state-fight-scope`。 |

**建議序**：A 先（最快讓經濟真活+驗框架對全鏈）→ B 逐域 → C 所有權。

## 系統域備辦（不卡藍圖）
- trust 飽和（reconcile 每觀察 tick）：known_reputations 已修但 trust delta cadence 仍可調。
- event_faction_defect:21 = **非 bug**（reproduce 證 0 faction violation，防禦清理），別動。
- 殘留舊 worktree（housekeeping，非阻塞）。

## 工作流提醒
- 每塊 merge 前自審 diff + 自跑回歸（headless 綠 + 驗收套件 TC/S + coin_eq=0 + InvariantAudit 0）+ world_sim 煙霧，不信 handback。
- foundational arc 每子專案走 brainstorm→spec→plan→子 session（本 session sub-project 1 即此流程）。
- 量測數字回呈藍圖走 handback（藍圖不讀 memory）。
- 別問技術微決策；ctx ~90% 才提醒交接。
- 預想 handback（戰俘 `prisoner-prethink`/性別 `gender-prethink`）已 consumed 歸檔，未來各自 spec 開時用。

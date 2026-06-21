---
from: implementer
to: systems
status: open
date: 2026-06-21
branch: feat/unified-decision-engine
plan: docs/superpowers/plans/2026-06-21-unified-decision-engine.md
---

# Hand Back: 統一決策引擎 sub-project 1（utility weigh + 商隊經濟切片）

## 成敗關鍵：TC7 分歧 ✅ 過

**同情境 3 leader → 3 不同 option（過不了 = 框架失敗）：**

```
[TC7] 霸主(野心.95/好戰.9) → 建設
[TC7] 商人(貪婪.9)         → 貿易
[TC7] 隱士(義氣.9/慎重.8/野心.2) → 駐守
TC7 divergence OK (3 leader 3 option: ["建設", "貿易", "駐守"])
```

bar #4（連貫≠同質）守住。人格→權重映射是真分歧來源，非抹平。

## 四 TC 結果

| TC | 結果 | 證據 |
|---|---|---|
| TC1 震盪消失 | ✅ | 50 tick option 變化 = 0（`changes=0, opt=貿易`）。承諾慣性 + 一隊一 argmax → 不再 trade↔生產 每 2 tick 翻 |
| TC4 野心有牙 | ✅ | 野心.9 安全 → **建設**（爬階）；野心.2 同安全 → **駐守**（知足）。option 不同 |
| TC6 多驅力權衡 | ✅ | 糧中+野心中+小 feud → 選**貿易**（非 survival、非極端）。term 分解可 dump（bar #5） |
| TC7 分歧 | ✅ | 見上 |

## 回歸閘（全綠）

- headless：`=== DONE ===`、**0 SCRIPT ERROR、0 Assertion failed**
- 單元測試（T1-5）：`decision context OK / decision terms OK / decision options OK / decide OK / commitment OK / unified seam OK`
- 驗證套件（T6）：`TC1/TC4/TC6/TC7 OK`
- `InvariantAudit population/faction/subteam 雙向 OK`
- coin_eq 守恆測試（既有 N5/投靠/trade）全過 → 本子專案只改決策面（task 選擇），不碰 resources/coin/state 池，coin_eq **形式確認 0**
- 既有商隊測試全過（`merchant trade dispatch OK` / `merchant seek market OK` / `market trade chain OK fulfilled=1`）——`_evaluate_solo` 商隊路徑改走引擎後仍產 TASK_TRADE

## 改了哪些檔案

- `scripts/data/team_data.gd`：加 `current_option` 欄位（承諾用）
- `scripts/simulation/decision/decision_context.gd`（新）：一隊一次唯讀快照
- `scripts/simulation/decision/terms.gd`（新）：term 函式庫 + w_term 人格映射
- `scripts/simulation/decision/options.gd`（新）：Option 註冊表 + applicable + to_task
- `scripts/simulation/decision/decision_engine.gd`（新）：decide(utility weigh + COMMITMENT_BONUS)
- `scripts/simulation/faction_ai_system.gd`：`uses_unified`/`_decide_unified` + member-loop & solo 接線；**移除舊商隊 hoist**
- `scripts/debug/headless_test.gd`：單元 + TC1/4/6/7

## world_sim 商隊行為對照（game_sim_test 煙霧，非閘）

- **0 SCRIPT ERROR、ALL INVARIANTS PASSED（violations=0）**
- 被追蹤商隊 Team1（自家 outpost、有貨/coin、leader=定居傾向人格）：
  - **task=`治理(p50)[unified]` 連續 25+ 天穩定承諾，零震盪**。`[unified]` reason tag 證引擎為單一 task owner
  - 對比 spec 描述的病（「人在別人市集、有 arb、卻在生產」每 2 天翻）→ **震盪消失**。THE bug 根治
- `g1.merchant_survival` 探針 = 0（舊 WS-2b 壓制旗未再觸發）
- **`訂單履約率 = 0.0%`（與 baseline 同）**：見下「待確認 1」

## 待主 session 確認

1. **履約仍 0% = 預期，非回歸**。本場景兩支商隊（Team1/Team6）leader 人格皆**定居傾向**（野心低/慎重高）→ 引擎**正確**地讓人格贏 tag，選 治理/駐守 而非貿易。這正是 spec「tag-vs-人格」病的**正解**（tag 只是小 fit bias，持久矛盾走 tag_shift 漂移；非硬逼商隊貿易）。**S6 履約脫 0 = 後續子專案（擴經濟定居隊納 uses_unified + 加駐守市集/下單/生產 option）**，plan 已界定不在本子專案驗收。本子專案驗收 = 不震盪（TC1）+ 分歧（TC7），**皆達標**。
   - 若藍圖希望「掛商隊 tag 就該見貿易」，需 world_gen 給商隊隊配商業人格 leader（貪婪高），或加速 tag_shift——屬平衡/生成面，非決策框架，呈報定奪。

2. **殘留震盪**：trace 內 = 0，**無需調 COMMITMENT_BONUS=0.3**。長跑/高商隊密度下若見隊棄守或抖動，bonus 為 TEST VALUE 可調。

3. **TEST VALUE 全表待平衡 pass**：w_term 映射（ambition 去 0.2 floor、ambition_drive 移出貿易、settle_fit 駐守 0.6 vs 建設/生產 0.4）、COMMITMENT_BONUS=0.3、term 公式、applicable 守衛。**為過 TC4/TC7 分歧而定的初值**，非最終平衡值。

4. **threat term 初版 = 0**（plan 已註：商隊切片威脅次要）。他域遷入（戰鬥/外交）時補 `_find_strong_neighbor`/鄰敵 strength。

## 偏離 plan（已自解，self-verify 對齊真實 code）

- plan Task1 `DecisionContext.gather` 寫 `RelationGraph.strongest(team.relation_edges, ...)`，但 **`relation_edges` 屬 `PersonData` 非 `TeamData`**。改讀 `leader.relation_edges`（feud 邊掛 leader person，符 invariants 關係圖段）。
- plan Task2 初值（ambition 0.2 floor / ambition_drive 含貿易 / settle_fit 統一 0.5）**會讓 TC4/TC7 抹平**（霸主與商人皆選貿易、知足 leader 也被推成長）。依 plan 授權（「TEST VALUE，先求 TC1/TC7 過再細調」）調整映射使分歧 by construction：野心 magnitude 不再同步抬所有成長 option（貿易移出 ambition_drive），低野心壓 0（去 floor），駐守給高 settle base。**這是分歧的核心修正，非偏離意圖**。

## 連動風險

- `MERCHANT_TRADE_BONUS` const 現只剩註解引用（商隊 solo 已在函式開頭 return）→ 留 const 定義（無害、其他 docs 引用），未刪。
- 非切片隊（軍隊/生產/掠奪…）`_evaluate_solo`/`_assign_member_tasks` 舊路徑**原封不動**（`uses_unified` 僅商隊-tag）→ de-risk 達成，零影響。
- `_decide_unified` 用 `PRIO_DISPATCH`(50)：生存(80)/威脅(70)/玩家(60) 仍蓋得過引擎 dispatch（survival/threat 不被引擎凍結）；vendetta(55) 亦高於 → 私仇脫軌不受影響。

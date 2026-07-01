---
from: systems
to: blueprint
status: open
topic: 逐檔窮盡 sweep 完成(76/76 production 檔)——核心對(TeamData getter 最強單寫者)但 fork 遠比 first-pass 4-cluster 多;修正 first-pass 錯(team.resources 乾淨,真洞在 tile 層+roster+Pattern B stub);確認 NPC 乞食/投靠死路 bug;首燒不變、單寫者 arc 應拉高(強制閘前提)
---

# 統一矩陣窮盡 sweep 完成

回你「這是真全貌嗎?有逐行逆向?」——你戳對了,first-pass 不是。現**逐檔 sweep 全 76 production 檔**(sim 66+data 10,debug/ui 出 scope)。全貌 `specs/2026-07-01-unification-matrix-audit`(已改寫成 EXHAUSTIVE)。

## 核心判斷不變(你對)
- **核心抽象對**:所有 team 型=同 TeamData,且 **computed getter+no-op setter(population/wounded/anon_tiers)= 最強單寫者(compile-time,比任何 Bank 強)**。不 KILL 正確。

## 但比 first-pass「4 cluster」多很多 + 兩個重要修正
1. **★修正 first-pass 錯**:我之前說「ResourceBank 被 53 處直寫繞」——**錯**。`team.resources` **乾淨、全走 bank**。真單寫者洞在:**tile 層全無 bank**(public_storage granary + tile.resources,22+直寫;**coin 憑空鑄入 public_storage 無 treasury bank**)、**roster named_members 無 chokepoint(59 site/17 檔)**、**combat_target/tags/solo_intent/faction.leader_team_id/person.coin 全無主**、**Pattern B driver-ledger=全 5 bank stub(reason 丟棄不記)**。→ **第3不變量「凡 state 變化必有 driver」= 大面積未實現**,這格最空。
2. **互動域多平行 resolver**:2 diplomacy resolver(一 god-view 一 belief,同 verb)、3 tribute 公式、3 deception 引擎、RelationGraph orphaned(社交 AI 不讀 feud graph)。

## ⚠ 窮盡揭確認 bug(非只 fork)
- **NPC-NPC 乞食(BEG)/投靠(JOIN) task 路徑死**:兩 agent 獨立確認 code-flow——`_try_interact:197` `if combat_target != -1: return` 先於 BEG resolver(:247),而 BEG 恆設 combat_target → 永不可達;**JOIN 根本無 resolver**。NPC 絕境「乞食/投靠」(P2a 補的 option)walk 到目標被殺、無 resolve。player 版直呼繞過故沒露。**→ P2a 絕境 repertoire NPC 側可能空轉**。按 measure-first 建議先插探針量 runtime 影響再定,別直接當實。
- **守恆盲區**:person.coin `+=` raw + coin 憑空鑄 public_storage 都在 coin_eq audit(對 team.resources 求和)盲區。

## 首燒確認不變 + 建議調序
- **首燒 = 獨立/faction 戰略合併**(帶致富+征服錨)——窮盡後更確認(intent fork 是 5+ scorer/5 菜單,順收 threat stub F-D6 + 雙 faction-goal producer F-D3)。
- **★建議:第3不變量單寫者 arc 拉高(不只排 backlog)**。理由:program 的**強制閘(②)守的就是「state-change 必在統一路徑」**;但單寫者現大面積未實現(tile/roster/combat_target/ledger stub)→ **閘現在立不起來**(沒有 driver-ledger 可查、太多直寫繞)。要 program 真止打地鼠,單寫者實現是強制閘的前提。建議序:首燒(intent)→ B(食物)→ **單寫者 arc(撐閘)** 並行/緊隨。

## 待藍圖
1. **窮盡矩陣收下**(76/76 逐行,confidence 高;first-pass 已修正取代)。
2. **首燒開否**(獨立/faction 戰略合併)。
3. **單寫者 arc 序**:拉高(強制閘前提)or 仍 backlog?
4. **BEG/JOIN 死路**:先插探針驗 runtime 影響否(measure-first)。→ 我已列 known_issues。
5. 強制閘 + checklist 我隨首燒 + 單寫者落地。

這次是真逐行全貌。核心對、但 fork 30+ 條、單寫者最空、且揪出一個真死路。你裁首燒 + 單寫者序。

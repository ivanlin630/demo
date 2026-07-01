---
from: systems
to: blueprint
status: open
topic: 統一矩陣稽核完成(全貌 in specs/unification-matrix-audit)——真 fork 聚 4 區(思考決策/player-vs-NPC/單寫者/俘虜);首燒獨立-faction 戰略合併確認直中;揭 latent bug 疑點(NPC 乞食/投靠 task 路徑疑死,需驗)
---

# 統一矩陣稽核完成 — 全貌 + 首燒確認

回 `unification-matrix-program` task 1。grep 實碼 4-domain fan-out 綜合。完整矩陣 `specs/2026-07-01-unification-matrix-audit`（實體×領域，每格 統一/補丁/缺口）。

## ★ 好消息：核心抽象對，fork 集中非瀰漫
**所有 team 型=同 `TeamData` class** → for teams 多數領域**自動統一**（population/anon/breeding/resource-read/belief-substrate/bidir 都免費統一）。**驗證你「不 KILL、核心抽象對」的判斷**。真系統性 fork **只聚 4 區**：

1. **思考決策 intent-forming = FORKED**（5 菜單 4 scorer）← **你的首燒直中**。
2. **player-vs-NPC**：primitive 多統一（2026-06-16 parity）但 **trigger/dispatch 層整條裂** + betrayal/demand_tribute/recruit 全平行。
3. **單寫者（第3不變量）大半未實現**：ResourceBank 被 53 處直寫繞、Pattern B driver-ledger=**stub 啥都沒記**、5 ad-hoc bank、granary/purse 直寫。
4. **俘虜兩模型**：captive_groups（NPC 活控制人力）vs prisoner_population（player 死路裸 int）。

## 首燒確認：獨立/faction 戰略合併帶出致富+征服錨
矩陣證你的假設：
- faction 菜單{征服/致富/防衛/守成/+立國}、**獨立截斷{建國/守成}**、unified team{無 emergent}、subteam{回歸/掠奪/攻擊}、named{P1..N5} = **5 套 hard-coded 菜單無共享**。
- 統一成「任何 leader 一套菜單、faction 只是執行規模 context」→ **獨立商隊得致富(前 tracer 缺的錨)、好戰隊得征服(前 CONQUER=0 的錨)一次解**。
- 順收 4 個關聯 fork：F-D3(faction 第2 producer strategic_ai，擴張只在此脫節)、F-D4(solo_intent 一槽兩義)、F-D5(unified-tag subteam 進不了 engine)、F-D1(4 平行 scorer 收斂)。
- **非再補獨立菜單**（那是第三次同型補丁=架構信號，[[feedback_structural_audit_complement]]）。

## ⚠ 稽核揭 latent bug 疑點（需 measure 驗，非直接當實）
- **NPC-NPC 乞食(TASK_BEG)/投靠(TASK_JOIN) task 路徑疑死**：`_try_interact` 早退 `if combat_target != -1: return`(interaction:197) **先於** BEG resolver(:247);但 BEG 設 combat_target → branch 疑不可達。`TASK_JOIN` interaction **無 handler**。player 版直呼 resolver 繞過。
- **含義**：若真死，NPC 絕境「投靠/乞食」option 選了但**resolve 不了**（P2a 補的絕境 repertoire 部分可能空轉）。**但這是 code-read 假設**——按 [[feedback_avoid_rabbithole]] 需 instrument 量 NPC 乞食/投靠實際 fire+resolve 否再定。要不要我插一探針驗?

## 建議燒序（矩陣據排）
1. **★獨立/faction 戰略合併**（首燒，帶致富+征服錨）
2. **B R1 食物張力**（給錨牙，隨戰略合併後）
3. 單寫者實現（ResourceBank 真單寫 + Pattern B driver-ledger 落地=第3不變量 enforce）——大塊獨立 arc
4. 俘虜統一（prisoner_population→captive，受控人力 Phase 2 早列）
5. player-vs-NPC dispatch 統一（玩家面 arc、大）
6. 互動 resolver 統一 + combat verb belief-gate + recruit NPC 化
7. latent bug 驗 + 強制閘推廣 + 設計 checklist

## 待藍圖
1. **矩陣收下**（全貌在手，不再驚喜）。
2. **首燒 = 獨立/faction 戰略合併**（帶致富/征服錨）→ 我開 spec？（這是統一決策 arc 的正解延伸，非補丁）
3. latent bug（NPC 乞食/投靠）要不要我先插探針驗（順手，measure-first）?
4. 強制閘 + 設計 checklist 我隨首燒落地（守 F-D 不退化 + checklist 納 01_architect）。
5. 平行不停：G3 Phase D（資訊維度）、scaling die-off spike（另案）仍排。

矩陣給了全貌：核心對、fork 集中 4 區、首燒直中致富/征服錨。你確認開首燒 spec?

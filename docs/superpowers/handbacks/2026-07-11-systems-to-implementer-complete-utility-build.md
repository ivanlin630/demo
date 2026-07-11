---
from: systems
to: implementer
status: open
topic: [§HOW-8 開工] 完整 consolidation utility——戰略盤算取代薄drive;R② CLEAN;決策統一win一起merge
---

# 實作工單：完整 consolidation utility（§HOW-8，R② CLEAN）

spec `specs/2026-07-10-consolidation-s-a-technical.md §HOW-8`（R② CLEAN，冗餘 lens 全過）。**疊既有 S-A worktree**（§HOW-1~7 carry forward）。用戶批投資把 consolidation 從薄選項做成真決策。**這是 consolidation 最後一塊——完整 utility + 決策統一 win 一起做完 merge（不先 ship 薄版）。**

## 改（4 件，§HOW-8）
1. **投靠 ungate**（`options.gd:99`）：`food_days<DESPERATION_DAYS` **OR** `(has_strong_neighbor AND threat > 威脅門檻)`（打不過的鄰求保護，有餘裕也可觸）。→ 中度隊不再被 gate 擋出評估。門檻 TEST VALUE。
2. **新 context 欄**（`decision_context.gd`）：
   - `resource_slack`：養得起更多 pop 的餘裕 = f(統領 pop_cap − pop 空額, resources 超 survival 的 buffer, 產能盈餘)。**★≠ food_days**（別拿 food_days 換皮；food_days=餘命、slack=養得起）。
   - `absorb_yield`：吸 target 淨收益 = f(target 產能/據點/地) − f(target pop 負擔)。**★別直接拿 `_belief_richness` 當 yield 抄捷徑**（reviewer 點；richness=值不值得搶=貪婪視角，yield=養不養得起=淨值視角。可讀同 belief 源但公式不同）。
3. **term 補全**（`terms.gd`，取代薄 drive）：
   - `join_drive` = 個性適配(求生欲 + 威脅下認慫求保護) × 生存壓(food OR 威脅) × host 期待安全。survival OR 威脅驅兩路。
   - `absorb_drive` = 個性適配(野心 + **仁慈(1-殘忍)/信義**) × 資源可負擔(`resource_slack`) × 期待收益(`absorb_yield`) × 擴展需求(`ambition_gap`:22)。
   - 仁慈 = `1-殘忍`/`信義`（既有 value 映射，非新造；reviewer 標 proxy 非精確，先用）。
4. weight/eval 分配照既有 rank_scored pattern。

## 守則（硬，blueprint 釘）
- **禁 flat/硬優勢湊 volume**：補全=決策更真實，**非把吸納調贏征服**。**征服若真划算而贏=保留不動**。目標「決策到位」非「consolidation 一定多」。
- 全 rank_scored 真 term；不重造（複用 ambition_gap/併入分流/loyalty init）。

## 驗（measurer 雙向重量，★測完才判世界抗拒）
- 雙向 completion：**謹慎投靠**（威脅驅非絕境）dispatch/complete + **仁慈吸納** dispatch/complete + **跟征服比**（`conq.intent` 對照）。
- **翻案判準**：起量（謹慎投靠/仁慈吸納真發生、隊聚合）→ 世界不抗拒=決策沒到位（翻案）；仍 ~0（決策到位仍強寧征服/弱寧覓食）→ 真世界抗拒→升 user。
- gate#1 非搬餓 / 隊數不崩(mega-blob) / determinism / 三端不退化 守。
- 大窗 `godot-detach.ps1`+`WARRING_RESUME`（03b SOP）；worktree rebase 最新 main。

## merge
- **決策統一 win（8 層 de-patch/join+整併合一/loyalty）+ 完整 utility 一起 merge**。merge 閘=reviewer 對實際 diff CLEAN + measurer 全站 + blueprint 翻案判準判。

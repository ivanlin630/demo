---
from: reviewer
to: systems
status: consumed
topic: [R² verdict] 計畫層4-slice plan = issues，PHASE_GATHER用stale pre-merge option名稱
---

# R² 審判 verdict — 中長期計畫層 4-slice 實作計畫

## verdict: issues（非premise_contradiction，一處需修正，halt）

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {
      "claim": "Task2 `_phase_option_bias(PHASE_GATHER)` 回傳 `{\"外交\": MAG, \"整併\": MAG, \"投靠\": MAG}`",
      "file_line": "plans/2026-07-12-midlong-term-plan-layer.md Task 2 Step 3 (`_phase_option_bias`) vs `decision/options.gd:17,49,100,177`",
      "truth": "「投靠」「整併」是S-A consolidation合併前的舊option名稱——今天稍早同session的consolidation-s-a arc（本reviewer親自R②過）已將兩者統一收斂為單一option「併入」（options.gd:17「統一『併入』(join+整併合一)取代兩row」，:49 SURVIVAL_OPTION_SET只含「併入」）。grep全codebase「投靠」「整併」兩字串已完全不存在於options.gd/terms.gd。若照plan字面實作，這兩把dict key在rank_scored評分時永遠對不上任何真實option（靜默無效非crash），PHASE_GATHER的聚勢偏置會只剩外交生效，併入完全不起作用——聚勢phase的核心語意（結盟/整併/立國前置）打了折扣。需修正為 `{\"外交\": MAG, \"併入\": MAG}`。"
    }
  ],
  "note": "其餘6項checklist皆驗過。找到一項次要watch item（非issue）：intent_fit「致富」貿易偏置(food_days充裕觸發) vs plan_phase_drive「求糧」貿易偏置(food_flow_avg赤字觸發)——兩條件通常反相關但非嚴格互斥，窄邊緣case下可能對「貿易」option雙重疊加，MAG已刻意壓低風險可控，建議measurer順便觀察此option量級。" }
```

## checklist逐項驗證
1. **milestone_met健全**：`ambition_ladder.gd:18-21` 四常數（ACCUMULATE_FLOW_MIN=0.5/EXPAND_MIN_POP=8/STATE_MIN_FACTION_TEAMS=2/HEGEMON_MIN_FACTION_TEAMS=4）確認精確吻合milestone_met邏輯。`target_rung()`(`:64`) grep全codebase只有一個caller（`:88`即update()自身），S1改後零外部呼叫，相容性非問題（可留可刪皆不影響）。過。
2. **★S2冗餘lens**：找到具體窄邊緣重疊——見上issue備註。窄case非阻擋，但plan自陳的驗法（grep語意分層）未能排除同option同時觸發的可能，建議measurer順便觀察。
3. **S2承諾綁rung**：phase每gather從已穩定的S1-rung重算，無獨立承諾狀態機，邏輯自洽。過。
4. **★S3層次分離**：bypass只碰`ambition_rung`（`:402-406`），不碰`_evaluate_survival`或任何task/option派工邏輯，觸發條件各自獨立定義，層次確實分離，未重演:39誤判。過。
5. **determinism**：全新增碼純算術，零randf，team迭代穩定序。過。
6. **統一框架**：`rank_scored`仍唯一求解器，`plan_phase_drive`只是新term輸入（weight=1.0比照intent_fit/train_drive pattern），非第二引擎。過。
7. **★誠實化——發現需修正的具體bug**：`_phase_option_bias(PHASE_GATHER)`用「投靠」「整併」stale pre-merge option名稱，S-A merge後這兩字串已不存在，需改為「併入」。見上issue。

## 需修
Task 2 Step 3 `_phase_option_bias` 的 `PHASE_GATHER` 分支，把 `{"外交": PLAN_PHASE_DRIVE_MAG, "整併": PLAN_PHASE_DRIVE_MAG, "投靠": PLAN_PHASE_DRIVE_MAG}` 改為 `{"外交": PLAN_PHASE_DRIVE_MAG, "併入": PLAN_PHASE_DRIVE_MAG}`。

改完後 CLEAN，可 dispatch S1 implementer（序列 S1→S2→S3，S4末）。

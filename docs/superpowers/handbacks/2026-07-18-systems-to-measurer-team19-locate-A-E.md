---
from: systems
to: measurer
status: consumed
topic: "[team19 精確 locate A-E·E-first·我①over-concluded] blueprint checklist:我 ① proactive_camp 是 5 選 1 的猜非坐實(pattern-match TASK_CAMP@50 沒確認 team19 真走那條;unified 隊 :3225 就 return 根本不到 proactive_camp)。★E 優先(probe 剛誤分類 4 隊=同 probe,先驗 team19『決策=survival/任務=安頓』數真不真,是驅動 task 的欄還是 probe artifact)。E 過→locate A-E:A 選項落不了地(to_task 無目標/skip)/B 優先序-latch(安頓 priority/reason 擋)/C 控制流早 return(哪行 return 前 dispatch)/D 多頭 desync(current_option 欄 vs 真驅 task 的欄不同源)/E probe 誤讀。定位是哪個(各 fix 不同)非確認眼熟。"
---

# team19 精確 locate A-E（E-first，我 ① over-concluded）

blueprint 打臉對——我 ① proactive_camp 是**5 選 1 的猜**（pattern-match「TASK_CAMP@50」到 `_evaluate_survival:3256` 沒確認 team19 真走那條路;若 team19 是 unified 隊,`:3225 if uses_unified: return` 根本不到 proactive_camp 那段）。原始事實只有「決策=survival/任務=安頓/不在戰鬥」。定位是哪個機制（各 fix 不同）：

## ★E 優先（別在假數據診斷）
probe 剛誤分類 4 隊（famine_days=0 計 starve）=同 probe。**先驗 team19 的「決策=survival/任務=安頓」讀數真不真**：
- 「決策=survival」讀的是哪個欄？`team.current_option`？是**驅動 task 的欄**還是 probe/trace 另讀的 artifact？
- 「任務=安頓」= `team.current_task == TASK_CAMP`？確認。
- E 若命中（讀數本身假）→ 根本沒 decision≠task 矛盾，是 probe 病，修 probe 不修 dispatch。

## E 過（讀數真）→ locate A-E
team19 瀕死 final ticks 精確 trace：
- **team19 是 unified 還是非統一子隊**？（決定走 _decide_unified 還是 legacy _evaluate_survival）——這定哪條 dispatch 路。
- **A 選項落不了地**：decision 選 survival，`to_task` 回 target=-1/skip（`_decide_unified:1518 continue` or legacy）→ 沒 try_set → 維持舊 task？
- **B 優先序/latch**：現任「安頓」的 `task_priority` + `task_reason`；survival try_set 被擋（priority 不夠 or latch）？（我上輪查 proactive_camp 是 B 的一個具體形,但要確認是這個 or 別的 latch）。
- **C 控制流早 return**：dispatch 前哪行 return（proactive_camp `:3273` 是 C 的一個,但也可能別行 or unified 路的 gate）？
- **D 多頭 desync**：QA/trace 讀的 current_option 欄 ≠ 真驅 task 的欄（survival latch vs 主 rank vs threat 不同權威）？

## 別預設
別預設逆向 arc 回歸=latch（5 選 1）。定位是哪個 → 各對應 fix（A=to_task 目標/B=latch 鬆綁/C=de-patch 該 return/D=統一權威/E=修 probe）。**locate 才設計 fix**。

## 附
② util-static（terms.gd 無 famine_days）是直讀 code 事實較穩，但也待 team14/27 確認是死因（同 E-first 精神:讀數真不真）。
blueprint ② escalation intent 另路由中。

## 溯源
blueprint team19 checklist（`2026-07-18-blueprint-to-systems-team19-hypothesis-checklist.md`）;我 ① over-conclude;probe count 灌水（E 風險）;[[feedback_symptom_vs_root_retry]] 定位真根;[[feedback_fileline_vs_interpretation]] 事實vs詮釋。

---
from: systems
to: reviewer
status: open
topic: [R①·premise] 決策生命週期統一(②成員決策+路收斂/⑦釋放統一)——factcheck 4 premise,尤架構紀律可達成(無殘留特判)
---

# R① premise factcheck：決策生命週期統一（②+⑦）

藍圖自主授權全流程(spec→R①→R②→build)。spec `docs/superpowers/specs/2026-07-13-decision-lifecycle-unify.md`。新概念大框(決策路收斂)+含未驗 code 斷言→R① premise。**架構紀律硬性**(藍圖 `architecture-discipline-reinforce`):收斂=真統一(單一決策點 rank_scored),隊形差異表為輸入維度非 if-else 分支。

## 請 factcheck 4 premise（file:line，premise_contradiction→halt）
1. **成員 faction_duty pull 替代 _assign_tasks push 不散協同**：`_assign_tasks`(:1352) 現派成員哪些命令(攻擊/徵收/外交/歸建/其他?)。`faction_duty` term(terms.gd:113) + faction_stakes context(gather:248) 是否**涵蓋全部** `_assign_tasks` 命令型別?**有無 _assign_tasks 派但 faction_duty term 未涵蓋的命令**(若有→該型別須先補成 term,否則成員收斂會留獨立決策點=違紀律)。
2. **成員無隱藏雙寫**：成員(faction_id!=-1)現除 `_assign_tasks` 外,有無別處寫成員 current_task(_assign_tasks 外的 push 源)?→收斂前須清點,免雙寫衝突。
3. **⑦四套 release 可單一機制**：survival release(食恢復 hysteresis:3042)/threat release(no-threat:368+FLEE_TIMEOUT:95)/stuck(_is_stuck:1792)——各 hysteresis/timeout 語意是否可**無損**表為**同一套**重評觸發(非四段 if 換殼)?有無某 release 語意本質無法併入統一急迫/停滯機制。
4. **★架構紀律可達成**：四隊形差異(unified survival-sticky :1443/subteam STRATEGIC-gate :60/member faction 語意)是否真能全表為 ctx 輸入維度(旗標/applicable-gate/term),**無殘留「該隊形特判行動」獨立決策邏輯**?若某差異本質是行動選擇非輸入(如 subteam lifecycle 歸建 move/merge queue),揭示(該保為既有例外 or 待藍圖裁新例外)。

## 意涵
- premise 全 CLEAN → 收斂真可達(隊形=輸入)→續 R②(設計審)→build。
- 某 premise 矛盾(如 _assign_tasks 有 faction_duty 未涵蓋命令 / 某 release 無法併 / 某隊形差異本質是行動決策)→halt,回報藍圖(這是藍圖許可的「premise 矛盾」岔路)。

範圍大(決策核心重構),慢工細審。尤 #4 架構紀律=本次統一成敗判準,請重點坐實。

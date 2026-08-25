---
from: measurer
to: qa
slice: convoy-return-conservation
status: consumed
topic: "convoy specimen v2(implementer放行版,feat/convoy-return-t3-budget@b4a0c98f)：3隻porter全部merged_home乾淨結案(9.2/13.2/6.3日)+附[Split]/[Merge]原始log行供②合法獨立vs③真stranded辨別；★這輪碰巧沒有ghost_alive案例可辨別，Split事件(Team24)供你參考『合法獨立長怎樣』"
---

# convoy specimen v2：implementer放行版，附Split/Merge log行

前一版specimen(`convoy-specimen-final.jsonl`,branch feat/convoy-return-conservation@e4e1d969)已送過，這版是implementer/systems放行的**正式版本**（`feat/convoy-return-t3-budget@b4a0c98f`，rehome_n writer已接、供你看「這是第幾次追家」）。

## 聚合面（獨立確認，供對照非要你信）

`dispatch=7 / deliver=7 / settled=6 / return=6 / rehome=14`，下場`merged_home=3`，殘留`{}`（無ghost_alive）。結案延遲**9.2 / 13.2 / 6.3日**（修前27.9日）。

## specimen落地+自驗

`docs/measurements/convoy-return/convoy-specimen-t3budget.specimen.jsonl`（seed1337/peaceful_economy/75天/`SPECIMEN_TEAM_ID=5,7,3`母隊+血緣自動含子隊）

交件前用欄位鍵驗(非中文任務名)：1810 entries、**221筆non-empty `convoy_phase`**、team_id涵蓋母隊(3/5/7)+子隊porter(12/20/22)。

## ★systems加碼要求：[Split]/[Merge] log行

已落地：`docs/measurements/convoy-return/convoy-t3budget-split-merge-lines.txt`（10行原始stdout）

**誠實局限**：這輪3隻porter(12/20/22)**全部**乾淨`merged_home`，沒有任何一隻卡在`ghost_alive`——所以這輪**沒有②(母團滿員/部分合併合法獨立)vs③(真stranded)需要辨別的案例**。附的log裡有1筆`[Split] Team24 回歸失敗（母團滿員），獨立為新分團`——**Team24不是convoy porter**（一般世界團隊事件），但格式跟內容可以讓你先看清楚「合法獨立長怎樣」，供你之後遇到porter ghost_alive案例時比對辨識。其餘9筆`[Merge]`裡3筆是我們3隻porter的真實歸建(Team5←Team12/Team7←Team20/Team3←Team22)，其餘是無關的一般世界團隊合併。

## 交你裁

這輪porter全部順利歸建，②③辨別的實戰案例這次沒撞到——若你判斷需要專門撞出ghost_alive案例才能驗證辨別邏輯，交你/systems判要不要再開一輪。地基KEEP。

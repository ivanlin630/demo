---
from: measurer
to: qa
slice: convoy-return-conservation
status: open
topic: "convoy RETURN specimen故事稽核請求：血緣修驗證通過(56筆non-empty convoy_phase,team_id含母隊3/5/7+子隊12/19/20)，正本聚合verdict已寄systems"
---

# convoy RETURN specimen故事稽核請求

正本聚合verdict已送systems：`2026-08-21-measurer-to-systems-convoy-return-verify.md`（含★rehome全7次集中porter_12單趟超過病態門檻、persist.hold對CONVOY可歸因=0更正implementer原估）。

## specimen落地

`docs/measurements/convoy-return/convoy-specimen-final.jsonl`（branch `feat/convoy-return-conservation`，seed1337，peaceful_economy，90天，`SPECIMEN_TEAM_ID=5,7,3`母隊+血緣自動含子隊）

**交件前已驗**（依systems叮囑用`convoy_phase`語言無關欄位鍵，非`convoy`字串）：2064 entries、**56筆non-empty `convoy_phase`**、`team_id`涵蓋母隊(3/5/7)+**子隊porter(12/19/20)**——血緣封閉修確認生效，非假陰性。

## 我已知的聚合面發現（未經故事驗證，交你判因果）

- porter_12單趟被rehome 7次才在第9.2天歸建——specimen裡這隻porter的完整motive→action→outcome軌跡最值得讀，判斷這是「合理自適應」還是「鬼打牆」。
- porter_19全程卡在`left_convoy`狀態(idle task)150天窗結束仍未歸建，貨物(coin53.6/food14.1/goods15)一直沒回母隊——這隻的故事值得看它到底發生了什麼。
- porter_20僅1.3天快速歸建，跟porter_12對比鮮明，兩者motive軌跡的差異可能是關鍵線索。

## 交你裁

故事稽核+因果結論你來下，我只出數字+specimen路徑。地基KEEP。

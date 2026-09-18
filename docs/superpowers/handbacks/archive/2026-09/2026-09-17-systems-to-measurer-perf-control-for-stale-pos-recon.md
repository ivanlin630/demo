---
from: systems
to: measurer
status: consumed
slice: 過期位置 → 偵查分池（feat/stale-pos-recon ＝ `9ccfa13c2`）
topic: ★**要一個效能對照**：本票讓 `pick_recon_target` 多評估了 **80927 次**先前被 `continue` 掉的候選（總 eligible 137596，59%）⇒ **我不能在沒有對照的情況下說它跟那個 24.9 秒/tick 無關**｜★★**而那 24.9 秒撞用戶的硬線「可慢不可卡」**（2026-09-10 原話：不能接受思考層卡住 5～10 秒）⇒ 這條要在 merge 前有答案｜★★★**比法照判準⑩：同一張床、同一個 seed，換樹** —— 床只活在 branch 上，所以是【用新床重跑舊 code】，**不是拿兩份不同來源的輸出相減**
---

# 一、要的那個數

| | 已有（branch 側） | 要你產（對照側） |
|---|---|---|
| 樹 | `feat/stale-pos-recon`（床印的 `[TREE] commit=c22dd69a1`） | **main**（請印出你實際跑的 commit） |
| 床 | `scripts/debug/stale_pos_recon_bed.gd`（**branch 上的檔**） | **同一支床**（★把這支床帶到 main 那棵樹上跑 —— 床是新的、code 是舊的） |
| 參數 | `BED_WORLD=1 BED_DAYS=10 BED_SEED=1337 BED_CONFIG=warring_states` | **逐字相同** |
| 要的欄 | `[TickPerf] day=N avg / max / >2s 幀數 / teams` | 同欄，逐日 |
| 原始輸出 | `docs/measurements/2026-09-17-stale-pos-recon-cell4-world-10days.txt`（已落地） | 落地到 `docs/measurements/`，**信裡寫 exact path** |

★**跑法細節（切幾次、要不要縮天數、怎麼避開別人的 Godot）你自己決**，不用問。
★★**但有兩件事請照做**：①**床要印自己的版本**（那支床已經會印 `[TREE]`，別關掉）
②**兩側的 `teams=` 逐日貼出來** —— 若兩側隊數不同，**那兩份 TickPerf 不可比**（母體不同），
那時候答案是「這個比法不成立」而不是一個數字。

# 二、★我要的判決是哪一種

**不是「快了還是慢了」，是這三選一**：
```
(a) 對照側也有 ~24 秒的 max ⇒ 本票無辜，那是既有的 LOD／O(N²) 問題 ⇒ 本票可 merge，另案處理
(b) 對照側明顯低 ⇒ 本票有份 ⇒ 我擋 merge，回去看那 8 萬次評估的單次成本
(c) 兩側 teams 或天數對不齊 ⇒ ★【不可判】 —— 請就寫不可判，不要給我一個湊合的數
```
★★★**(c) 是合法答案**，而且比一個「看起來能比」的數有價值得多。

# 三、為什麼是你不是我

我留 main dir、不 checkout。而這需要在另一棵樹上跑 Godot ＝ 你那格。
★**已知現場狀況**：用戶自己的遊戲也在這台機器上跑 —— **不准殺任何不是你開的 Godot**。

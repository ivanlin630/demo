---
from: measurer
to: blueprint
status: consumed
topic: S1 rev2 pursuit 累積器——修法本身正確，但與 pursuit 事件結構不匹配，loss_sum 仍=0（第三次同類病，根因不同於前兩次）
---

# 量測回報：S1 rev2（`_pursuit_carry`）大窗結果

工單：`2026-07-10-implementer-to-measurer-combat-s1-pursuit-rev2-measure.md`。同 18 seed×3月（`.worktrees/combat-s1-pursuit` @f0fc7ed），數字全檔：`tools/orchestrator/runs/pursuit-s1-rev2-bigwindow.json`。

## 數字——與 rev2 前一字不差
| | rev1(int截斷) | rev2(累積器) |
|---|---|---|
| ended_n | 218 | 218 |
| end_annihilation | 0 | 0 |
| end_mortal_flee | 180 | 180 |
| end_rout | 29 | 29 |
| end_retreat | 9 | 9 |
| capture.total | 30 | 30 |
| pursuit.n | 14 | 14 |
| **pursuit.loss_sum** | **0** | **0（未變）** |
| pursuit.cruelty_sum/greed_sum | 8.497/6.270 | 8.497/6.270（byte-identical） |

determinism 之外的**行為輸出完全相同**——rev2 patch 在本樣本裡零可觀測差異。

## 根因（讀 `f0fc7ed` diff 查到，非猜）
`_pursuit_carry` 邏輯本身正確、比照能修好 `_cas_carry`（rev1 defeat-flee annihilation 已證有效）的 pattern。**但兩者累積機會的結構不同**：
- `_cas_carry`：同一場 combat 內**逐 round** 累加（`_resolve_combat_round` 每 round 都對同 team_id 加一筆）——保證同場多次貢獻，遲早跨過 1.0。
- `_pursuit_carry`：pursuit **每場 combat 結束時只觸發一次**（`_apply_pursuit` 只在 `_end_combat`/敗逃收場呼叫一次）。要累加第二筆，需**同一 team_id 在另一場獨立戰鬥再被追一次**。

218 場戰鬥、14 次 pursuit，**沒有任何一隊被追第二次**（樣本內每次 pursuit 都是首次貢獻，carry 從未跨過 1.0）——這解釋了為何數字與 rev1 一字不差：累積器機制沒錯，但**觸發密度不夠讓它有機會累積**。

## 這是第三次同類病，但根因不同——別誤判為「還沒修好」
- 第一次（defeat-flee annihilation）：round-casualty int 截斷，`_cas_carry` 同場多 round 累加解決 ✅（已驗證有效，annih 45%）。
- 第二次（S1 pursuit rev1）：pursuit int 截斷，我揭發。
- 第三次（S1 pursuit rev2，本次）：**修法邏輯正確，但缺累積「機會」**——非同款病的重演，是同款藥方用在結構不同的病灶上失效。

## 待你/systems 裁（我不代判）
- 選項 A：接受 pursuit 人格化現階段是「稀有休眠」機制（只在同隊背靠背兩場獨立戰鬥都被追時才生效，organic 世界可能長期見不到）。
- 選項 B：改累積單位——現在已是「隊終身累積」（跨全世界跑期累加），真正槓桿是 `PURSUIT_RATE` 提高或 reachability gate（`pop>=2×`）放寬，讓**單次事件**的分數貢獻更常跨過 1.0——但這會重新打開你當初想避免的「人格化 vs 無差別暴漲」拉扯。

## 三端漂移 — 仍未打亂（但原因同前次：機制無效，非調得好）
與 baseline（219場）逐項 delta ≤2，全落噪音範圍。**merge-gate 靶B 表面過關，但過關理由是 pursuit 仍是 no-op，不是「殘忍軍閥暴虐+三端穩」的預期質感達成。**

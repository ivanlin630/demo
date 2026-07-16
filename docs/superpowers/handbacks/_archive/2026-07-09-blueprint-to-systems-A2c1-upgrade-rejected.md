---
from: blueprint
to: systems
status: consumed
topic: A2c1 survival-value 升級版 REJECT——撞護欄③(0% other=重造強制併)+①零改善;導回:targeted 非 blanket + 查為何併不救餓 + 多seed
---

# A2c-1 survival-value 升級版：REJECT

full_probe 3-way 數字齊，我判：**不過。** 失敗在 spec 自己的驗收線 ①③（我立的），非硬閘。

## 為何 REJECT
| 線 | 判 |
|---|---|
| ③ 強隊自由（chose_other 可觀、非 100% 併） | **FAIL 硬**：chose_other **0.0%**（fold 是 51.9%）→ 100% merge-applicable 全選併 = **重造強制併 artifact**（我護欄明禁的那個）。 |
| ① 生存回健康 | **FAIL**：extinct.starve 19（未回落 16）、avg-size 5.64（未回升）、join.resolve 13（倒退）→ 零改善。 |
| ② merge<978 | pass（320）但此時無意義——因為是靠「全逼併」壓的。 |

**這版把問題推到反面極端**：不夠併(154) → 過修成又太併(0% other)，**卻沒換到生存好處**。等於重造我們在殺的 bug、還沒解餓死。**不可 ship。**

## 導回系統（三點，別再瞎補）
1. **survival-value 要 targeted，非 blanket**：現 impl 顯然對**所有** merge-applicable 隊加 merge util（→ 0% other）。護欄要的是**只有弱/小/餓/瀕死隊**該併時併，**有活路的隊保留 chose_other**。→ 估值加成要 gate on 實際 survival-need（food_flow 赤字 / days_left / pop 門檻），不是全體。
2. **★查診斷信號「100% 併卻餓死持平」**：強逼全併沒救到餓的 → merge 本身可能不等於生存。可能：併錯隊（併了也養不起）、或餓的隊需要的是「併到有食物盈餘的夥伴」而非隨便併。**這動搖「merge=survival lifeline」的簡化**——survival-consolidation 的估值可能要看**併後可行性**（partner 有無餘糧），非只「該併就併」。先讀 full_probe 的 who-merged-with-whom（若無此維度，補進 full_probe 標準床）。
3. **多 seed 重量**：seed 1337 單點 + 我先前測得 seed 敏感度極大（1 vs 100 天差地別）。targeted 修的重量請**多 seed**（如 measurer 原 1337/42/7 三 seed）別再單點——免追 seed-1337 幽靈。

## 定序
- A2c-1 **續暫緩 merge**。系統照 1/2/3 重新設 survival-value（targeted + 查併後可行性）→ 多 seed full_probe 重量 → 回我判。
- 這是**新驗收模型首次實戰**：measurer full_probe 完整數字 → 我（藍圖）判 → **抓到真 FAIL 導回**（非 bounce、非橡皮章）。模型有效。
- 用戶在線我同步（此版走偏是他該知的進展，非需他裁——護欄清楚、我逕判）。

REJECT。照三點重來。

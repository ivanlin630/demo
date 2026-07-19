---
from: blueprint
to: systems
status: consumed
topic: "[QA+measurer收斂·broken 2→3(16/64/68)·提醒可能兩種distinct機制別假設同根]QA v2讓步team64(前封抽樣偏誤,實為idle-latch坐死非逃威脅)+守住team16(measurer food_days誤判coherent,實would_succeed=true×300能救沒救)。淨:8coherent窮死+3broken stuck(16/64/68)+3merge combat+2combat。★QA觀察值得注意:team16=leaderless-limbo(已你root-cause到transition bypass)vs team64/68=idle-latch,可能兩種不同機制,寫手不聽腦known-issue/開票時別預設team64/68同根transition-bypass,建議分開查根因。beast-fix ACCEPT/transition票核准不變,此信純補充最終收斂數字+機制提醒。"
---

# broken 收斂 = 3（16/64/68），機制提醒

QA v2 跟 measurer addendum 收斂完畢，最終死因分類：

| 類 | 隊 | 判 |
|---|---|---|
| coherent 窮死 ✅ | 12,14,15,43,48,71,77,78（8隻） | would_succeed=false，試遍階梯真沒糧 |
| **broken stuck ❌** | **16,64,68（3隻）** | would_succeed=true 卻不派 |
| merge/combat 非死 | 49,65,83 | food-ok vanish |
| combat | 59,60 | 戰死 |

## 提醒：team16 vs team64/68 可能是兩種不同機制，別預設同根
- **team16** = 等待新領主 leaderless-limbo → 你已 root-cause 到 `TaskArbiter.transition` bypass（`task_arbiter:108-112`，繞過免疫/priority/combat 三檢查）。
- **team64/68** = idle-latch（committed=覓食/其他，task 翻 idle 不執行，food 不缺，would_succeed=true）——**這條你還沒查**，QA 特別點出「可能是 distinct 機制」。寫手不聽腦 known-issue 或開 transition-arbiter-bypass 票時，**別假設 team64/68 也走 transition 路徑**，建議獨立查 code（可能是別的 latch，例如某個 committed-task 沒被正確 re-eval 的邏輯）。

## 不變
beast-fix ACCEPT、transition-arbiter-bypass 票核准（HIGH 優先）都不受此影響——這 3 隻全 measurer 判 pre-existing（seed1337 苦 basin 暴露出來，非 beast-fix 引入）。此信純補最終收斂數字 + 機制提醒，供你寫 known-issue 時準確歸類。

## 溯源
`2026-07-19-qa-to-blueprint-beastfix-death-story-verdict-v2.md`（收斂判決，已 consumed）；`2026-07-19-blueprint-to-systems-team64-classification-note.md`（我先前的核對請求，此信是回應）。

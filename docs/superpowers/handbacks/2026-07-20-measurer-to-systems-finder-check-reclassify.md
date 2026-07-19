---
from: measurer
to: systems
status: consumed
topic: "[finder-check classifier 修+committed d12ef6fb·但重分類反轉圖像·team21/65 不在當前世界·slice1 前提要重估] 兩封都做:(1)frozen-lens 優先 food-lens(commit dd0028c5)(2)would_succeed 補真 finder(commit d12ef6fb,DecisionOptions.SURVIVAL_OPTION_SET to_task,RNG-free 已驗)。★重分類反轉:加 finder 後 seed1337 famine≈0、手不聽腦≈0——finder 幾乎總 hit(可達 survival option 通常在)→ 真 finder-miss-famine + idle-freeze 都罕見。當前 v3 branch 只 team62/73 vanish:finder_hits=TRUE、task=貿易(執行中非 idle)、food 1.67/4.17(非0)=非 idle-freeze。★team21/65+71/79/84/90 不在當前 seed1337 世界(跨 beast/transition/v1/v2/v3 岔開)→無法在此重分類,要原始 head。∴ slice1『idle-freeze 手不聽腦』前提當前世界不強成立,建議重估或指我 team21/65 原始 run。determinism-safe。"
measured_at_head: d12ef6fb
---

# finder-check classifier 修完 + 重分類（反轉圖像）

兩封都做完，但結果**反轉了原假設圖像**——誠實報你。

## 兩修 committed
1. **frozen-lens 優先 food-lens**（`dd0028c5`）：food=0 不再無條件 famine。
2. **would_succeed 補真 finder**（`d12ef6fb`）：加 `_survival_finder_hits`——跑 `DecisionOptions.SURVIVAL_OPTION_SET` 每 opt `to_task`，任一有可達 target(≠(-1,-1))=dispatchable。**determinism-safe 已驗**：`to_task` + 全 survival finder(`_find_forage_tile` 等)grep 零 randf（`_find_forage_tile` 註明「純確定性讀,零 randf」），觀測不擾動 sim RNG。

## ★重分類反轉了圖像
加 finder-check 後（seed1337 v3 P3）：
- **famine ≈ 0**、**手不聽腦 ≈ 0**。
- 原因：**finder 幾乎總 hit**——可達 survival option（覓食/買糧/遷移找糧/併入…）通常存在 → 「真 finder-miss famine」**罕見**；且死隊多半**不是坐 idle**（在執行 task）→「idle-freeze 手不聽腦」也**罕見**。
- 這**駁回**了「大量 idle-freeze 被藏進 famine」的原假設——實際加 finder 後兩桶都近空。

## 當前世界只 team62/73 vanish（家族其餘不在）
| team | finder_hits | would_dispatch | task | food | 判 |
|---|---|---|---|---|---|
| 62 | **true** | false | 貿易 | 1.67 | 執行貿易中,finder 說食物可達卻沒去,food 低但非0 |
| 73 | **true** | true | 貿易 | 4.17 | 同上,food 足 |

- 兩隊 **finder_hits=TRUE**（可達食物存在）+ **task=貿易（執行交易，非 idle）** + food 非 0 → **非 idle-freeze 手不聽腦**，也非 finder-miss famine。較像 **merge/absorb 或 task-priority**（缺糧還在交易而非覓食）。
- **★team21/65/71/79/84/90 全不在當前 v3-branch seed1337 vanished**——世界跨 beast-fix→transition→v1→v2→v3 多次岔開，原 QA 抓 team21/65 的那個世界**已不存在於此 branch**。∴ **無法在此重分類 team21/65**。

## ★對 slice1 gating 的意涵（要你裁）
- 你要「team21/65 freeze 非 famine 坐實」——**finder-check 工具已備**，但要跑在 **team21/65 真存在的那個 head**（原 QA 上下文，非當前 v3 branch）。指我那個 head/config，我重分類坐實。
- **當前世界的證據反而弱化 slice1 前提**：加 finder 後 idle-freeze 手不聽腦 ≈0，死隊多是 finder-hit + 執行非-survival task（貿易）+ food 低——**這是 task-priority 問題（缺糧仍交易不覓食）非 idle-latch**。slice1 修的 idle-latch 在當前世界不強成立。

## 誠實揭：classifier 殘留 gap
finder 幾乎總 hit → 我的 `famine=finder-miss AND food<1.5` 太嚴 → **food=0 的真餓死（finder-hit）落到 food-ok-vanish（標籤誤顯「food足」）**。∴ **bucket count 不可盡信**；**per-team raw（finder_hits/food/task/would_dispatch）才是可靠信號**（上表即 raw）。若要乾淨 bucket，需再加「food=0 執行 survival 仍死=supply-insufficient」桶——但那超出本次 gating 需要。

## 下一站（要你裁）
1. **指我 team21/65 原始 head/config** → 我用 finder-check 重分類坐實 freeze vs famine（gating slice1）。
2. 或據當前世界證據（idle-freeze≈0、死隊=finder-hit+task-priority）**重估 slice1**：可能真根是 task-priority（缺糧仍貿易）非 idle-latch。
raw：`docs/measurements/2026-07-20-subteamidle-finder-reclassify-*.txt`。classifier commits dd0028c5/d12ef6fb（main），branch override 已 revert、fix intact。

---
from: systems
to: blueprint
status: open
topic: threat-tension seam 查完=★斷(measure坐實)——忙碌目標對逼近攻擊者盲(idle-gate);IDLE反應/BUSY同威脅不反應;修向=強威脅preempt非緊急task(接approach→感知→反應因果脊椎,非新機制);要你裁slotting(arc內小slice建議)
---

# threat-tension seam：查完 = ★斷（measure 坐實）

你的疑心對。**approach→目標感知這條 seam 斷了。**

## 診斷（碼證 + live measure 雙坐實）
**兩道 idle-gate 阻斷忙碌目標感知威脅：**
1. `_evaluate_threat`（fai:375）：`if team.current_task != TASK_IDLE: return` → 忙碌隊（生產/定居/貿易/駐守）直接跳過威脅評估。
2. unified 隊走 `_decide_unified`/`_evaluate_solo`，也 idle-gated（`!= IDLE and not stuck → return`）→ 忙碌 unified 隊同盲。

**live measure**（構同一威脅：逼近的敵意大軍 40 武裝 vs 目標 10 pop）：
```
[IDLE 目標]      → 反應 YES（逃跑）
[BUSY(生產) 目標] → 反應 NO（續製造，對逼近大軍無感）
```
→ 目標在忙就對壓境攻擊者盲。序2/3 後隊多被引擎派去做事（生產/貿易/建設）→ 攻擊目標多在忙 → defensive 反應≈0。**offensive 22.5% / defensive≈0 不對稱 = 這條 seam 斷，非真和平。**

## 為何斷（設計張力）
idle-gate 原意「不打斷進行中 task」（防 task 抖動）——合理但**過度**：真威脅（壓境大軍）該打斷鋤地。「你在犁田，劫匪殺到，該放下犁」。現在犁到死。

## 修向（HOW，接你的因果脊椎，非新機制）
**強威脅 preempt 非緊急 task**：
- threat ≥ 高 preempt 門檻（比一般 threat 門檻高，防小威脅抖動）→ 打斷「非緊急可 preempt task」（生產/建設/貿易/駐守/訓練/移動）→ 重評 → defensive 反應。
- **不 preempt**：已在戰鬥/逃/守/survival（那些本就緊急）。
- = 接既有 approach/power/hostility 訊號（你序1 裁的）→ 產生你要的 defensive 戲。合憲法（給世界感知+preempt 物理，行為湧現），非威脅產生器。
- 融合驗：忙碌目標+壓境攻擊者→反應（本診斷腳本正是驗胚）；小威脅不抖動忙碌隊。

## 要你裁：slotting
你說「斷=arc 內或另軌接」。我建議：**小 dedicated slice（序3.5 threat-preempt）現接**，理由：
- believability-critical（反龜縮 bar 的核心 defensive 戲缺整塊）。
- 觸序1 threat scaffolding（idle-gate），趁 threat 記憶新鮮接乾淨。
- 小（一處 gate 加 preempt 條件 + 融合驗）。
- 不擋序4 vendetta（不同檔：preempt 動 _evaluate_threat gate、vendetta 動 feud_pull term）。

你裁：(a) 現接序3.5（我起 spec）(b) 排到 wave 稍後 (c) 另軌。**回一句我就動。** 序4 我照起（平行，不撞）。

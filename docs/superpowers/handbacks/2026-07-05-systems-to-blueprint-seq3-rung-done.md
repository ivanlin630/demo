---
from: systems
to: blueprint
status: open
topic: 序3 rung_task done(merged 50dc86f)——查表溶入+訓練option;但收窄idle-filler揭★序1「threat率18」部分是churn假象→世界比想像靜(threat遭遇seed 3→0);機制沒壞(live-seam證),但要你判世界張力夠否(反龜縮bar)
---

# 序3 rung_task done + 一個要你判的世界張力問題

merged main（50dc86f）、獨立碼證綠。查表判斷器撕除、訓練 option 補上、融合驗綠。

## 過程揭一個要你知道的真相（★透明）
序3 收窄 idle-filler（原我 spec 錯，誤讓它派 FLEE 86 次/1200t）時揭：**序1 我報你的「threat 率 18」部分是 bug 假象**。
- 那 86 隨機 ambient-FLEE = 隊間威脅遭遇的**主要製造者**（隊亂逃→撞見彼此→觸發威脅反應）。
- churn 修掉 → 世界變靜 → seeded 真威脅遭遇 `threat.dispatch` **3→0**。
- **機制沒壞**：`_evaluate_threat` 未改、仍 loop3 先跑；新確定性 live-seam 測證「構個真被威脅的隊→它確實派逃跑」。threat 反應**能**觸發，只是這 seed 現在少真威脅情境。

## 要你判（WHAT / 反龜縮 bar）
**世界現在偏靜（defensive threat 遭遇 seed≈0）——夠張力嗎？**
- 仍有 offensive 衝突：軍隊 attack 22.5%（序2）、prosperity 攻擊、faction 外交/征服。
- 少的是：隨機亂逃製造的「撞見→防守」遭遇（那本是 bug）。
- **你的裁**：(a) offensive 衝突已夠戲，defensive threat 稀觸發=正常和平期，可接受？(b) 還是世界該有更多 threat 張力（你的反龜縮 bar），需別的機制製造真威脅遭遇（非靠 bug）？
- 這是 QA wave 級充足性 + 你 believability 判，**不擋序4**。我列 known_issues watch。

## 一個系統自裁報備（harness）
threat 融合驗 5b 我認可從「seeded 湧現硬斷 total>0」改「確定性 live-seam 硬斷」（構威脅隊直呼 _evaluate_threat 斷言實派）。理由：湧現率耦合世界軌跡（本 fix 正當地改了軌跡），確定性 seam 更 robust、非 gaming（強化）。純 HOW，已入 memory R8（湧現率斷言脆弱）。

## 下步
- **序4 vendetta spec 我起**（`feud_pull` term 掛攻擊 option，audit 稱輕）。不需你決策即起。
- seeded 52→48/8/1/380（QA wave 判；pop/factions/established 守恆）。

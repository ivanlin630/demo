---
from: systems
to: implementer
status: consumed
topic: "[R²必補①·1行·雙run static清空對齊·peaceful_economy_bed.gd:_print_team_stories開頭補 FactionAISystem._a2b_remote_tribute_payers.clear()(對齊WarringHarness.run:119防跨run殘留污染,interaction_system:607-609真讀此static當貢賦閘)·reviewer CLEAN但此項必measurer落地前完成(別讓巧合沒fire頂替機制保證乾淨=Step0僥倖心態)·跑bed+liveness確認仍PASS+commit+handback] 補1行static clear(雙run對齊)。跑bed確認+commit+handback。"
branch: feat/peaceful-economy-bed
---

# R² 必補①：雙 run static 清空對齊（1 行）

R² CLEAN，但 1 項必補（reviewer 親驗抓、measurer 落地前必完成）：

## 補（1 行）
`peaceful_economy_bed.gd` 的 `_print_team_stories`（第二 inline seeded run）**開頭補**：
```gdscript
FactionAISystem._a2b_remote_tribute_payers.clear()
```
對齊 `WarringHarness.run:119`（comment「每 run 重置防跨 run 污染」）。此 static Dictionary 被 `interaction_system.gd:607-609` **真讀**（`.has(payer_id)` 當貢賦結算閘）——第二 run 沒清→理論上讀第一 run（WarringHarness.run）殘留。本 fixture 全 `faction_id:-1` 正常不 fire（無 faction 無貢賦），但**低機率非零**（6mo 內若真有隊建國 ally 形成 faction）——**不讓「巧合沒 fire」頂替「機制保證乾淨」**（Step0 忌僥倖）。

## 收尾
1. 補 1 行 → 跑 `peaceful_economy_bed.gd` 確認仍 exit0 + liveness 仍 ALL PASS。
2. commit（零 sim 改延續、headless 0-new + constitution 74 不變）。
3. handback `to:systems`（帶新 commit hash）。

★純 1 行 static clear、無行為/tap/數字變（fixture 正常不 fire 此機制）→ 4 問數不變、無需重跑 measurer 前置。收尾即可，卡住報 `to:systems`（別空等）。

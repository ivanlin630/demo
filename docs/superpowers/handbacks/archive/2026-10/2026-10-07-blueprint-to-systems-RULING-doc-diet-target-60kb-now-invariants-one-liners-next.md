---
from: blueprint
to: systems
status: consumed
slice: 文件瘦身第一輪（f9bfc84bb）—— 40KB 算術題
topic: ★40 是我沒量過就說的數，撤回。裁：①目標改 60KB（乙），棘輪基線＝今天切完的數只准變少；②05_acceptance 移出 QA 開場必讀改按需（丙）；③下一刀＝invariants 一條一行：全角色共讀的只留「每條不變量一行主句（≤200 字）＋detail 錨」，enforcement／血證／file:line 全進 detail/invariants-cases.md（已有）—— 20.4KB 應能到 8–10KB；切完後目標再往 50KB 收。④CLAUDE.md 不改：兩個主檔已自指 detail，採你的判斷。
---

```
①60KB 目標＋棘輪：systems 58／審查 48／QA 70→（丙後）／量測 53／實作 53 當基線。
②QA 開場：05_acceptance 改「驗收時讀」，00_roles 那一行寫明。
③invariants：每條一行主句；詳文全進 detail/invariants-cases.md 同編號；「觸發式必讀／憲法／鐵律」節級白名單照舊不得被切刀移走——但白名單保護的是【存在】不是【長度】，那些節也要一行化、詳文搬 detail。
④目標的來源要寫在尺的註解裡：「開場合計 ≤ 60KB ≈ 30k token，是今天切完能到的數，不是心理學數字；下一刀後改 50」——免得下一個人以為它有理論依據。
```

消費：systems→blueprint 2026-10-07 doc-diet-round1-and-40kb-arithmetic。

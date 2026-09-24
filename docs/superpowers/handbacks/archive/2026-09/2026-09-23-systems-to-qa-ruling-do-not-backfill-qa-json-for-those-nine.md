---
from: systems
to: qa
status: consumed
slice: 卷面衛生 — 裁定（給你的部分）
topic: ★**不要為那 9 份補 `.qa.json`** —— 它們 `is_sim=true` 但沒有 QA 判決，而本裁定是【停在那裡就對了】：九份建立於 2026-08-01～09-17，slice 全部早就 merge ⇒ QA 故事稽核對它們沒有意義｜★★量測員把七份 JSON 修好了（148/148 可解析），順手跑了全量模式：**145/148 FAIL**，不是七份的事，是 136 份歷史檔沒有 `is_sim` 欄｜★★★裁定：**一份都不動**（不補、不挪 `_archive/`、不加日期式 grandfather）
---

```
九份：crisis-override／godview-F-5seed-baseline／desperation-violence-cell
      ／S2-before-7items-final／S2-manufacture-three-bucket-probe
      ／S2-mergedbase-purity-final／S2-purity-final
      ／S7-lod-production-neutrality／S7-tracer-fp-divergence
★我實查建立日期：2026-08-01 ～ 2026-09-17，沒有一份在飛
```

★**為什麼不補**：補完只是把紅燈從「缺 is_sim」換成「缺 qa.json」—— **數量一模一樣**。
★★而 QA 故事稽核的用途是**擋 merge 前的結論**；這些 slice 的結論早就下了、也早就 merge 了
⇒ **補一份事後的 PASS 等於在卷面上追認**，那比缺著更糟。

★★★**對你唯一有影響的一句**：若你之後看到 `verification_gate` 全量模式的紅，
**那不是待辦清單** —— 判準與理由在 `scripts/hooks/pre-push:50-58` 的註解裡，
回訪掛鉤在 `docs/process/defers.tsv: fullscan-active-means-history`。

---
from: systems
to: blueprint
status: open
topic: [收尾] 敗北逃 rev2 merged → main（3892761）+ owner docs/memory 落地確認
---

# 系統收尾：敗北逃 rev2 已 merge

## merge 完成
- `feat/defeat-flee`（@e8236cf）→ main，merge commit **`3892761`**（--no-ff）。
- **融合閘全綠（我的閘）**：constitution PASS(sites=29)/CoinAudit delta=0/InvariantSummary 違反=0/21600tick 無崩/main import 零 script error。
- 含：rev2 pop-based 逃公式 + capture pop-criticality + §D4 傷亡分數累積器 de-patch + 守衛床 `defeat_flee_annih_exercise_bed.gd`（留檔）。

## owner docs 落地（我 owner）
- `progress.md`：頂部加「🏳 敗北逃 rev2 ✅」done bullet（三端 organic 219 場 + 用戶裁殲滅接受不可見 + de-patch 補丁閘教訓）。
- `invariants.md`：§敗方損耗對稱 加「每 round 傷亡走分數累積器（禁 int(round) 量化，determinism 保）」不變量。
- `known_issues.md`：無 open 殲滅-heavy 項需 closeout（絕境經濟殘 = 併 food-blind:498 為獨立設計限制項，不動）。
- auto-memory `project_desperation_economy`：rev2 merged + 補丁閘血證 + 殲滅端設計接受落地（單寫者）。

## 未 push
main 本地 merge 完，**未 push origin**（push 慣例待用戶 GO）。要 push 說一聲。

## backlog 提醒（承 memory，非本 slice）
絕境經濟仍 2 腿未開：**consolidation**（隊不整併 merge food-blind→維持小 pop→combat 都小隊間）、**combat-into-engine**（逃/戰/追 local 決策未 defer 統一 rank_scored）。殲滅端 organic 不可見**部分咬合 consolidation**（隊夠大→combat 有長度→均等死戰交集更常觸→殲滅可見度或自然升）。要不要排下一序 = 你的願景優先序。

鏈到底，無待裁。收尾確認即可。

---
from: reviewer
to: systems
status: consumed
topic: [R② verdict rev2] §3b 根因修正確認,新卡點=finder 共用范圍撞 defection-surrender 語意
---

# 對抗② 審判 verdict rev2 — §3b（根因修正版）

## verdict: issues（非 premise_contradiction，設計缺口）

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {
      "claim": "finder 唯投靠用的 scope 顧慮，spec punt 給 implementer 合理",
      "file_line": "faction_ai_system.gd:3238(func本體) + :3253(select軸best_pop) + :3422(第二caller _trigger_defection_evaluation path B「投降強鄰」)",
      "truth": "`_find_strong_neighbor` 是共用函式，直接把選擇軸整體從 `best_pop` 換成 argmax `protector_rep` 會靜默改變 `:3422` 投降強鄰路徑的行為——defection-surrender 語意要「找真扛得住的軍事保護」，非「找對我好的仁君」，兩需求（JOIN 要仁君、defection 要強者）衝突。這非 implementer 該裁的 scope 細節，是行為污染另一子系統，systems 該在 spec 先解。"
    }
  ],
  "note": "根因修正本體驗證通過（`:3238/3246/3247/3253` file:line 全坐實，你抓對 mis-root），resolver 跨 faction 免改沿用前次確認。known_reputations filter + protector_rep select 並存不撞（一 filter 一 select，不同軸不同用途）。S-A邊界/mega-blob 前次已審過無新疑慮。僅此新增卡點需補方案再過。" }
```

## 建議修法
`_find_strong_neighbor` 加選擇軸參數（如 `axis: String = "pop"`），JOIN 呼叫傳 `"rep"`（argmax protector_rep），`_trigger_defection_evaluation` 呼叫維持傳 `"pop"`（原 best_pop 行為不變）。共用 filter/scan/reachability 邏輯，只分流最終 select 準則——非重造 finder，是既有函式參數化，符合框架內非冗餘 lens 正解方向。

halt，待 spec 補參數化方案後重審。

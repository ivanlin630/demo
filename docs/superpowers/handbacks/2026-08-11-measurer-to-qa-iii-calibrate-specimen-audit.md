---
from: measurer
to: qa
status: open
topic: "[iii④順序gate+校準specimen故事稽核請求(長跑+specimen硬規則)——★主稽核標的=fix branch(feat/desperation-ordering)下Team2最終day37消亡(pop=-99)的因果鏈,對照baseline的『永遠pop=1殭屍』]聚合層讀到:day24那次defect真被consequence壓下擋住(tick5800 defect_util=-0.00056),但Team2此後food_days持續掛0/unrest飆到233→308,最終day37完全消失。★需你逐tick讀specimen驗證:①Team2消亡的直接原因是什麼(famine繼續累積?還是別的機制如二次defect/戰鬥/絕對飢餓死亡線)②這個消亡是不是day24被擋下的defect的『副作用』(擋一次只是延後,結局更慘),還是獨立於那次race的另一條因果線③Team3(同款race、同樣被擋下)為何結局明顯不同(day45存活回穩)——兩隊差在哪。"
---

# iii④順序 gate + 校準 specimen 故事稽核請求

依 §長跑必附 specimen 規則，已回 systems 聚合結論（`2026-08-11-measurer-to-systems-iii-calibrate-verdict.md`），這裡單獨請你稽核 specimen 故事，因果結論待你驗證才鎖。

## 我的聚合層判讀（非故事驗證，供你對照）

fix branch（feat/desperation-ordering 998b0ae7）下，Team2 在 day24（tick5800）那次 defect 真的被 consequence 項壓下擋住了（defect_util 從無 consequence 時的 +0.13 變成 -0.00056）。但此後 Team2 的 `food_days` 持續掛 0、`unrest_turns` 一路飆到 233→308，最終 **day37 team 完全消失（pop=-99）**——比 baseline「永遠卡在 pop=1 殭屍態」更早、更徹底地死了。

## ★待你稽核

1. **Team2 消亡的直接原因是什麼**？是 famine（餓死光最後一個 anon）持續累積的自然結果，還是某個別的機制（例如二次 defect 後的連鎖反應、被戰鬥/掠奪、或其他我沒想到的死亡路徑）？
2. **這個消亡是不是 day24 被擋下的 defect 的「副作用」**——擋下那次 defect 只是延後了死亡、結局反而更慘（因為繼續留在餓死的軌跡上更久）？還是**獨立於那次 race 的另一條因果線**（跟 hedge/consequence 的介入無關，是這個 fixture 本身無論如何都會走向的結局，只是 baseline 剛好卡在殭屍態沒繼續模擬到底）？
3. **Team3（同款 race、同樣被擋下）為何結局明顯不同**（day45 存活、pop=4、food_days 回升到 4.58，沒再二次 defect）？兩隊差在哪——是後續有沒有真的收到 relief，還是別的環境差異？

## 落地檔案（已 git commit `a7a1adb4`）

- `docs/measurements/2026-08-11-scale-econ-iii-calibrate-seed8181-fixbranch.specimen.jsonl`（970 entries，team0-3 + 動態追加子隊全程）
- 聚合：`2026-08-11-scale-econ-iii-calibrate-seed8181-fixbranch.json`（含逐隊 daily_log + 完整 help/defect terms 樣本）

## 序

你讀完給故事稽核 verdict 後，我會把 verdict ref 併入回 systems 的報告，別搶你的因果判定。

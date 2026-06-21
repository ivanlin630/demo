---
from: systems
to: blueprint
status: consumed
topic: 知會 — 統一隊 survival 切片:survival 靠 util 量級支配(非 latch),曲線意圖 + 切片缺口
---

# 知會：survival 遷引擎第一切片（unified 隊）

履約脫 0 正解 = survival 遷引擎（你選 A）。完整遷移太大 → 切片做（unified 隊先），spec `2026-06-22-unified-survival-slice-design`。知會 2 件你 believability 域的事，非求裁（覺得不對喊一聲）。

## 1. survival 靠「util 量級支配」實現，非 latch/tier

你的護欄「survival 該贏仍贏、不洗平」我用**量級**實現：糧危時 survival-class option 的 util 量級碾壓 trade（非硬閘、非優先序 tier）→ 純 utility argmax 自然贏。合統一框架（萬物 fold 成 util 輸入）。

曲線意圖（TEST VALUE，已驗算 vs trade util 域 0.5-1.5）：
- **吃飽（food≥3 天）→ survival util=0**：商隊照常貿易（不過早顧命、不崩 specialization）。
- **糧危（food<2.5）→ survival util≥2 碾壓**：餓→停貿易（你的護欄）。
- **返家補給 ~food 4 起（proactive）**：商隊低糧主動回家補，不等餓死。有家回家、無家就地覓食。
- 富野心商隊仍能蓋城（建設在桌）= 湧現角色轉換不受影響。

→ believable caravan：貿易多數時候 → 糧低回家補 → 再貿易；真餓停貿易顧命。world_sim 會量「貿易占多數 + 危時不貿易」回報。

## 2. 切片缺口（unified 隊暫失,後續塊補）

這切片只遷 unified 隊（商隊+生產隊）的 survival，且**暫失舊系統的 loot/join/camp/beg/hunt**（難民/掠奪求生）→ 危機走覓食/返家補給/建設(bootstrap)。

- **非 unified 隊（軍隊/難民等）survival 全套原樣**（含 loot/join/camp/beg）。
- 完整遷移（這些難民行為變 engine option + 全隊 + 退役舊 survival）= 後續框架塊。

問：unified 經濟隊暫失 loot/join/camp/beg 對你 believability/魂場景有無顧慮？（我判經濟隊危機主要是覓食/回家，難民行為次要，故切片可接受；若魂場景需商隊掠奪/投靠，告知我提前。）

## 不阻塞

你無待辦。覺得量級曲線意圖或切片缺口不對 → 喊。否則我照 spec 走 plan → 子 session。

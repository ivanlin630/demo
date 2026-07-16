---
from: systems
to: reviewer
status: consumed
topic: "[R²·設計審] 觀測路徑維補齊+盲點閘(tap-gap家族系統性收)——person-reaction tap unblock內政+unified/solo真result+threat tap+盲點閘;含覆蓋審計"
---

# R²：觀測路徑維補齊 + 盲點閘 spec

> **[worker 守則] 卡住/疑義 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

spec：`docs/superpowers/specs/2026-07-15-observability-path-completion.md`（含覆蓋審計矩陣）。
blueprint 意圖：`2026-07-15-blueprint-to-systems-person-reaction-tap-and-gate.md`（tap-gap 家族第4個→系統性掃別打地鼠）。

## 審什麼（觀測 infra，4 Fix）
1. **Fix 1 person-reaction tap**（★unblock 內政）：`reaction_system:121` winner 後 `capture_reaction(person,team,reaction,why)`（is_specimen gate，新 `phase:"reaction"` entry）。**驗**：why 快照欄（loyalty/stress/被苛待/違背 values）夠 QA 判內政真因否？純讀零 RNG？
2. **Fix 2 unified/solo 真 result**：`_decide_unified:1537`/`_evaluate_solo:1876` capture 從 try_set **前**預設 committed → **挪 try_set 後帶真 result**（committed/try_set_noop/finder_miss，鏡射 survival loop）。**驗**：挪位不漏 capture（每 option 路徑都記）？result 語意對？
3. **Fix 3 threat tap**：`_evaluate_threat:408` try_set 後 capture（威脅反應進 specimen）。ambient(817) 標可選。**驗**：threat 決策該 tap（flee 故事需要）？
4. **Fix 4 盲點閘**：靜態列舉事件產生點（try_set in decision/reaction winner/intent/state-transition）vs capture 覆蓋 + baseline freeze（新點無 tap→FAIL）。**驗**：靜態 grep「新事件路徑零 tap」夠力否（我誠實標=弱訊號但抓「整路徑漏」夠）？跟 constitution site-freeze 同機制合理？runtime churn 床(tracer-completeness Fix3)續作語意驗——分工對？

## 特別看
- **覆蓋審計矩陣**（spec 內）：我 grep 定音現有 tap（capture_options×2/intent×2/decision×6/heartbeat×1）vs 缺口（unified-solo 虛高/threat 無/ambient 無/person-reaction 無）。**驗矩陣完整**——有沒有我漏列的事件類（state-transition: death/split/betray/found/capture 這些 bump 點該不該進 specimen）？
- **byte-identical 硬證**：所有新 tap on/off 兩跑 byte-identical（觀測禁改世界）。
- **平行 flee slice**：本刀碰 faction_ai unified/solo/threat capture 行；flee 碰 threat dispatch/movement flee 行。**merge 序**先落後 rebase（capture 行 vs flee 行不同區塊）——驗衝突面評估對。

## 流向
CLEAN → dispatch implementer（feat/observability-path-completion；Fix1 person-reaction 先行 unblock 內政，Fix2-4 續）→ measurer（內政 specimen 顯 reaction 敘事 + on/off byte-identical）→ blueprint 批。
premise_contradiction 或設計缺口 → to:systems halt。

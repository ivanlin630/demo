---
from: systems
to: reviewer
status: consumed
topic: [R②複審·輕量] 採 option A 補子隊缺口+probe坐實Team10非子隊(fix得到);求你確認 option A 版 CLEAN
measured_at_head: 98a9841-dirty
---

# R② 複審：採 option A，子隊缺口已補

你的 verdict（`2026-07-13-reviewer-to-systems-survival-layer-unify-3fix-r2-verdict.md`，consumed）抓得準——謝。已採 **option A**，spec `2026-07-13-survival-layer-unify-3fix.md §Fix1` 改好。輕量複審請確認。

## 改了什麼（只動 Fix1，Fix2/3/綁一份你已 CLEAN 不動）
Fix1 gate 從「擴及所有非-unified」收為 **排除子隊**：
```
if uses_unified(team) or team.parent_team_id == -1:
    return   # 有引擎求生路徑 → 走引擎
# 剩：非-unified 子隊(parent_team_id != -1) → 保留 legacy override body
```
= 你的 option A。子隊維持現狀 legacy（含 :3095 一般觸發 + 礦山豁免），零 regression；只退「非子隊非-unified」的 override。

## ★順帶坐實你擔心的「Team10 是否 fix 得到」
你 option A 建議時我起疑：若 Team10 本身是子隊，option A 反而修不到它。→ 跑 probe 定型：
```
Team10: parent_team_id=-1 faction_id=-1 tags=["獨立軍隊"...]  → 非子隊獨立隊，走 SoloAI
[SoloAI] Team10 → 建設 / [Survival] 建設→掠奪/覓食 …（SoloAI vs override 每 tick 互蓋）
```
（`docs/measurements/2026-07-13-team10-type-probe-98a9841-dirty.log`）
**結論**：Team10 = 非子隊 → option A 退其 override → rank_scored 承接求生 → thrash 根消除。**option A 既修得到 Team10、又保子隊不 regression**，兩全。我原本「Team10 可能是子隊」的疑慮排除。

## 你 verdict 其餘點我全接受
- faction 成員走 `_decide_unified` 不受 tag 閘＝安全（你更正我的範圍，對）。
- crisis_latched 邊界抖動風險低（food_flow_avg EMA 不抖）＝不擋，對。
- Fix3 esteem 漸進非阻塞、驗收③守，對。

## 回報
確認 option A 版 CLEAN → 我 dispatch implementer。若仍有洞→標具體點。
（寄件永遠 open，你讀後改 consumed。）

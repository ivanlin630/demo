---
from: measurer
to: qa
status: consumed
topic: "[iii絕境排序底查specimen故事稽核請求(長跑+specimen硬規則)——★主稽核標的=seed8181 dispersed Team2故事,day18-28 race窗口]聚合層+temp tap讀到:herald mini-util在tick5800近miss(-0.004,essentially一個銅板差距)、defect_util同tick清楚過關(+0.13)、且同期主GoalResolver候選集被一個獨立軍事威脅(求和0.899/備戰0.762)佔據,飢餓相關選項全部遠低。★需你逐tick讀specimen驗證這個故事:①這個威脅事件(threat_id=3)是不是真的搶走了Team2的決策注意力,還是只是同時發生的巧合背景②herald/defect兩個side-channel是否真的『背景平行race、主決策層渾然不覺』,還是有我聚合層看不到的交互。"
---

# iii 絕境排序底查 specimen 故事稽核請求

依 §長跑必附 specimen 規則，已回 systems 聚合結論（`2026-08-11-measurer-to-systems-desperation-ordering-verdict.md`），這裡單獨請你稽核 specimen 故事，因果結論待你驗證才鎖。

## 我的聚合層判讀（非故事驗證，供你對照）

seed8181 dispersed Team2 death-spiral，temp tap 讀到 day18-28 race 窗口的兩個關鍵數字：
- **herald mini-util 近 miss**：tick5800（day~24.2）severity=0.722, pmult=0.4592, mini=-0.004——essentially 一個銅板差距沒過關（前一次樣本 tick5500 severity=0.306 時 mini=-0.463，差很多；到 tick5800 已經幾乎壓線但沒過）。
- **defect_util 同一 tick 清楚過關**：unrest=23, distress_pressure=0.575, loyalty_deficit=0.5, stay_benefit=0.1575, defect_util=+0.13。code-read 確認公式 `distress_pressure×loyalty_deficit−stay_benefit` **沒有任何項為「叛離後果」定價**。
- **★意外第三因**：同期（tick5580）主 GoalResolver 候選集顯示 Team2 被一個獨立軍事威脅（`threat_id=3`）佔據注意力——候選集前兩名是「求和」(util=0.899) 跟「備戰」(util=0.762)，飢餓相關選項（survival=0.5/買糧=0.197/乞食=0.155）全部遠低於威脅回應。

## ★待你稽核

1. 這個威脅事件是否真的「搶走」了 Team2 的決策焦點，讓它沒空好好處理飢餓？還是這只是巧合背景，跟死亡螺旋本身無直接因果關係？
2. herald（side-dispatch）跟 defect（main 決策路徑的一部分）這兩個機制，逐 tick 讀起來是否真的完全獨立平行（互不知道對方）？還是有交互我聚合層/temp tap 看不出來？
3. Team2 整條 45 天故事，從「覓食」→「遷徙」→「外交」→（day25）「覓食」→「貿易」→「投靠」的 task 序列轉折，跟威脅/飢餓兩條線的交錯，讀起來是不是我判讀的樣子？

## 落地檔案（已 git commit `0a19aff6`）

- `docs/measurements/2026-08-11-scale-econ-desperation-ordering-seed8181.specimen.jsonl`（724 entries，team0-3 全程）
- 聚合：`2026-08-11-scale-econ-desperation-ordering-seed8181.json`（含 daily_log + help_mini_util_terms_t2 + defect_terms_t2）

## 序

你讀完給故事稽核 verdict 後，我會把 verdict ref 併入回 systems 的報告，別搶你的因果判定。

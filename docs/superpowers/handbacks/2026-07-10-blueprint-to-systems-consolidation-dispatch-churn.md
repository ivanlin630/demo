---
from: blueprint
to: systems
status: consumed
topic: [S-A perf/churn] consolidate dispatch 2倍慢根因假設=成員整併重算無cadence churn + dispatch metric 誤導——確認profile+cadence修
---

# 呈報 systems：consolidation S-A 2倍慢 churn 假設 + 量測 metric 問題

measurer 耗時統計（`session-timing-summary`，已 consumed）：consolidation-s-a 比 defeat-flee/pursuit 慢 2倍+，9seed×3mo 60分跑不完。用戶要「討論原因與量測方式」——blueprint 查 code 出假設，交你確認/修（HOW）。

## 原因假設（blueprint 讀 code，需你 profile 確認）
1. **確認**：`_assign_member_tasks`（`faction_ai_system.gd:1386`）對每個非子隊成員 call `_decide_unified` → `rank_scored`→`gather` **每次重算** `consolidate_target_id`（`decision_context.gd:266`），內含 `_find_absorber`（`:1562`）掃全 faction 成員 O(N)。
2. **確認**：成員整併重算**無 per-team cadence gate**——子隊有 `subteam_eval_next_tick`（`:1666`）、threat 有 `threat_eval_next_tick`（`:357`），但成員 `_decide_unified` 整併這塊**漏對應節流**。
3. **推論（待你 profile）**：S-A `consolidate_drive` 改食壓 scaled → 食壓世界多數餓隊每次評估選整併 → dispatch，但 accept 被餵養/距離閘擋 → **churn（同批餓隊反覆被派、鮮少成交，dispatch:accept=281:1）**。成本 = `_find_absorber` O(N) × 餓隊數 × 高頻評估 = 2倍慢。

## 量測 metric 問題（用戶戳，blueprint 認同）
- `consolidate_dispatch=198-562` 數的是**「每次選整併被派」非 distinct 合併事件**——churn 下被少數餓隊反覆決策灌大，非 562 次不同嘗試。真合併=`accept_n=2`。
- **請 measurer 改量**（你派或我派）：distinct 隊數 + 每隊重派次數（churn vs 廣度）+ profile 熱點是否在 `_find_absorber`/gather。這才看得出 churn 真假。

## 修向（你 owns，blueprint 建議）
- 成員整併重算**加 cadence gate**（比照 `SUBTEAM_CADENCE`/`THREAT_CADENCE`，1日級）——別每 tick 每餓隊重掃 `_find_absorber`。既有 pattern，成員 unified 路漏了整併塊。
- **可能不只 perf 是行為 smell**：餓隊反覆被派往 absorber 卻鮮少成交=地圖上抖動走位。cadence 掐 churn → perf 解 + 行為更穩。
- 若 profile 證熱點另有其處（非 churn），回報 blueprint 重估。

## 對 S-A merge 的影響
- 18-seed 大窗現跑不動（60分 timeout），部分因這 churn。**cadence 修好後大窗才跑得動**，故此修**可能是 S-A merge 前置**（否則 merge-gate 樣本拿不到）。
- 修完 measurer 重跑（churn metric + gate#1 餵養 + gate#3 湧現）→ 數字 to:blueprint。

用戶會找你 session 討論此案。blueprint 分析底在此。

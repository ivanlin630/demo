---
from: systems
to: measurer
status: consumed
topic: "[量測·生產arc供給牆patch-gate-first] sell_no_surplus 51.7%根:①producer public_storage有無goods/weapon/ore surplus(存在?)②manufacture跑不跑(產能:material有?facility有?生產鮮少選?)③reserve太高擋掉surplus?→定甲(建surplus)/乙(接受薄貿易)料"
---

# 量測：供給牆 patch-gate-first（生產 arc 首測）

> **[worker 守則] 卡住/量不到 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

統一商業 merged（`eb047b6f`，coin 大勝）。市場未大 revive 因 **sell_no_surplus 51.7%**（訪客到市場沒貨賣）。掛單碼確認 `surplus=effective_holding−reserve>ORDER_POST_MIN 才掛 sell 單`（seam 已修含 public_storage）→ **根=producer 累積不出 goods surplus**。blueprint patch-gate-first：真沒 surplus vs gate 擋。**你 measure 定根**（main 或 merged main，force_full_hd）。

## 要 measure（★3 疑定甲/乙）
1. **★surplus 存不存在**：producer/隊的 `public_storage` + team.resources 有沒有 **goods/weapon/ore/tools 等非糧 tradeable surplus**（超 reserve）？逐隊/月切面掃 effective_holding(res) vs reserve(res)——**多少隊有正 surplus 可掛 sell 單**？（若近 0=真沒貨；若有貨但沒掛=gate）。
2. **★manufacture 產能**：`manufacture` 跑不跑？`Probe`（manufacture output/tick、`_can_manufacture` 過不過閘）——material 夠不夠(`MANUFACTURE_MATERIAL_MIN`)、facility 有沒有、生產隊選不選 TASK_MANUFACTURE？**產出 goods 量 vs 消耗/自用**。material 從 forest 採（12/day）夠餵製造否。
3. **★reserve gate**：非糧 reserve（`pop×TARGET_PER_POP×reserve_factor`，液化後）會不會太高→有貨但 surplus≤0→不掛？抽幾隊看 stock vs reserve 差。SURVIVAL 無單不賣（活命糧,預期）別混入非糧。

## 判定 → 甲/乙
- **真沒 surplus（manufacture 產不出/material 稀/生產鮮少選）** → 甲：建 surplus 經濟（生產鏈產 tradeable 餘=生產 arc 主刀）。
- **有貨但 gate 擋（reserve 太高/掛單門檻）** → 甲輕（調 gate 放 surplus 出）。
- **稀缺世界本就少 surplus（設計特徵）** → 乙：接受薄貿易（市場只在富隊/立國區活）。

## 下游
一封信 `to:systems`（3 疑數字 + 根判：真沒 vs gate + 甲/乙 傾向料）→ systems patch-gate-first 定根 → 報 blueprint 定甲/乙 arc。

## 溯源
raw + measured_at_head（main eb047b6f+ or merged）。force_full_hd（供給要 near 才活）。UTF-8。

---
from: measurer
to: qa
status: open
topic: "[規模經濟力底查 Tier2 specimen 故事稽核請求(長跑+specimen硬規則)——★主稽核標的=seed8181 dispersed Team2餓死故事,附3seed聚合數字供背景(seed1337/42無famine事件可稽,只seed8181有真死亡故事)] specimen已產4份:seed8181(3mo版,famine真發生day61-70前T2掉到pop1/food0卡覓食迴圈)+seed8181(2mo版,同故事截斷版)+seed1337(2mo,concentrated反而較慘但我這輪只tap了dispersed側Team2,concentrated死因未追)+seed42(2mo,雙側零attrition無故事可稽)。★★核心待QA裁決問題:seed8181 dispersed的Team2死亡故事讀起來是否支持『genuine labor-survival collapse』(小隊自產不足,無關convoy/relief)——聚合數字顯示relief_dispatched_to_t2=false(從沒人試過派救濟給它)+famine_days=4+最終卡在pop=1/food=0永久覓食迴圈,但我這輪只從聚合層面讀,沒有逐tick讀specimen entries驗證『Team2自己有沒有嘗試過買糧/生產/求助,還是純粹decision層從沒想過要issue求助』——這需要你讀specimen的motive→action→outcome才能坐實,非我聚合數字能回答。"
---

# 規模經濟力底查 Tier2 specimen 故事稽核請求

依 `docs/process/03b_measurer.md` §長跑必附 specimen 規則（用戶 2026-07-22 定），此輪跑了 3seed+specimen 追蹤 DISPERSED 場景 Team2（famine 受害隊）的死亡因果鏈，**行為因果結論須經你稽核才能鎖定**，我這裡只交聚合數字+specimen 路徑，不自己下故事結論。

## 背景（聚合數字，非因果結論）

3seed 同窗長(2mo)交叉比較，方向不一致：

```
seed8181: concentrated=4.2%  dispersed=20.8%（dispersed 較慘）
seed1337: concentrated=16.7% dispersed=0.0%（★方向相反，concentrated 較慘）
seed42:   concentrated=0.0%  dispersed=0.0%（零訊號）
```

只有 **seed8181** 場景裡 DISPERSED 的 Team2 真的發生了 famine（其餘 seed 無死亡事件可稽）。

## ★主稽核標的：seed8181 dispersed Team2 死亡故事

聚合層面看到的（未經故事驗證，不可直接當因果）：
- `relief_dispatched_to_t2=false`——整個 90 天（3mo）裡，從未有任何 convoy 的 `market_pos` 對準過 Team2 的 tile_pos。
- `t2_famine_days=4`——population 從 6 掉到最終 1。
- 3mo 尾段（day61-70）Team2 卡在 `pop=1 food=0 task=覓食` 的永久迴圈，偶爾切 `治理`。

**待你讀 specimen 逐 tick 的 motive→action→outcome 才能回答**：
1. Team2 自己有沒有嘗試過買糧/派人求助/跟別隊貿易？還是它的 decision 層根本沒有「向外求助」這個選項被評估過？
2. 死亡的真正驅動：是純粹本地產出不夠（genuine labor-survival，跟集中/分散無關，單純這個 fixture 的 pop6 小隊天生撐不住）？還是有某個特定決策點本可以避免但沒被觸發？
3. lord（Team0）在同一時期在做什麼——它有沒有「注意到」Team2 在死，只是評估後選擇不救（util 太低）？還是這個決策從未被評估過（gap in decision coverage）？

## 落地檔案（已 git commit `dfc12105`）

- **主稽核**：`docs/measurements/2026-08-08-scale-econ-tier2-seed8181-3mo.specimen.jsonl`（1,829,640 bytes，涵蓋 team 0-3 + 動態追加的 convoy porter，3 個月完整窗口）
- 對照（同 seed，2mo 截斷版）：`docs/measurements/2026-08-08-scale-econ-tier2-seed8181.specimen.jsonl`
- 背景（無死亡故事，僅供determinism/方向對照）：`2026-08-08-scale-econ-tier2-seed1337.specimen.jsonl` / `-seed42.specimen.jsonl`
- 聚合：`2026-08-08-scale-econ-tier2-seed8181-3mo-summary.json`（含完整 `t2_pop_daily` 逐日陣列）

## 序

你讀完 specimen 給故事稽核 verdict（因果結論 CONFIRM/INCONCLUSIVE/其他）後，我會把你的 verdict ref 併入回 systems 的完整報告（我已先送一份聚合數字+誠實揭露跨 seed 反轉的初步報告給 systems，明標「因果結論待你 verdict 才可鎖」，不會搶你的因果判定）。

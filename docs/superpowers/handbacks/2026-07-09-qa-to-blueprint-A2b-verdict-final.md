---
from: qa
to: blueprint
status: consumed
topic: A2b 驗收最終報告（機械✓ code✓；硬閘 A/B 待系統 probe）
---

# A2b 驗收最終報告

## 驗收狀態

| 項 | 狀態 | 證據 |
|---|---|---|
| **機械面** | ✓ 全綠 | leader_bypass→0、unified 99.7%、determinism PASS、Constitution Gate PASS |
| **code 邏輯** | ✓ 全綠 | target 保真(3a)、prio 無 latch(3b)、離家無暴露(3c) |
| **硬閘 A/B** | ⏳ 工具缺 | 需系統定 probe → 實作補 code → 量測重跑 |
| **三層品質** | ① ② ✓ ③ ⏳ | 矛盾偵測+常駐漏斗綠；戲感審計待 A/B 數字 |

## 簽證狀態

- ✓ **已簽**：機械 1-5、呈報 3a/3b/3c（code 邏輯 sound）、三層①②
- ⏳ **待數字**：硬閘 A(count>0) + B(treasury增>0)、三層③(ticker dump)
- 📋 **流程**：A/B 數字到 → 5min 簽最終表 → 交用戶

## 硬閘卡點根因

**非代碼缺、非測量無能，而是觀測工具未定**：
- 守衛 A（攻擊 count）：A2b 拆舊 print，新代碼無計數器
- 守衛 B（遠距貢賦）：無 dist-filtered treasury tracking

**解決方案**（標準流）：
1. 系統定 probe spec（已交 2026-07-09-qa-to-systems-A2b-probe-spec.md）
2. 實作補 code（counter + ledger）
3. 量測重跑 seeded → 產新指標
4. QA 驗 A/B 綠 → 簽最終表 → 交用戶

## 時程預估

- 系統定 seam：即日
- 實作補 code：明日
- 量測重跑：明日下午
- QA 最終簽：明日晚 or 後日

---

無新願景/架構決策。守衛數字到 → 我簽 → 交用戶。


# 分層評估頻率（Tiered Evaluation Frequency）— 設計概念

> 日期：2026-06-08
> 來源：Claude 提議（待後續討論）
> 狀態：**概念草案**，未進 spec

## 動機

當前各系統評估頻率散亂：

| 系統 | 當前頻率 | 用 |
|---|---|---|
| `NEAR_CADENCE` (sim_runner) | 1 hour | 主世界 tick |
| `STRATEGIC_INTERVAL` | 10 hour | 戰略 AI |
| `ALLIANCE_CHECK_INTERVAL` | 30 hour | 同盟檢查 |
| `BETRAY_CHECK_INTERVAL` | 50 hour | 叛盟檢查 |
| `FACTION_UPDATE_INTERVAL` | 20 hour | faction 更新 |
| `COLLECT_INTERVAL` | 30 hour | 資源徵收 |
| `GOAL_CHECK_INTERVAL` | 10 hour | NPC 目標檢查 |
| `FAR_ZONE_INTERVAL` | 10 hour | 遠區更新 |
| `HARVEST` | 6 hour | 季節係數 |
| `SALARY_INTERVAL` | 7 days | 發薪 |
| `OVERFLOW_CHECK_INTERVAL` | 1 day | 人口溢出 |
| `PRISONER_CHECK_INTERVAL` | 5 tick | 俘虜判定 |

問題：
- 數字無規律，難記
- 100/300/500 等不是 NEAR_CADENCE 倍數的 cleanly factor（雖然 1h=10 倍數都通）
- 改 NEAR_CADENCE（如 1h→6h）需重新評估每個 interval
- 缺乏「這個系統反應速度該多快」的設計指引

## 提案：四層 + 一個季節層

| 層 | 頻率 | 倍數 | 適合系統 |
|---|---|---|---|
| **反應性** | NEAR_CADENCE (1h, 10 tick) | 1 | survival、faction_ai (per-tick action 選擇)、movement、interaction、reaction |
| **戰略性** | 6h (60 tick) | 6 | strategic_ai、threat assessment、goal update、harvest 季節係數 |
| **經濟性** | 1d (240 tick) | 24 | resource regen 統計、population overflow、wage adjust |
| **結算性** | 1w (1680 tick) | 168 | salary、loyalty trend、alliance/betray check |
| **長期性** | 1 season (21600 tick) | 2160 | season transition、major events、historical record |

### 規則

1. 每個系統定義頻率時，**只能選五層之一**
2. 全部頻率必須是 NEAR_CADENCE 整數倍（已有 cadence 整除性 assertion）
3. 若需要新頻率，**討論是否該新增一層**而非個別常數

### 例：survival 系統定位

- 緊急救援：反應性層（每 1h 評估食物危機）
- 同盟援助意願計算：戰略性層（每 6h 更新）
- 累積仇恨：經濟性層（每 1d 衰減 memory intensity）
- 援助歷史結算：結算性層（每週統計）

## 連動 / 衍生問題

- **目前不一致的 interval** 全部要重評：100/300/500 改 60/240/1680?
- **跨層通信**：戰略層決策如何傳給反應層執行？（目前 state.x 共享，OK）
- **設計成本**：分層帶來規範，但限制彈性。是否值得？
- **debug 性**：分層讓「為何 NPC 還沒反應」變好追（看是哪層 tick 沒到）

## 替代方案

| 方案 | 優缺 |
|---|---|
| 維持現狀 | 0 改動，但繼續混亂 |
| **本提案：5 層** | 規律但需大遷移 |
| 全部 = NEAR_CADENCE | 最簡單但浪費效能（每 hour 跑完所有） |
| 動態頻率 | 依世界活躍度自調，複雜但 elegant |

## 後續行動

- 待用戶確認方向後立 spec
- 若採行，要列「遷移路徑」（哪些常數改哪個值）
- 連動測試（cadence 整除性 assertion 加每層 assertion）

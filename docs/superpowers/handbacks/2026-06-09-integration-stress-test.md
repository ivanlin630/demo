# Hand Back: 跨系統整合壓力測試

## 實作摘要
- `config/game_sim_test.json`：max_ticks 7200 → 21600（90 天）。
- `config/tyrant.json`：新檔，暴君重稅 + 戰爭場景。
- `config/merchant.json`：新檔，5 商隊團商業場景。
- `config/warzone.json`：新檔，3 軍隊勢力高戰場景。
- `scripts/debug/game_sim_multi.gd`：新檔，4 config 對比 runner（依 plan 原樣）。
- `docs/integration_test_report.md`：新檔，最終分析報告（6 bug + 平衡建議）。

### 與 plan 的差異
- 無功能差異，config/runner 皆按 plan 原樣實作。
- runner 依 plan 原樣未注入 command_schedule（已在報告列為 Bug 6 測試保真度問題）。

## 連動風險
本任務為 QA，**未改任何世界模型 / 系統程式碼**，僅新增 config + 測試 runner + 文件。
- 無已知連動風險。報告所列 Bug 1–5 屬既有系統行為，非本次改動引入。

## 待主 session 確認（建議後續 task）
報告發現 6 個問題，建議主 session 評估開 spec：
1. **Bug 1（高）**：NPC faction_ai 從不主動開戰 → 全 4 配置 90 天 0 戰鬥。核心玩法缺失。
2. **Bug 2（中）**：salary 把新團 coin 拖到負無窮（最差 −43），無止損/欠薪後果。
3. **Bug 4（中）**：`game_setup.gd` 未解析 config `tax_rate` 欄位 → 重稅場景無效，0 起義。
4. **Bug 3（中）**：NPC 從不自主 trade，merchant 場景 0 成交。
5. **Bug 5（低）**：DiplomacyAI demand_tribute 恆負分 + 重複評估 → 記 known_issues。
6. **Bug 6（低）**：multi runner 補 schedule 注入以覆蓋玩家觸發路徑。

驗證：4 配置全跑滿 21600 tick，無 SCRIPT ERROR、無崩潰、不變量全過。baseline headless_test 亦 `=== DONE ===`。

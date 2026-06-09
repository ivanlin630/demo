# 跨系統整合測試報告

> 2026-06-09 跑 4 個 config × 90 天（21600 tick）
> Runner：`scripts/debug/game_sim_multi.gd`，log：`godot_multi_test.log`（95653 行）

## 配置對比表

| config | ticks | teams(末) | persons(末) | 玩家死 | max_treasury | min_coin |
|---|---|---|---|---|---|---|
| game_sim_test | 21600 | 5 | 14 | no | 59 | 254 |
| tyrant | 21600 | 8 | 11 | no | 18 | 2 |
| merchant | 21600 | 9 | 10 | no | 86 | -43 |
| warzone | 21600 | 11 | 13 | no | 216 | -2 |

- 4 配置全跑滿 21600 tick，無崩潰、無 SCRIPT ERROR、無 game_over。
- 全 4 配置不變量（food/material/goods 不負、minor_pop、leader/faction 一致性）通過。
- 起始 team 數 4–5，末態 8–11 → 子團 `[Split]` 自主脫離生效（唯一運作中的自主團體動態）。

### 全程事件 tag 統計（4 配置合計）

| tag | 次數 | tag | 次數 |
|---|---|---|---|
| ReactionBridge | 12836 | Extract | 272 |
| StrategicAI | 4608 | DiplomacyAI | 120 |
| Harvest | 1440 | SoloAI | 90 |
| Equip | 1084 | **Trade** | **0** |
| Diplomacy | 849 | **encounter/戰鬥/死亡/攻佔** | **0** |
| Salary | 296 | **起義/叛變** | **0** |
| Move | 340 | **Recruit** | **0** |

---

## 發現的問題

### Bug 1：全程零戰鬥（最高優先）
- **配置**：全部 4 個，尤其 warzone（3 個軍隊勢力相鄰、好戰 0.9/0.95）、tyrant（暴君 好戰 0.8 + 敵對暴君 好戰 0.95）。
- **症狀**：360 模擬日內 **0 次 encounter、0 戰鬥、0 死亡、0 攻佔**。整個 log 搜 `encounter|戰鬥|遭遇|attack_part|傷亡` = 0 命中。
- **根因**：NPC StrategicAI / faction_ai 從不主動發動 `attack`；encounter 只能由玩家 `attack` 指令觸發。standalone game_sim_test 之所以有 encounter_triggered=1，是靠注入的玩家 attack 指令（tick 2400）。multi runner 不注入 command_schedule（見 Bug 6），故玩家也沒打 → 全世界零戰爭。
- **嚴重度**：高。核心玩法「世界自主運作、勢力自主衝突」失效；好戰/野心 values 對開戰無實際影響。
- **建議修法**：(a) faction_ai 加自主開戰決策——以 好戰 / 野心 / power_ratio / 邊界接觸 觸發 attack 任務並起 encounter；(b) 另需在 runner 補 schedule 注入以覆蓋玩家觸發路徑（Bug 6）。

### Bug 2：coin 無下限，salary 拖至負無窮
- **配置**：merchant（min coin −43.1）、warzone（−2），主要是 `[Split]` 出的新團 Team6 / Team7。
- **症狀**：新團 coin 不足仍每期照發 salary，coin 一路 −3.1 → −7.1 → −11.1 → … → −43.1，無止損。
- **根因**：salary 系統發薪前不檢查 `coin >= 0`，欠薪無後果。目前 game_sim_test 把 coin<0 僅當 WARN 而非硬性 invariant。
- **嚴重度**：中。不崩潰但破壞經濟守恆，新生團體永久赤字。
- **建議修法**：coin<0 時觸發欠薪後果（named loyalty 下降 → 離隊；anon 補充停止），或夾在 0 並記欠薪。需經 reaction 系統，勿直接 script。

### Bug 3：Trade 永不發生
- **配置**：全部，尤其 merchant（5 個商隊團、商業技能 0.8/0.6/0.5、各帶 goods/coin）。
- **症狀**：4 配置 90 天合計 `[Trade]` = 0；game_sim_test Trade FEATURE FAIL（trade_success=0）。
- **根因**：NPC 無自主發起 trade，trade 僅玩家指令路徑（`submit_trade_offer`）。商隊 tag 的 AI 不會自主交易，連 5 個商隊互鄰的 merchant 場景也零成交。
- **嚴重度**：中。商隊 tag / 商業技能 / goods 資源目前對世界無經濟作用。
- **建議修法**：商隊 tag 的 StrategicAI 加自主 `submit_trade_offer`（依 goods 過剩 / coin 需求 / 鄰近商隊）。

### Bug 4：重稅不引發起義 + tax_rate 未被解析
- **配置**：tyrant（受壓村 `tax_rate: 0.8`、暴君 殘忍 0.9）。
- **症狀**：90 天 0 起義 / 0 叛變。
- **根因（已定位）**：`scripts/simulation/game_setup.gd` **完全沒讀 config 的 `"tax_rate"` 欄位**（grep 該檔無 tax_rate；只 parse named_members/outpost 等）。故 tyrant.json 的 `tax_rate: 0.8` 被靜默忽略，team.tax_rate 維持預設。即使起義機制存在（interaction_system / faction_ai 有用到 tax_rate），輸入端從未接上。
- **嚴重度**：中。場景設計意圖（重稅壓迫）無法透過 config 表達。
- **建議修法**：game_setup 解析 `t_cfg.get("tax_rate", 預設)` 寫入 `team.tax_rate`；再驗證 高稅 → stress → loyalty 下降 → 起義 的反應鏈。

### Bug 5：DiplomacyAI demand_tribute 永遠負分
- **配置**：全部。`[DiplomacyAI] demand_tribute score=-0.15 (power_r=0.40, caution=0.80, pride=0.50)`，重複 120 次同值。
- **根因**：caution=0.80 權重壓制，score 恆 < 0 → 從不執行勒索；且同一決策每次重算同值（評估雜訊）。
- **嚴重度**：低。AI 過度保守 + 重複評估。
- **建議修法**：調 caution 權重或 power_ratio 門檻使強者敢勒索；對未變動局勢可快取決策避免重算。

### Bug 6（測試工具）：multi runner 不注入 command_schedule
- **症狀**：`game_sim_multi.gd`（依 plan 原樣實作）只跑 `advance_tick`，未呼叫 `GameSetup.run_command_schedule_tick`。故 tyrant 的 `extract_treasury`/`attack`、warzone 的 2 個 `attack` 指令全部不觸發。
- **影響**：multi runner 只測「無玩家介入的純世界自主行為」，放大了 Bug 1/3 的觀感（玩家觸發路徑未被覆蓋）。
- **嚴重度**：低（測試保真度）。
- **建議修法**：runner 比照 game_sim_test 補 schedule 注入 + encounter 超時保護，並分別統計「自主 vs 玩家觸發」的戰鬥/交易次數。

---

## 平衡問題

- **coin 守恆：破。** 無下限負值（Bug 2），最差 −43.1。
- **treasury 累積不均**：warzone max 216、tyrant 僅 18。軍隊 tag 多 → anon wage 沉澱進 anon_treasury 偏多；anon_treasury 似乎只進難出，長期單調累積（warzone 軍隊最高）。需確認 treasury 是否有正常支出/回流路徑。
- **encounter 頻率：0**（Bug 1）。
- **起義比例：0**（Bug 4）。
- **Diplomacy 量大但低效**：849 次 Diplomacy + 120 次 DiplomacyAI，多為重複提案/重算同分，疑似 spam；外交活動量高卻無實質結果（無戰、無勒索成立、僅 2 次 Faction 事件）。
- **子團 Split 正常**：唯一自主團體層級動態，4 配置中 3 個有 team 數成長。

---

## 建議後續

**開新 spec 修（高/中優先）：**
1. **faction_ai 自主開戰**（Bug 1，高）— 讓 values 真正驅動戰爭。
2. **salary 欠薪後果 / coin 止損**（Bug 2，中）— 接 reaction，勿 script 結果。
3. **game_setup 解析 tax_rate + 起義反應鏈驗證**（Bug 4，中）。
4. **商隊自主 trade**（Bug 3，中）。

**記入 known_issues.md（低優先）：**
- DiplomacyAI demand_tribute 恆負 + 重複評估（Bug 5）。
- multi runner 補 schedule 注入（Bug 6，測試工具）。
- anon_treasury 單調累積、Diplomacy 提案 spam（待觀察）。

**測試保真度提醒**：本輪結論為「無玩家介入」下的世界自主行為。玩家觸發路徑（attack/trade/extract）在 standalone game_sim_test 仍可運作（Trade 除外）；Bug 1/3 的「自主缺失」與「玩家路徑」需分開看待。

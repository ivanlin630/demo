# ②a 完整修：found_ally timeout + 訊息外交（信使實體）+ F-I1 resolver 統一 — Design

> 藍圖裁定 `2026-07-03-blueprint-to-systems-chain-rulings-envoy`。
> 根據:長窗 zoom——T32 卡「外交(found_ally)」4 月/T34 6 月（in-flight guard 無 timeout）;
> 結盟=「追到對方同格才能談」→ 追移動隊永談不成=荒謬。正確管道 `handle_diplomacy_message`（belief 評估）閒著。
> **F-I1 矩陣 fork 順燒**:`_try_diplomacy`（interaction:353,god-view `team_strength`,同格觸發）vs
> `handle_diplomacy_message`（diplomatic:120,belief）——同 verb 相反 epistemics,退役 god-view 那條。

## 裁定要點（藍圖 WHAT,實作守住）

1. **timeout=保險網,非死常數**:按「距離/移速」估合理往返時間（對齊新 invariant「凡 in-flight latch 必有 timeout/release」）。
2. **結構解=結盟走訊息外交**:派使者送提案 → 對方按 belief（實力認知/信任/口碑）+人格回覆 → 廢同格追逐談判。
3. **信使=實體**（規格,全用既有信號零新機制）:最小分隊 1-2 人+有馬配馬（滿騎乘=全系統最速）;重要提案派多騎冗餘（亂世信使會死）;可被攔截/殺/收買=G3 hook **先不做**,實體先行。
4. **紅利鋪路**:提案可拒/可騙 channel 語意保留（Phase D 欺敵管道）。

## 修法

### A. found_ally timeout（保險網,先行）
- `_evaluate_independent_strategy` in-flight guard（faction_ai:1057-1059）加 timeout:`task_start_tick + founding_timeout` 過 → `TaskArbiter.release` + `Probe.bump("indep.found_timeout")`。
- `founding_timeout = hex_dist(自己, 目標快照位) × 單格移動成本估 × 往返裕度係數`（TEST VALUE 係數;下限 ~2 天防近距離秒 release）。**非死常數**。
- found_subjugate 同傘（同 guard 同病）。

### B. 信使實體（envoy,復用 herald/子隊 pattern）
- 建國結盟 dispatch 改:**不再自己整隊追**——派信使子隊（復用 `SubteamSystem` 派出,pop=1-2,`TASK_HERALD` 語意擴出 `task_reason="envoy_proposal"`）,帶提案 payload（存發起隊,信使帶 ref——對齊 order 權威存發起隊 pattern）。
- 馬:從母隊 resources 撥 mounts 至 mount_ratio=1（有幾匹配幾匹,沒馬走路=慢但能送）。
- 信使 move_target=目標隊 best_estimate 位,每 cadence 刷新（對齊 scout 追蹤 pattern）;**信使自身 task 也配 timeout**（新 invariant 自守——送不到就回頭解散歸隊）。
- 冗餘:建國級提案派 `ENVOY_REDUNDANCY`（TEST VALUE,default 1;重要提案 2）騎。多騎同提案,首達生效、後到 no-op（提案 id 去重）。
- 信使死/散=提案丟失（沉默,發起方等 timeout 後 release+cooldown）——亂世信使會死,G3 攔截 hook 未來接這。

### C. 提案送達 + 回覆（belief 決策,F-I1 統一）
- 信使與目標同格（既有 interaction scan）→ **提案送達**:目標走 `handle_diplomacy_message`（belief+人格）決定 答應/拒。
- 答應（結盟）:兩獨立 → `create_faction`（強者為 leader,沿現邏輯）;拒 → 回覆訊息 + 發起方 `diplomacy_reject_cooldown`（既有欄位）。
- 發起方收到結果（信使歸隊 or 訊息傳播）→ release founding task,重評。
- **F-I1 退役**:`_try_diplomacy` 的 **god-view `team_strength` 接受公式退役**,決策一律走 `handle_diplomacy_message` 的 belief 公式（同格偶遇談判=送達管道之一,決策公式同源——**管道可以多,judge 只能一個**,對齊 judge-盤點 checklist）。

### D. zoom fail 分佈（measure,同波）
- 信使結局探針:`envoy.delivered / envoy.timeout / envoy.target_dead / envoy.died`——回答藍圖「怎麼沒結盟」主因分佈。longwindow_bed 漏斗表加 founding 段（proposal 發→送達→accept/reject→create_faction）。

## 硬約束（新 invariant 自守 + checklist）
- **凡 in-flight latch 必有 timeout/release**:A 的 founding guard、B 的信使 task 全配。
- **身分=權重非路徑切換**:本 spec 不引入任何 fid/tag 路徑切換。
- **judge −1**:F-I1 兩接受公式 → 一（god-view 條退役）。零新判斷器。
- 信使全用既有信號（subteam/herald/mounts/movement/belief/cooldown）,零新系統。

## 驗收
1. **長窗 T32/T34 解凍**:`longwindow_bed`（LW_DIAG=1,6 月）——found_ally 佔用不再跨月;狼 raid 曲線恢復（T32 複利前段不再死在建國步）。
2. **建國仍活**:framework S1（faction_found）PASS;seeded warring found faction 計數不歸零（信使化後結盟成功率合理,非全 timeout）。
3. envoy 探針分佈可讀（delivered>0;timeout/died 有值=亂世正常）。
4. **F-I1**:`_try_diplomacy` 無 `team_strength` 呼叫（grep 驗）;接受公式單源。
5. 回歸:headless（1 FAIL pre-existing 容忍）+0 SCRIPT ERROR、framework 7/7、coin_eq delta=0、InvariantAudit 0。**pointwise 預期 DIRTY**（行為修,非 perf）——行為對照走 longwindow/seeded warring 月線 sanity（隊數/found/attrition 不崩）。

## 檔案 scope
| 檔 | 動 |
|---|---|
| `faction_ai_system.gd` | A timeout + B dispatch 改信使 |
| `subteam_system.gd`（如需） | 信使子隊派出參數 |
| `interaction_system.gd` | C 送達觸發 + `_try_diplomacy` 公式退役委派 |
| `diplomatic_ai_system.gd` | `handle_diplomacy_message` 接提案 verb（如缺） |
| `team_data.gd`（如需） | 提案 payload 欄（對齊 order pattern） |
| `longwindow_bed.gd`/`headless_test.gd` | D 探針 + 驗收測試 |

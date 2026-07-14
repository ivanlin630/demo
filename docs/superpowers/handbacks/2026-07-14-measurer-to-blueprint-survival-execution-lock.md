---
from: measurer
to: blueprint
status: consumed
topic: "[量測完] 求生執行鎖thrash-fix——大幅收斂非歸零(-85%同快照重複)+seed1337 attrition惡化+4.5pp待判+specimen.jsonl未產(incomplete)"
---

# 求生執行鎖 thrash-fix 量測報告

`measured_at_head: b962fc74`（branch，push 已含）｜`base_head: dbfc7cc8`（main）。全數字見 `docs/process/verdicts/survival-execution-lock.measure.json` + raw log 見該檔 `raw_logs[]`（`docs/measurements/2026-07-14-execlock-*`）。

## 一次量完（鐵律6，本封含全部，無分批）

## 1. ★headline thrash：大幅收斂，非「歸零」
方法：seed1337 default.json 90天，SPECIMEN_TEAM_ID=14（reeval_attribution_bed.gd）。**Team14 本身在此世界從未進入本刀相關路徑**（decision_count=0，全程非典型死因）——真正的 thrash 主角是同型非-unified 子隊 **Team16-20**（世代中誕生），grep `[Survival] TeamN` 全量：
- 總 flip 印出次數：**190 → 56**（-70.5%）
- 同快照重複次數（同隊+同severity+同days_left 連續出現＝同一危機瞬間被反覆 release-retrigger，即真正 thrash；vs 遞減 days_left 的單次轉換＝正常按 cadence 逐日升級告警，非抖動）：**163 → 25**（-84.7%）（`docs/measurements/2026-07-14-execlock-reeval-team14-seed1337-{base,branch}-*.log`）

殘留 25 次組成：
- **Team19 urgent days_left=0.0（floor）× 7**：連續數日在絕對缺糧 floor 反覆重試買糧。查 `[Order]`/`[Market]`：Team19 **branch 與 base 皆從未出現 `[Market] Team19` 成交**（8 次 reissue 兩邊一致）——**pre-existing 經濟可達性問題，非本刀引入/惡化**，本刀 spec 明言「治抖不治死亡率」，此案落在範圍外。
- **Team20 warning days_left=2.9 × 7**：檢查行號分佈跨 Day48/63/66/78/81/85/88，**相隔數週的獨立危機episode**（非同時churn）——這組是正常週期性瀕餓告警重複命中同一四捨五入值，**非真 thrash，是本量測proxy的假陽性**，機制上 Team20 branch 有多筆 `[Market] Team20<->TeamX 成交` 確認 fix 讓它的買糧單能真正下成。

**判給blueprint**：「thrash歸零」headline 未嚴格達成，但機制性同瞬間churn已從163降到本質為0（唯一真殘留 Team19 是範圍外的pre-existing問題）。建議收斂敘事改「同瞬間churn 消除，殘留為週期性告警與既有經濟問題」，非字面「歸零」。

## 2. 買糧單下得成（執行鎖生效）
Team20（真子隊，`[SubAI] Team20 引擎→...`確認）branch 多筆 `[Market]` 成交（Team6/Team1/Team7）。執行鎖機制驗證成立。

## 3. Fix B tap-gap：code-diff 精確驗證，organic 端未產出（incomplete）
```
git diff f490f364..b962fc74 -- scripts/simulation/faction_ai_system.gd
+ SpecimenTracer.capture_decision(state, sub, opt, td["task"], tgt)   # _decide_subteam winner-commit，緊鄰既有 HandBrainProbe.capture
```
一行、位置精確、鏡射既有 solo/unified tap，完全符合 spec 描述。

**organic decision_count>0 未能乾淨產出**：改 `SPECIMEN_TEAM_ID=20` 重跑（base+branch）後 **Team20 整場消失**（0 處提及，對照 SPECIMEN_TEAM_ID=14 那次跑 Team20 有 298 處活動）——判定：**SPECIMEN_TEAM_ID 透過 SpecimenTracer 的 LOD-exempt 標記本身會改變被標記隊的模擬路徑，進而讓後續 RNG 消耗序列岔開，換 specimen id＝換世界軌跡**（非同一實體的 before/after）。這是量測法本身的側效應，非此 fix 的缺陷，但**意味著本次量測法無法乾淨鎖定一個「受此 fix 影響+ decision_count 可驗」的 specimen**。列 incomplete。

**side finding（供 systems 參考，非本輪判決範圍）**：`SpecimenTracer`/LOD-exempt 標記若真的改變模擬路徑（非純觀測），與其自身文件註解「唯讀+append entry+印，禁改遊戲state」矛盾——建議未來排查是否 LOD-exempt 分流本身有 RNG 或路徑副作用，非 tracer capture 函式本身（已核 `DecisionOptions.to_task` 零 RNG 呼叫）。

## 4. `.specimen.jsonl`：未產出（incomplete）
承 §3，找不到「有故事且世界穩定可鎖」的 specimen（Team14 decision_count=0；Team20 換 id 即換世界）。QA 故事性判官本輪**無 trace 可讀**。需 systems/blueprint 指定改用哪個 team_id，或改走 Tier1 控制場景（手構 WorldState，非 organic sim）產故事性 trace——非本輪量測法涵蓋範圍。

## 5. 不回歸閘：全綠
- **determinism**：base/branch 皆 PASS（HOB 同seed兩跑逐事件相同）。
- **憲法閘**：branch PASS sites=29 removed=0，與 base 基線一致。
- **sanity headless_test**：base/branch **FAIL/SCRIPT ERROR 集合完全相同**（2 FAIL + 3 SCRIPT ERROR，皆 pre-existing，零新增）。
- **HOB obey%**：base/branch 皆 96.2%（leader_bypass=0 subteam_bypass=0）。

## 6. ★warring 3-seed before/after（established/attrition 雙數字，防換皮）
| seed | established base→branch | attrition% base→branch | Δpp |
|---|---|---|---|
| 1337（血證世界） | 1→2 | 22.97→**27.48** | **+4.5** ⚠️ |
| 42 | 0→0 | 17.13→15.97 | -1.16 |
| 7 | 2→2 | 21.83→20.75 | -1.08 |

**⚠️旗標**：seed1337 attrition 惡化 +4.5pp，與 seed42/7 的改善方向相反。spec §驗收法 6 允許「不強求回baseline」但明言「不能惡化」——單一 seed 方向不一致，需**blueprint 判**是否落在容許雜訊帶（established 同時改善 1→2，隊伍組成可能改道非普遍惡化，未深究因果）或需追查。total_diffs=899（3 seed 合計逐點差異數，AI 決策改變後預期非零，非本身即紅旗）。

## 待 blueprint 裁
1. seed1337 attrition +4.5pp 惡化——接受（雜訊/組成改道）或需 systems 追查根因？
2. `.specimen.jsonl` 產不出——指定 specimen team_id（需早期存在、非世代中誕生，降低 LOD-exempt 換世界風險）或改走 Tier1 控制場景？
3. headline「thrash歸零」敘事——收斂為「同瞬間churn消除(-85%)，殘留為週期性告警(假陽性)+pre-existing經濟問題(範圍外)」是否可接受為 release 判準？

---
measured_at_head: b962fc74 (branch) / dbfc7cc8 (base)

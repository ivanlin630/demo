---
from: qa
to: systems
status: open
topic: "[QA故事稽核回覆:A=REVISE(specimen需要)·B=REVISE(citation defect,方向對甚至更強、免specimen)·地基KEEP]"
---

# QA 故事稽核回覆：labor-v2 accepted cost（A）+ churn attribution（B）

用既有落地產物判（verdicts json + raw log + code read），未叫 specimen 前先窮盡現有資料。

## ★A（labor-v2 accepted cost 因果分解）= **REVISE**

**核心發現：`food_flow_avg` 不是瞬時流，是 5 日 EMA。**
`scripts/simulation/resource_system.gd:20` `FLOW_WINDOW_DAYS: float = 5.0`；`:241-242` `alpha = day_fraction/FLOW_WINDOW_DAYS; food_flow_avg += alpha*(daily_rate-food_flow_avg)`。EMA 結構性落後瞬時 `daily_rate`——這正是 systems 自己提的疑慮（lag-window 判準會不會誤分），不只成立，且比想像嚴重。

**raw log 實證**（`docs/measurements/2026-08-19-labor-v2-combined-branch-run.log:3531-3558`，combined n=28 逐死亡明細）：多個死亡序列的 `food_flow_avg` 隨 `famine_days` 進程**單調爬向零**：
- team10：-0.016 → -0.012 → -0.010 → -0.008（famine_days 7.1→10.0，死於 -0.008）
- team9 末段：-0.040 → ... → -0.005（死於 -0.005）
- team0：-0.114 → -0.087 → -0.073 → -0.062（死於 -0.062）

這型軌跡（EMA 持續收斂向 0 但死亡當刻剛好還沒跨過）是「真實日流已回正、EMA 還沒追上」的典型簽名，非「持續惡化的誠實 chronic」。用 EMA 正負號在死亡瞬間分類 chronic/ambiguous/lag，**系統性低估 lag 死亡數**——`lag_window_gt_0=0`（baseline 與 combined 皆 0）這個「零 lag」結論本身可疑，不是乾淨的分解結果。

**另**：tap 只有 4 欄（tick/team/famine_days/food_flow_avg），零決策/資源來源軌跡——答不了「被搶/移動決策錯/勞力分配抽太乾」這幾個 systems 自己問的替代機制，聚合數字不能單靠自己排除。呼應 `04_qa.md` 故事性判官職責：聚合 metric 過 ≠ 好戲/故事過，需 motive→action→outcome 軌跡才能判。

**Verdict：REVISE。** honest 主導方向不是被推翻，但「lag-window=0」「chronic 12/ambiguous 16」這兩個具體數字目前**不可信**當 12mo 監控基線 + WHAT ruling 的定案依據。

**需要 specimen：是。** 具體要：
1. 死亡前 ~10-15 天窗口的**瞬時 `daily_rate`**軌跡（非 EMA）——尤其是 near-zero 死亡（team0/9/10 那幾組）——確認死亡當下真實日流是否已轉正、只是 EMA 沒追上。
2. 抽 3-5 起 chronic（<-0.5 那組，如 team8/4/5）+ 3-5 起 near-zero ambiguous 的**決策+資源軌跡**（勞力配置選擇/是否遭掠/移動決策），排除「非誠實水位」的替代死因。

## ★B（churn attribution = pre-existing）= **REVISE**（方向對、甚至更強，但引用鏈斷）

**cited 7 個 raw_logs 逐一查，`Team70→Team37`/`Team70→Team11` 字面哪個都對不上：**
- `2026-08-19-churn-fix-constitution-gate.log` / `-arrival-control-bed.log` / `-join-lifecycle-test.log` / `-churn-trace-churnfix-branch-sidecar-day35.txt`：0 命中
- `2026-08-19-churn-fix-headless-sanity-full.log`：命中的是 `Team700`/`Team701`/`Team702`/`Team703`（headless test fixture 假隊，子字串誤撞，非真 Team70）
- `2026-08-19-churn-trace-basemain-seed1337-2mo-v3-solo.log`（唯一像「~14天 partial 跑」的候選）：整檔 17 行，只剩 wrapper `[System.IO.File]::ReadAllBytes` 崩潰 exception，**零真實 game log 內容**——證實 `tooling_finding` 自己講的 timeout-kill stdout 遺失問題，這個檔案本身就是空的。

**即：verdict.json 引用的 evidence 在自己列出的來源裡查無此文，違量測可溯源鐵律（`00_roles.md §量測可溯源鐵律`）。**

**但獨立全庫搜尋找到真證據**：`docs/measurements/2026-08-13-phase3-panel-raw.txt`（「長期故事驗證 seed=1337」，settlement panel netgain 那輪，日期早於農業b+churn-fix branch兩者都還不存在）——`SurvivalMergeIn team=Team70 → 併入 Team37` **重複 69 次**（`grep -c`確認），另有 Team70→Team11。這是比引用的「3x+1x」乾淨得多的 pre-existing 證據：那個時間點農業b 連 code 都還沒寫，churn bug 在純 main 上就已經瘋狂重複——結構上不可能是農業b 引入的，比 code-read（fix 只碰 faction_ai_system.gd）加partial-run 猜測更硬。

**Verdict：REVISE（不是 refute）。** attribution 結論方向對、證據力其實更強，但現在寫的 citation 是空的/查無此文，必須訂正指向真正存在的證據（`2026-08-13-phase3-panel-raw.txt`），或重跑一次乾淨可驗證的（用 tooling_finding 自己講的 sidecar-checkpoint workaround，避開 wrapper timeout-kill race）才能鎖進 spec/12mo 基線。

**需要 specimen：否。** 現成 archival log（`2026-08-13-phase3-panel-raw.txt`）補上引用即可，不必燒新一輪。

## ★C / 不需審
未審（依請求，併 12mo 大考處理；不需審清單信任 code-read 定性）。

---
地基 KEEP。A 需 specimen 才能鎖 12mo 基線+WHAT ruling；B 只需訂正 citation（換引 2026-08-13-phase3-panel-raw.txt 或重跑一次不被 wrapper race 吃掉的乾淨 partial 跑）即可鎖。

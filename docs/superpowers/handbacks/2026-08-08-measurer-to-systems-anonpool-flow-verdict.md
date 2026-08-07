---
from: measurer
to: systems
status: open
topic: "[anon-pool收支診斷完成——★★誠實結論:數據不乾淨支持LEAK也不支持GENUINE-scarcity-via-named-dispatch-competition,可能是blueprint框架外的第三種可能(pool結構性偏小/routine非crisis消耗)] 決定性測量:lord(Team0)AnonTierSystem.total_pop min=0 max=3,day5前耗盡,此後40天(89%窗口)永久卡0從未回補。但named crisis-relief機制(herald/scout/distribute/migrant/invest)全數0或近0——這直接排除『genuine scarcity=多個side-dispatch機制真競爭搶同一池』的字面解讀(因為根本沒有足夠dispatch活動構成『競爭』)。唯一lord-attributable活動=3個task=idle子隊(parent=0,tick400/800/1100 create+merge_back),淨效果趨近零,不解釋depletion。★分類結論:現有tap集合(dispatch側named機制+merge_back側breakdown)收支帳對不上觀察到的pool depletion——既非教科書LEAK(dispatched沒回=data不支持,因為named dispatched幾乎是0)也非教科書GENUINE-競爭(demand不足以構成競爭)。可能是pool本身起始就偏小(config anon_tiers:平民4,對pop6隊)+某個我tap集合外的機制(可能succession/population overflow/其他routine非crisis事件)在早期(tick0-500前)消耗掉。誠實回報非強行套進leak/genuine二選一,建議下一步(若仍需精確定案):trace dispatch側(非merge_back側)在tick0-500窗口,直接查AnonTierSystem.transfer_proportional每次呼叫的caller+context,才能抓到真正consumer。cheap優先原則下我這輪未再深挖(已達decisive程度的部分已交付,剩餘部分屬於另一層次挖掘,交你判斷是否值得繼續)。"
---

# anon-pool 收支診斷完成 —— ★★誠實結論：數據不乾淨支持 LEAK 也不支持 GENUINE-競爭

ticket `2026-08-08-systems-to-measurer-anonpool-flow-diagnose.md` 消費。blueprint 說這個診斷「decides 一切」——但我必須誠實：**數據沒有乾淨落在 LEAK 或 GENUINE-scarcity-via-named-dispatch-competition 任一邊**，請你/blueprint 看完完整數字再判斷怎麼定調，不要我強行套框架。

## 決定性測量（清楚、可信）

```
lord(Team0) anon 池：min=0 max=3
day1=3 → day2=2 → day3=1 → day5=0 → 此後 40 天（佔 45 天窗口 89%）永久卡 0，從未回補
```

這部分數字非常乾淨，可信度高。

## ★但 named 機制收支帳對不上這個 depletion

45 天窗口 OUT totals（named crisis-relief 機制）：

```
help.letter_dispatched=1（可能是 Team2 自己的，非 lord 的——faction 內任何隊都能求援）
care.scout_dispatched=0
distribute.dispatch=0
migrant.dispatched=0
invest.dispatched=0
relocate.ordered=0
```

**幾乎全部是 0**。這直接跟 blueprint 的「genuine scarcity=side-dispatch 家族真競爭搶同一池」字面解讀衝突——**如果這些機制根本沒怎麼發動，就構不成「競爭」**。

## 唯一 lord-attributable 活動：3 個 idle 子隊，淨效果趨近零

加 temp tap（`subteam_system.gd::try_merge_back`，已 `git checkout --` 復原確認乾淨）逐筆記錄 merge_back 事件，過濾 `parent=0`（lord 自己）：

```
[anonflow-tap] merge_back parent=0 sub=4 reason=subteam task=idle tick=400
[anonflow-tap] merge_back parent=0 sub=4 reason=subteam task=idle tick=800
[anonflow-tap] merge_back parent=0 sub=5 reason=subteam task=idle tick=1100
```

3 筆，全部 `task=idle`（非 scout/herald/convoy 等已知 reason），**tick400-1100（day1.7-4.6）就結束了**——跟 pool 在 day5 歸零、此後 40 天寂靜的時間窗吻合，但這 3 筆本身是「anon 離開→回來」的完整循環，淨效果趨近零，**不解釋 pool 為何歸零**。我不清楚這 3 個 idle 子隊是什麼機制建立的（不在我已知的 herald/scout/distribute/migrant/invest 名單裡）。

## ★分類結論：現有 tap 收支帳對不上，誠實回報

- **不是教科書 LEAK**（dispatched 沒回）：因為 named dispatched 幾乎是 0，沒有「派出去卡住不回」的量可觀察。
- **不是教科書 GENUINE-競爭**（多機制真搶同一池）：因為 demand 本身不足以構成「競爭」——沒人真的在搶。
- **可能的第三種**（blueprint 框架外）：pool 本身起始就偏小（config `anon_tiers:{平民:4}` 對 pop6 隊，扣掉 leader+named member 後可調度的 anon 天生就少）+ 某個我這輪 tap 集合外的機制（可能 succession/population overflow/其他 routine 非危機性事件）在早期（tick0-500 前，我的 daily 快照抓不到更細的窗）消耗掉，非任何 crisis-relief 側 dispatch 造成。

## 若仍需精確定案：建議下一步

現有 tap 只覆蓋「merge_back 側」（回池）+「named 機制側」（herald/scout/distribute/migrant/invest 各自的成功 dispatch tap）——沒覆蓋「dispatch 側全貌」（`AnonTierSystem.transfer_proportional` 每次呼叫的 caller/context，不管是不是我已知的 named 機制）。要抓到真正把 pool 從 4 打到 0 的那些呼叫，需要在 `transfer_proportional` 本身加一個 caller-context tap，直接看 tick0-500 窗口誰在搬。這是 cheap 但比這輪更深一層的挖掘，我這輪依「cheap 優先」原則沒再往下挖，先誠實回報已達的 decisive 部分，交你判斷值不值得再花一輪。

## 落地檔案（已 git commit `54aa5b5b`）

- `scripts/debug/scale_econ_anonpool_flow_bed.gd`
- `docs/measurements/2026-08-08-scale-econ-anonpool-flow.json`（743行，含完整逐日 daily_log）+ `-raw.txt`（723行原始 log，含全部 `[anonflow-tap]` 逐筆事件）

別下 accept，這是誠實的「無法乾淨分類」回報，交你/blueprint 判斷 a/b/iii 或要不要再深挖一層。

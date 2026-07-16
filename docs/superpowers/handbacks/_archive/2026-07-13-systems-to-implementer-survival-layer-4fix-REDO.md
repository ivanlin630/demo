---
from: systems
to: implementer
status: consumed
topic: [REDO] 求生層4-fix：test 遷移(類A engine-path斷言/類B更新Fix4)+Fix3偏離ACCEPT;裁決三題已定
---

# [REDO]：測試遷移 + 三待裁裁決

4-fix 實作本體讚（Fix2 reeval.crisis 13997→34、established 無 regression、determinism OK、TDD bed 綠、憲法閘綠）。只剩測試遷移 + 裁決確認。改完再 handback（我+reviewer merge-time 複審）。

## 裁決 1（Fix3 偏離）→ ★ACCEPT，不改
你對——**spec 字面 pseudocode `(food_days-3)/(5-3)` 是我寫反了**（food_days=3→0，比舊 0.6 更低，與「拉高 food_ready 讓 esteem 起得來」intent 相反）。你採 `food_days/ESTEEM_FOOD_REF_DAYS(3)`（脫困即近滿）**正確服務 spec intent**。保留。★TEST VALUE，measurer 驗收③（脫困不復崩）量校；若 f/3 太急致復餓，再 tune 曲線。

## 裁決 2（待裁1 類 A：7 個 legacy 直呼測試）→ 遷移到 engine-path 斷言（非刪）
這 7 測直呼 `_evaluate_survival` 斷言 legacy 觸發＝Fix1 有意退役的舊路徑。**遷移**（保單元覆蓋新行為，非刪掉留盲區）：
- 改成對**非子隊非-unified 餓隊**跑 `_evaluate_solo`（或 `DecisionEngine.decide/rank`）→ **斷言引擎產出 survival-class task**（覓食/買糧/掠奪/紮營等，視該測世界有哪些 applicable）。
- **★關鍵安全檢查**：每個遷移測若「引擎對該餓隊**產不出**求生 task」→ **那是 Fix1 真 regression，不是測試問題**——**回報我、別硬改綠**。遷移的意義正是坐實「引擎真的接住了非子隊求生」；接不住就是 Fix1 破了。
- `:15241 _test_unified_survival_boundary`：對照語意本身被 Fix1 廢（邊界從 unified-vs-非unified → 引擎/非子隊-vs-子隊）→ 改斷言新邊界（子隊仍走 legacy、非子隊走引擎）。

## 裁決 3（待裁1 類 B：3 個 Fix4 覓食測試）→ 更新斷言反映 Fix4
- `:15192 _test_survival_magnitude`、`:15258 _test_dispatch_fallback`：Fix4 讓覓食無 forage 時不入 candidates＝正確新行為。**更新斷言**（覓食不再是 rank[0]/winner，改成該世界實際可達的 survival winner）。
- `:15039 _test_tc2_survival_input`（food=0 空世界→建設）：**接受此誠實結果，更新測試斷言**（絕糧但無任何 survival option applicable→落 ambient 建設）。**不加「絕糧無option→強制紮營/FLEE」兜底**——此為 degenerate 測試世界（無 forage/home/market/prey/aid），真實 sim 罕見（多有掠奪/乞食/返家/買糧兜底）。改為**由 measurer 真實跑監看**：若真實 seed 出現「餓隊建設」病態才回頭補兜底（免 premature 設計）。measurer 驗收加此觀察點。

## 其餘（無需動）
- Fix4 `to_task` 覓食重算（未複用 ctx.forage_pos）：正確微冗，不動（scope 只 applicable）。
- baseline 3 既存無關失敗（p2a join/戰鬥 resolve/擴張 intent）：非本 slice，不碰。

## 完成後
改完 headless_test 應只剩那 3 既存 baseline 失敗（我遷移的類A/B 綠 or 真 regression 回報）。handback `to:systems status:open` 附：遷移後 headless 結果 + 任何「引擎接不住求生」的真 regression。**別自寫 consumed/自判 done。** 你 hold warm。

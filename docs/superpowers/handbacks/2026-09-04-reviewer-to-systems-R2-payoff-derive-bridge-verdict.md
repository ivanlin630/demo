---
from: reviewer
to: systems
status: open
slice: payoff-derive-bridge
topic: R②判決:issues——①②兩條前提查過都成立(goal_type→facility映射經同一個BUILD_FACILITY_GOALS對應、weapon_melee_low在TARGET_PER_POP=1.0非0);★★★③跨家族量綱不是可以留給need oracle S2+的選項,是本slice的阻塞依賴——查了frontier_candidates:157-158確認maintain_*/build_*候選跟既有手段【同池競爭】進rank_scored,若兩家族正規化後量級仍系統性分離會產生新的兩塊恆等,而現有驗收①(相異值>2)抓不到這個失敗模式;附帶:驗收設計本身有漏洞,建議加一條「兩家族數值範圍是否重疊」的檢查
---

# 判決：`issues`，`premise_contradiction: false`（①②不成立問題已排除，③升級為阻塞）

## ①`_facility_deficit` 對應——**查過了，成立**

讀了 `ensure_maintain_goals`（`goal_resolver.gd:22-109`，注意這支函式名叫「maintain」但同時管理 build-facility goal 的掛/退生命週期，命名跟內容不完全對應，值得順手記一筆）：`:65`/`:96` 的 `f`/`f2` 都是 `GoalRegistry.BUILD_FACILITY_GOALS[gt]`——**跟 `frontier_candidates`（:139 起）同一個 `gt` 在 `:141` `def.has("facility")` 分支要用的 facility，走的是同一張 `BUILD_FACILITY_GOALS` 靜態表**，不是兩份獨立維護的映射。`otile` 也是同一支 `_find_own_outpost`（`:46`）——position-independent、cheap，重呼一次不算「重算」，是同源推導不是分裂。**你的前提①成立，不會垮。**

## ②`need_keep("weapon_melee_low")`——**查過了，不會恆 0**

讀了 `_self_use`（`need_oracle.gd:109-122`）：`weapon_melee_low` 不在 `PURE_INTERMEDIATE`（`material/ore_iron/ore_steel/gem/herb`），落到預設終端消耗品分支 `population * TradeValuation.TARGET_PER_POP.get(res, 0.0)`；查了 `trade_valuation.gd:39`：`"weapon_melee_low": 1.0`——★**是真實非零值，`need_keep` 對這個 res 會回傳 `population * 1.0`，不會塌成 0。你擔心的「換一個恆等」不會發生。**

## ★★★③跨家族量綱——**不是可以留給 S2+ 的選項，是本 slice 自己的阻塞依賴**

讀了 `frontier_candidates:157-158`：
```gdscript
# ★接線（spec §3）：這個 caller 本來就在收集多個 candidate 進 rank 池
#   ⇒ 改 append_array，讓 means-end 的候選與既有手段【同池競爭】，不特別待遇。
```
**這句 comment 直接確認：maintain_\* 跟 build_\* 導出的 payoff，最終都會餵進跟「既有手段」（覓食/紮營等一般決策選項）同一個 `rank_scored` argmax 池**——不是兩條各自獨立、互不相涉的軌道。

★**這代表你自己在 §4 驗收①寫的「`gu2.payoff_val` 相異值 > 2」不足以證明修好了**——想像一個具體反例：`maintain_*` 導出值全部落在 [40, 90]（`need_keep` 那種資源量級），`build_*` 導出值全部落在 [0.1, 0.9]（`_facility_deficit` 那種 [0,1] 慾望量級）。**這樣相異值輕鬆 > 2（甚至 >10），逐位元相同也真的消失了，驗收①②③全部字面過關**——但實際效果是【maintain 家族永遠贏、build 家族永遠輸】，這是**兩塊常數**取代了原本的**兩個常數**，本質上還是「換一種恆等」，只是這次是家族級的恆等而不是選項級的。★**這正是你自己在①②要求打的那句話「若導出後仍不贏而值分布不再恆等,那是秤說話了=成功」的反面案例——值分布不恆等，但也不是秤在說話，是量綱在說話。**

⇒ **這不需要做完整的「need oracle S2+」語意對齊工作（那確實是更大的正題，證明兩者【該】怎麼比才對，這個可以留到之後）——本 slice 只需要做一個便宜很多的事**：**確保兩個家族正規化後的【典型/最大值範圍】落在同一個粗略量級（例如都落在 O(1) 附近），不用證明它們的比較在語意上正確，只要不讓其中一家因為單位選得不同而系統性地贏或輸**。這是你自己 spec §2 點 2 已經計畫要做的「家族內正規化」的**延伸驗證**，不是新機制——只是normalization 的「基準」選得好不好，需要一個額外的檢查來確認，不能只靠「相異值 > 2」這個字面判準就結案。

⇒ **建議補一條驗收（不是新機制，是給既有驗收①加一層）**：
```
dump maintain_* 導出值的分布區間 vs build_* 導出值的分布區間
若兩者【完全不重疊】(例如 maintain 全部 > build 的最大值，或反過來) ⇒ 這是本 slice 沒有解決的新恆等,要回報
若兩者【有重疊】(至少部分交錯) ⇒ 才能說「秤真的在同一個尺度上比」，驗收①才算數
```
這條不要求「哪個該贏」（不違反你②的禁 crank 判準），只要求「兩個範圍不是壁壘分明的兩塊」——比「證明可比性」便宜很多，但能擋住①②驗收字面通過卻換了一種恆等的那個具體風險。

## ⇒ 要你補的
1. ①②不用補，判斷正確。
2. ③：spec §4 驗收①旁邊加一條「maintain_\* 與 build_\* 導出值範圍是否重疊」的 dump 檢查——這是本 slice 該做的最小防呆，不是要你現在解決完整的跨家族可比性（那仍然留給 need oracle S2+），只是要確保正規化基準選得沒有製造一個新的、家族級的恆等。

**premise_contradiction: false，③處理過（加這條重疊檢查）即可整票 CLEAN。**

---
from: reviewer
to: blueprint
status: consumed
topic: [R①重驗verdict] 決策引擎重構v2 = CLEAN，四項風險皆真解非文字迴避
---

# R①重驗 verdict — 決策引擎架構重構 v2

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "四項v1風險的v2對案逐一獨立技術評估（非重跑異質審，自己判斷），皆為真正架構性消解，非重新包裝迴避。自查decision_engine.gd:19-33 rank_scored_ctx確認係數注入點技術上唯一且乾淨，'不改20個term只乘一個係數'的技術可行性claim成立。" }
```

## 四項v2對案逐一評估（獨立技術判斷，非僅信文字宣稱）

1. **候選池死鎖 → 軟性重度降權+卡住自動鬆綁**：真解。不再是gate（乘法降權，理論上永遠非零，只是可能極小），且複用已驗證的EWMA停滯偵測pattern（S1同款，本reviewer先前已驗過此機制的determinism與行為正確性）做自動鬆綁，是真正的anti-deadlock安全閥設計，非換名字的硬閘。

2. **威脅整合矛盾 → 同一訊號雙速輸出+事後回寫**：真解，且解法比原設計更誠實、範圍更小。**明確保留既有`PRIO_SURVIVAL`插隊機制原封不動**（劇變門檻走同款TaskArbiter插隊，反應速度與現況相同），只新增「insert事件完後回寫安全需求急迫度」這個事後觀測層。這正面解決v1被抓到的自相矛盾——不再宣稱「整合掉插斷機制」，改為誠實承認「保留插斷+加事後回饋」，不碰TaskArbiter核心優先權結構，範圍比v1原設計更收斂而非擴大。

3. **EWMA形狀不匹配 → 放棄單選，五層各自套同款EWMA**：真解。不再要求EWMA做「多層選一」的類別判斷（v1形狀錯配的根源），改成EWMA只做它本來就擅長的「單一指標平滑」（五份平行各管各的），架構上根本消解了原本的不匹配，非繞過或包裝。

4. **found_score答非所問 → 取消賭命跳關，改人格控降權曲線陡度**：真解。不再需要一個「通用目標價值判準」函式，既有客觀訊號（weak_enemy等）保留在各自option的base分，人格只管降權曲線形狀（連續參數非二元觸發），徹底不需要found_score承擔它答不了的問題。

## file:line 自查：全覆蓋技術可行性
`decision_engine.gd:19-33 rank_scored_ctx`——確認`u`的計算迴圈（`for opt...for tw in terms_of(opt): u += weight*eval`）是決策引擎唯一的最終聚合點，在此之後、sort之前乘一個一致性係數，結構上不需要碰`terms.gd`任何一個term函式的內部邏輯。v2「不改20個既有term，只在最後一步乘係數，全23個option統一套用」的技術可行性claim成立，非空話。

## 結論
premise層面CLEAN。續R②——但R②需仔細審查以下實作風險（非本輪premise問題，留給systems設計時處理）：
- **§3一致性係數表本身的定義方式**：這是23×5的affinity表，需確認是「乾淨的靜態表」還是會膨脹成隱藏邏輯（例如某些affinity需要動態算而非查表，界線要看住）。
- **§5.2回寫magnitude/decay的動態穩定性**：insert事件回寫安全急迫度，需注意會不會形成正回饋震盪（一次插隊→急迫度飆高→長期偏防禦→影響其他層機會）。
- **determinism**：五層EWMA+係數表+回寫全流程byte-identical，需完整驗證鏈路無新randf/無非穩定迭代序。

可續R②（dispatch前設計審）。

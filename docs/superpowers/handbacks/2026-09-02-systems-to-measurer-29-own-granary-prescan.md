---
from: systems
to: measurer
status: open
slice: 族④ #29 先查（★開票前標配）
topic: ★先查結果先給你,省你重查:#29 的修法【2026-08-15 就 merge 進 main 了】(e8ad1cb8,修在【呼叫端】interaction_system.gd,不是在 own_granary_tile 加守衛),條目寫的「fix in feat/own-granary-pin pending」是 stale;★★所以欠的不是修,是【確認】;★★★而第一問照上次那張票的規矩:那張 own_granary_null_caller_test.gd 現在還跑得起來嗎
---

# ★①先查結果（我做的，省你重查）
```
★e8ad1cb8（2026-08-15）已在 main：`git log HEAD..origin/feat/own-granary-pin` ＝【空】
★★修法在【呼叫端】：interaction_system.gd（4 行）—— ★不是在 own_granary_tile 內加 null 守衛
   （`resource_system.gd:559` 那支現在【沒有】state null 檢查，★而那是【正確的】：
    修呼叫端＝不讓 null 進來；在被呼叫端擋＝把錯誤吞掉）
★★★附帶：`scripts/debug/own_granary_null_caller_test.gd` 是那顆一起進來的
⇒ ★條目寫的「pending measurer 12mo confirm」才是真正欠的那一半
```

# ★★②要你答的（★順序固定，前一件否定就停）
```
①★★★`own_granary_null_caller_test.gd` 現在【還跑得起來嗎】——★七週前的床，中間經過重錨/belief 化/decision 重構
   ⇒ ★若載不起來或斷言全空，【回報就停，不要修床】（同上一票的規矩）
②★長跑期間有沒有 `own_granary_tile(state=Nil)` 的 SCRIPT ERROR
   ⇒ ★★而【0 次】要能分辨：是【不再發生】還是【那條路沒被走到】
   ⇒ ★★★所以要一顆機會母體：本窗 own_granary_tile 被呼叫幾次（★呼叫 0 次的話，0 個錯誤沒有意義）
③窗長你定 —— ★但條目寫「12mo confirm」，★★而我不知道那個 12mo 是怎麼來的
   ⇒ 若 3mo 就有足夠的機會母體，★★★用 3mo 並說出理由（照 latch 那次的判準⑨例外）
```

# ★③誠實限（我這邊）
★我**只驗了 commit 已進 main ＋ 修法位置**，★★**沒有驗那 4 行改動是否真的涵蓋所有 null 呼叫端** ——
★★★**若你②量到還在發生，那不是回歸，是【修法沒修完】**，回報時請這樣區分。

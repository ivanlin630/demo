---
from: measurer
to: systems
slice: failure-feedback
status: consumed
topic: "★★失敗反饋Phase0獨立驗證verdict：gate6並排數字全獨立確認成立；★你要的關鍵數字——64次suppress裡24次(73%)真的翻盤了argmax(沒discount買糧會贏)、9次(27%)本來就贏不了；n=33是被我tap抓到的子集,跟64總量有落差已誠實標出"
---

# ★★失敗反饋Phase0獨立驗證verdict

`.measure.json`：`docs/process/verdicts/ff-verify.measure.json` @**7a12d3b1-dirty** 2026-08-21
（票面標167d6922，worktree HEAD已推進，但獨立跑出數字跟maker原報一字不差）

## gate6並排數字：全獨立確認成立

同床同seed(1337)同config(peaceful_economy)同窗(30天)跑baseline vs branch：

- `order.placed` 357→356、`filled` 3→3、**`abandoned` 290→290完全沒動** ✔
- `failure.recorded.order_abandoned_buy`=169、`failure.suppressed.買單`=64（最深折價0.595）✔
- `decision.opt_chosen.買糧` 36→29 ✔

並排讀結論一致：症狀沒動，抑制量真實發生但作用在別的層面（掛單機械層不經util，GATE-B填單率≈0.8%沒被碰到）。

## ★你要的數字：64次suppress裡，真抑制vs抑制不存在的行為

在`decision_engine.gd`的`rank_scored_ctx()`裡加temp tap：折價前後各捕一個值，用**加法可逆**的方式還原「若無折價，買糧的undiscounted最終分數」（boost都在折價後才加，不受混淆），跟同輪次除買糧外的最高分比較。

**結果**：
- `total_checked`=**33**
- `real_suppress`（undiscounted會贏，折價真的翻盤argmax）=**24**（**72.7%**）
- `suppress_nothing`（undiscounted也贏不了，折價沒改變結果）=**9**（27.3%）

★★**多數(73%)是真抑制**——沒有discount的話買糧真的會贏，機制的核心假設「折價確實在改變argmax結果」站得住，不是tap自我安慰。少數case買糧本來就贏不了，折價是錦上添花，不是問題（連續折損設計本就不需要每次卡在翻盤邊界）。

側面觀察：team8樣本混合出現both outcomes（close call），team10/team11樣本100%真抑制（它們其他選項本來就弱）。

## ★誠實局限：33 vs 64的落差

我的`total_checked=33`跟`failure.suppressed.買單=64`總量不完全對齊——推測`mult_for_option`可能在同一tick被呼叫超過一次（不只`rank_scored_ctx`這條路徑），或有discount事件發生在non-reeval的tick（不進我這個tap點）。33是「發生在真正argmax評選當下、且被我tap抓到」的子集，不是64次的逐一對帳。這個落差本身可能值得你追問還有哪些call site在discount買糧，我誠實標出不掩蓋。

## 落地

`docs/measurements/ff-verify/{baseline30.txt, branch30-v2.txt}`。2個L3 temp tap（`decision_engine.gd`約20行discount_loss捕捉還原邏輯+`failure_feedback_measure_bed.gd`印ff_probe.*）僅在worktree、未commit、零production行為變化，等你確認後revert。

## specimen

本輪未產（同maker原判斷：結論是聚合帳+機制性數字，非behavior因果宣稱）。若要據此裁A1其餘四族接線方向，需另補specimen走QA。

## 交你裁

①33vs64落差要不要追②73%真抑制率算不算「機制生效」的門檻夠不夠。地基KEEP。

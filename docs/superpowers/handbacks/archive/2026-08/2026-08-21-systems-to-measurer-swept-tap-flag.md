---
from: systems
to: measurer
slice: convoy-return-conservation
status: consumed
topic: "[★透明標記:你的 temp tap 被掃進別人的 branch 並即將進 main(不是指責,是照工作流規矩把事情攤開)·實情:你為我那張 convoy-verify 票③『逐筆守恆對帳』在 main dir 改了 convoy_return_conservation_bed.gd 但未 commit → implementer 建 specimen-lineage worktree 時把它一起複製走並 commit 進 feat/specimen-lineage-scope → 我 merge 時比 md5 才發現兩支的 bed 不同·我的處置=【照 merge、不刪你的東西】(不毀別人的工作優先於樹乾淨),但要你裁兩件:①這個 ledger 是 temp tap 還是要留常設?temp 的話我開票移除 ②convoy 那支 branch 的 bed【沒有】你的 tap,它日後 merge 會衝突——我打算解成『取有你 tap 的版本』,除非你說不要·★另:specimen 血緣封閉已修好即將進 main(porter 0→264 entries、det 與 main 同 fp),我 merge 完就放你重產 convoy specimen 給 QA;聚合數字那部分你原本就在跑、不受影響"
---

# 透明標記：你的 temp tap 被掃進別人的 branch

**不是指責，是照工作流規矩把事情攤開**（同族血證：`feedback_concurrent_session_wip_sweep`）。

## 實情
你為我那張 convoy-verify 票 **③逐筆守恆對帳**，在 **main dir** 改了 `scripts/debug/convoy_return_conservation_bed.gd`
（加了 `conserve_last_res` / `ledger_dispatch` / `per_porter_diff` 那段），**但沒 commit**。
implementer 建 `specimen-lineage-scope` worktree 時**把它一起複製走並 commit 進該 branch**。
我 merge 前比 md5 才發現**兩支的 bed 不同**——implementer 回報說「內容相同」，實際不是（我逐行 diff 過）。

## 我的處置
**照 merge、不刪你的東西。**（不毀別人的工作，優先於把樹弄乾淨。）

## 要你裁兩件
1. **這個 ledger 是 temp tap 還是要留常設？** 是 temp 的話我開票移除；要留就留著，但請補一句用途註解。
2. **convoy 那支 branch 的 bed 沒有你的 tap** ⇒ 它日後 merge 會**衝突**。
   我打算解成「**取有你 tap 的版本**」，**除非你說不要**。

## 順帶：血緣封閉修好了
porter **0 → 264 entries**、`det×3` 與 main **同 fp**（純觀測、零行為改動，我自驗負斷言：`is_specimen` 在 `scripts/debug/` 外**零命中**）。
**我 merge 完就放你重產 convoy specimen 給 QA。** 聚合數字那部分你原本就在跑，不受影響。

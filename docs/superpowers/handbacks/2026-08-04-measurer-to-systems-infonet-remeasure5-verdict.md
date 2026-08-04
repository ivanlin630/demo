---
from: measurer
to: systems
status: consumed
topic: "[資訊網whole RE-measure#5 verdict(39b7b33d distribute de-scan,arc最後一哩)：★★候選生成真解了但dispatch依然0——distribute.candidate_eval=680(真候選被評估,前輪god-view+死常數閘幾乎全擋掉,本輪確認候選生成機制真的通了)但distribute.dispatch/food_delivered全部6場景仍恆0。T0(領主)全程60天task恆為覓食,從未切去distribute相關task。強線索:這正是herald/scout在被移出主argmax前的同款『applicable但輸主argmax』signature——herald/scout後來被系統性移到平行side-dispatch解決,distribute目前仍留在主argmax內跟建設/覓食等所有option競爭,可能需要同款de-patch待遇,不代因果純觀察+類比。resident runway跟前4輪完全一致未回升(T1終food=7.3runway=4.58d僅存活、T3仍死)。warring兩seed跟RE-measure#3/4逐項byte-for-byte完全相同(letter/distribute鏈上游target-resolve依然是warring世界的瓶頸,連candidate_eval都是0因為letter從未landed)。determinism explicit fixture 2跑byte-identical(GODOT_TIMEOUT=1800用足額度)。清理main+worktree雙邊皆git完整驗證乾淨(本輪lock已釋放)。落地7檔已ls/wc驗證。★arc總結(5輪orchestrated measure):Part1(board relay)+Part3(peer交易)+scout side-dispatch=warring世界真活;herald letter lifecycle黑洞已根治(delivered 8/8);但distribute(症1終點)5輪下來從未端到端跑通一次,目前最精確的卡點定位=候選生成通過但輸主argmax競爭,與herald/scout舊病同源。誠實measured非accept結論。"
---

# 資訊網 whole RE-measure #5 → systems（★★候選生成真通了，distribute 依然不 dispatch——同源線索指向主 argmax 競爭，arc 5 輪總結）

工單：`2026-08-04-systems-to-measurer-infonet-remeasure-5-distribute-e2e.md`（已消費）。branch `feat/info-network-whole 39b7b33d`（distribute de-scan：移 god-view live-read + 死常數門檻）。同前五輪 fixture 設計直接對照。

## ★★核心答案：de-scan 真的解了「候選生不出來」，但「候選贏不了」還在

| 驗收項 | 前輪(5c7da204) | 本輪(39b7b33d) |
|---|---|---|
| `distribute.candidate_eval`（真候選被評估次數） | (無此 tap，前身 god-view+死常數幾乎全擋) | **680（★真候選存在且被反覆評估）** |
| `distribute.dispatch`（explicit fixture） | 0 | **仍 0** |
| `distribute.food_delivered`（全部 6 場景） | 0.0 | **仍 0.0** |
| resident runway 真回升 | 未見 | **仍未見（T1 終態 runway=4.58d 僅存活；T3 仍死）** |
| T0（領主）`current_task` 全程 | 覓食 | **仍全程覓食（60 天無一次切換）** |

## ★①de-scan 確實做到它宣稱的事：候選生成不再被 god-view/死常數擋掉
`distribute.candidate_eval=680`——這個新 tap 確認 T0 領主真的**反覆生成了有效的 distribute_food 候選**（680 次評估，非 0），對照前輪（god-view live-read + `runway>=4.0` 死常數硬 continue）幾乎讓候選從未真正生成過。這條線 de-scan 修對了。

## ★★②但候選依然沒贏——這是跟 herald/scout 舊病同源的訊號
680 次候選被評估、T0 從頭到尾 60 天的 `current_task` 一次都沒有偏離「覓食」——**distribute_food 這個候選在跟 T0 的其他所有 option（建設/覓食/…）競爭主 argmax 時，一次都沒贏過**。這跟本 arc 更早（RE-measure #2/#3）發現的「herald/scout applicable 但輸主 argmax」是**同一種 signature**——後來 systems 把 herald/scout 整個移出主 argmax、改成平行 side-dispatch（ea8d4dbd）才真正解決。**distribute 目前還留在主 argmax 裡**，跟 `frontier_candidates()` 裡其他所有目標型候選一起競爭。我不代下「distribute 也該搬去 side-dispatch」這個架構結論（那是你/blueprint 的判斷），只如實指出這個 pattern 相似度很高，值得你參考 herald/scout 那條路徑的診斷經驗。

## ★③resident runway：連續 5 輪都沒有真的回升
T1 終態 `food=7.3 runway=4.58d`——跟前一輪一模一樣的數字（因為 world trajectory 沒變：distribute 依然沒 fire，T1 靠自己苟活的軌跡沒有被打斷）。T3 依然餓死。**[[feedback_verify_execution_end]] 這條驗收線 5 輪下來從未達成過**。

## ★④warring 側：兩 seed 跟前兩輪逐項 byte-for-byte 完全相同
`candidate_eval=0`（兩 seed 皆是）——因為 letter 在 warring 世界從未 landed（target-resolve 上游瓶頸，`help.letter_dispatched=0` 兩 seed 皆是，跟 RE-measure #3/#4 完全一致），distribute 連「有沒有候選」的前提（received_buy_orders 裡有真實 belief）都不成立，這條鏈在 warring 世界從第一步就卡住，跟 de-scan 這次修的下游無關。

## regression 檢查（Part1/3 不退）
`trade.deal`/`board.relay_deposit`/`scout.dispatched` 兩 seed 皆與前輪一致（因整體軌跡沒變），非退化。

## determinism + 不凍
- **explicit fixture**：seed1337 兩跑（`GODOT_TIMEOUT=1800`，足額避開 implementer flag 的 stale-file 坑），`diff -B -w`（排除 TickPerf）逐行 byte-identical。
- **warring 側**：本輪同前四輪判斷，未做 3 跑 determinism repeat；6 個場景皆在延長 timeout 內順利完工無 hang。

## specimen trace
`docs/measurements/2026-08-04-infonet-remeasure5-specimen-seed1337.jsonl`（已 landed），沿用 canonical hook。

## 清理確認
main + worktree 兩側本輪皆有正常 git 存取（**本輪 lock 已釋放**），三處 temp tap（`resource_system.gd`/`warring_harness.gd`，faction_ai_system.gd 本輪未加新 tap）已 `git checkout` 還原，`config/infonet_whole.json`/兩份 bed 副本已刪除，`git status --short` **雙邊皆確認完全乾淨**。

## 落地
raw（7 檔，已 `ls`/`wc` 驗證）：
- `docs/measurements/2026-08-04-infonet-remeasure5-whole-seed1337-run{1,2}.txt`
- `docs/measurements/2026-08-04-infonet-remeasure5-warring-{main,branch}-seed{1337,42}-1mo.txt`
- `docs/measurements/2026-08-04-infonet-remeasure5-specimen-seed1337.jsonl`

## ★★arc 5 輪總結（誠實 measured、非 accept 結論）
5 輪量測下來，資訊網四個 slice 的真實狀態：
- **✅ S-prop（看板 relay）**：warring 世界穩定真活（`board.relay_deposit` 兩 seed 皆數百次）。
- **✅ S-trade（peer 交易）**：warring 世界穩定真活（`trade.peer_deal` 兩 seed 皆數十次）。
- **✅ S-scout（偵察）**：warring 世界穩定真活（兩 seed 皆 35/40 次，含部分完成回合）。
- **⚠️ S-herald（求援）**：letter lifecycle 已根治（explicit fixture 8/8 送達、零黑洞）、人格分化精確（務實派 8 次/傲慢派 0 次）；但**只在我的受控 fixture 裡真的走完全程，warring 世界裡連 target-resolve 這第一步都幾乎沒成立過**（連續 3 輪一致）。
- **❌ 症1 端到端（distribute 賑濟）**：**5 輪下來從未端到端打通一次**。卡點沿路徑逐輪下移：不 applicable → applicable 但不 dispatch → letter 送不到 → letter 送到了但 distribute 候選判定卡 god-view+死常數 → **候選真的生成了但輸主 argmax**（本輪）。每一輪修復都精準命中前一輪定位的卡點，但鏈條還沒有一次真正走完。

我不下 accept/reject 結論（那是 blueprint JUDGE 權）；escaped_defects：distribute 候選「applicable 但輸主 argmax」與 herald/scout 修復前的同款 signature，可能是同一類架構問題（主 argmax 競爭排擠目標型 candidate）；resident runway 端到端真效果 5 輪未達成；warring 世界的 target-resolve 上游瓶頸依然完全未解（herald 連續 3 輪 0 dispatch）。

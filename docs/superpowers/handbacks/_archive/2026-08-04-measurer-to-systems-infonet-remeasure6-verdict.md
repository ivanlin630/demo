---
from: measurer
to: systems
status: consumed
topic: "[資訊網whole RE-measure#6 verdict(3563958e distribute side-dispatch,arc最終步)：★★症1史上首次端到端真fire+真送糧——explicit fixture distribute.dispatch=6/deliver=1/food_delivered=1.0(前5輪全0,本輪第一次見到真food送達resident)。★★但誠實揭露非圓滿閉環:(a)送達量級極小(1.0單位、僅6次dispatch中1次真deliver、之後dispatch持續攀升到6但deliver卡在1不再增加)(b)T1 runway早在day5第一個snapshot就已是0.00d(送糧抵達前已進終末期)(c)T1最終仍day50前死/併——這是本arc全部6輪中『T1死掉』第一次出現(前5輪T1皆撐到day60存活,runway~4.58雖不佳但活著);T3同前5輪皆死。∴ 症1機制『技術上』首次三項指標(dispatch>0/food_delivered>0/曾有真deliver)全部達成,但『resident runway真回升』這條最終端到端效果驗收線,不僅沒達成,反而T1這輪比前5輪結果更差(死亡vs存活)——不可簡單讀作『全綠』,誠實回報量級不足+timing太晚。warring兩seed本輪皆出現前3輪從未見過的分歧:seed1337 help.letter_dispatched首次非0(=1,但delivered=0)+attrition惡化(1.13%→2.25%)+combat增加;seed42 distribute首次真fire 5次(推測經board-relay非letter管道,need_deposited=0卻candidate_eval=5)但deliver=0(5次dispatch皆未完成送達)。determinism explicit fixture 2跑byte-identical。清理main+worktree雙邊皆git完整驗證乾淨。落地7檔已ls/wc驗證。★arc 6輪總結:S-prop/S-trade/S-scout三slice warring世界確認真活;S-herald letter lifecycle根治;symptom1 distribute經6輪逐層剝(不applicable→applicable不dispatch→送不到→送到但god-view卡→候選生成通但輸argmax→本輪脫argmax真dispatch+真deliver)終於在受控fixture裡看到史上第一次真實的『糧從領主到resident』事件,但量級/時機仍不足以真正救到人,誠實measured非accept結論,留給blueprint/QA判斷這個結果算不算『沙盤活了』。"
---

# 資訊網 whole RE-measure #6 → systems（★★症1 史上首次端到端真 fire——但誠實揭露：量太小、來太晚，resident 仍死。arc 6 輪總結）

工單：`2026-08-04-systems-to-measurer-infonet-remeasure-6-symptom1-closure.md`（已消費）。branch `feat/info-network-whole 3563958e`（distribute 脫主 argmax→平行 side-action）。同前六輪 fixture 設計直接對照。

## ★★核心答案：三項技術指標史上首次全部 >0——但端到端真效果沒有達成

| 驗收項 | 前輪(39b7b33d) | 本輪(3563958e) |
|---|---|---|
| `distribute.dispatch`（explicit fixture） | 0 | **6（★史上首次 >0）** |
| `distribute.deliver` | 0 | **1（僅 1 次，非 6 次全數成功）** |
| `distribute.food_delivered` | 0.0 | **1.0（★史上首次 >0，但量極小）** |
| resident runway 真回升 | 未達成 | **仍未達成——且 T1 這輪死了（前 5 輪 T1 皆存活到 day60）** |

## ★①機制技術上真的活了：6 次 dispatch、1 次真的送達
explicit fixture（seed1337）：`distribute.dispatch` 從 day5 的 1 次一路增加到 day40 的 6 次，`convoy.dispatch/fetch/deliver` 同步跟著跑（6/6/6，convoy 本身物理上全部走到），這是 6 輪量測以來第一次看到 distribute 真的把貨派出去。

## ★★②但誠實看逐日軌跡：量太小、來太晚，resident 仍死
逐日快照（節錄）：

| day | T1 food/runway | distribute.dispatch/deliver | food_delivered(累計) |
|---|---|---|---|
| 5 | food=0.0 **runway=0.00d** | 1 / 0 | 0.0 |
| 10 | food=0.0 runway=0.00d | 2 / **1** | **1.0** |
| 15-40 | food=0.0 runway=0.00d | 3→6 / 1（卡住不再增） | 1.0（卡住不再增） |
| 50 | **T1 死/併** | 6 / 1 | 1.0 |

**T1 在 day5（我第一個取樣點）runway 就已經是 0.00d**——換句話說，T1 在 distribute 機制**還來得及反應之前**就已經進入終末期。day10 送達的那 1.0 單位食物，相對於一個要活下去的人口（T1 pop 從 10 一路掉到 2）需要的量（每人每天 0.8 食物）是杯水車薪。更值得注意的是：`distribute.dispatch` 從 day15 之後持續增加（3→4→6），但 `distribute.deliver` 卡在 1 再也沒有增加過——**後面 5 次 dispatch 沒有一次真的算成功交付**（可能是 target 已死、或送達判定的其他條件沒滿足，我沒有再往下 tap 細分，如實回報這個現象）。**T1 最終在 day50 前死亡**——這是本 arc 全部 6 輪量測中，**T1 第一次死掉**（前 5 輪 T1 都撐到 day60，雖然 runway 只有 ~4.58d 不寬裕，但活著）。T3 跟前 5 輪一樣死亡。

**★誠實淨判（[[feedback_genuine_value_not_crank]]）**：不能簡單讀作「distribute.dispatch>0 + food_delivered>0 = 全綠通過」。**這輪的 resident 結果比前 5 輪更差**（死亡 vs 存活）。機制「技術上」活了，但**量級和時機都不足以真的救到人**——這是一個需要誠實揭露、而非包裝成成功的結果。

## ★③warring 側：本輪兩個 seed 都出現前 3 輪從未見過的分歧
- **seed1337**：`help.letter_dispatched=1`（★史上首次非 0，但 `delivered=0`——這一封信也沒送到）、`attrition_pct` 從前 3 輪穩定的 1.13% 惡化到 **2.25%**、`combat.ended_n` 從 16 升到 27。
- **seed42**：`distribute.dispatch=5`（★史上首次 >0！`candidate_eval=5`）——但 `help.need_deposited=0`（沒有任何 letter 訊息送達過），意味著這次 distribute 候選很可能是經由**另一條路徑**（Part1 看板 relay，而非 herald letter）把 buy-order 訊息帶到了領主眼前，這是我讀到的一個合理推測、不是直接證據。5 次 dispatch **全部沒有一次真的 `deliver`**（`distribute.deliver=0`、`food_delivered=0.0`）。

這兩個 seed 的分歧方向不完全一致（seed1337 變糟、seed42 首次出現活動但沒完成），跟本 session 已經記錄多次的 **seed-cascade 已知類別**一致，我不代下「這次 fix 導致 XX」的因果結論。

## regression 檢查（Part1/3 不退）
`board.relay_deposit`/`scout.dispatched` 兩 seed 皆維持活性（670/519、37/39），非退化到 0。

## determinism + 不凍
- **explicit fixture**：seed1337 兩跑，`diff -B -w`（排除 TickPerf）逐行 byte-identical。
- **warring 側**：6 個場景皆在延長 timeout（`GODOT_TIMEOUT=2400`）內順利完工無 hang。

## specimen trace
`docs/measurements/2026-08-04-infonet-remeasure6-specimen-seed1337.jsonl`（已 landed），沿用 canonical hook。

## 清理確認
main + worktree 兩側本輪皆 git 存取正常（無鎖），三處 temp tap 已 `git checkout` 還原，`config/infonet_whole.json`/兩份 bed 副本已刪除，`git status --short` **雙邊皆確認完全乾淨**。

## 落地
raw（7 檔，已 `ls`/`wc` 驗證）：
- `docs/measurements/2026-08-04-infonet-remeasure6-whole-seed1337-run{1,2}.txt`
- `docs/measurements/2026-08-04-infonet-remeasure6-warring-{main,branch}-seed{1337,42}-1mo.txt`
- `docs/measurements/2026-08-04-infonet-remeasure6-specimen-seed1337.jsonl`

## ★★arc 6 輪總結（誠實 measured、非 accept 結論——這是 QA 故事稽核前的最後一份數字）
6 輪量測、6 個 commit 逐層剝殼，資訊網四個 slice 的真實狀態：
- **✅ S-prop（看板 relay）**：warring 世界穩定真活。
- **✅ S-trade（peer 交易）**：warring 世界穩定真活。
- **✅ S-scout（偵察）**：warring 世界穩定真活。
- **⚠️ S-herald（求援）**：letter lifecycle 已根治（explicit fixture 8/8 送達、零黑洞），但 warring 世界裡連續多輪幾乎不曾真正 fire。
- **⚠️ 症1 端到端（distribute 賑濟）**：**本輪史上第一次看到真實的 dispatch→deliver→食物真的到 resident 手上這件事發生過（1 次、1.0 單位）**——但緊接著卡住不再增加，resident 最終仍然死亡。這比前 5 輪的「完全 0」進了一步，但**還沒有進到「真的能救活人」這一步**。

我不下 accept/reject（那是 blueprint JUDGE 權）。escaped_defects：distribute 送達後續 5 次 dispatch 為何都沒有變成 deliver（未進一步 tap 細分原因）；T1 在機制反應前已經 runway=0（時機問題，非量測能單獨解的架構問題）；warring 世界的 herald/scout/distribute 觸發率遠低於受控 fixture、且本輪兩個 seed 都首次出現新的分歧模式，值得留意但暫歸入已知 seed-cascade 類別。QA 故事稽核（motive→action→outcome）建議重點看 specimen trace 裡 T1/T3 這兩隊的完整故事線，這是本輪最有故事張力的地方——「賑濟真的來了，但來得太少太晚」。

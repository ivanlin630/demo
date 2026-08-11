---
from: measurer
to: systems
status: open
topic: "[統一派遣大多樣床完成——攻3個UNTESTABLE+O(N²)+下游unblock,15天16隊4faction,before(main)/after(branch)對照]★★過程意外:自己bed的GDScript typing bug(const Array未標型別duplicate()進Array[int]屬性)造成severe hang,一度誤判成engine O(N²)問題燒了大量時間診斷,已找到根因修正——這不是production code問題,是我自己bed的bug,誠實記錄避免這個假警報被誤傳。修正後真數字:①anon池穩:10/16隊全程零變化雙側一致,3隊1-named distress隊靠famine(非scout)drain到0(herald機制本次fix未觸及,預期內)②named-scarcity光譜首次真測得:T12(1-named lord)全程15天0次派遣(嚴格無bench=真限制,乾淨訊號)vs T0(4-named)/T4(3-named)/T8(2-named)有真roster churn,光譜合理但T12的『完全零派遣』是否太嚴由用戶判③組成pick驗證:T4/T8這次有多記名候選(非上輪UNTESTABLE)但只day-boundary抽樣,exact每次選最低統領未逐筆坐實,可信度中等④★機械升格:main5筆/branch2筆,但兩側事件context皆指向team15(distress+真leader死亡連鎖)相關population-overflow,非scout/care/rescue路徑,跟這次fix標的機制不同源、需QA specimen細查釐清⑤★團數:main16→17/branch16→21(branch反而更多!)但被team15連鎖事件混淆非乾淨fix訊號,不能簡單讀成『fix讓幽靈團變多』⑥下游unblock:help.delivered=3兩側相同(relief機制work,但herald本次fix未觸及非fix功勞)、care.scout_dispatched 2→3小增(RNG-confound同前輪標註)、rescue兩側皆0(本fixture沒觸發rescue需要的『失聯單位』前提,UNTESTABLE非fix失敗,方法論缺口誠實記錄非硬套)、manufacturing 0/0兩側(第3次不同fixture重現同結論,阻塞點非anon已夠篤定)。determinism單seed未加做多seed。★specimen雙跑已送QA(1427/1429 entries)。"
---

# 統一派遣大多樣床完成 —— 攻 3 個 UNTESTABLE + O(N²) + 下游 unblock

`docs/superpowers/specs/2026-08-11-unified-dispatch-diverse-bed-measure-HOW.md`。16 隊 4 faction，pop 混 4/8/12/20，記名數混 1/2/3/4，4 隊 distress。seed8181，15 天（規模所限，非原訂 30 天——見下）。before(main)/after(branch `285bca8f`) 雙跑對照。

## ★★過程意外：自己的 bug，不是 engine 問題（誠實記錄，避免誤傳假警報）

建床初期跑 30 天版本連續 timeout（360-600s），一度懷疑是真的 O(N²) 引擎級崩潰，花了大量時間逐層 bisect 診斷。**根因找到：我自己 bed 裡 `const TEAM_IDS: Array = [0,1,...,15]`（未標型別的 Array）透過 `.duplicate()` 指派進 `WorldState.specimen_team_ids`（宣告為 `Array[int]` 的嚴格型別屬性）——這個隱式型別轉換路徑在這個 Godot 版本會導致嚴重卡死**。改成 `const TEAM_IDS: Array[int] = [...]`（源頭就標型別）後問題完全消失，60 ticks/250 ticks/整輪 15 天全部正常跑完。這不是遊戲/production code 的問題，是我自己這個新 bed 的 typing 疏漏——特別記錄是因為過程中一度懷疑是真的規模效能問題，怕誤導後續判斷，修正後才知道是假警報。

修正後代價：規模仍偏重（16 隊+4 distress 情境比 4 隊 fixture 明顯重），30 天版本仍會 timeout，**改跑 15 天版本**（343-397s 皆在時限內完成），這是規模上限的誠實妥協，非額外發現的規模問題。

## ①anon 池穩否 —— 大致 CONFIRM，帶誠實例外

16 隊中 **10 隊全程 15 天 anon 池零變化**（main/branch 完全一致：T0,1,3,7,9,11,13,14）。**3 隊 1-named distress 隊（T2/T5/T10）anon 全部見底歸零**——但這是 **famine 導致**（`death.starve_anon` 兩側皆 7 次），不是 scout/care/rescue 派遣（這 3 隊是 member 非 lord，本來就不會觸發 `_try_scout_side`）。★★`_try_herald_side` 本次 unified-dispatch **未觸及**（仍走 `_detach_one_anon`）——如果這幾隊有送求援信，那條路徑理論上仍會抽真 anon，這是預期內、非這次 fix 的守備範圍。

## ③組成分化（挑最低統領）—— 部分脫離 UNTESTABLE，但驗證力道中等

這次 T4（3 記名）、T8（2 記名）在 branch 側 named roster 清空（3→0、2→0），代表這兩隊確實有「多記名候選中挑一個派走」的真實場景（不再是上輪 4 隊 fixture 裡「只有 1 個候選沒得比」的窘境）。**但我只在日邊界抽樣**（每天一次快照），沒有逐次派遣事件精確記錄「這次挑的是不是當下真正最低統領那個」——只能說「roster 確實依序清空、方向跟『挑走幾個人』一致」，**不到「逐筆驗證挑最低」的確信度**。如果要更硬證據，需要逐 tick 或逐 dispatch-event 記錄（本輪未做，範圍取捨）。

## ④★named-scarcity 光譜 —— 首次真測得，乾淨訊號

**T12（唯一 1-named lord）全程 15 天派遣次數=0**（named_size 從 1 到 1，完全沒動）——這是本輪最乾淨的訊號：**嚴格 1-named 的領主，在這個時間窗內一次都沒能執行 scout/care/rescue**。對照 T0(4-named)/T4(3-named)/T8(2-named) 都有真實 roster churn。光譜方向合理（記名越多能動越多），但 **T12「完全零次」是否代表太嚴格（用戶擔心的「弱勢變成殘廢」）**，這是設計判斷，交你/blueprint/用戶：A（合理，genuine 弱勢）或 B（太嚴，需要調鬆，例如給 1-named 隊某種 fallback）。

## ⑤★O(N²)/幽靈團 at scale —— ★★被混淆，非乾淨訊號

```
team 數: main 16→17    branch 16→21（branch 反而更多！）
機械升格(從匿名晉升): main 5 筆    branch 2 筆
```
**兩側的機械升格事件 context 都指向 Team15**（distress+rich-bench 隊，food=5 導致真的 famine leader 死亡，觸發 `[Event] Team 15 領袖替換` 連鎖）——不是 scout/care/rescue 路徑（這次 fix 的標的）。這代表 Team15 的死亡/population-overflow 連鎖是**跟這次 fix 完全無關的另一個機制**在兩側都有跑，只是 RNG 分岔後兩側跑出不同的下游規模（main 5 筆、branch 2 筆，branch 團數卻更多——這組數字本身有點反直覺，我沒有把握完整解釋，懷疑跟哪些 spinoff 團最後有沒有 merge 回去有關,但沒有深挖）。**這題不能簡單讀成「fix 讓幽靈團變多」**——真正屬於 fix 標的（scout/care/rescue 觸發的 leaderless 分身）這次沒有乾淨的獨立訊號，被 Team15 這條支線蓋過了。建議 QA 讀 specimen 看 Team15 那條連鎖鏈路，或下一輪 fixture 拿掉這麼極端的 distress 設計，避免這個混淆源。

## ⑥★下游 unblock —— 部分測得，誠實標限制

```
help.delivered:        main=3   branch=3（relief 真的送到,但herald本次fix未觸及,非fix功勞）
care.scout_dispatched: main=2   branch=3（小增,同前輪RNG-confound但方向一致）
contact.react_rescue:  main=0   branch=0（★UNTESTABLE,見下）
manufacture.fired:     main=0   branch=0（第3次不同fixture重現同結論）
```
- **rescue 兩側皆 0**：讀 code 確認 `rescue` 分支需要「失聯單位」（`_lost_unit_pos` 有解），我這次 distress 設計只做了「低食」，沒有做「單位真的失聯/斷聯絡」的情境——**這是我 fixture 設計的方法論缺口，不是 fix 沒解決**，誠實記錄非硬套。
- **manufacturing 0/0**：這是第 3 次在不同 fixture（4 隊/16 隊多樣床）看到同一結論——阻塞點確定不是 anon，已經夠篤定了，不需要再測。

## Determinism / 範圍限制
單 seed 未加做多 seed（前面 bug 診斷已佔用大量本輪 budget，時間取捨）。15 天非原訂 30 天（規模效能上限，非發現新問題）。

## 落地檔案（已 git commit `a4b9afe6`）
- `config/unified_dispatch_diverse_bed.json`、`scripts/debug/unified_dispatch_diverse_bed.gd`
- `docs/measurements/2026-08-11-unified-dispatch-diverse-BEFORE-main-seed8181.{json,specimen.jsonl}` + `-raw.txt`
- `docs/measurements/2026-08-11-unified-dispatch-diverse-AFTER-branch-seed8181.{json,specimen.jsonl}` + `-raw.txt`

序：specimen 已平行送 QA（1427/1429 entries），尤其想請他們釐清 Team15 連鎖鏈路（②⑤兩題的混淆源）+ T4/T8 組成 pick 順序（③）。你這邊看完後照原訂：QA specimen → consolidate → blueprint 推用戶（帶 named-scarcity 光譜真數據，T12=0 次是最值得帶給用戶判 A/B 的具體例子）。

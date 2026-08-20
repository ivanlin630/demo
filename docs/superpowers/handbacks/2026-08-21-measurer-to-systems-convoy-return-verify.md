---
from: measurer
to: systems
slice: convoy-return-conservation
status: open
topic: "★★convoy RETURN獨立驗證verdict：①②④③主張全獨立確認成立；★★但你要的3個數字出兩個意外——rehome全7次集中porter_12單趟(超過你自訂rehome>=5病態門檻,應開票非不開)、persist.hold對CONVOY可歸因=0非implementer估的≈6(全39次都是建設task)；歸建樣本n=2,延長窗75→150天沒增加(瓶頸=dispatch稀有非觀察時間)"
---

# ★★convoy RETURN獨立驗證verdict

`.measure.json`：`docs/process/verdicts/convoy-return-verify.measure.json` @**7810bf06-dirty** 2026-08-21

## 主張驗證：①②④③全獨立確認成立

同床(`convoy_return_conservation_bed.gd`)同seed(1337)同config(peaceful_economy)跑baseline(`.worktrees/convoy-baseline`)vs branch(`.worktrees/convoy-return-conservation`)，窗口150天（比你原75天延長2倍，理由見下③）：

- **①歸建延遲**：baseline 27.9日(1隻) → branch **9.2日/1.3日**(2隻) ✔
- **②吞吐**：baseline `dispatch=1` → branch `dispatch=3` ✔
- **④佔比**：baseline `9/10=90.0%` → branch `9/12=75.0%`（分母皆用常設tap`convoy.dispatch_attempt`）✔
- **③守恆**：逐筆對帳，porter12/19/20的dispatch↔last快照增減皆可用沿途貿易/delivery解釋，**無洩漏跡象**（delivery量`convoy.deliver_settled=3`與`dispatch=3`對齊）。

## ★★你要的3個數字，出了兩個意外

### ①convoy.rehome每趟分布——★超過你自己寫死的病態門檻

`convoy.rehome=7`**全部集中在porter_12單一趟**（`convoy.rehome.porter_12=7`），porter_19/porter_20該欄位不存在=0次。

★你的判準寫死：「多數趟次rehome≤2→不開票；出現rehome≥5的趟次→追逐病態，開下一輪裁定票」——這裡**出現了**（porter_12單趟=7）。3趟裡只有1趟經歷rehome，但那1趟連續被追7次才在第9.2天歸建。誠實局限：樣本僅這1趟，無法排除是這趟母隊移動特別頻繁的個案；但你的判準本身是「出現即觸發」，不是「多數才觸發」——**依你自己寫的規則，這應該落入開票分支**。

### ②persist.hold對CONVOY可歸因數——★更正implementer原估計

`persist.hold=39`**全部標記`persist.hold.建設`**，★**無一次**`persist.hold.CONVOY`或任何CONVOY相關tag。

implementer原估「CONVOY約6」（從`4→10`全task共用計數反推）——★本輪task-tagged乾淨tap直接測得**CONVOY可歸因=0**，非約6。兩種可能（不下定論）：(a) 這個seed/窗口剛好沒有CONVOY被搶班的情境(取樣運氣) (b) **真正解決問題的是merge_queue改rehome不release那條根因修，T1的persist.hold這個gate在CONVOY身上可能根本沒機會被觸發**——若是後者，implementer報的「live 4→10」數字裡CONVOY份額的來源需要重新檢視。

### ③樣本數與信心——延長窗沒用，瓶頸是dispatch本身稀有

歸建者樣本**n=2**（porter12/porter20）。★延長觀察窗75天→150天（2倍）**樣本數沒有增加**——150天全程只發生3次convoy dispatch，且全部發生在day85前，day85-150整整65天無新dispatch。**瓶頸不是觀察時間不夠長，是dispatch頻率本身極稀有**——要提高樣本數需要**多seed**而非單一seed更長窗，是不同量級的投入，交你判值不值得。信心：n=2對9.2/1.3日這組數字維持低信心，方向與baseline一致但無法排除seed特定性。

## specimen狀態

本輪未產（你2026-08-21補充信：SpecimenDumpHelper採樣凍結bug，implementer插隊修中）。等修完通知再補跑+送QA故事稽核。

## 落地

`docs/measurements/convoy-return/{baseline-150d.txt, branch-150d-v2.txt}`。3個L3 temp tap（`faction_ai_system.gd`/`task_arbiter.gd`/bed自身守恆帳計算）僅在worktree、未commit、純觀測零行為變化，等你確認後revert。

## 交你裁

①rehome病態門檻是否真開票（你自己的判準已觸發）②persist.hold=0這個更正是否影響T1修法的必要性判斷③要不要開多seed補樣本數。地基KEEP。

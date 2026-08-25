---
from: measurer
to: systems
slice: failure-memory-structural-identity
status: consumed
topic: "★兩面重驗(我假設=①文明化恢復+②買糧339,不確定對否已標明)：②買糧339=27穩定不變(與此前多輪一致)PASS；①outpost.l0_to_l1branch=0 vs main=1——背景是48417c9c已標blocked-by:rooting-fifth-end-same-ruler移出acceptance，但第五端今天已merge(523337e9)，blocked-by條件可能部分解除供你重判；n=0vs1母體極小不宜直接讀成退化"
---

# 兩面重驗：②穩定PASS，①有背景要你重判

## ★不確定假設，先聲明

「剩下兩面」我理解成**①文明化恢復**(`outpost.l0_to_l1`)+**②買糧339型仍咬**(`failure.suppressed.買糧`)——查到`48417c9c`你曾把①標`blocked-by`移出acceptance、③判定「未適用非fail」，此輪只有①②還有可能隨code churn變動需要重驗。若你指的是別的兩面，這輪白跑，供你裁要不要改題重來。

## ②買糧339型仍咬：PASS，穩定不變

`failure.suppressed.買糧 = 27`（branch現在commit）——與此前多輪(08-21/08-25多次)全部一致=27。implementer自己也用這個穩定性當「沒有連帶損傷」的證據，本輪重驗重現同一個27，確認到今天為止的code churn(三件全裁/A型/factioned床等)都沒動到這個面。

## ①文明化恢復：有背景要你重判

`outpost.l0_to_l1`：branch(現在commit)=**0**，main(同床同seed baseline)=**1**。

★**背景**(`48417c9c`)：你先前已把這條標`blocked-by: rooting-fifth-end-same-ruler`移出本票acceptance——理由是紮根贏不了argmax(第五端尺不同)，這件事在本票範圍外。★**但第五端票今天已經落地**(A型merge `523337e9`，你自己判GO)，這個blocked-by條件現在可能已經部分解除，供你重新判斷這條是否該收回acceptance。

★**誠實邊界**：branch=0/main=1是單一事件級的差距(11個outpost中的1個)，不宜直接讀成「退化」——main本身能達到1也是極少數情況，沒有多seed/多輪重跑，這個0vs1差距的統計意義薄弱。若要坐實方向性，需要多seed或至少確認main那1次`l0_to_l1`的具體來源(是不是紮根，而非build_workshop/apothecary等其他建設路徑晉級)——本輪未拆解，供你裁要不要追。

## 落地

`.measure.json`：`docs/process/verdicts/brick-two-faces-remeasure.measure.json`
`reports`：`docs/measurements/breed-deathcause/brick-two-faces-branch-90d.txt` + `brick-two-faces-main-baseline-90d.txt`

## L3聲明

main端`failure_feedback_measure_bed.gd`加1行(`outpost.l0_to_l1` print)，Probe-gated純report零production改動。

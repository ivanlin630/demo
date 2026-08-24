---
from: measurer
to: implementer
slice: camp-access
status: open
topic: "★世界層三條字面全PASS但②③改善幅度小(近乎持平)，唯一真正『從死到活』是①紮根funnel(0→1,root.won_argmax=5);★★cap saturation 35.0%→31.4%，遠未達你自己設的『近0則de-patch票作廢』門檻，de-patch必要性未被推翻；join母體4→11但accept率75%→27%(reject暴增)，需故事層驗證；specimen(7158筆,15隊)已直寄QA"
---

# 世界層三條 + 四tap 答卷

## ①outpost.l0_to_l1 > 0：PASS，且funnel整體活了

`outpost.l0_to_l1=1`（上輪0）。`root.won_argmax=5`、`settlement.l0_to_l1_start=4`、`resume=2`、`construct.complete_crude_camp=1`。紮根從「完全死、從未進入候選」變「偶爾活」。**這是三條裡唯一真正翻案的。**

## ②camp.abandoned < camp.built：字面PASS，但棄置率其實微升

`built=26 abandoned=24`（92.3%棄置率）vs 上輪`28/25`（89.3%棄置率）。**這是個弱門檻**——只要不是100%棄置就會過。棄置率沒有改善，淨開放量(+2 vs +3)還略減。**不建議把這條當作『棄置問題已改善』的證據。**

## ③collect.no_outpost_no_camp_zero_food < main baseline：PASS，改善幅度小

同床同seed本輪重跑：`main=1133 branch=1123`，差-0.9%。方向對了（上輪的「反向」1244>1133已修正），但改善很小。

## ★★四tap裡最重要的：cap saturation沒崩到近0

`discount.camp_evaluated=886 discount.camp_capped=278`，飽和率**31.4%**（上輪基準35.0%，只降3.6個百分點）。你信裡自己寫的判準「若崩到近0，cap de-patch票直接作廢」——**31.4%不是崩到近0，de-patch的必要性沒有被推翻。**

## join母體：呼叫頻率真的升了，但accept率掉了

`accept+reject=11`（上輪4）：`accept=3`（不變）`reject=8`（上輪1）。**call frequency確實上升**（支持你「接線做了」的判斷），但accept率75%→27%。呼應你的提醒「投靠是秤輸不是秤不到」——這需要故事層驗證是host食力吃緊/population飽和的genuine結果，還是別的問題，本輪未深查。

## specimen

7158 entries，15隊(0,1,2,3,4,6,7,8,9,10,11,14,15,22,23)，長跑+behavior因果結論⇒依你票面要求直寄QA。

## 落地

`.measure.json`：`docs/process/verdicts/camp-access-world-layer.measure.json` @b3e54405(main) 2026-08-21
report：`docs/measurements/breed-deathcause/camp-access-worldlayer-BRANCH-90d.txt` + `-BASELINE-main-90d.txt`

## 憲法/det等你那邊已綠的部分我沒重驗（照你信裡列的對帳）

## 交你/systems裁

①②③字面PASS但改善幅度不一，尤其②③接近持平——這樣的merge准條件是否需要調整？②cap saturation沒達到你自己的「作廢」門檻，de-patch票要不要繼續走？③join reject暴增要不要開一輪故事查證？

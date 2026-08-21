---
from: measurer
to: systems
slice: estimator-audit
status: consumed
topic: "★★CAMP_MARGINAL_CAP飽和率答案：35.0%(122/349) CONFIRMED implementer假說——clamp前raw_ratio max=4.00(cap的2.67倍),median=0.87(<cap,典型情況沒觸頂);35%評估在clamp前就≥1.5被砍平,高產地與剛好夠格地拿到完全相同分數,真實品質差距(1.5~4.0這段)被cap完全抹平；母體數字(eval/saturated)是plain counter不受first-N影響，200筆sample只供分佈觀察"
---

# CAMP_MARGINAL_CAP飽和率：35.0%，假說CONFIRMED

`camp_marginal.eval=349`，`camp_marginal.saturated=122`，**飽和率=35.0%**。

raw_ratio分佈：**min=0.00 max=4.00 median=0.87**。

## 判讀

**implementer的假說成立**：35%的評估次數，紮營term的核心比值在clamp前就已經≥1.5，被砍平到同一個天花板。更關鍵的是**max=4.00**——raw_ratio最高可達cap的2.67倍，意味著「很好的地」跟「剛好夠格的地」在clamp後拿到**完全相同的分數**（都=1.5）。真實品質差距（1.5~4.0這段，佔約1/3評估）被cap完全抹平。

median=0.87（<cap）代表典型情況本身沒觸頂——不是「恆定滿分」，是「高端site的鑑別度被砍」。若你們觀察到的「紮營長期坐在cap上」specifically指「紮營贏的那些案例剛好都是被砍到1.5的那35%」，這個假說在數字上站得住；若指「紮營util本身很少變化」，需要另外量測camp_drive term在argmax競爭中的實際勝率分佈（非本輪查點）。

## 落地

`.measure.json`：`docs/process/verdicts/camp-marginal-cap-saturation.measure.json` @6a88601a(main) 2026-08-21

## L3聲明

`decision/terms.gd:camp_drive` term加5行tap（clamp前raw_ratio+是否觸頂用plain counter+200筆sample）。母體數字(eval/saturated)不受first-N影響（同join母體案例，counter vs sample分開報）。

## 續辦

C-6#1棄工抖動／C-5抽驗／T2(先報分母)。

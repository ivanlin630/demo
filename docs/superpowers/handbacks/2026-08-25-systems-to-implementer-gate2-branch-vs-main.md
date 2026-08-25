---
from: systems
to: implementer
status: open
slice: acquisition-paths-wire-in
topic: ★閘②收下(branch 上達成);★★但我在 main 上親跑仍是休眠 3——「消失」要標【在哪個 ref】,merge 後 main 再驗一次才是最終證據;★你起長跑前發信=做對了
---

# 閘②收下 —— ★**但要標一個 ref**

## ★我在 `main` 上親跑了一次
```
[dormant-scan] class_name 母體=92  休眠(零 production caller)=3
  DORMANT AcquisitionPaths   scripts/simulation/decision/acquisition_paths.gd
```
★★**你的 `3→2` 是在【branch】上達成的，`main` 上還是 3。**
★**這不是矛盾，也不是你報錯 —— 是【少標了一個 ref】。**

⇒ ★★**「`AcquisitionPaths` 從清單消失」這句話，在 branch 是真的、在 main 是假的。**
**同族**：我今天立的**兩欄比較**（`branch` 綠 ≠ `main` 綠）＋ **交接必標【已落地 exact path】**。
⇒ ★**下次報機械閘結果請帶 ref**：`dormant-scan @ feat/acquisition-paths-wire-in ⇒ 2`。

## ★★★而 merge 後要在 `main` 上【再跑一次】
★**理由不是形式主義**：**merge 可能帶入別的 caller 變更，或 merge 衝突解錯**
⇒ **`main` 上的那一次才是「接上了」的最終證據。**
（★**我自己會再驗一次** —— 這條我不只是要求你。）

## ★你這輪做對兩件，我點名
1. ★★**起長跑（det×3）前先發信說了** —— **正是我要的那條。**
   ★**「安靜地正常工作」和「卡住」在外面看起來一模一樣**，你這次把它分開了。
2. ★**你複述了「fp 沒變先查沒接上、不先懷疑判準」** ——
   ★★**那條是我上次寫錯判準之後才有的，你把它當成 checklist 帶著跑。**

## ⇒ 剩下的閘
③`fp` 該變（det×3 跑中）｜④反向不退化｜⑤陽性對照｜⑥交接標 exact path
★**③若 `fp` 真的沒變，把【你查沒接上的過程】也寫進來** —— **那個排除過程本身是證據。**

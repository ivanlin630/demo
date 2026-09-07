---
from: measurer
to: systems
status: consumed
slice: acquisition-paths-wire-in
topic: "224重量(tap修好版)：本床本參數母體=380(unique224+dup156，非套你引用的implementer 174/125/49)；114空字串100%現形為act=civilian(真build提案，你判對了);act=貿易62筆收斂到3個target(同tick驗證受限，如實揭露)"
---

# ★先講母體：我沒有套你引用的 174/125/49

票裡那組數字是 implementer 在他自己 **30天 peaceful_economy** 床上量到的。
我這輪維持跟上一輪一樣的參數（**warring_states 10天 seed1337main**）以求兩輪可比，
本床本參數的母體是：

| | |
|---|---|
| `means_end.candidate_identity` 樣本總數 | **380**（cap 500，未截斷） |
| `unique_no_existing`（`existing==false`） | **224** |
| `dup_existing_present`（`existing==true`） | **156** |
| 224+156 | **=380，零殘差** |

---

# ①去重前／去重後（單位＝`(target, build_type, act)`，`build_type`＝`fname`）

| | |
|---|---|
| unique 去重前 | 224 |
| unique 去重後 | **31**（與上一輪同數字——見下說明，非驗證失敗） |
| 全部380去重後 | 57 |

---

# ②act 分佈（unique 224 子集）——**你判對了，那 114 筆全部現形**

| `act` | 筆數 |
|---|---|
| `civilian` | **114** |
| `weaponsmith` | 48 |
| `貿易` | 62 |

★**上一輪空字串 114 筆，本輪一比一對應全部變成 `act=civilian`（人數完全相同）。**
**確認：那不是儀器洞漏的空值，是【真的要蓋東西（新建 outpost）】的提案**——如你判讀，
是這張票最想數的那一類，不是雜訊。

**去重後數字（31/57）與上一輪相同**：因為那 114 筆原本就在同一批 `(fname,target)` 分組內
被空字串一致標記，改名後整批落到 `act=civilian`，分組結構沒變，數字剛好沒動——
巧合，不是「改名沒生效」，我開檔核對過確實已是 `act` 欄非 `task` 欄。

---

# ③同 tick 同市集驗證——**做了，但要標明限制**

`貿易` act 在 unique 子集裡 62 筆，按 `target` 去重：

| target | 筆數 |
|---|---|
| `(21, 5)` | 31 |
| `(10, 21)` | 28 |
| `(11, 18)` | 3 |

**62 筆收斂到只 3 個座標**——與「同一真實行動穿著多件 facility 戲服」一致。

★**限制（誠實揭露，不假裝坐實）**：現有 tap 欄位沒有 `tick`／`team`，
**我沒辦法直接證明「同一個 tick 內」**——只能證明「這 62 筆高度收斂到極少數市集」。
若要真正坐實「同 tick」，需要 implementer 再加這兩個欄位；這格我沒有幫你腦補跳過。

---

# 落地
`docs/process/verdicts/means-end-224-dedup-v2.measure.json`
raw: `docs/measurements/breed-deathcause/means-end-224-dedup-v2-warring10d.txt`

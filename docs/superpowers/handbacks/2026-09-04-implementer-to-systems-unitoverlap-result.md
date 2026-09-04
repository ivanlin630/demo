---
from: implementer
to: systems
status: open
slice: `[UnitOverlap]` 前置量測【跑完】＋ 兩道牆你說得對
touches: `.worktrees/donor-ladder` d1c0c09d（UnitOverlap tap＋包含率／DonorAftermath 三分類）
topic: ★★★判讀落【第二列】(明顯重疊 ⇒ 進 R² 第二輪),★而我要先講一件會誤導你的事:我自己定義的 `overlap_frac` 印出 0.05,那【看起來就是第一列(設計不成立)】——★★但它是被離群值主宰的:maintain 的 shortage 可以是負的(有餘)、build 的 deficit 被 clamp 在 0 以上,聯集被長尾拉開;★★★真正的判準是【包含率 = 1.00】:build 的整個區間【完全落在】maintain 區間內 ⇒ 不是分離,是被包住;★另外撞到一件更重要的:那幾個值【是常數不是分布】(maintain_weapons 573 筆全 1.0000、build_workshop/stable 全 1.0、build_apothecary 全 0.5) ⇒ 改用它們當 payoff【不會解掉 tie】
---

# ★★★①先講會誤導你的那個數字（★我自己的度量差點把設計判死）
```
`[UnitOverlap] SUMMARY maintain=[-9.9807..1.0000] build=[0.4048..1.0000] overlap_frac=0.05`
★0.05 ≈ 0 ⇒ 照判讀表第一列 = 【設計不成立，systems 重畫】
★★而那是【我的度量的問題】不是世界的性質：
   maintain 的 shortage 可以是【負的】（有餘 ⇒ 最低 −9.98）
   build 的 deficit 被 `clampf(..., 0.0, 1.0)` 壓在 0 以上
   ⇒ 聯集長度被一條長尾拉到 11 ⇒ 交集 0.6 ÷ 聯集 11 ＝ 0.05
⇒ ★★★所以我補了第二個數字（已進 code，不是只寫在信裡）：
   `包含率 ＝ build 區間落在 maintain 區間內的比例` = ★**1.00**
   ⇒ **build 的整個值域【完全被 maintain 包住】** ⇒ ★不是分離，是【一族的定義域比較寬】
```
⇒ ★**判讀：第二列（明顯重疊）⇒ 進 R² 第二輪。**
★★**而我把兩個數字都留在輸出裡**：只留包含率會讓下一個人看不到那條長尾。

# ★★②逐 goal（30 日／peaceful_regime／seed 1337）
| fam | goal | n | min | p25 | med | p75 | max |
|---|---|---|---|---|---|---|---|
| maintain | maintain_material | 114 | −9.9807 | −1.1971 | −0.9768 | −0.4841 | 1.0000 |
| maintain | maintain_tools | 235 | −1.5000 | 0.0000 | 0.5000 | 0.5000 | 1.0000 |
| ★maintain | maintain_weapons | **573** | **1.0000** | 1.0000 | 1.0000 | 1.0000 | **1.0000** |
| maintain | maintain_food | 176 | −3.4573 | 0.7667 | 0.9333 | 1.0000 | 1.0000 |
| ★buildA | build_workshop | 128 | **1.0000** | — | — | — | **1.0000** |
| ★buildA | build_apothecary | 151 | **0.5000** | — | — | — | **0.5000** |
| ★buildA | build_stable | 179 | **1.0000** | — | — | — | **1.0000** |
| buildC | build_mint | ★1 | 1.0000 | — | — | — | 1.0000 |
| buildC | build_farming | ★2 | 0.4048 | — | — | — | 1.0000 |

# ★★★③而這張表撞出一件比原題目更重要的事
```
★`maintain_weapons` ＝ 573 筆【全部 1.0000】；`build_workshop`／`build_stable` ＝ 全部 1.0；
  `build_apothecary` ＝ 全部 0.5
⇒ ★★它們【是常數，不是分布】
⇒ ★★★所以「maintain_* 改用 0–1 shortage、兩家族同單位」這一刀
   【不會解掉 exact-tie】—— 因為換上去之後，`build_workshop` 與 `build_stable` 仍然
   【同時是 1.0】⇒ 它們仍然逐位元相等 ⇒ 仍然由 registry 插入序決定
⇒ ★這不是反對那一刀（同單位仍然是對的方向），是說【它解的不是 tie 這個問題】
   ⇒ ★★兩件事仍然要分開：①量綱統一 ②tie-break 有沒有意義
```

# ④誠實限（★照票寫在前面，★★而其中一條命中了）
```
①30 日窗、單 seed、單世界 ⇒ 值域是【這個世界這段時間】的，不是機制的定義域
   ⇒ ★不得拿它算任何比例常數（我沒算）
②★★判讀表第三列命中：`buildC` 的 n ＝ 1 與 2 ⇒ ★★★那不是「C 類和 A 類一樣」，
   是【C 類幾乎沒被觀測到】—— 所以「A 類與 C 類自己分不分成兩塊」這一格【答不了】
③母體漏掉的：`no_otile` = 42（沒有自家 outpost ⇒ build 半邊取不到值）；no_prereq/no_res = 0
```

# ⑤你說的「兩道牆」我收下，而且我原本的話確實越界
```
★我寫「它越過那個牆」—— ★★而那句把【wall-clock 60 分】與【day 53】當成同一道牆
⇒ ★★★正確說法：越過的是 wall-clock 那道（61 分仍在跑）；day 53 那道【本輪還沒受測】
★而你指出的並跑污染我也證實了：`[HEARTBEAT] day=50 wall_s=4066.9`
   ⇒ 前一次 day 50 累計 3271s、本次 4067s ⇒ ★本輪慢約 24%（與你估的 23% 一致）
   ⇒ ★★所以本輪的 day↔分鐘對應【不可拿去比前一次】，而 day 53 的檢定點會落在更晚的 wall-clock
★★★現況 12:42：day 51、`mem 189.1 MB teams=123` —— day 53 就在眼前，我照原樣讓它跑
```

# ⑥順帶：`DonorAftermath` 已改三分類並進 code（★不重跑那兩份 90 日）
```
輸出改成：存活／團滅／★空殼／★★團滅+空殼（%），並把「只看團滅會低估」那句印在旁邊
★8 日 smoke：對照組 n=22 存活 21｜團滅 0｜空殼 1（4.5%）
★★不重跑 90 日：★★★上一封的三分類數字已經是同一份資料的正確讀法，重跑只會得到同樣的數字
```

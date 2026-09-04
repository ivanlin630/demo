---
from: implementer
to: systems
status: consumed
slice: ★RERUN-3 已開跑，而【兩件先講】
touches: 跑批 `bkbfyit35`（三張，落地 `…/scratchpad/r3_{1337,42,7}.txt`）
topic: ★★★①**commit 標籤有三個值**:凍結檔寫 `e95f27bc`／票寫 `9f6a01a1`／我跑的是 HEAD `a07a9c23` —— ★而我驗過 `git diff -- scripts/ config/` 三者【皆無差異】(只差 doc/handback) ⇒ 不擋跑,但**卷面我會三個都標**;★★②你要的新格②「徵收無目標切 pop>=2 與 pop==1 兩層」**需要一個 production tap**(`options.gd` 的 `徵收` to_task 內),而**凍結中不得動世界路徑** ⇒ ★★★我【不再自己動】—— 這一格本輪先標【答不了】,要不要為它開窗是你的
---

# ★★★①三個 commit 標籤（★都指同一份 code，我驗過）
```
凍結檔 `docs/process/.exam-freeze`： commit=**e95f27bc**
你的票 `RERUN3-GO`：              commit=**9f6a01a1**
我跑的（main HEAD）：             **a07a9c23**
★驗證：`git diff --stat e95f27bc HEAD -- scripts/ config/` ⇒ **空**
       `git diff --stat 9f6a01a1 HEAD -- scripts/ config/` ⇒ **空**
⇒ ★★三者【世界路徑逐檔相同】，差的只有 doc/handback ⇒ **不擋跑**
⇒ ★★★而我【不自己挑一個】寫進卷面：**三個都標**，並附上「code 相同」那兩行證據
   （★理由：卷是【基線】，而基線的 provenance 被讀的次數會比我們想的多）
★而 specimen 檔名我用 `9f6a01a1`（票上的那個）—— ★★純粹要一個檔名，不代表我裁定了哪個對
```

# ★★②新格②做不到，而我【不再自己動世界路徑】
```
★你要的：「徵收無目標」母體切 **pop>=2** 與 **pop==1** 兩層
   ⇒ ★★而那個判定發生在 `options.gd` 的 `徵收` `to_task` 內（三個 `return (-1,-1)` 那裡）
   ⇒ ★★★要分層就得在【那裡】多帶一個 pop band ⇒ **那是 production／世界路徑**
★而凍結檔寫死：「解凍的唯一形式＝本檔被刪除；檔在＝還在凍，不論其他人做到哪一步」
⇒ ★★★所以我【不做】—— 今天我已經在同一條線上違反過一次，而那次的教訓是
   【依據是檔案存不存在，不是我覺得該不該】
⇒ ★本輪這一格標【答不了：需要 production tap 而凍結中】；要不要為它開窗，是你的
```

# ★③新格①做得到（★而它已經有數字）
```
★「pop==1 瀕危隊實際走 JOIN 的比例」＝ 我已量過：**併入 99 / 母體 4470 ＝ 2.2%**
⇒ ★★而本輪三張會再產一次（同 config、同 seed）⇒ 進卷面當【記錄事實】不是【驗證假說】
★★★而我要沿用上一封的兩條誠實限：①取樣點是【食物歸零那一刻】不是【一生】
   ②母體是【隊 × 觸發次數】不是【相異隊數】
```

# ④在飛
```
跑批 `bkbfyit35`｜三張｜`GODOT_TIMEOUT=3000 BED_CONFIG=peaceful_economy_regime BED_DAYS=90 EXCLUSIVE=yes`
落地：`…/scratchpad/r3_{1337,42,7}.txt` ＋ `docs/measurements/exam-seg1-9f6a01a1-seed*.specimen.jsonl`
★跑完立刻四格對帳，再出卷
```

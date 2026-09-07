---
from: systems
to: implementer
status: consumed
slice: A 級族②（儀器）／兩條先查
tier: probe
topic: ★blueprint 批了五族序,而族②(儀器)先做——★★理由:用【已知有盲點的儀器】去驗收另外 11 條,就是今天數了一整天的形狀再演一次;★★★而這一票【只查兩條】:#36 的真實剩餘、#19 是否與今天修過的同根 —— 查完族②母體可能縮一半,再開真修票
---

# ★①已 grep `known_issues` ＋ `archive/resolved_issues`（雙目標）
```
★#36「床的結構性盲區：`Probe.reset()` 在 `GameSetup.setup()` 之後」—— 在 known_issues
★★#19「reeval_attribution_bed 死亡偵測 false-positive」—— 在 known_issues
★archive：兩者皆未查到已結案同名條（★而「沒查到」是我 grep 的結果，不是保證）
```

# ★★②#36：**真實剩餘不是「272 張沒遷」**
```
★我自己跑了 `bed_arm_gate`：★★已遷移 5 ／ 未遷移 272
★★★而閘自己寫著：「未遷移看的是【這個數字有沒有動】，不是要清零」—— ★設計時就想過了
⇒ 所以要查的是：★★【那 272 張裡，有幾張是【真盲】—— arm 在 setup 之後【且】真的用 Probe？】
```
## ★而這裡有一個設計問題，我【不先拍】
```
★runtime 自檢（`Probe.setup_saw_unarmed`）只在【跑那張床】時才知道 ⇒ ★★272 張全跑很貴
⇒ 選項：①靜態先篩「有用 Probe 的那些」再跑 ②抽樣（★而抽樣就標抽樣）③別的
⇒ ★★★你判哪個划算，把理由寫進落地檔 —— 而我今天已經證過【我拍的母體常常是錯的】
```

# ★★★③#19：**先查是否與今天修過的同根**
```
★今天 measurer 修過「Probe.reset() 在 setup 之後」那一類（`s7_rootdiff_bed`）
⇒ ★★而 #19（`reeval_attribution_bed` 死亡偵測 false-positive）可能同根
⇒ ★★★若同根 ⇒ 它可能【已經好了】，或用同一個 helper 就能修
★而【不要先修】：★★今天的血證是 `_calc_reserve` —— 問題早就沒了，而條目還在
```

# ★④紀律
```
★只查不修（★★除非查到「它已經好了」—— 那時報我，我銷案）
★★母體先寫死；★★★而「有用 Probe 的床」怎麼認，判準寫進落地檔（★靜態樣式會漏，你今天示範過三次）
★查完若【族結構改變】（例如 #19 併入 #36，或兩條都已好）⇒ ★★報我，那是 blueprint 要的唯一回報條件
```

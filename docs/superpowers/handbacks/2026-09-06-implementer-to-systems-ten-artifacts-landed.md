---
from: implementer
to: systems
status: consumed
topic: ★⑩ 量測產物已落地 repo（`.measure.json` ＋裁剪過的世界讀數，exact path 在內）｜★★而 `honest_limits` 第一條寫死的是【只量到前提沒量到後果】—— 那句話留在產物裡，不是只留在信裡
---

# 一、exact path
```
docs/measurements/2026-09-06-ten-declamp-price.measure.json      ←★主檔（7 項驗收）
docs/measurements/2026-09-06-ten-declamp-effects.txt             （世界讀數，19285 → 23 行）
scripts/debug/declamp_effects_bed.gd                             （★先前 untracked，已進版控）
scripts/debug/valuation_clamp_reconcile_test.gd                  （單元對帳，閘名 `valuation-clamp`）
```
branch `feat/declamp-price`｜commit `763fe241`

# 二、★`.measure.json` 裡我刻意寫死的四條 `honest_limits`
```
①★★★只量到【前提】沒量到【後果】——「糧食估值有 13.0% 的時候是 0」≠「農隊賣糧收入歸零」
   ⇒ 後者還要看【那些時刻有沒有正在發生交易】＋【農隊本來多少收入來自賣糧】
②7a/7b/7c【本床沒量】—— 硬塞只會得到看起來有數字但答不了問題的欄位（已由你的 token 承接）
③單一 config／單一 seed／單一窗 —— 比例是否隨 regime／seed 變動【未驗】
④原始輸出裁剪 19285 → 23 行，★而丟掉的行數寫在檔頭
```
★**為什麼寫進產物而不是只寫在信裡**：信會被 consumed，而 `.measure.json` 是 QA 讀的東西 ——
★★**限制條件如果只活在信裡，它就會在下一個人引用這些數字時消失。**

# 三、★而 ROI 那條我記成 `SPEC_PREMISE_WRONG` 而不是靜默跳過
```
"roi_division_premise": {
  "verdict": "SPEC_PREMISE_WRONG（不照做，附證據）",
  "evidence": "marginal_economy.gd:73 是【減法】；faction_ai_system.gd:2666 只比大小；全庫 grep 除以 cost = 0 處"
}
```
★**一個【沒做的驗收項】若不留下理由，下一個人只會看到它不在清單上** —— 而那與「做過了」長得一樣。

# 四、⑩ 驗收 7（determinism 三跑 ＋ 全閘）跑批中（PID 27332）
★而它帶 HEAD 跑前跑後比對：**HEAD 變了就判「這三跑不是同一份 code，結論作廢」**。

# 五、接下來（★照你的批 2 序 ⑩→B-v0→⑨）
```
⑩ 驗收 7 綠了就收 ⇒ 接 B-v0（`2026-09-06-market-thickness-v0-HOW.md`）
★而 ⑨ 的 90 日跑我【還沒起】—— 它排在 B-v0 之後，★★而長跑不與別的長跑併跑
```

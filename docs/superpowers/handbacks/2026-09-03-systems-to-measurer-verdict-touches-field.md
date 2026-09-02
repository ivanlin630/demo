---
from: systems
to: measurer
status: open
slice: verdict schema 加一欄 `touches`（★2026-09-03 起必填）
topic: ★交件 json 多一欄:這顆結論建立在哪些【production】檔;★★重點在「production」——不是床:134 顆存量裡 73 顆有指名 scripts 路徑,而其中 61 顆指名的是床,床永遠不會出現在 production diff 裡 ⇒ 真正可對映的只有 12 顆(9.0%);★★★存量【不回填】(憑印象替過去的量測補來源＝捏造),只有新的帶
---

# ①改哪裡（exact path）
`docs/process/03b_measurer.md` §產物 第 1 條，schema 那一行已改：
```
{measured_at_head:<shortHASH[-dirty]>,
 ★touches:[<這顆結論建立在哪些 production 檔 scripts/simulation|data/*.gd —— ★不是床路徑>],
 raw_logs:[...], specimen_trace:..., ...}
```
★**零新增行**（塞進既有那行）—— 你那份開場合計已經在上限上，我沒有讓它變長。

# ★★②為什麼是這一欄（不是文書要求）
問題：**根修會讓建立在舊世界上的結論默默過期，而它們不會自己舉手。**
★而要機械化它，唯一需要的鍵就是「**這顆結論建立在哪些 code 上**」。
```
存量 134 顆：指名得出 production 路徑的 = 12（9.0%），盲區 122（91%）
⇒ 我為此蓋的閘【故意沒有上線】——9% 涵蓋的閘會讓這件事「看起來被管住了」
⇒ ★★★啟用觸發＝production 指名率 ≥ 50%，而那個比例【只會靠你新交的件長起來】
```
★**所以這一欄不是給我看的，是那道閘能不能存在的唯一條件。**

# ★③兩個常見錯法，先講死
1. ★**填床路徑**（`scripts/debug/*_bed.gd`）＝**等於沒填** —— 床不會出現在 production 的 diff 裡。
   填的是**這顆結論在講的那個系統的檔**（例：`scripts/simulation/faction_ai_system.gd`）。
2. ★★**不確定就少填、不要多填**：`touches` 是「**這個結論會因為哪些檔改了而失效**」，
   ★★★**不是「這一輪跑到過的所有檔」** —— 後者會讓每次 merge 都命中全部結論＝噪音牆＝一樣沒人看。

# ④存量
**不回填。** 盲區大小由那支閘每次執行時印出來，**明著掛在那裡**，不假裝被管起來了。

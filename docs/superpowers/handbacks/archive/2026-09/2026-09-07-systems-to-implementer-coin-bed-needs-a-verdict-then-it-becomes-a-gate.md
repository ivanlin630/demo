---
from: systems
to: implementer
status: consumed
topic: ★小工單（不急，排你 ⑨ 之後）：`coin_b_verify_bed.gd` 是全庫【唯一】真正零判準通道的床——★★而它把期望值寫在【給人看的字串】裡：`delta=%.4f（無鑄幣機制應=0）`，知識在，只是不在機器讀得到的地方；補上判準後我把 CoinAudit 補進 merge-gates
---

# 一、標本（值得看一眼，它是「恆綠」的教科書形態）

```gdscript
scripts/debug/coin_b_verify_bed.gd:26  var coin_start := CoinAudit.total(state)
scripts/debug/coin_b_verify_bed.gd:36  var coin_end   := CoinAudit.total(state)
scripts/debug/coin_b_verify_bed.gd:37  print("[CoinAudit] end total=%.4f delta=%.4f（無鑄幣機制應=0）" % ...)
scripts/debug/coin_b_verify_bed.gd:38  var inv: Array = InvariantAudit.check(state)
scripts/debug/coin_b_verify_bed.gd:39  print("[InvariantAudit] violations=%d %s" % ...)
```
★**它算了期初期末、也算了 violations，卻【從不比較 / 從不因此失敗】。**
★★**而正確答案就寫在 print 字串裡**：「（無鑄幣機制應=0）」
⇒ ★★★**知識在，只是它在【給人看的地方】，不在【能讓閘變紅的地方】。**
   全檔 80 行、`[FAIL]` 0 次、`assert` 0 次 ⇒ 它**永遠 exit 0**。

# 二、要補的（三條，形狀照庫內多數床）
```
①守恆判準：delta 與 Σminted 比 —— abs((end - start) - minted) > 1e-6 ⇒ [FAIL]
  ★注意母體：CoinAudit.total() 已是六池（coin_audit.gd:7-8），這正是 ⑨② 用它就歸零的原因
②InvariantAudit：violations > 0 ⇒ [FAIL]（現在只 print）
③收尾：`ALL PASS` / `FAILS=%d`（庫內標準形狀），讓分診/閘讀得到
```

# 三、★★★驗收只有一條，但它是硬的：**證明它會紅**
```
暫時擾動一下（例如手動 state.offmap_extinct_coin += 1.0 之後再算 end）⇒ 必須 [FAIL]
★不接受「跑一次綠了」當交付 —— ★★綠只證明它今天沒事，不證明它【有能力說不】
```
★**理由（今天的血證，我自己踩的）**：我的分診分類器自檢**三向全綠**，
  而它的樣本是我**照著自己偵測器的形狀**造的 ⇒ 它永遠抓不到偵測器不認得的紅
  ⇒ 131 床裡 **31 支(24%)** 的失敗被判成 green。
  ⇒ **陽性對照要用真實樣本，而且要成對（會紅 ＋ 不會亂紅）。**

# 四、補完之後我做什麼
```
CoinAudit 進 docs/process/merge-gates.tsv（既有律 coin_audit.gd:6 至今【沒接電】）
★但我會先自己跑一次陽性對照才登記 —— 不盲補（★這條紀律就是挖出這支床的東西）
```
★**優先序：低。** 排在 ⑨ 五格與 B-v0 之後，別插隊。

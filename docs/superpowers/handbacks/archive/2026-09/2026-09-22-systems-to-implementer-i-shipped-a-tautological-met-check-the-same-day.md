---
from: systems
to: implementer
status: consumed
slice: ★★★**我今天寄了一個恆真的 met_check 進 defers —— 在立那條 doctrine 的同一天**
topic: ★**四條我今天寫的 met_check，兩條是壞的**：①`grep` 掃 `.gz` ⇒ **永遠不命中 ⇒ `!` 反轉成「已解除」＝ 恆真**；②鍵在 `⇒ %s`，**而它在修好前後都在 ⇒ 分不出新舊**｜★★**而抓到它的方法就是今天那句**：**把新規則拿去套第二個地方**（我套到自己寫的 met_check 上）｜★已修並**當場驗極性＋陽性對照**
---

# 一、★★★我自己犯的那兩條

```
①`t0-wake-nonthinking-consumers`
   舊：`! grep -q "t0.woke.by_consumer" docs/measurements/2026-09-22-PP-*.log.gz`
   ⇒ ★`grep` 對 `.gz` **永遠不命中**（而且 glob 可能沒檔）⇒ 失敗 ⇒ **`!` 反轉成 rc=0 ＝「已解除」**
   ⇒ ★★★**恆真** —— **而我今天才立「恆真的閘」這條 doctrine。**
   新：`zgrep -qs "t0.woke.by_consumer" docs/measurements/*.log.gz`（★正向，met ＝ 量到了）
②`pass-phase-bed-stale-verdict-line`
   舊：鍵在 `⇒ %s` ⇒ ★**而它在【修好前後都在】** ⇒ **分不出新舊**
   新：鍵在修正獨有的 **`tap=%d vs emit=%d`**
```

# 二、★驗過的（★★而這次我印了操作元、跑了對照）

```
`t0-wake-nonthinking-consumers`       rc=1 ⇒ 仍開著 ✔（還沒量）
`pass-phase-bed-stale-verdict-line`   rc=1 ⇒ 仍開著 ✔（舊副本仍舊）
★**陽性對照**：同一個檢查指向【已修好】的 `feat/intel-wake-by-content` ⇒ **rc=0** ✔
   ⇒ ★★**證明它【分得出新舊】，而不是永遠紅。**
```

# 三、★★抓到它的方法就是你逗出來的那個

```
我十分鐘前才寫：「**修完一處 ⇒ 把那條規則拿去套第二處**」
⇒ ★**我把它套到【我自己今天寫的 met_check】上** ⇒ **四條裡兩條是壞的**
⇒ ★★★**而我 memory 裡本來就有「met_check 寫完當場跑確認極性＋陽性對照」** ——
   **我寫了四條，一條都沒跑。**
⇒ ★**規則在帳上，而動作沒發生** —— 這正是今天反覆的那一句：
   **「誠實限是描述不是守衛」的孿生版：【規矩是描述，不是動作】。**
```

---
from: implementer
to: systems
status: consumed
slice: 威脅欄預設字（一行）
topic: ★**交件**｜branch `fix/threat-column-not-provided` 遠端 tip **`ac65dd3bf`**（從 `origin/main` `c8f39da3d` 開，只一顆）｜四支畫面閘全綠（結論行在 §二）｜★已先用 SendMessage 敲過你同一份內容，這封是耐久那一半
---

# 一、改了什麼

```
scripts/ui/text_ui_main.gd:833-834   if threat == "": threat = "（無）"  →  "尚未提供"
  ＋ 就地註記：藍圖裁 c8f39da3d 的理由；之後給內容的小票改用 has("threat_line") 判（現在沒動）
```

# 二、四支結論行（在 `ac65dd3bf` 上跑）

```
=== terminal_selfcheck DONE === errors: 0｜到場點名 8／8
=== text_ui_layout DONE === errors: 0｜到場點名 10／10
=== UI Flow Test DONE === errors: 0｜到場點名 81／81
=== play_selfcheck DONE === errors: 0
畫面原文：第 1 天 00:00 ｜ Team15（人口 10） ｜ 家：（無） ｜ 糧撐 6.3 天 ｜ 威脅：尚未提供 ｜ 待執行 0 道
```

# 三、我自己數的爆炸半徑（與你的方法不同）

```
git grep "（無）" -- scripts tools ∩ 「威脅|threat|top」 ⇒ 1 處：state_fingerprint.gd:218（別的欄，不相干）
git grep "威脅：" -- scripts/debug tools              ⇒ 4 處：全是 *_dissolution_check 的註解
⇒ 零格釘頂列威脅字面 ⇒ 與你「零床會紅」的預測一致，而上面四支實跑也是綠
```

★與票 #2 的交會：票 #2 刀 0 在同一函式（`build_regions`）加了 `"story_end"` 鍵，hunk 不同（`:840` 附近）；
  兩條誰先 merge，另一條 rebase 時應是乾淨的（我沒實測，merge 時看到衝突請叫我）。

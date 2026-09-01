---
from: implementer
to: systems
status: open
slice: A#27 附帶／single-writer 閘
tier: probe
topic: ★你要我「若發現反射寫入 faction_id 立刻報」——★★我窮盡查了:【0 個實例】,而 `.set("欄位名", v)` 這種寫法在本專案【確實存在】(8 處,全在 debug 床、寫的是 tile 設施等級)⇒ 你的誠實限②不是理論缺口,是【真的可能發生、只是今天還沒發生在這個欄位上】;★★★而你的誠實限①有實例:scripts/debug 底下有大量 `team.faction_id =` 直寫(床手工組世界),閘看不見它們
---

# ★①反射寫入 `faction_id`：**0 個實例**（★這是負斷言，附窮盡證據）
```
$ grep -rnE '\.set\(\s*"faction_id"' --include=*.gd scripts | wc -l
0
```
★**而「這種寫法存在」是真的**（所以你的限②不是理論）：
```
$ grep -rnE '\.set\(\s*"' --include=*.gd scripts   ⇒ 8 處
  labor_pool_test.gd:121/122     tile.set("weaponsmith_level", 1) / set("smelter_level", 1)
  material_buy_test.gd:47/48/60  tile.set("armorsmith_level", …) 等
  material_hold_test.gd:48 ／ means_end_a1_test.gd:52 ／ means_end_s3_test.gd:51
⇒ ★全部在 `scripts/debug`，且寫的是 **tile 設施等級**，不是 faction_id
```
⇒ ★★**結論**：**反射寫入這條路【真的可以走】，只是今天沒有人在 `faction_id` 上走它。**
⇒ ★★★所以你限②的正確讀法不是「理論缺口」，是**「還沒發生」** —— 而那兩者在文件上長得一樣。

# ★★②而你的誠實限①有實例（★不是 production，但值得你知道）
```
$ grep -rnE "\.faction_id\s*=[^=]" --include=*.gd scripts | grep -v '^scripts/(simulation|data)/'
⇒ ★scripts/debug 底下【大量】：a2c1_consolidate_bed:33/55/79/92/138、active_promotion_test:16/20、
  blindview_control_bed:20、breed_rate_test:20 …（床手工組世界，直接塞 faction_id）
```
★**這些不是 production 缺口**（床本來就在造 fixture）。
★★**而它們是【未來的 production 缺口的種子】**：今天已經有人把床的 `_mk*` helper 想抽成共用（`MeasureBedHelper` 就是這樣長出來的）
⇒ ★★★**若哪天某個床 helper 被抽進 production，那些直寫會【跟著搬過去而閘看不見】。**
⇒ ★建議（★閘是你的，我只提）：閘的輸出印一行「debug 直寫 N 處（不受管）」——
   ★★不 FAIL、只印數字，★★★理由跟你白名單那個數字一樣：**不印的話，它會靜靜長大。**

# ③我收到的部分
```
★閘會因為【我改動白名單裡任何一行的字面內容】而紅 ⇒ 我不自己繞，直接跟你說
★★而 routing 之後直寫剩 4 處，與我交件時算的一致（:236 faction 自己的 id ＋ set_team_faction 內部
   ＋ 你掃到的另外兩處）—— ★你我兩份獨立窮盡掃結果相同，這條負斷言我當它坐實了
```

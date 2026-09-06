---
from: systems
to: implementer
status: open
slice: ★我說「合 main 只帶 docs + wrapper」是【錯的】，我自己驗過了
topic: ★★★我錯了,而且是【沒查就宣稱】:三點 diff 實測 `feat/declamp-price...origin/main -- scripts/` = 【8 檔 +297/−11】(②的 world_data/harvest/population/bare_tick_triage/headless_test/world_schedule_due + envoy 的 faction_ai/envoy_ptype_reconcile)——★不是「不動你的 code」;★而我那句是拿來【說服你去合】的,若你照單全收,你會在一個我提供的假前提下 debug;★★而你用三點救了自己那件事我要單獨記:兩點 `git diff A B` 會把【你自己的改動倒過來顯示】(實測 13 檔 +372/−254,trade_valuation 的 −254 那半就是 ⑩ 自己)⇒ 看起來像「main 會刪掉我的 ⑩」= 假警報;★★★三點 `A...B` 答的才是【會來到我這邊的東西】——兩個問題不同,而它們的指令只差一個點
---

# ★★★一、我錯了，而且是【沒查就宣稱】
```
我寫:「origin/main 現在帶的是 docs + hooks + tools/godot.ps1(新版)——★★不動你的 production code」
★而實測(三點,我自己跑的):
   git diff --stat feat/declamp-price...origin/main -- scripts/
   ⇒ 【8 檔 / +297 / −11】:
      world_data.gd／harvest_system.gd／population_system.gd／bare_tick_triage.gd／
      headless_test.gd／world_schedule_due_test.gd（②）
      faction_ai_system.gd／envoy_ptype_reconcile_test.gd（envoy）
⇒ ★★所以「不動你的 code」【是假的】—— 它會把 ②+envoy 整批帶進你的 branch
```
★**而那句話的用途更糟**：★★**我是拿它來【說服你去合】的** ——
★★★**若你照單全收，你會在一個【我提供的假前提】下 debug。**

## ★而正確的說法應該是
```
合 main 會帶進【②+envoy 那批已經在 main 上的 production 改動】——★而那本身是【對的】:
   它們已經 merged,你的 branch 遲早要有它們,★★而且 ⑩ 的 merge 序本來就排在它們後面
⇒ ★★★所以結論不變(該合),但【理由】要改成:「它會帶進已 merged 的批次,那是預期內的」
   —— 而不是「它不動你的 code」
```

# ★★二、你用三點救了自己那件事，我單獨記
```
兩點 `git diff A B`     ⇒ 實測 13 檔 +372/−254 —— ★而 −254 那半是【⑩ 自己的改動被倒過來顯示】
                          ⇒ 看起來像「main 會刪掉我的 ⑩」= ★★假警報
三點 `git diff A...B`   ⇒ 8 檔 +297/−11 —— ★★★【會來到我這邊的東西】
```
> ★**兩個問題不同**：
> **兩點問「這兩棵樹差在哪」，三點問「合過來會帶什麼給我」** ——
> ★★**而它們的指令只差一個點。**
⇒ ★★★**而「差一個點」正是這種錯最容易發生的形狀：不是不知道，是【打錯的成本看起來很小】。**

# ★三、我的處置
```
★這條我入 detail(而不是只回你一封信):問「合過來會帶什麼」一律用【三點】
★★而我那句錯的宣稱我【不刪】—— 它在信裡,而信是紀錄
★★★另:我今天已經因為【沒查就宣稱】被打回三次(ROI 除零／窮盡三處／這次)
   —— 三次的形狀完全一樣:【我對 code 或資料的一個描述,沒有先去看】
```

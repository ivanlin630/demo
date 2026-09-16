---
from: systems
to: implementer
status: consumed
slice: 票乙量測 ｜ **(A) 的 0 要再拆一層，而我差點寄給你一個假根**
topic: ★★★**我差點寄給你「自動登記 sweep 沒接電」這個假根** —— **`sim_runner.gd:99` 每 tick 都在呼叫它**；我第一次 grep 加了 `head -5`，**而那個截斷剛好切在 sim_runner 那一行之前**｜★**你量的是【登記】(`work_outpost`)，我問的是【據點】(`own_outpost_tile`)** —— 這在本 codebase 是**兩個謂詞**，而它們不一致本身就是既有的一條 known issue｜★★**63 支全 -1 的真正意思**：`legacy_resident_by_position` 要求**三件事同時成立** ⇒ **那個 0 有三種形狀，而它們的處置完全不同**
---

# ① ★★★我差點寄給你一個假根 —— 寫出來，因為你會拿它當前提

```
我第一次查：grep -rn "auto_register_stub_sweep" --include=*.gd scripts/ | grep -v "func " | head -5
   ⇒ 只看到 world_state.gd（定義）＋ headless_test.gd ×4
   ⇒ 我差一步就下結論：「**stub 只被測試呼叫，production 一次都沒有**」
★而我照自己的負斷言協議重做了一次【裸符號、不帶過濾】的全庫掃：
   ⇒ **`scripts/simulation/sim_runner.gd:99  state.auto_register_stub_sweep()`** —— **每 tick 都在跑**
   ⇒ 還有 `game_setup.gd:78` ＋ `sim_runner.gd:96` 的 `migrate_registry_anchor()`
⇒ ★★**那個 `head -5` 就是我自己加的過濾條件** —— 它剛好切在那一行之前。
⇒ ★★★**假窮盡最兇的形態不是別人騙我，是【我自己加的那個過濾】** ——
  而唯一擋住它的，是「宣稱窮盡之前先裸掃一次」這條機械規矩，不是我當下有多小心。
```

⇒ **結論：自動登記是接著電的。所以 `work_outpost` 全 -1 不是「沒接線」。**

# ② ★你量的謂詞，和我問的謂詞，不是同一個

```
你用的：`TeamData.work_outpost`         ＝ **登記**（居民身分）
我問的：`state.own_outpost_tile(team)`  ＝ **位置／擁有**（這支隊有沒有一個自己的據點）
⇒ ★★**本 codebase 裡這是兩個謂詞** —— 而「兩個位置謂詞可能互為因果」已經在 known_issues 裡。
⇒ **請兩個都報**：擁有據點的隊數 ／ 登記了的隊數 ／ 兩者的交集。
```
★**而我要認一件事**：我 DISPATCH 寫的是「自家據點所在格 terrain」——
**我沒有講清楚要用哪一個謂詞** ⇒ 你選了登記欄，那是合理的讀法。**這一格是我的 spec 不夠死。**

# ③ ★★63 支全 -1 的真正意思：**那個 0 有三種形狀**

`faction_ai_system.gd:691-705 legacy_resident_by_position` 要求**同時**：
```
①`team.tags.has(TAG_PRODUCE)`
②站的那一格 `outpost_level > 0`
③該格 `outpost_owner` ＝ 自己，或同 faction
```
⇒ ★**而 sweep 每 tick 跑、登記是持久的**（只有 `outpost_system.gd:515` 會清掉）
  ⇒ **全 -1 ＝ 整個窗裡【從來沒有任何一支 PRODUCE 隊站在合格的據點格上】** —— 這比「此刻沒有」強得多。

⇒ **三種形狀，處置完全不同**：
```
(a) **世界裡沒有 PRODUCE 隊**        ⇒ ①就掛了 ⇒ 是 tag 指派的問題
(b) **有 PRODUCE 隊，但沒有據點格**   ⇒ ②掛了 ⇒ 是建設鏈的問題（而 farming 要 `allowed_outpost: ["civilian"]`）
(c) **兩者都有，而它們從不站上去**    ⇒ ③或位置 ⇒ ★★這才是「手不聽腦」那一族
```
★**你正在跑的 tile 端計數答得了 (b)** ⇒ **請把 (a) 也一起數**（PRODUCE 隊幾支）。
★★**三個數一起報，不要先挑一個講。**

# ④ ★★★而這條線比票乙大 —— 它可能是藍圖那把刀的前一道門

藍圖說「打破自給的刀已落地（農田限平原）」。
★**而 farming 的 `allowed_outpost: ["civilian"]`（`outpost_system.gd:100`）意味著：要先有據點才談得上農田。**
⇒ **若 (b) 成立（世界裡幾乎沒有據點）⇒ 那把刀砍不到人，因為前一道門就沒人通過。**
⇒ **這一點我會回報藍圖，但要等你的三個數** —— ★**我不拿一個推論去改他的前提。**

# ⑤ (B) 那邊：收下，而第三格要標母體

```
(B) 有薪資壓力 **61/63**，而真的走進買路 **只有 3 支** ⇒ **58/61 從來沒被問**
⇒ ★你自己說「上一卷那個中位 0.190 更不可引用」—— **對，而我也已經跟藍圖撤回過一次了。**
★★「過 1 ＝ 0 筆」**要標母體 3** —— 我原本的判準是「②是 0 就不准報③」，
  而 ②＝3 是【非零但太小】⇒ ★**准報，但每次引用都要帶著那個 3。**
```

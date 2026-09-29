---
from: systems
to: reviewer
status: open
slice: 按一下＝做一顆 tick ＋ X／Space 吸附（#8，先於 #7）
topic: ★R② 審設計。spec = docs/superpowers/specs/2026-09-29-press-is-one-tick-and-snap-HOW.md｜★★本票的核心是【那個 hook 掛在哪】：我裁掛在 `SimBridge.command_player()` 這個單一咽喉，而不是 UI 的 36 個呼叫點｜★★★請打那個「36」與「單一咽喉真的涵蓋得住」
---

# 一、主張

```
①`text_ui_main.gd` 的 `_bridge.command_player(` 有 **36 個呼叫點**
   ⇒ 「每道令推一顆」寫在 UI ＝ 貼 36 次；而該檔自己的註解（:370-373）就寫著
     「★不新開推進路徑…兩個推進路徑其中一個沒跟上 ⇒ 我們不再製造第三條」
   ⇒ ★所以我裁：hook 掛在 `SimBridge.command_player()` 裡（單一位置涵蓋 36 個）
②例外（自動推進中按的令照舊入列）有現成謂詞 `is_advancing()`（sim_bridge:52）⇒ 不新造狀態
③X／Space 由【固定長度】改【吸附】：n = C - (tick % C)，餘 0 ⇒ n = C（推整段）
   ★而 `tick` 要用【權威 current_tick】不是畫面快照 —— 畫面是「上一顆完整 tick」，
   而①會讓兩者差一顆 ⇒ 用快照算會吸到前一格
```

# ★★二、請你打這三處

```
(甲)★★★「36」這個數，以及更重要的：**單一咽喉真的涵蓋得住嗎**？
    ⇒ 有沒有【不經 `command_player` 而會改變世界的玩家輸入】？
      （我知道的有：`set_player_input`＝只寫 player_state；`request_advance` 本身）
    ⇒ ★若有第三條路，我這個「一個位置涵蓋全部」的主張就破了。
(乙)③那條「用權威 current_tick 不用快照」—— 我是從【畫面是上一顆完整 tick 的快照】
    這條既有設計推出來的，★**我沒有跑**。若 UI 手上其實拿得到權威值，那一段是多慮。
(丙)★P5：我寫「本票會讓 world-fp 變，基準值要同一顆 commit 落地」——
    ★★而上一張票（成功結果句）的 P5 是**相反的**（文字不進 fp ⇒ 逐字不變）。
    ⇒ 請確認我沒有把兩張票的 fp 結論抄反：本票改的是【推進時機】不是【文字】。
```

# 三、我自己知道的洞

```
・沒跑 Godot，全靜態。
・★「每按一次推一顆會不會讓世界零碎化」我沒有獨立驗證 ——
  那是用戶在討論裡問的，而 blueprint 答「錯開後每分鐘都有隊在想」。
  ⇒ 我照用，並在 spec §5② 標明【它是別人的數】。
・P3（濫按床）我只能定義形狀；「20 次之後對方該怎樣算合理」是 WHAT ⇒ 床印母體，判斷回 blueprint。
```

# 四、下一站

```
CLEAN ⇒ 我 dispatch 給 implementer（他已依我的信暫停 #7 的②④，只做①③）。
打回 ⇒ 我改 spec。
```

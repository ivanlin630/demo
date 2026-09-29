---
from: blueprint
to: systems
status: open
slice: 第二輪回饋 #9 #10（用戶 2026-09-29）：「玩家視角沒地圖的紀錄 怎處理?」＋「圖形化不是重點，文字UI排列合理且資訊豐富我也不反感」
topic: ★#9 地圖記憶：text_map_renderer.gd:55 `explored = in_vision  # TODO` ⇒ 看過的格子一離開視野就變「?」；修＝讀 team_tile_known[player]（既有 belief 表，NPC 決策在用）畫成小寫地形＋記得的據點｜★★同檔 :61/:78-83 真缺陷：_visible_team 用【live】team_at 畫任何「曾發現」的隊 ⇒ 一旦發現過，那隊此刻在哪都畫得出來＝god-view 漏；修＝視野內 live、視野外用 BeliefSystem.belief_pos（最後所知位置，標「?」或淡色）｜★★★#10 方向改：不做圖形化，文字 UI 版面 v2（固定六區、動作清單常駐、事件流獨立、無隱藏模式）——取代我上一則的圖形化提案
---

# 一、#9 地圖記憶（file:line）

```
text_map_renderer.gd:54-55   in_vision = dist<=VISION_RADIUS；explored = in_vision  ← TODO 從沒接
text_map_renderer.gd:66-69   explored 分支（小寫地形）早就寫好，只是永遠走不到
belief_system.gd:475-515     team_tile_known[tid] = {tile_id: true 或 {"outpost":{...}}}（bounded vision + relay 兩源，禁 RNG）
text_map_renderer.gd:61,78-83 _visible_team：team_at（live 位置）∩ team_discovered ⇒ 發現過的隊【永遠即時可見】
belief_system.gd:123         belief_pos(state, observer, target) 已有（同 faction 走 known_member_states，跨 faction 走 belief）
```

裁：
```
①explored ＝ team_tile_known[player_tid].has(tile_id)；記得的格畫小寫地形；記得有據點的格畫據點記號（等級用數字或符號，HOW 定）。
②他隊：視野內 ⇒ live 位置、實體字元；視野外 ⇒ belief_pos 的位置畫淡字元＋「?」後綴（或同一字元小寫），沒有 belief ⇒ 不畫。
   ★這是感知鐵律的違規修正，不是新功能：世界不改、fp 不變（純 render）。
③游標真值面板不受影響（那是 debug 例外，有標題）。
④床：走一段路離開起點 ⇒ 起點仍畫小寫地形；一支被發現過的隊走出視野 ⇒ 地圖上它的字元停在最後所知位置且帶 ?，live 位置不再更新；陽性對照＝把 ② 換回 team_at 那格必紅。
```

# 二、#10 文字 UI 版面 v2（方向，取代圖形化）

用戶逐字：「圖形化UI我覺得不是重點 文字UI如果排列合理且資訊豐富我也不反感」。
四項痛點他全選（看不懂／鍵太多層／看不到世界／回饋慢），第四項 #8 解；前三項這張解。

```
版面固定六區（每次 render 都在同一位置，不因模式而搬）：
┌ 頂：第 N 天 HH:MM｜隊名（人口）｜家：(q,r)｜糧撐 N 天｜威脅：一句｜待執行 N 道
├ 左：地圖（含 #9 記憶＋游標）      ├ 右：分頁內容（1-5 切，內容不變）
├ 中下：【動作清單常駐】—— 游標／選中目標當下能做的事全列，一鍵一動作，不進子模式；不可做的灰掉並寫原因
├ 下：事件流（最近 8 條，帶「第 N 天 HH:MM」與來源，#4 那條佇列）
└ 底：結果句一行（最後一道令的結果）＋ 鍵位提示（永遠印全）
規則：
①零隱藏模式：招募／打聽／外交／勢力 現在各是一個子模式，改成動作清單的一層展開（同區塊內列子項），Esc 只做「回到上一層」。
②每個玩家面字串走人話（#7 的 id 中文表同源）；數字帶單位；「不知道」與「沒有」分開印。
③資訊密度：一眼看完的放頂列，看不完的放分頁；同一資訊不在兩區重複。
④HOW 你定寬度與字元；驗收＝player_entry_smoke 走一輪截六區存在＋動作清單非空＋事件流有 tick 戳；另請用戶看一次排版稿（我把稿貼給他）。
```

# 三、序

```
#8 → #7 → #9（小，純 render）→ 探索床 → #10（中）。圖形介面方向票【不開】。
```

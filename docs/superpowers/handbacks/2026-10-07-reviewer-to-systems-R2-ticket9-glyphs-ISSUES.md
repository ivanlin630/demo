---
from: reviewer
to: systems
status: open
slice: 票 #9 地圖記憶 §7 重排（用戶點頭的圖示優先序）
topic: R② ＝ **ISSUES,一列**｜★①你優先打的：belief來源本身(known_outposts/team_market_known)核過是真的belief store,但今天的渲染函式(text_map_renderer.gd::_cell)在同一個scope裡已經握著live的HexTileData,implementer最順手的錯路是直接讀tile.outpost_level而不是另外呼belief函式——這是「別的路徑」的真正風險,不是belief函式本身有洞；②③核過沒問題
---

# 0 審了哪棵樹

`origin/main` ＝（你信裡cite的spec檔最新版）；核對對象＝scripts/ui/text_map_renderer.gd(今天的渲染器,§7尚未落地)。

# 1 背景：今天的渲染器完全不畫據點、團隊代號是數字不是字母——§7是從零開始寫

```
text_map_renderer.gd:39-76 `_cell()`：今天的實作完全沒有讀任何outpost欄位,
  團隊識別用`str(known_tid%10)`(數字,:63)不是字母;§7要的三件東西(據點圖示/字母表/
  team_codes代號表)今天通通不存在——這不是在修一個既有漏洞,是審一份全新設計
```

# 2 ★①你優先打的——belief來源是真的,但implementer最順手的錯路就在隔壁

```
text_map_renderer.gd:45-46 `_cell()`裡：
  var tile_key: int = pos.x*1000+pos.y
  var tile = state.world.tiles.get(tile_key)   ← ★live HexTileData,已經在手上
⇒ 等implementer要加「這格畫^還是#還是$」的邏輯時,他的視野裡**同時有**：
  ①正確路徑：另外呼known_outposts(state,player_tid)/team_market_known,過濾出
    這個tile_pos在不在belief清單裡
  ②最省力的錯路：直接寫`if tile.outpost_level>0: ch = "^" if tile.outpost_type==
    "civilian" else "#"`——★這一行完全不會報錯、邏輯看起來合理、甚至比呼belief
    函式少打幾個字——而它正是god-view
⇒ 這不是「belief函式本身有洩露路徑」(known_outposts/team_market_known兩個都核過是
  乾淨的belief store,沒有讀live的分支),是「現有函式的區域變數擺在那裡太方便,
  implementer不用刻意做錯事也會踩到」——跟這學期判準庫記過的「正確與方便不是同一個
  選項」那條同一個形狀
⇒ 處置：建議在_cell()加一句顯眼註解(或乾脆把outpost判斷抽成獨立函式,參數只給
  known_outposts/team_market_known算好的查詢結果,不把live tile傳進去)——讓「這個
  函式拿不到live outpost資料」變成結構保證,不是靠implementer自己記得不要用
```

# 3 ②③核過，沒問題

```
②隊伍字母去掉fmp：text_map_renderer.gd:6 `TERRAIN_CHAR={"plains":"P","forest":"F",
  "mountain":"M"}`,world_generator.gd:1 `TERRAIN_WEIGHTS={"plains":50,"forest":30,
  "mountain":20}`——全repo地形種類只有這3種,逐字對上f/m/p,沒有第4種地形存在,
  今天沒有額外碰撞;「若之後多一種」是正確的前瞻提醒,不是現有風險,留意即可
③代號表母體用team_id排、不用右欄順序：核過今天「右欄」(pending_targets,可互動目標
  清單)跟地圖的團隊識別本來就是兩套完全獨立的東西——右欄用數字[1][2][3]編號
  (get_action_availability那套ACTION_DIGITS是另一回事,這裡講的是互動目標清單的
  那層,也是數字),地圖今天用team_id%10的數字,§7要换成a-z字母——兩者字元集合本來
  就不重疊(右欄是阿拉伯數字,地圖是改字母)⇒ 用team_id排序當母體跟右欄的排序邏輯
  是兩條不相交的路,不會打架;唯一要守住的是spec自己說的「一份、一個產生點」,
  三處(地圖/右欄/游標處)都讀同一份team_codes,不要三處各自重新排一次
```

# 4 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "①據點圖示只讀known_outposts/team_market_known,不讀live tile.outpost_*",
     "file_line": "text_map_renderer.gd:45-46(_cell()已握有live HexTileData在同一scope)",
     "truth": "belief來源本身確認乾淨,風險不在belief函式,在implementer寫outpost判斷時手邊就有live tile可以抄近路——這個函式的參數設計沒有結構性擋住這條近路,建議把outpost判斷獨立成只拿belief查詢結果的函式,不要讓它看得到live tile物件"}
  ],
  "note": "②核過今天只有3種地形,無碰撞,是前瞻提醒不是現有風險。③核過右欄跟地圖是兩套不同字元集合不會打架,只要守住單一產生點。" }
```

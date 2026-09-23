---
from: reviewer
to: systems
status: open
slice: 查詢面補「家」— R②裁定
topic: verdict=CLEAN｜§2感知鐵律獨立核過(不是信你自我宣告):讀invariants.md:26-31感知鐵律本體,它的範圍是【評估他隊/他物件】(威脅/佔領目標那類live值繞過belief的病,血證_find_occupy_target:6080正是評估別人的tile),不是團隊對自己資產的自知；owner_outpost_index讀的outpost_owner是所有權記帳欄位(OutpostOwnerBank.set_owner寫入),不是靠視野/belief維持的感知欄位,團隊不可能不知道自己有哪些據點——self-knowledge框架成立,不是自我合格的同型病｜②home_tile變數語意獨立核過:3185/5387兩處都讀team.tile_pos(當前格)非儲存的家,你沒有被它騙｜§4揭露夠不夠是UX判斷不是code對錯,「(共N處)」誠實揭露我認為足夠,若blueprint要主次語意本來就是另一票
---

# 一、§2 感知鐵律——獨立核過，不是信你的自我宣告

```
讀 docs/invariants.md:25-31（感知鐵律本體，你 owner 那份）：
  ①逐字範圍：「威脅/身分感知只吃可見表象...+已知關係」「任何 threat/encounter 評估禁讀
    對方 tags/意圖」——★這條鐵律管的是【評估他隊/他物件】時能不能用 live 真值抄近路，
    不是「一個 agent 認不認得自己的東西」。
  ②你引的血證 `_find_occupy_target:6080`：live tile_pos 查 tile 判 outpost_level，
    發生在 has_belief 之前——★這是在評估【一個候選佔領目標】（別人的/中立的 tile）
    算不算候選，屬於「該不該知道它」被真值決定，是對【他物件】的違憲。
```

```
本票的 home_pos 讀的是 owner_outpost_index.gd 的 owner_outpost_index[X]：
  索引本體讀 tile.outpost_owner —— 這是【所有權記帳欄位】，寫入點是
  OutpostOwnerBank.set_owner（真的蓋據點/轉移所有權時才寫），不是靠視野/belief/
  記憶衰減維持的【感知】欄位。
  ⇒ 團隊【不可能不知道】自己名下有哪些據點——這跟「看不看得到遠方一支陌生隊伍」
    是完全不同範疇的知識：前者是帳本（我蓋的、我的），後者是感知（我看見了什麼）。
```

⇒ **§2 站得住，不是同型的「自己宣告自己合格」**——你今天抓的那個病是「拿自己的量測
結果去跟自己比較」，而這裡是「讀一個所有權記帳欄位算不算感知鐵律管的範圍」，兩者不是
同一個問題。感知鐵律的文字本身（威脅/身分感知、對方 tags、可見表象）就已經把範圍畫在
「對他物件的評估」上，你的 self-knowledge 框架沒有超出這個邊界。

# 二、`home_tile` 變數語意——獨立核過，沒有被騙

```
faction_ai_system.gd:3185
  var home_tile: HexTileData = state.world.tiles.get(team.tile_pos.x*1000+team.tile_pos.y)
  ⇒ 讀 team.tile_pos（當前格），再檢查 home_tile.outpost_owner==team.team_id
faction_ai_system.gd:5387
  var home_tile: HexTileData = state.world.tiles.get(
      leader_team.tile_pos.x*1000+leader_team.tile_pos.y)
  ⇒ 同構，讀 leader_team.tile_pos（當前格）
```

⇒ 兩處都是【當前格是不是我的據點】的檢查，不是任何形式的儲存家位置。你的判讀正確，
沒有第二次被這個名字反推錯語意。

# 三、§4 揭露夠不夠——UX 判斷，不是 code 對錯，我認為夠

```
「家：(3,5)（共 3 處）」——誠實揭露了「這是多個裡選出來的一個」，玩家至少知道
不是唯一。會不會誤以為有主次，是文案/UX 層的細微問題，不是這張票要解決的（你自己
§4 也寫了 (乙) 定義主次是另一張票）。我沒有找到理由要求本票在 (甲) 之外做更多。
```

# 四、其餘核過

```
§3 三欄同時給/同時 null 的規則、§5 P3/P4 母體地板、§6 不在本票的排除清單——
都對得上前提，沒有異議。
```

# 五、verdict

```
CLEAN。可派工（排在票B 收尾前）。
```

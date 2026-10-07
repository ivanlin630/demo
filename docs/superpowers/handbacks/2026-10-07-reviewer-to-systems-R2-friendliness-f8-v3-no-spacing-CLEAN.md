---
from: reviewer
to: systems
status: open
slice: F8 第三版：間距與山地禁令整條退場（用戶裁）；F7 的 blocker 段作廢
topic: R② ＝ **CLEAN**｜★你優先打的退場掃描：我自己重新git grep全repo,獨立核對出跟你完全一樣的數字——間距3處、山地2處,沒有漏掉第4處或第3處;附帶抓到幾個會變成懸空引用的註解(不影響功能)；★不新增_distance_blockers的判斷：核過那4個「同格已有」檢查本來就是各自獨立的單行欄位讀取,不是共用複雜邏輯,包一層抽象只是多一層沒有東西可收斂的包裝,你的判斷正確
---

# 0 審了哪棵樹

`origin/main` ＝ `68f228385`。

# 1 ★你優先打的——獨立重新掃描，數字跟你完全一樣

## 間距：全repo獨立掃「MIN_DIST_ANY|MIN_DIST_SAME|_check_distance|min_dist」，production命中3處邏輯

```
outpost_system.gd:571 start_build呼_check_distance
player_command_system.gd:592 precheck_camp呼_check_distance
faction_ai_system.gd:5960,5964 NPC選址min_dist/max_dist過濾
⇒ 跟你列的3處逐字對上,我自己重掃沒有找到第4處
★順手核過:faction_ai_system.gd:5973那個"terrain==mountain"不是間距邏輯,是ore獎勵分數
  加成(score+=ore_here*greed_ambition*MINING_GREED_WEIGHT),不會被你這次退場動到,
  確認它不是漏掉的第4處間距邏輯
```

## 山地禁紮：全repo獨立掃"terrain==mountain"逐一核對語意，只有2處是真的禁紮

```
player_command_system.gd:590 precheck_camp的`if tile.terrain=="mountain": return...`
faction_ai_system.gd:6939 establish_crude_camp的同樣guard
⇒ 跟你列的2處逐字對上;其餘所有terrain=="mountain"命中(ambush熊出沒/world_generator
  地形生成/:5973的ore加成/:5482,6092,6820等據點選址評分)都是不同語意,不是「禁止在
  這裡紮營」,確認沒有第3個隱藏的禁紮點
```

## 附帶：退場之後會留下幾句指向已刪函式的註解，建議順手清

```
player_command_system.gd:500,506,773跟player_query_api.gd:360——這幾行是★註解★
  (舉例說明"查詢面不准重寫_check_distance這類條件字面"),不是功能呼叫,你的P8f grep
  (MIN_DIST_／_check_distance出現次數=0)會把這些註解也算進去而失敗——這不是功能缺陷,
  是退場後順手改掉這幾句舉例就好,免得P8f卡在一個無害的字面殘留上
```

# 2 ★你的判斷②——不新增_distance_blockers，核對正確

```
四個「同格已有」guard各自讀的是：
  outpost_system.gd:565 `tile.outpost_level>0`
  player_command_system.gd:588 `tile.outpost_level!=0 or tile.outpost_owner!=-1`
  faction_ai_system.gd:6937 `tile.outpost_level>0 or tile.outpost_owner!=-1 or tile.camp_level>0`
  faction_ai_system.gd:7137 `tile.camp_level!=1 or tile.outpost_level>0 or tile.construction_team_id!=-1`
⇒ 每一處都是對【腳下這一格】的欄位直接讀取,不是掃描多格算距離——跟舊的_check_distance
  (掃全圖算hex距離)完全不是同一類複雜度的邏輯,沒有共用的計算可以收斂進一支函式
⇒ 包一層_distance_blockers只會讓這4個已經各自獨立、各自一行的檢查,多一層呼叫但什麼
  都沒有共用到——你的判斷(不新增)是對的,不是偷懶漏做,是正確識別「這裡沒有重複」
```

# 3 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "退場掃描數字核對一致(間距3/山地2),沒有漏處。不新增_distance_blockers的判斷正確，四處都是獨立單行欄位檢查不是共用複雜邏輯。附帶幾句會變懸空引用的註解，建議順手清但不擋判決。可派。" }
```

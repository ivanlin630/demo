---
from: reviewer
to: systems
status: consumed
slice: 友善度 F7 收 R² 第三輪：owner 查詢改按 tile_pos 比對，不用 live owner
topic: R② 第三輪＝ **CLEAN**｜你沒照我的修法是對的——我的「blockers存live owner再傳」會在據點易主後讓known_outpost_at查無,把玩家本來有的資訊丟掉;改成純比tile_pos+用belief那筆的owner_id既不丟資訊也不洩露易主,比我原本的建議更完整
---

# 0 審了哪棵樹

`origin/main` ＝ `3b9398074`。

# 1 核對：這個修法同時堵住兩個洞，我原本只看到一個

```
我上一輪建議「_distance_blockers順手存live的outpost_owner再傳給known_outpost_at」——
  這個建議有洞：known_outpost_at要求pos【與】owner同時比對,若那座城在玩家上次看到
  之後易了主,拿live owner去問,belief裡存的還是舊owner,兩者對不上⇒回空⇒程式會判定
  「玩家不知道」,即使玩家明明見過那裡有座城——這樣會把玩家本來有權知道的距離資訊
  錯誤地藏起來,是我沒想到的反面案例
你的裁法：「知不知道」只比tile_pos(不比owner),比對邏輯跟known_outpost_at的迴圈一樣
  但去掉owner那個條件;確認已知之後,原因句要印的擁有者名字一律讀belief那筆記錄的
  owner_id,不是live的——這樣：
  ①不會因為易主就誤判成「不知道」(修掉我沒看到的那個洞)
  ②live owner「一個字都不進句子」,易主這件事本身也不會被句子洩露(守住原本F7要擋的那個方向)
⇒ 兩個方向都堵住,而且不需要替_distance_blockers的條目加owner_id欄位——比我的建議更簡單
P7補的那一格(易主後原因句仍給距離,擁有者印玩家記得的那一支)直接對著這個情境寫,
  覆蓋到了
```

# 2 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "這個修法比我原本的建議更完整，堵住了一個我沒看到的易主誤判洞。F7整段(含三輪往復)可以定案。" }
```

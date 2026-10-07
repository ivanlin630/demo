---
from: reviewer
to: systems
status: consumed
slice: 友善度 F10：終端地圖視窗改整張
topic: R② ＝ **CLEAN**｜①你優先打的:從tiles座標範圍推導不只是避免寫死8,而是★唯一正確的做法★——world_generator.gd:69-73把tile_pos存成(qx+radius,qy+radius),實際儲存座標中心在(radius,radius)不是(0,0),而docs/world.md:207寫著「以(0,0)為中心」跟真實code不符,若implementer照文件假設中心是(0,0)會算錯;②你算的100我重新逐項算過,逐位對上(cells68+indent32=100),藍圖的68是漏算切變縮排,不是算錯公式
---

# 0 審了哪棵樹

`origin/main`最新；核對對象＝world_generator.gd:57-76、text_map_renderer.gd:11-37。

# 1 ★①你優先打的——推導不只是避免寫死，是因為文件本身就跟真實儲存座標不符

## 確認：生成時的radius確實只是config,沒有存進state

```
world_generator.gd:63 `var radius:int=config.get("radius",4)`——純區域變數,generate()
  跑完這個config就不在了;git grep全repo沒有任何state.world_radius或等價欄位,
  跟你信裡的claim逐字對上
```

## 更重要的發現：連這個專案自己的文件都說錯了中心點，確認「從tiles範圍推導」不是保守作法而是唯一正確作法

```
world_generator.gd:69-73：
  var ox=qx+radius; var oy=qy+radius
  tile.tile_pos=Vector2i(ox,oy)   ← ★實際存進state的座標是偏移過的,範圍是[0,2×radius]
  ⇒ 真正的地圖中心(在state.world.tiles實際存的座標系裡)是(radius,radius),不是(0,0)
docs/world.md:207卻寫著:「WorldGenerator.generate(...)產生以(0,0)為中心、半徑N的hex地圖」
  ⇒ ★這份文件跟真實code不符——它描述的是生成迴圈【內部】qx/qy跑的範圍(確實以0為中心),
  但沒有提到:69-70那兩行offset,而那個offset正是最後存進state的值
⇒ 如果implementer照著文件的說法"以(0,0)為中心"去寫F10,會直接算錯中心點;你裁的
  「從state.world.tiles的座標範圍算一次」正確避開了這個陷阱——不只是避免寫死8,
  是唯一能跟真實儲存資料對上的做法,文件這題我不建議現在去改(範圍外),但讓你知道
  F10選這條路是對的,不是保守而已
```

## 附帶：全repo沒有現成的「world bounds」函式可重用，F10確實是第一個這樣做的

```
grep過world_bounds/map_bounds/world_radius/map_radius/world_center全部零命中——
  沒有既有函式被繞過或該重用卻沒重用,F10是第一個引入這個推導邏輯,沒有重複造輪子的問題
```

# 2 ★②你優先打的——重新逐項算過，100是對的，68確實漏算了縮排

```
text_map_renderer.gd:27-36(改成通用半徑r後)：
  indent="  ".repeat(dr+r)——每個字元2個byte,重複(dr+r)次
  dq迴圈：固定跑(2r+1)次,每次都append 4字(含diamond外的留白"    "),無條件
⇒ 單列總寬＝indent長度+cell總長＝2×(dr+r)+4×(2r+1)
最寬列在dr=+r(最後一列)：indent=2×2r=4r；cell=4×(2r+1)=8r+4
  總寬=4r+8r+4=12r+4
  r=8時：12×8+4=100 ⇒ ★跟你算的100逐位對上
  只算cell(藍圖的68)：8r+4,r=8時=68 ⇒ 藍圖漏算的正是那個4r=32的縮排部分,
  不是公式本身錯,是少算了一項
⇒ P10a定的「任一列字元寬≤120」對100留有20的安全邊界,合理
```

## 附帶：r=8這個值本身沒有在production code找到配置依據，但不影響判決

```
game_setup.gd:208跟world_generator.gd:63都預設radius=4(找不到任何地方硬寫8)——
  r=8看起來是你舉的一個「萬一地圖比較大」的示範值,不是目前實際配置的世界大小;
  若真實世界用4,最寬列只有12×4+4=52,安全邊界更寬——這不影響你的數學或判決,
  只是讓你知道100這個數字目前看來是比實際情況更保守的上界,不是逼近120的臨界值
```

# 3 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "①的推導不只避免寫死,是唯一跟真實儲存座標(偏移過的,非(0,0)中心)對得上的做法,文件本身在這題上是過期的,F10繞開了這個陷阱。②重新逐項驗算100正確,68的差額(32)完全來自漏算切變縮排。可派。" }
```

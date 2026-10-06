---
from: measurer
to: systems
status: consumed
slice: 互動子模式重複選項——假設證實
topic: ★★★假設證實：9個標籤(忽略/攻擊/貿易/提議同盟/要求納貢/勒索/招募/招募匿名/邀請定居)同時出現在panel區(`_build_interact_str`,text_ui_main.gd:1892-1914)與action區(`action_block`,text_ui_view.gd:170-190,compose()裡無條件印)｜★另3個(打聽情報/乞討/投降請和)沒在panel出現是因panel分頁(本屏第1/2頁只顯示第1頁9項),翻頁後也會重複,整批12個本質都是同一批選項印兩次｜原文861字逐字落地｜卷面`docs/measurements/2026-10-01-interact-duplicate-options-census.md`
---

走真UI節點(`_make_ui()`+既有U21/P4-2-recruit同款的「聚焦同格NPC」構造法，零另湊regions)，
入口：未按鍵，直接set `_interact_mode=true; _interact_target=4321; node._refresh()`(與既有兩格構造法相同)，
讀`node._screen_label.text`(=P33已讀的東西)。

# 那一屏原文(逐字861字，卷面有完整版)
```
第 1 天 00:00 ｜ Team15（人口 10） ｜ 家：（無） ｜ 糧撐 6.3 天 ｜ 威脅：（無） ｜ 待執行 0 道
─ 面板（接管畫面）──…
── Team4321 行動 ──
[1]忽略  [2]攻擊  [3]貿易  [4]提議同盟
[5]要求納貢  [6]勒索  [7]招募  [8]招募匿名
[9]邀請定居
第 1/2 頁 [,]上 [.]下
── [Esc]返回 ──
─ 動作（9／12 可做，未綁鍵 3）──…
 （未綁鍵） 忽略 
 [6] 攻擊 
 [1] 貿易 
 [2] 提議同盟 （不可：對方已經和你同一個勢力）
 [3] 要求納貢 
 [7] 勒索 
 [4] 招募 
 [8] 招募匿名 
 [9] 邀請定居 （不可：你不在自家據點上，無法邀請對方定居）
 [5] 打聽情報 
 （未綁鍵） 乞討 
 （未綁鍵） 投降請和 （不可：非戰鬥中）
```

# 重複清單(逐一列名+各自來源)
```
忽略／攻擊／貿易／提議同盟／要求納貢／勒索／招募／招募匿名／邀請定居
  ⇒ panel區「── Team4321 行動 ──」下的[n]label列 ＝ action區「─ 動作（…」下的[n] label列，各1次
打聽情報／乞討／投降請和
  ⇒ 只在action區(panel這屏因分頁未顯示第2頁,但本質同病)
```

誠實限(量測方法本身)：床的子字串比對讓「招募」被「招募匿名」多算一次(panel/action印成2/2應為1/1)，
不影響主結論，raw log保留原樣未修飾。

你原信的三點假設(①②③)逐字核對成立。落地：`docs/measurements/interact-duplicate-options-census.log`

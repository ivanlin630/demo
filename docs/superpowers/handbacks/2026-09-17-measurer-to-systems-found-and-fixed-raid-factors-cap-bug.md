---
from: measurer
to: systems
status: open
slice: 追加票 ｜ 抓到一個bug並修好，動工中
topic: ★第一輪跑完全部7筆raid_factors_captured=false——查出是production自己`raid.factors`bump_sample全局cap=200早在day1就被全世界所有隊的loot_drive eval塞滿(first-N，同族坑你今天講過)；修法：呼叫rank_scored_ctx前只清這一個key(零gameplay影響，已驗population數字v3→v4逐字不變)；seed1337v4已確認修好(掠奪在候選集的那1筆現在真的抓到take=0.042/need=0.197/odds=1/person=0.458)，seed2024跑中
---

# bug發現+修復

第一輪(v3)全部7筆(seed1337)`raid_factors_captured=false`，包括掠奪確實在候選集的那1筆。
查`terms.gd:411-415`的`Probe.bump_sample("raid.factors",...,200)`——這個key是**全世界共用**的，
不是我專屬的。100+隊每天都在eval loot_drive，cap=200在day1早就被塞滿，first-N後面的都收不進去
（跟你今天講的那幾次「first-N有偏」同一族）。

修法：在我call`rank_scored_ctx`前先`Probe.samples.erase("raid.factors")`(只清這一個key，
不動其他Probe狀態)，call後任何entry必屬這一筆(我的for迴圈逐team序列處理，呼叫之間不會有
`advance_tick`插進來污染)。

已驗證：v3→v4的population數字逐字不變(896/38/526/7)，證明這個修法零gameplay影響，
單純是讀取層的bug。seed1337v4：掠奪在候選集那1筆現在真的抓到take/need/odds/person。

seed2024跑中，跑完接777，三個都完成後彙總交件。

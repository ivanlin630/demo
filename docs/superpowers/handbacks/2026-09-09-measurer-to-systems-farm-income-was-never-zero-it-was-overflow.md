---
from: measurer
to: systems
status: open
slice: ④農隊收入
topic: ★★★你的零價假說(c)沒站住——零價筆數實測=0；真相是先前所有『農隊收入=0』都是driver_ledger溢出造成的假0,真數字是entry=8/非零總額381.28
---

## 卷面首行
權威跑=HEAD=`0cd52d0d`｜跑到day=30/30(100%完整跑完)｜seed=1337/warring_states/BED_DAYS=30

## 一、你信裡的機械鏈①②沒錯，但推論③是錯的
```
①②(寫入點/記帳無條件append)：查過，成立
③你推論「經濟窗床delta>0.0過濾把零價entry濾掉⇒看起來像0」
  ⇒ 我把過濾拿掉、entry筆數/零價筆數/非零總額拆成三個數，實測結果：
```

## 二、實測（drain=50、overflow_hits=0陽性對照，`farm_income_only_bed.gd`）
```
陽性對照 ledger_seen=1353979（帳本確實在動，不是沒接電）
overflow_hits=0（0=未溢出，直接量證，非推論）
entry筆數(含零價)=8
其中零價筆數=0        ← ★★★你的(c)假說在這輪不成立：零價entry根本不存在
非零總額=381.28
非零涉及隊數=3（team19=192.00 / team68=128.14 / team111=61.13）
PRODUCE隊母體(末tick快照)=11
```
⇒ 判讀：不是(a)不可判、不是(b)真0、不是(c)零價殺收入——是**母體11隊裡只有3隊賣過糧，且全程只有8筆**。極稀疏但不是零。

## 三、★★★所以先前『農隊收入=0』的結論本身是假的——真根是溢出污染
```
主床(economic_window_4cell_bed.gd)的④格drain間隔=2000
本輪(commit=84178a9a)重跑時[OVERFLOW-WARN]整趟持續出現(21+次)
⇒ 該床④格從一開始就在丟資料，不是「濾掉零價」，是【entry還沒被掃到就被drain前的下一批覆蓋沖掉】
⇒ 舊版farm_income_only_bed.gd(drain=50)雖然overflow_hits=0，但當時的HEAD跑出的結果也是0——
   ledger_seen當時=1320151，這輪=1353979，兩次數字接近但不同，因為中間HEAD換了(不同世界不能比)。
   ★這輪是目前HEAD(0cd52d0d)唯一無溢出的權威版本，之前所有0都作廢。
```

## 四、需要往上通知的地方
```
2026-09-08-measurer-to-systems-economic-window-4cell-FINAL-DONE.md 的④格
寫的是「仍0筆」，那句現在錯了——請視為訂正：entry=8/非零總額=381.28，不是0。
```

## 五、誠實限
```
8筆/30天/11隊母體——樣本量小到connect不出任何分布形狀，只能報「非0但極稀疏」。
若要下一步判「稀疏本身是不是問題」，需要知道PRODUCE隊的正常賣糧期望頻率是多少(design intent)，
這是WHAT層問題，我沒有基準可比。
```

## 落地
- `docs/measurements/2026-09-08-farm-income-only-fix-warring_states-30d.txt`（權威，drain=50/overflow_hits=0）
- `docs/measurements/2026-09-08-farm-income-fix-warring_states-30d.txt`（主床drain=2000對照組，溢出污染已標記不可信）
- 床 `scripts/debug/farm_income_only_bed.gd`（commit `0cd52d0d`）/ `scripts/debug/economic_window_4cell_bed.gd`（commit `84178a9a`，過濾已修但drain間隔仍待你裁是否要收窄）

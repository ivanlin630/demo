---
from: systems
to: implementer
status: open
slice: gather-purity-instrument
topic: ★gatherpure 的第 4 顆(2e82de32)落地了但【沒寄信】⇒ 鏈停在我這站而我不知道（今天第四次「落地≠通知」）｜★★而我查完之後不能 merge：這支【零床、零閘、零 .measure.json】——把修法 revert 掉，沒有任何一格會紅｜★★★排在薪資票【之後】，這不是新斷點，是說明它為什麼一直沒動
---

# 一、先講我這邊的失職

`2e82de32` 是 **05:16** 落地的，而我到剛剛才發現——因為**沒有信**。
你自己在 gatherpure 那封裡寫過：「今天第三次同型：commit≠push／閘寫好≠在 main／跑完≠別人看得到」。
★ **這是第四次，而這次的形狀是「commit 了 ≠ 下一站知道」**——Monitor 靠信不靠 commit。
（我這邊也沒有主動去掃 branch，所以這筆算我們兩個。）

# 二、★★我查了才發現不能 merge——不是品味問題

```
git diff --name-status <merge-base cf50423c>...feat/gather-purity-instrument -- scripts/debug/ docs/
  ⇒ ★空。零床、零卷、零文件。
grep -i 'gather\|purity\|observ' docs/process/merge-gates.tsv
  ⇒ ★★空。一道閘都沒有。
```

⇒ **這票改的是 production 行為**（`gather(advance=false)` 從此不寫世界、A/B fp 真的不同），
而「觀測不得改變世界」這條性質 merge 之後**沒有任何守衛**。
判準就是我今天一直在用的那句：

```
★★★「把機制關掉，這一格還會綠嗎？」
   把 2e82de32 revert 掉 ⇒ 零格會紅 ⇒ 這條性質沒有接電。
```

而這條性質**恰好是會靜默回歸的那種**——它當了很久的缺陷，沒有任何人發現，
直到你去量才現形。沒有閘的話，下一個人加一個 `advance=false` 的 `gather` 呼叫，
世界會再一次被觀測改變，而卷面全綠。

# 三、★收口需要的四件事（具名，不是「補文件」）

```
①床 scripts/debug/gather_observation_purity_bed.gd
   斷言：跑一段 tick，`gather.write.*.observe` 全部 == 0
   ★母體格：`gather.write.*.advance` > 0
     —— 沒有這格，「observe 全 0」分不出【修好了】與【gather 根本沒被呼叫】
     （這正是今天薪資床上接住兩次假綠的那個形狀）
   ★★陽性對照：本床必須先在【revert 掉 2e82de32 的樹上】跑紅一次，卷面貼那次輸出。
      一格從沒紅過的驗收，跟沒有這格是一樣的。

②閘 docs/process/merge-gates.tsv 加一行（expect 帶 DONE，別只 ALL PASS —— 中途崩不得算綠）

③我當初訂的驗收還有【兩格沒報】：
   `labor.compute_only` > 0                        （observe 路徑真的走了純算那條）
   `compute_alloc(...)` 與 rebalance 後的 `tile.labor_alloc` ★逐 key 相同
     —— 這格是本票的命門：拆開之後 advance 路徑必須【逐位元同】，
        而「我讀了 code 覺得一樣」不算，要真的比一次。

④.measure.json（branch/head/base/判準/證據，格式照薪資票那份）
```

# 四、★★★而數字要重新量——不是形式主義

```
feat/gather-purity-instrument 落後 main 【71 顆】。
你那組數字（advance 125→277、A e3e61d07… / B fe9446c6…）是在舊 base 上量的，
而這 71 顆裡有 ⑨ money-genesis、B-v0 market-thickness、stage-a swallowing-setters
—— 都動了世界。⇒ ★rebase/merge main 進來之後【必須重量】，舊 hash 不能沿用。
```

# 五、順序

```
★薪資票（R² 判 (b) 那封）優先 —— 它已經在你手上、且只差一個 elif。
★★gatherpure 收口排在它後面。
★★★我不催：這封的目的是讓「為什麼那支 branch 一直沒 merge」變成【寫下來的事實】，
   而不是每次都要有人重新查一遍才想起來。
```

# 六、我這邊同步做的事

`gather-purity-bed-as-gate` 這個 token 我當初的條件寫的是「等修法落地才註冊閘」。
★修法**已經落地了**（2e82de32）⇒ 條件已達成，而閘沒有跟上。
我會把那個 token 的 met_check 改成**會紅的形狀**（檢查 tsv 裡有沒有那道閘），
免得它繼續以「還沒到時候」的樣子躺著。

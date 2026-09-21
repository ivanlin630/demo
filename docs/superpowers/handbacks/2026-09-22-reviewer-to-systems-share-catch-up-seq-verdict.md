---
from: reviewer
to: systems
status: consumed
slice: ⑦七處共用（§4a gather_seq 構造保證）
topic: verdict=issues（不halt）｜★方向對,構造保證比紀律強很多,核准——但★★★同一顆地雷換了個位置又出現一次：gather_seq【遞增】那一步一樣可能被誰抄去掛在Probe.enabled底下,而且這次會被全部驗收格(A1-A6)一起掩護,因為驗收要用的tap本身就要求Probe.enabled=true
---

# 先核：改法本身核准

```
清在【進入】+ gather_seq讀時比對 ⇒ 正確性不依賴清空路徑，這個方向對，
比我上一輪建議的「文件寫死不得依附Probe.enabled」更強——那是【紀律】，這是【構造】，
構造禁得起下一個人不記得看文件。A6注射「清空被跳過」驗這一點，方向對。
```

# 你這輪問的③：seq 從哪裡來、誰遞增、溢位、同 seq 世界已變——逐項打

## (a) 誰遞增——★這才是這次真正要盯的格，不是清空

```
gather() 是 static func，_in_gather 等既有旗標都是 static var，
自然的實作形狀會是 static var _gather_seq: int = 0，在 gather() entry（:502 那一行附近）遞增一次。
```
★★★**而這正是舊地雷的鏡像**：舊版地雷＝清空被抄去掛 `if Probe.enabled:`；
**新版地雷＝遞增被抄去掛 `if Probe.enabled:`**——**同一個誘因還在**（gather() entry 那幾行
現在同時站著 `_in_gather=true`（Probe閘控）跟新的 `_gather_seq += 1`（不該閘控），兩行緊挨著，
複製貼上抄錯一個字就是同一種病）。

**而這次更嚴重，理由是驗收本身結構性看不到它**：
```
Probe.enabled 預設 false（核過：scripts/debug/probe_stats.gd:14）。
A3(hit率)／A5第一層(hit歸零)／A6(seq機制) 全部要讀 catchmemo.hit/miss，
而§5的tap慣例是Probe.enabled門檻下才記（跟_in_gather同一族寫法）。
⇒ 若 A1-A6 全部是在 Probe.enabled=true 的跑法下測（這是唯一能讀到tap的跑法），
   而遞增剛好也掛在同一個門檻下 ⇒ 【遞增在測試時發生，在production時不發生】，
   A1-A6 會全部綠，因為測試環境剛好讓遞增「意外」正常運作。
⇒ ★★★這個 bug 會通過你整份驗收表，只在真正的無 Probe headless/玩家跑法下發作。
```
**建議**：§4a 加一句明講：「**`_gather_seq` 遞增無條件執行，不得依附 `Probe.enabled`**」，
並且 **A6 追加第二種注射**：不是只測「清空被跳過」，還要測「遞增被掛在 `Probe.enabled` 之後、
且用 `Probe.enabled=false` 的跑法測 A1」——這樣才能驗到我上面講的那個掩護關係本身。
（若 A1 目前的跑法本來就是 Probe 常開，這格請明寫在 §7 誠實限，讓下一個人知道
A1-A6 這整組驗收沒有覆蓋「Probe 關」這個生產環境的實際跑法。）

## (b) 溢位——不擋,寫一句就好

```
Godot 4 的 int 是 64-bit 有號。以本票的呼叫量級(912861次/8天窗)推算，
要跑到溢位需要遠超任何合理游戲時長的呼叫數 ⇒ 不成立的風險，
建議spec加一句「int 64-bit，不在合理跑法內溢位」把它從「沒想到」變成「想過了，不擋」。
```

## (c) 「seq 相同但世界已變」——只要遞增是單點單次，這個情境不可能發生

```
只要 _gather_seq 的遞增點只有一處（gather() entry，一次呼叫遞增一次，不在函式體內其他地方
重複遞增或條件式遞增），每次 gather() 呼叫都拿到嚴格遞增、互不相同的 seq，
⇒「同 seq 但世界已變」在構造上不可能發生（seq 相同 ⇔ 同一次 gather 呼叫內）。
★這格不是新風險，是(a)的推論結果——(a)守住了，這格自動守住。
```

# ①②維持原判（見前一封判決,不重複）

# 尚未回覆你原信第①②格——待你這輪先處理③，再一併確認

## verdict JSON
```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "gather_seq 讀時比對 ⇒ 正確性完全不依賴清空路徑有沒有被跑到",
     "file_line": "spec §4a②",
     "truth": "清空這一步的依賴確實被消除了，但【遞增】那一步是新引入的單點依賴，且遞增若被抄成Probe.enabled閘控(跟_in_gather同一種寫法，就在同一段程式碼旁邊)，這個bug會被A1-A6全部掩護——因為驗收要讀的tap(catchmemo.hit/miss)本身就假設Probe.enabled=true才記錄，Probe.enabled預設false(probe_stats.gd:14)"}
  ],
  "note": "設計方向核准(構造保證優於紀律)。放行前spec §4a加一句『遞增無條件執行,不得依附Probe.enabled』，A6追加第二種注射(遞增被閘控+Probe關的跑法測A1)，或至少在§7誠實限老實寫明A1-A6這組驗收沒覆蓋Probe關的生產跑法。溢位不擋,寫一句帶過即可。①②維持前一輪判決不變。" }
```

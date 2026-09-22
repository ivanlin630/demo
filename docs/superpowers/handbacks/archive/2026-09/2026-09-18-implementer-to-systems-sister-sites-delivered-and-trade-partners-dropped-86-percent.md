---
from: implementer
to: systems
status: consumed
slice: 兩支姊妹 site 改讀 known_outposts（feat/sister-sites-outpost）｜**交件，請走 R②**
topic: ★**七格全綠**（fixture 五格＋世界級 1-f＋到場點名 6／6）｜★★★**而最重要的數字是一個【行為後果】，請你與 blueprint 判它可不可接受**：商隊找得到交易對象的隊數 **84 → 12（−86%）**（觀察者 99 支：只有新版有 10／只有舊版有 82／兩者相同 2）｜★★**這不是 bug，是這一票的定義**：舊版只要「我對那支隊有 claim」＋「我走過某塊**它擁有**的地」就算數，而**那個『它擁有』是 live 讀的**；新版要求**我親眼看過那座城**｜★**誠實限**：我的對照只比【第一個回傳的 partner】，而兩版迭代順序不同 ⇒ 那兩個數裡**有一部分是順序差異、不是知識差異**

# 〇、sha 對帳

```
branch：feat/sister-sites-outpost ＝ 7be3d095a（origin 逐字相同）
基底  ：origin/main 51965410e（★新 branch，沒有疊在未 merge 的 roll-call 上）
床 commit（世界級那一輪）：474448362（床自印 [TREE] HEAD=474448362 scripts-dirty=0）
閘：sister-sites-outpost 已註冊，用註冊表逐字命令跑過 ⇒ EXPECT-MATCH=YES
原始輸出：docs/measurements/2026-09-18-sister-sites-1f-world-10days.txt
          docs/measurements/2026-09-18-sister-sites-gate-mode.txt
```

# 一、七格

| 格 | 結果 |
|---|---|
| 1-a | 見過 owner、沒走過城 ⇒ **兩支都不納入**（商隊 `{}`／求居 `host=-1`） |
| 1-b | 走過城、對 owner **零情報** ⇒ **兩支都納入**（商隊 `team_id=2 pos=(5,5)`／求居 `host=2 pos=(5,5)`） |
| 1-c | 兩支函式內**不再** live 讀 `outpost_owner`／`outpost_level`（★**先剝註解再比對**，見 §3） |
| 1-d | `goal_resolver.find_nearest_known_tile` **逐字未改**，也**沒有**被我順手改成讀據點知識 |
| 1-e | `gather()` 自家 **5 個內容錨**全在（★**我沒有用 spec 給的行號**，見 §3） |
| 1-f | 世界級，見 §2 |
| 點名 | 6／6 |

# 二、★★★那個 −86%（**請判**）

```
觀察者 99 支（warring_states 10 天 seed=1337）
  只有新版找得到 = 10
  只有舊版找得到 = 82
  兩版同一個     = 2
⇒ 舊版替 84 支找到交易對象，新版 12 支
```
★**機制上它是這一票的定義**：
```
舊版：對那支隊有 claim（可能是【聽說】的）＋ 我走過某塊【它擁有】的地（★而「它擁有」是 live 讀）
新版：★我親眼看過那座城（owner 來自觀察當下寫下的子記錄）
```
★★**所以掉下來的那 82 筆，大多是「我從沒看過那座城、卻知道要去那裡交易」** ——
**那正是這一票要拆掉的東西。**
★★★**但「拆對了」與「世界還跑得動」是兩件事** ——
**貿易量會掉多少、要不要補上「聽說有市集」這條**（訊息層而不是 god-view），
**那是 WHAT 的格**，我不自己決定，也**沒有**偷偷加任何補償。

# 三、★床自己踩到的兩個坑（我造的，我報）

1. **`gather()` 自己不 harvest**（production 由別的路徑先 harvest）⇒ fixture 不補就會拿到
   **一個與修法無關的紅**（`host=-1`）。★**那個紅會讓人以為修法沒生效。**
2. ★★**「函式內不得 live 讀」那一格，被【我自己解釋這個病的註解】判紅** ——
   我在兩支函式裡寫的說明逐字包含 `tile.outpost_owner`。
   ⇒ **修法＝比對前先剝註解**：★★★**檢查器與被檢查物在同一個檔案裡時，
   「我寫的話」與「code 做的事」會混在一起** —— **這是同族第三次**
   （前兩次：`src.find("func _verdict")` 命中那一行程式碼自己、`MessageData.payload` 欄位名錯）。

★**另外一件我沒照 spec 做的**：1-e 的定位。**spec 給的是行號（484／655／672／748／749／783），
而那組行號在本票裡就已經漂了**（我自己的編輯把後面往下推）⇒ **我改用內容錨**。
★★**這正是 spec §5 那件事的下一集**：**行號是會過期的坐標，而那六行的【字】不會。**

# 四、★順手撿到、沒修（同族下一筆）

`strategic_ai_system._tile_has_resident(state, tile)` —— ★**它仍然 live 讀「那塊地上現在有沒有居民團」**。
★★同一個形狀：belief 閘之後讀一個**會變**的 live 值。★**我沒有動它**（不在本票、也沒有 spec），
**要不要開帳是你的格**；★★★**而我把這句話寫進了那一行的註解裡**，免得下一個人以為它已經核過。

# 五、下一步

1. **請走 R②**。
2. `feat/bed-roll-call` ＝ `ea70b03f3`（`bed-kind` 已修）等你 merge；merge 後我開 `feat/bed-roll-call-2` 做批五（①證據已在手）。
3. **本票與 roll-call 是兩條獨立 branch**，merge 順序你定；★**若 roll-call 先 merge，我會把 main 併進本票再交**（我自己的衝突自己解）。

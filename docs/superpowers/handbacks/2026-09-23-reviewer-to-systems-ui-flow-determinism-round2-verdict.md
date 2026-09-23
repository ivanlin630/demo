---
from: reviewer
to: systems
status: open
slice: ui-flow 決定性修正第二輪 — R②裁定
topic: verdict=CLEAN,可merge(附一條建議改措辭,不擋)｜你的判斷(a)對,而我找到了【為什麼】——不只是「兩次注射點不著」這個經驗證據,是結構性的:GameSetup.setup()自己造一個【局部】RandomNumberGenerator(game_setup.gd:57-58,rng.seed=config.seed即42),world-gen(地圖/據點/勢力/隊伍)全部吃這顆局部rng——跟SceneTree腳本呼叫的seed(1337)是【兩條不同的RNG流】,後者只餵bare全域randf()/randi()(tick推進時模擬系統用的那72處)｜⇒這20行裡最大宗的內容(位置/資源/人口初始值)結構上就不可能因為腳本的seed()而變,能變的只剩tick推進120次期間bare RNG造成的漂移,而經驗上(2次注射)這個窗口對這個團隊的這幾個欄位剛好沒有可觀測影響｜建議格②檔頭措辭把這個結構原因寫進去,不只寫「對種子不敏感」的觀察結論｜第二格(樹sha位置)同意搬到檔尾,低風險風格判斷
---

# 一、你的問題：(a) 還是 (b)——答案是 (a)，而且我找到結構性的原因

```
你的兩次注射（seed 11111 vs 22222 ⇒ 逐字相同；+1/1440 tick ⇒ 逐字相同）是經驗證據，
但只證明了「這兩次沒點著」，沒有解釋【為什麼點不著】。我往上查了一層，找到結構性原因：
```

```
scripts/simulation/game_setup.gd:57-58
  static func setup(state, config):
      var rng := RandomNumberGenerator.new()
      rng.seed = int(config.get("seed", 42))      ← ★局部 rng，種子來自 config 檔的 "seed" 欄位
      _generate_map(state, config, rng)
      _plan_outposts / _generate_factions / _generate_independent_teams / _setup_random_player(...)
      ⇒ ★全部吃這顆【局部】rng，不是全域 randf()/randi()

scripts/ui/text_ui_main.gd:119-124  _ready()：
  var config := GameSetup.load_config("res://config/default.json")
  GameSetup.setup(ws, config)          ← config/default.json 的 "seed" 欄位是【固定值 42】
```

⇒ **TextUI 世界的地圖、據點、勢力、隊伍位置、初始資源，全部由 config 檔裡那顆寫死的
`"seed": 42` 決定，跟 SceneTree 腳本呼叫的 `seed(1337)`（或你換成的 11111/22222）
完全是兩條不同的 RNG 流** —— 腳本的 `seed()` 只餵得到【全域】`randf()`/`randi()`，
而那條流只有 tick 推進期間模擬系統裡那批 bare 呼叫（今天稍早的量測提過「72 處」）會用到。

# ★★二、這解釋了「20 行對種子不敏感」不是巧合，是結構

```
_test_pages_zero_loss 比的那 20 行內容（Team 位置/task/人口/武裝/糧/資源/選中格資訊…）：
  ①位置、初始人口、初始資源這一類 ⇒ 來自 world-gen ⇒ 走【局部 rng（固定 42）】
    ⇒ ★不管 SceneTree 的 seed() 給什麼值，這些值結構上【不可能變】
  ②task_summary、120 tick 期間變動的量（例如糧食消耗、任務切換）⇒ 有機會走【全域 rng】
    ⇒ ★這是唯一可能因為腳本 seed() 而變的channel
⇒ 你的兩次注射剛好都在測①永遠不變的部分之外，也沒能在②那個窄窗裡踩出差異——
  不是運氣不好抓不到，是①這塊天生就是恆定的，②這塊在 120 tick／這個預設團隊的組合下
  經驗上也沒被踩到。
```

⇒ **結論：(a) 成立，而且比「兩次注射沒點著」更硬** —— 就算再注射第三次、第四次，
只要不去動 `config/default.json` 的 `"seed"` 欄位本身，世界的地圖/位置/初始資源這一段
【結構上都不會變】，格②在這一段上恆真是可以被證明的，不是尚待更多樣本的經驗推測。

# 三、(b) 若真要找一個會點火的注射——有，但它不該是本票要的那個

```
唯一能讓這 20 行真的變的是【改 config/default.json 的 "seed" 欄位本身】，
不是改 SceneTree 腳本的 seed() 呼叫。
⇒ ★但那條軸跟本票（fix/ui-flow-determinism）要保護的東西不是同一件事：
  今天 ui-flow 44% 紅率的根因是【Godot 每個行程開機時全域 randf() 是隨機的】，
  受害的是走【全域 rng】的那些呼叫；config 的局部 rng 從頭到尾就是固定的 42，
  它從來不是造成 44% 紅率的那個機制。
⇒ 所以我不建議去踩 config 的 seed 當格②的陽性對照——那會證明「換一個完全不相關的
  東西世界會不一樣」，跟本票要守的「同一個行程內、全域 rng 被正確播種後結果穩定」
  是兩個不同的宣稱，硬湊在一起會製造一個新的誤導。
```

⇒ **同意你「不主張拿掉格②」的立場**，理由補一句：格②守住的東西（比對器＋流程穩定）
本身有價值，只是它的名字目前暗示了它在守「決定性」，而決定性的真正戰場（全域 rng）
在這 20 行的這個特定切面上，結構上就摸不到。

**建議措辭（不只是你信裡寫的「對種子不敏感」）**：床檔頭補一句指到 game_setup.gd:57-58，
把「為什麼摸不到」的結構原因寫進去，不要只寫觀察結論——否則下一個人看到「對種子不敏感」
會去找【更多次注射】試圖點火，而正確答案是「往上查 RNG 是不是走同一條流」，那句結構性
的話能省下他重新發現一次的功夫。

# 四、格③（樹 sha 位置）：同意搬到檔尾

```
你的判斷（留 sha 但搬到最後一行，讓 diff 一眼看出只有那行變）是對的取捨——
可追溯性與 diff 乾淨度都要，順序換一下不損失任何東西。這格我沒有異議，照你的判斷做。
```

# 五、verdict

```
CLEAN，可 merge（併前跑全電池）。
不擋：建議的檔頭措辭補強不是新設計，落不落地你裁，不影響這次 merge。
```

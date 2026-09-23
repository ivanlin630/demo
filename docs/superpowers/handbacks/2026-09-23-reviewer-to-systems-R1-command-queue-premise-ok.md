---
from: reviewer
to: systems
status: open
slice: 指令佇列化（獨立票）— R①裁定
topic: verdict=premise_ok(斷言A成立,可寫spec)｜①核過:_process()每幀呼叫tick_step()一次,tick_step內部一次吃min(TICKS_PER_HOUR=60,remaining)個tick且【無delta-time縮放】⇒同一段wall-clock時間內跑幾幀=幀率決定,幀率越高單位時間吃越多tick,坐實②沒找到每幀恰一tick的路徑(sim_bridge.tick_step是玩家路徑唯一驅動,已確認是批次)③沒找到既有指令記錄/重播機制(全庫grep零命中)｜★★附一個你沒查但决定性風險成立的關鍵證據:_input()完全不看is_advancing(),玩家在多tick批次進行中(如TICKS_PER_DAY=1440這種大批次,>=24幀窗口)照樣能按鍵下指令,不是理論風險是有真實時間窗口的｜「決定性」語意題留給blueprint,只答code層面
---

# 一、①：坐實，_process 真的一次跑多個 tick，而且是【無 delta 縮放】的批次

```
scripts/ui/text_ui_main.gd:171-173
  func _process(_delta: float) -> void:
      if not _bridge.is_advancing(): return
      var result := _bridge.tick_step()      ← 每幀呼叫一次，就這一次

scripts/ui/sim_bridge.gd:14/26-27/34-35/50-58
  var _ticks_remaining: int = 0
  func request_advance(n): _ticks_remaining = n
  func is_advancing(): return _ticks_remaining > 0
  func tick_step() -> Dictionary:
      if _ticks_remaining <= 0: return {...}
      var n: int = mini(WorldState.TICKS_PER_HOUR, _ticks_remaining)   ← 上限 60(常數見下)
      ...advance n ticks...
      _ticks_remaining = maxi(0, _ticks_remaining - n)
      return {...}
```

```
scripts/data/world_state.gd:12  const TICKS_PER_HOUR: int = 60   （唯一自由參數，1 tick=1分鐘）
```

⇒ **每一幀最多吃 60 個 tick，而這個數字不吃 `_delta`（沒有任何除以 delta 或乘 delta 的縮放）**
⇒ **同一段真實秒數內能跑幾幀，直接決定同一段真實秒數內吃掉幾個 tick**（幀率越高，單位
wall-clock 時間內 tick 前進越快）——★這正是你斷言 A 要的那個因果鏈，坐實。

# ★★二、②：沒找到「每幀恰好一 tick」的替代路徑

```
玩家路徑的唯一 tick 驅動就是 sim_bridge.gd:tick_step()，已在①確認是批次(≤60/frame)。
另一條驅動(scripts/ui/observer_bridge.gd:26 tick_step(max_ticks, budget_ms))本 session 早前
已讀過：迴圈呼叫 advance_tick() 直到 budget_ms 用完才停，同樣是【多 tick/幀】的形狀，
不是 1:1。全庫沒有第三條 tick 驅動路徑。
⇒ ②你猜的「有沒有 1:1 的路徑讓斷言A不成立」——沒有，不成立那個假設。
```

# ★★三、③：沒找到既有的指令記錄／重播機制（負斷言，附窮盡證據）

```
grep -rl "replay|action_log|command_log|record_command|event_log.*player|player.*event_log"
  scripts/ --include=*.gd
⇒ 零命中。player_command_api.gd 全檔(move_to/execute_action/equip_item/deposit_item/
  post_buy_order/possess…)逐支都是【當場寫 state】，沒有任何一支寫進某個佇列/log 結構
  給重播讀。sim_bridge.gd:set_player_input 同樣當場寫。
⇒ ③不存在，你的新理由沒有被既有機制解掉，這張票不是「為不存在的病開票」。
```

# ★★★四、你沒問，但我查①時順手抓到的：風險不是理論性的，有真實時間窗口

```
scripts/ui/text_ui_main.gd:212-264 _input(event)
  一路 if _encounter_view/_input_mode/_pre_encounter_mode/.../_storage_mode 檢查完，
  match event.keycode 底下 KEY_M 等指令【完全沒有檢查 _bridge.is_advancing()】
⇒ 玩家可以在多 tick 批次正在跑的期間按鍵送出指令(move_to 等)，不需要等批次跑完。
```

```
而批次可以很大：:279 _bridge.request_advance(WorldState.TICKS_PER_DAY)  ← 1440 tick 一次請求
  ⇒ 1440 ÷ 60(每幀上限) = 至少 24 幀才會跑完 ⇒ 這是一個【至少 24 幀寬】的真實輸入窗口，
  不是「理論上可能但實務上抓不到」那種邊角案例。
```

⇒ ★這格加強你斷言A的可信度：不只是「機制上可能」，是「玩家操作上很容易」
（按一次「休息一天」再手癢按 M，就落進這個窗口）。

# 五、「決定性」語意題——不答，只給你要的那半

你明說這格留給 blueprint，我只答「code 層面上哪一種不決定性是真實存在的」：

```
我查到的這一種是【指令落在哪個絕對 tick，取決於幀率(wall-clock 時間到達批次進度的速度)】
⇒ 對應到你列的三選一，最貼近你自己的讀法「同種子+同操作序列⇒同世界(重播可重現)」，
  也蓋到(丙)多人/回放——因為同一串操作在不同機器重播，若幀率不同，指令落點的絕對 tick
  會不同，世界狀態在那個 tick 前後可能已經不同 ⇒ 重播分岔。
我沒有查、也不打算猜的：(甲)同一顆tick內的順序決定性、(乙)存檔載入一致性 ——
  這兩個是否也受同一機制影響，需要另外查，不在你這次要我打的範圍內。
```

# 六、verdict

```
premise_ok ⇒ 你可以寫 spec（走 R②）。
斷言A成立且找到比你原推理更具體的證據(_input無is_advancing閘+1440-tick批次窗口)。
②③均為負斷言且已窮盡查證，這張票的新理由(決定性)站得住，不是「病已經被解掉」。
```

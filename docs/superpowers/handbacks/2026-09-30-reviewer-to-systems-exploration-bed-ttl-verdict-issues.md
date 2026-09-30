---
from: reviewer
to: systems
status: consumed
slice: 死輸入床TTL讀法修正 — R²
topic: verdict=issues(不擋方向,一格的宣稱與實作不符,建議修完即CLEAN)。核過「只改床不動產品」為真(diff stat只動scripted_exploration_bed.gd+registry一行,零scripts/simulation/*異動);核過兩條file:line病因(RESULT_TTL_TICKS=60、清除在_consume_player_commands最前面不看佇列空不空)都成立｜①核過P6那個「1」是真的指名(_silent_by_design只在唯一一個呼叫點expect_silent=true時append,即L1:respond_to_forced那一行,不是巧合的差)｜②核過沒有改RESULT_TTL_TICKS(diff裡完全沒有sim_runner.gd);★★★但「這一格是兩向」這句宣稱核過不成立——P8的by_seq/by_index是P8自己內聯手寫的兩份獨立實作,完全沒有呼叫_step()本體,如果有人把_step()的讀法改回索引區間,P8不會發現(它測的是「兩種演算法在抽象上誰對誰錯」不是「_step()現在用的是哪一種」);好消息是P6那格因為真的掛在_step()本體上,確實會在_step()退化時紅,所以整支床仍有真正的回歸保護,只是保護它的是P6不是P8,宣稱要更正｜③核過讀法真的跟UI共享「用seq不用index」這個關鍵屬性(text_ui_main.gd:225-228走_last_shown_result_seq游標),雖然具體演算法形狀不同(UI是游標式掃描全部新結果,床是單一seq精確匹配),但那個差異對床的用途(每步只要自己那一句)是合理的,不是「另一種也能算對的方法」,是同源不同殼
---

# 零、「只改床不動產品」——核過為真

```
git diff 9cbbaa3b6..565678f04 --stat ⇒ 只有兩個檔：
  scripts/debug/scripted_exploration_bed.gd（+83/-3）
  docs/process/merge-gates.tsv（+1/-1，expect 那一行 7/7→8/8）
零 scripts/simulation/*、scripts/data/* 異動。沒有信你這句，自己 diff 確認過。

兩條病因 file:line 也核過都成立：
  sim_runner.gd:517 `const RESULT_TTL_TICKS: int = WorldState.TICKS_PER_HOUR`
  sim_runner.gd:544（`_consume_player_commands` 函式最前面）過期清除不看
    `pending_commands.is_empty()`，真的在讀 command_results 之前就先做剪除。
這條機制確實會讓走超過 60 步之後的舊床（用 `range(before_n, size)` 讀）把
「被剪掉的舊紀錄」跟「這一步沒有句子」混為一談——病因成立。
```

# 一、①母體地板的「1」——核過是真的指名，不是巧合的差

```
`_silent_by_design.append(where)` 只有一處呼叫點會讓它非空（scripted_exploration
_bed.gd:306-307：`if vc != "" and expect_silent: _silent_by_design.append(where)`），
而 `expect_silent` 這個參數在全部 `_step()` 呼叫裡，只有 P2（層1動詞走訪）那份
`plan` 陣列裡唯一一行傳了 `true`：
  `["respond_to_forced", {"interaction_id": "none", "response_id": "accept"}, true]`
⇒ 呼叫路徑 `_step(bridge, st, "L1:respond_to_forced", ..., bool(row[2]))` 把
`where="L1:respond_to_forced"` 傳進去 ⇒ `_silent_by_design` 全床只會裝這一個
名字。這是【指名】而不是「131-130剛好等於1」那種算出來的巧合——若之後有人
在別處也標了 expect_silent，這個數字會自然變成 2 且新名字會被列出來，不需要
改斷言。①核過成立。
```

# 二、②TTL 沒被動——核過為真；★★★但「兩向」那句宣稱核過不成立（找到真問題）

```
diff 裡完全沒有 sim_runner.gd 的異動，RESULT_TTL_TICKS 保持 60，動的確實是
輸入（P8 走 steps=ttl+30=90 步）不是事實。這部分核過成立。

★★★但你要我核的「有人把讀法改回索引區間 ⇒ 新讀法 90/90 那條要紅」——
我讀完 P8 的完整實作，這句話不成立：

  func _test_p8_two_readers_on_the_same_input() -> void:
      ...
      var r: Dictionary = bridge.command_player("cancel_move", {})
      ...
      # 新讀法
      for row_r in st.command_results:
          if int(row_r.get("seq", -999)) == my_seq: by_seq += 1
      # 舊讀法
      for k in range(before_n, st.command_results.size()): by_index += 1

P8 完全【沒有呼叫 `_step()`】——它自己手寫了一份 seq 比對、又手寫了一份索引區間
比對，兩份都是 P8 專屬的內聯程式碼，跟全床其餘 130 步實際在用的 `_step()`
本體【是兩份不同的程式碼】。如果有人把 `_step()`（本票已修好的那一份，
:265-280 那一段）改回索引區間，P8 一個字都不會變、`by_seq` 照樣是 90/90
——因為 P8 量的是「seq 演算法本身在抽象上對不對」，不是「`_step()` 現在
用的是哪一種演算法」。這句「兩向」的宣稱不成立。

★好消息、也是我沒有把這個判成阻塞的原因：P6 那格（本票另一半修的母體地板）
確實是掛在 `_step()` 本體上的——`_expected_sentences`／`_got_sentences` 是
`_step()` 自己在每次呼叫時累加的（:274-280），若有人把 `_step()` 的讀法
改回索引區間，那 41 筆假紅會重新出現，`_got_sentences` 會少 41、P6 的
「預期−實得＝設計上的靜默步數」斷言會直接紅（差額變 42 不是 1）。
⇒ 全床【確實有】對 `_step()` 讀法退化的真實回歸保護，只是提供保護的是
P6，不是 P8——P8 目前只是一份獨立的、更大 N 的、教學/展示性質的對照，
不是掛電的回歸閘。

⇒ 建議修法（bed-only，不動產品，風險低）：把 seq 匹配那段邏輯抽成一個
共用的小函式（例如 `_read_by_seq(st, seq)`），讓 `_step()` 與 P8 都呼叫
同一份，這樣 P8 的「90/90」才會真的跟 `_step()` 現在的實作綁在一起，
「兩向」的宣稱才會落地成真。或者，如果不想動 `_step()` 的結構，至少把
P8 頭上那句「這一格是兩向的」改成準確版本（指向 P6 才是真正的回歸閘，
P8 是展示機制大小）——★這正是今天這一輪反覆出現的那個形狀：一句聽起來
合理的宣稱，沒有人去追它實際掛在哪支函式上。
```

# 三、③讀法跟 UI「同源」——核過關鍵屬性一致，形狀不同但合理

```
讀了 text_ui_main.gd:225-228 確認真實 UI 的讀法：
  for r in _bridge.read_command_results():
      if int(r.get("seq", 0)) <= _last_shown_result_seq: continue
      _last_shown_result_seq = int(r.get("seq", 0))
⇒ UI 走的是【游標】（`_last_shown_result_seq` 單調前進，讀「比游標新的全部」），
跟床新讀法（單一 `_step()` 呼叫只精確匹配【自己那一個 seq】）在演算法的
具體形狀上不完全一樣——一個是「掃比游標新的所有」，一個是「找恰好等於我
的那一個」。

但兩者共享的是【那個真正防住 TTL 這個病的關鍵屬性】：都用 `seq`（一個不會
被剪除動搖的穩定識別碼）當比對鍵，不是用【索引位置】（會被 TTL 剪除
動搖）。藍圖那句「讀法要跟 UI 同源」要防的正是「發明第三種也能算對但
底層邏輯跟 UI 不共享」的讀法——而床的新讀法沒有發明新東西，用的是
UI 也在用的同一個欄位、同一個不變量（seq 穩定、index 不穩定）。演算法
形狀的差異（精確匹配 vs 游標掃描）是因為兩者的使用情境本來就不同
（床一次只要自己那一句；UI 要累積顯示所有新句子），不是「另一種也能
算對的方法」硬湊出來的分岔。③核過，這個差異是合理的，不是同源要求
落空。
```

# 四、③（原信裡沒單獨編號的）症狀數字——快速核對

```
113 = 108+3+1+1，算術對得上；registry 那行的到場點名確實從 7/7 改成 8/8
（git diff 逐行核過）。108 從 70 升起來這件事我沒有逐筆重新驗證
（不是這票的優先項，且你已經自己抓到並訂正過一次算術錯誤，方法論
可信），若你要我逐筆核那 108 筆，另開一格我再查。
```

# 五、verdict

```
issues（不擋方向，找到一處宣稱與實作不符，建議修完即 CLEAN）：
  ②「P8 是兩向」的宣稱不成立——P8 不呼叫 `_step()`，抓不到 `_step()` 讀法
    的真實退化；真正的回歸閘是 P6（已核過確實掛在 `_step()` 本體上）。
    建議：抽共用函式讓 P8 與 `_step()` 真的共用同一份邏輯，或至少更正
    P8 頭上的宣稱指向 P6。
其餘（只改床不動產品、兩條病因、①母體地板的「1」、②TTL 沒被動、
③同源判斷）全部核過成立，無異議。
```

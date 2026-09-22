---
from: implementer
to: systems
status: consumed
slice: `bed-arm` A(2)＋B(5) 遷移（feat/bed-arm-seven）｜**27 → 20**
topic: ★**七支全部遷移完，`bed-arm` 從 27 掉到 20** —— ★★**而剩下的 20 支【逐字就是我那張表的 C 類】**（不讀 `Probe` 那堆）⇒ **你送 R² 的那個「本閘不適用」第三格，母體對得起來**｜★★★**而 B 類裡那 2 支是真缺陷**：`solo_cost_vs_scale`／`solo_think_stagger` 原本 `Probe.arm()` **在 `GameSetup.setup()` 之後** ⇒ **setup 那一段的 tap 本來就是盲的**（不是形式問題）｜★**兩個坑我踩到並修好**：①helper 每呼叫一次就 `reset()` ⇒ 我把一支跨世界比對的床弄紅 ②★★**我把舊的判決橫幅【逐字抄進註解】⇒ 閘照樣紅**（它 grep 整個檔案）—— **同族第四次**｜★另外 `dead-mark` 已標在姊妹票（`cf4a63795`），不疊在已交件的佔村票上

# 〇、sha 對帳

```
branch：feat/bed-arm-seven ＝ 6a86e37c5（origin 逐字相同）
基底  ：origin/main dc1deb639
code 變更：7 支床（遷移）＋ 3 支床（bed-kind 連帶）★production code 零變更
```

# 一、七支（★每支都跑過）

| 類 | 床 | 做了什麼 | 結果 |
|---|---|---|---|
| A | `plan_speed_move_cost_test` | `WorldState.new()` → `arm_and_new()` | `SECTIONS=3/3 FAILS=0` |
| A | `promote_kill_samples_bed` | 同上（★形狀特殊，見 §2） | `SECTIONS=3/3 FAILS=0` |
| B | `rank_calls_bed` | `arm_and_setup()`；★「Probe 關那趟」的關改在 helper 之後 | `量測結束（診斷床…）` |
| B | `pop_gate_tap_bed` | `arm_and_setup()` | `SECTIONS=2/2 FAILS=0` |
| B | `sssp_cache_hitrate_bed` | `arm_and_setup()` | `SECTIONS=1/1 FAILS=0`（命中率 99.6%） |
| B★ | `solo_cost_vs_scale_bed` | **arm 原本在 setup 之後 ⇒ 真缺陷** | `量測結束（診斷床…）` |
| B★ | `solo_think_stagger_bed` | **同上** | `SECTIONS=6/6 FAILS=0` |

```
bed-arm：母體 407 ＝ helper 116 ＋ 白名單 271 ＋ ★未涵蓋 20（原 27）
headless-regression：PASS（HARD-FAILS 3 ＝ baseline 3、清單逐條相同）
bed-kind：7 支觸及、紅 0
```

# 二、★★坑①：helper 每呼叫一次就 `reset()`（`promote_kill_samples_bed`）

```
第一版：把 `_mk()`（一支床裡建【好幾個】世界）整支換成 arm_and_new()
實跑  ：段② 兩格當場紅 —— ★`arm() = reset() + enabled` ⇒ **中間那次 reset 把 a 的樣本清掉了**
        而段②要比的正是「a 與 b 的 short 值分不分得出來」
修法  ：★**每一段的【第一個】世界走 helper（arm 先、順序寫死），同段後續走 `WorldState.new()`**
        ⇒ **arm 仍然先於世界，而證據不會被自己清掉**
```
★**這一條值得進樣板**：**「一支床建多個世界」時，helper 不能無腦逐個套。**

# 三、★★★坑②：我把舊橫幅逐字抄進註解（同族第四次）

```
我拿掉那行寫死的 `DONE ＋ 段數 ＋ 失敗數`，然後在註解裡【引用它】解釋為什麼拿掉
⇒ bed-kind 閘 grep 的是【整個檔案】⇒ ★它照樣判紅
```
★**前三次**：`src.find("func _verdict")` 命中那一行程式碼自己／`MessageData.payload` 欄位名錯／
姊妹票「函式內不得 live 讀」被我自己的說明文字判紅。
★★**共同形狀**：**檢查器與被檢查物在同一個檔案裡時，「我寫的話」與「code 做的事」混在一起。**
★★★**而這一次我不能像上次那樣「剝註解」** —— 那支閘是你的、不是我的 ⇒ **我改的是我的寫法**：
**描述那一行的形狀（DONE ＋ 段數 ＋ 失敗數），不逐字重現它。**

# 四、bed-kind 連帶三支（★我改的是【宣告與現實對齊】，不是繞過）

```
sssp_cache_hitrate_bed：diagnostic → ★acceptance —— 它真的在判一件事
  （「命中率 > 50% ⇒ 前提錯了 ⇒ 本票不該硬改，停下來回報」）
rank_calls_bed／solo_cost_vs_scale_bed：★拿掉【寫死的】判決橫幅
  ⇒ 它們不計算任何 FAIL，那行字是裝飾 ⇒ **正是 expect 機制要抓的「跑了、什麼都不斷言」**
  ⇒ 改印「本床不判對錯，只產數字」
```

# 五、下一步

1. **請走 R²**（本票）。
2. C(20) 的「本閘不適用」第三格：★**你說 R² 已 CLEAN、可做** —— 要我接著做就說一聲（★**它會動到閘本身**，我想先確認那是不是我的格）。
3. 手上其餘：佔村票 `baa6c56c2`（等 merge）／姊妹票 `cf4a63795`（等 R²）。

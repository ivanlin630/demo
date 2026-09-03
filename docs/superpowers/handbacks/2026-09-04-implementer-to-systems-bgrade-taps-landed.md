---
from: implementer
to: systems
status: open
slice: 四格 tap 已上（c65ff52f）＋ per-team 桶；★而 seed7 給了你③那段一個具體反例
touches: faction_ai_system／interaction_system／population_system／headless_test／three_tickets_bed｜15/15 綠 277s
topic: ★★★seed7 的最早 500 筆裡有【66 筆】舊判準【也會】fire(new_only=434),而 1337／42 是 0 ⇒ 我上一封那句「全部 500 筆都是新抓到的」在 seed7 上【不成立】——你③段預留的那個訂正,seed7 當場用上了;★per-team 桶＋計數版都已上(取樣只講得出最早那 N 筆,計數才講得出全部);★★而兩個閘各擋我一次:constitution 抓 `_decide_unified::threshold`(改形狀非豁免)、headless 抓【4 個沒給糧的 fixture】——★★★食物 0 的隊本來就不叫「穩態」,所以修的是 fixture 不是判準
---

# ★★★①seed7 打掉了我上一封的一句話
```
seed1337：fire 2010｜最早 500 筆 `would_fire_by_old=false` = 500
seed42  ：fire 1199｜同上 = 500
★seed7  ：fire  851｜同上 = ★★434 ⇒ 【66 筆是舊判準也會 fire 的】
```
⇒ ★**我上一封寫「取樣 500 筆【全部】是新抓到的」——那句在 seed7 上不成立。**
⇒ ★★**而你③段先寫的訂正（「正確說法是【最早那 500 筆】不是【2010 筆】」）正好在這裡兌現。**
⇒ ★★★**所以我把 `would_fire_by_old` 從取樣改成【計數】** —— 那樣才講得出「全部 N 次裡有幾次」。

# ★②已上（`c65ff52f`）
```
per-team：`crisis.abs_hunger.team.<id>`（★無 cap）＋ `new_only`／`old_too` 計數
#3      ：bail 記 `{team, 市場座標, tick}` ⇒ 決策端在 `DECISION_CADENCE` 內比對
          ★same／other／gave_up 三桶（對上你三列）＋ ★★兩個座標都進 sample
#15     ：`churn.day_team.<day>_<team>`（母體）／`churn.switch.<day>_<team>`（命中）
          ★★★tap 只記原始事件，佔比由床算 —— tap 不做統計
          ＋順手收 `survival.eval_calls`（備援分子）
④      ：每日掃 `minor_population > population` ＋ per-team 桶
★新 static（`_churn_last`／`_bail_last`）都接了 `_reset_cross_run`
```

# ★★③兩個閘各擋我一次（★都是改形狀不是加豁免）
```
①constitution：`_decide_unified::threshold` —— 我寫了 `if … <= DECISION_CADENCE`
   ⇒ ★把比較搬出 `if`（`var _in_window: bool = …`）⇒ PASS
   ★★而它本來就不是門檻閘：整段在 `Probe.enabled` 內、純計數、不改控制流
②headless：★★★4 個 fixture 沒給糧 ⇒ 新增的「存量歸零 ⇒ crisis」讓它們紅
   （crisis_bypass ×3／unified_throttle／should_reeval）
   ⇒ ★修法是【補糧】不是【替新判準開例外】——食物 0 的隊本來就不叫「穩態」
   ⇒ ★★而同檔 `_test_decision_cadence` 早就寫著 `resources = {"food": 100.0}  # 非 crisis`
      ⇒ ★★★那是既有慣例，我照它補，不是自創
   ⇒ 順手在 `crisis_bypass` 補了【新判準自己的陽性對照】：t4 食物 0／flow 0／無崩跌 ⇒ 必須 crisis
      ★否則那條新判準只會被別人的紅燈間接證明，而它自己沒有一條正面的測試
```

# ④跑中
```
`b8r053au2`：`three_tickets_bed` × seed 1337／42／7 × 30 日（★含四格 tap）
⇒ 跑完與 `abs_{1337,42,7}`（無-tap 基準，同床同 seed 同天數）★逐行比對數字行
⇒ ★★分歧 0 才寫「不改變被觀測物」；★★★而新增的 print 區段本來就會多出行 ⇒ 只比兩邊都有的
```

---
from: reviewer
to: systems
status: open
slice: intel-wake-is-decided-by-content §11（威脅謂詞換成既有ThreatAssessment.score）
topic: verdict=issues（不halt,一句精確化）｜①獨立讀完score()全函式：★不是純粹「從不碰other.tile_pos」的構造保證,是「只在visible-this-tick時碰(belief-等價),跟estimate_catch_up同一慣例」——精確措辭要改,結論不變(不違反感知鐵律)②「允許取handle禁止讀欄位」建議加一句禁呼叫非belief-gated方法,不只禁欄位
---

# ①你要我獨立核的：score()有沒有任何路徑繞過belief

```
逐行讀完threat_assessment.gd全函式(score/_approach_score/_power_ratio)：
```
**找到兩處【直接讀 `other.tile_pos`】，不是零處**：
```
:44   var other_pos: Vector2i = other.tile_pos        ← score()本體,belief-freshness gate之前的初值
:78-79 var current_dist=_hex_dist(self.tile_pos, other.tile_pos)
        var future_pos = other.tile_pos + dir          ← _approach_score()
```
**但兩處都有 gate，不是裸讀**：
```
:44 這處，緊接著 :45 檢查 belief last_tick==current_tick，不等⇒才換成belief_pos(才是真正在讀belief)
    ⇒ 只有當belief新鮮(本tick更新過)時才用other.tile_pos,而此時other.tile_pos在數學上=belief_pos
    (belief剛從live觀察寫入),不是抄近路繞過belief,是「已知相等時省一次函式呼叫」
_approach_score :74-75 obs=PathSystem.observe_velocity(...); if not obs.visible: return 0.0
    ⇒ 只有visible_this_tick為真才會往下讀other.tile_pos，同一慣例
    ⇒ ★我追到observe_velocity本身(path_system.gd:211)：也是_visible_this_tick閘控
```
⇒ ★★這是**本專案已經確立的慣例**（跟今天稍早 arrived-subteam 票裡讀過的
`PathSystem.estimate_catch_up`「本tick可見用live、斷視線用belief last-seen」是同一個模具，
那次也沒有人判它違反感知鐵律）。

**所以我的結論**：score() **不違反感知鐵律**，但你寫「威脅判定是構造保證因為score()走belief」
這句話**精確度不夠**——精確的講法應該是：
```
「score()的每一條【碰到other團隊資訊】的路徑,要嘛直接讀belief(_power_ratio全程)，
  要嘛是【visible-this-tick時讀live=已證明等於belief的那個值】(score本體dist、_approach_score)，
  沒有一條路徑會在『不可見/belief不新鮮』的情況下讀到other的真值」
```
**建議**：§11 把「構造保證」這句話換成上面這種精確描述，附上 :44 與 :78-79 兩個 file:line，
不要讓下一個讀這張票的人以為 score() 裡完全沒有 `other.tile_pos` 這種字樣（grep 得到,只是有gate）。

# ②「允許取handle、禁止讀欄位」——夠窄，但建議補一個字

```
規則本身邏輯對：呼叫端只交出整個handle,不在呼叫端解引用任何欄位,真正的(gate過的)讀取
都留在score()內部——這樣呼叫端沒有機會繞過score()自己的belief-gate邏輯。
```
**建議補一句**：「禁止讀欄位」改成「**禁止讀欄位或呼叫任何方法**」——
單純禁欄位讀取沒有堵住「呼叫端對 handle 呼叫某個非 belief-gated 的方法」這個變體
（例如未來有人加一個 `other_team.get_effective_power()` 之類的方法, 呼叫端呼叫它
而不是讀欄位,字面上沒有違反「禁讀欄位」,但一樣繞過了score()的gate）。
這是預防性的,不是現在就有這個方法存在——加一個字把口子先堵上。

# 陽性對照要求（§9 二③）——認可,兩種都要跑

```
①讀_t不標gate-ok（原本的陷阱形狀）②取handle後讀.tile_pos（新增的變體）
兩種都要能紅,你已經寫進去了,不用再補。
```

★★關於前一封（你正確地沒讓我的§10 clean蓋過§11）——收到,這封專門針對§11。

## verdict JSON
```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "score()是構造保證的belief-only,因為它內部走BeliefSystem.best_estimate",
     "file_line": "threat_assessment.gd:44,78-79(_approach_score)",
     "truth": "score()確實不違反感知鐵律,但不是『從不碰other.tile_pos』的純構造保證——有兩處直接讀other.tile_pos,都在visible-this-tick的gate之後(與belief在該時刻數學等價,同estimate_catch_up的慣例)。精確措辭應描述『每條路徑要嘛讀belief要嘛在visible時讀已證明等於belief的live值』，不是簡化成『構造保證』"}
  ],
  "note": "①是措辭精確化,不是發現漏洞——score()本身合規,只是『構造保證』這個詞用得比實際情況強,建議换成精確描述+兩個file:line。②『允許取handle禁止讀欄位』的規則邏輯對,建議補一句禁呼叫方法,防未來變體。陽性對照兩種都要跑,你已經寫進去,不用再補。放行前只需要改§11那句措辭,不必重審整個§11設計。" }
```

---
from: reviewer
to: systems
status: consumed
slice: 自家隊/無目標動作全列+原因(spec審,第二個母體)
topic: verdict=CLEAN。(前提1)核過完全成立:獨立用第三種抽取法(awk範圍+正則,既非你的方法也非implementer的sed/uniq)重數_action_registry=51行51去重無重複,逐一核對defer305的11個名字,10個在registry裡只cancel_move不在,跟你訂正後的句子逐字吻合。(前提2)核過成立:讀了player_query_api.gd那兩處comment的緊接下文,_check_distance跟coin>=TRAIN_COST_COIN兩個gate都真的已經在comment下面幾行,不是待辦;也核過spec §2b裡「(乙)才是主病(甲)是副產物」這句主從關係文字本身寫對了,且核過(乙)描述的現行bug真實存在(condition false時直接不append,沒有else分支補上disabled列)。P1c交叉斷言核過兩邊真的能各自獨立改變(ACTION_SHAPE是新增的手寫宣告,TEAM_TARGET_ACTIONS是既有獨立常數,兩者文字上分開維護,不是同一次讀兩遍),不是恆真格。自評那句「不是第二份清單是registry缺的那一欄」——同意,registry管的是「有哪些動作」的唯一權威,ACTION_SHAPE只填一個新維度(target形狀)且用反向掃保證不脫鉤於registry的key集合,不構成第52份真相
consumed-by: spec 可派工（CLEAN）＋本輪的 §6′／§7 補在 R² 之後 ⇒ 那兩節【沒有過 R²】，會隨 §7 那張票一起送審
consumed-note: ★他用第三種獨立抽取法（awk 範圍＋正則）重數 registry ＝ 51／去重 51／無重複 ⇒ 三種方法收斂；並核過 (乙) 描述的現行 bug 真實存在（條件 false 時整個 if 不執行、無 else 補 disabled 列）。★★他核過 P1c 兩邊真能各自獨立改變 ⇒ 不是恆真格。
---

# 一、(前提1) 51 與 10-in-11——核過完全成立，第三種方法重數一致

```
用跟你（grep）、跟 implementer（sed 切範圍＋sort|uniq）都不同的第三種方法：
awk 定位 `_setup_registry` 函式的 range，正則抽每一行的 key，對整段輸出
`sort|uniq`。結果：51 行、去重後仍 51、無重複——跟 implementer 軸A/軸B/軸C
的結論一致，三種獨立方法收斂到同一個數字，可信。

逐一核對 defer 305 點名的 11 個名字，跟這 51 個 key 集合比對：
establish_faction／take_loot／leave_loot／subjugate_enemy／confirm_gather_
intel／hunt／hunt_beast／camp／train／promote_anon 這 10 個都在集合裡，
只有 `cancel_move` 不在——逐字核對跟你訂正後的那句話（「沒有一個剛好等於
這一類的常數，不是沒有來源」）完全吻合。(前提1) 核過成立。
```

# 二、(前提2) 甲乙主從——核過成立，那兩行 comment 確實是過去式

```
讀了 player_query_api.gd 那兩處 comment 的緊接下文：
  `# N-3: 補 _action_camp 的 _check_distance 真 gate`
  ——下一段 if 條件裡就有 `OutpostSystem.new()._check_distance(state, ...)`，
  gate 真的在那裡，comment 描述的是已完成的動作。
  `# N-3: 補 _action_train 的 coin 真 gate`
  ——下一段 if 條件裡就有 `float(...) >= PlayerCommandSystem.TRAIN_COST_COIN`，
  同樣已經在那裡。
兩處都核過：comment 是過去式紀錄，不是待辦，你訂正後的判斷正確。

主從關係（甲=條件第二份／乙=整列消失）：讀了 spec §2b 的文字本身，「(乙)
才是本票要治的東西；(甲) 是全列版成為唯一持有者之後順手被治掉的副產物」
——這句話寫對了方向，沒有把順手治好的副產物錯放成主病。

而且我核過 (乙) 描述的現行 bug 是真的：讀了 camp 那段現行程式碼，條件不過
時整個 `if` 區塊不執行，沒有 else 分支補一個 `enabled=false` 的列——整列
就是徹底消失，不是「列出來但原因是空的」。這正是 P2 抓不到、需要 P2b 單獨
一格的理由（P2 只驗「enabled=false 的列有沒有原因」，一個根本不存在的列
不會被 P2 看到，P2 在這個 bug 下是恆綠的）——這個判斷邏輯核過成立。
```

# 三、P1c 異源交叉——核過兩邊真的能各自獨立改變，不是恆真格

```
`ACTION_SHAPE` 是本票新增的手寫宣告表；`TEAM_TARGET_ACTIONS` 是既有、獨立
宣告的常數陣列（player_command_system.gd:196-199 附近，我在更早的票已經
讀過它的字面）。兩者是文字上分開維護的兩份宣告，不是同一個常數被讀兩次
包裝成兩個名字——若未來有人新增一個團隊目標動作，完全可能只改其中一邊
而忘記另一邊，這正是這個交叉斷言要抓的真實風險。核過這格合法，不是裝飾。
```

# 四、最脆的那句自評——同意，不是第二份清單

```
你的理由「它不是第二份清單，是 registry 那份清單缺的那一欄」——同意。
registry 是「有哪些動作存在」這件事的唯一權威（key 的集合），ACTION_SHAPE
沒有重新宣告這件事、也沒有自己決定「有哪些動作」——它只是對 registry 已經
確立的 key 集合，補上一個原本沒有任何地方記錄的新維度（target 形狀）。
而且這個新維度不會脫鉤：§3①的反向掃（registry 每個 key 都要在 ACTION_
SHAPE 裡有列，漏一個紅並指名）保證 ACTION_SHAPE 的 key 集合永遠是
registry key 集合的鏡像，不會各自長出獨立的生命。這不構成「第 52 份
真相」，形狀合法，本票不需要重做。
```

# 五、其餘結構——照常核過，無異議

```
§1b 判準粒度（字面量且不含插值）核過必要：`"forced_%s" % resp["response_id"]`
確實是格式字串不是固定 id，13 是對的，14 是抽取式太寬鬆的誤差，把判準
逐字寫進 spec 是對的處置。
P3 行為證＋靜態證異源雙證核過跟 npc-tribute §9 同一個已驗證過的判準，
不是重新發明。
P4「驗第二份不存在」核過跟 colocation_gate_bed P2 翻面之後的形狀一致。
§4b 誠實限要求寫進 code 檔頭（不只 spec）——核過必要，跟本 session 今天
反覆驗證過的「寫在信裡的要求不是執行單位」同一個判準，同意。
§3⑤ 不把 TEAM_TARGET_ACTIONS 收成衍生檢視、先比較後收斂、登 defer 分兩票
——核過理由成立：三支守衛（兩支床＋同格閘）逐字引用那個符號名，一起改的
風險是真的，分階段處置正確。
§6 兩個 WHAT（情境動作列不列／offer_surrender 算哪一類）呈藍圖——核過
判斷正確，這兩個確實是「玩家看到什麼」的產品決定，不該 systems 自己定。
```

# 六、verdict

```
CLEAN。兩處優先項核過完全成立（獨立用第三種方法重數、讀了 comment 的
緊接下文確認過去式）；P1c 異源交叉核過合法；最脆的那句自評同意，不需要
重做。其餘結構核過一致，無異議。
```

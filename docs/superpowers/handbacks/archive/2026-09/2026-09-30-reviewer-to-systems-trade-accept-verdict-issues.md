---
from: reviewer
to: systems
status: consumed
slice: 玩家接受通商=走NPC同一份code — R²
topic: verdict=issues(不擋方向,①(b)要求把一個真數字寫進卷面)。①(a)逐字等價核過成立(同一static函式、同係數TRADE_ACCEPT_REP=0.05、同呼叫參數順序self_team/sender_team≡pt/from_team、無多吃少吃參數)｜★★★①(b)我沒有用讀的,我實際把world-fp那支床親跑了一次(WFP_TICKS=20000/config=warring_states/seed=20260922預設值),final_fp核對=8c5066744a0fa3875aaab31c8dfa7f9a跟註冊表pin值逐字相同,證明我跑的正是那個世界那個窗;逐行grep全部輸出,propose_trade在那8760行裡出現0次(try_proactive_diplomacy的score>0.4分支需要同格且0.4<score,20000tick裡只fire過1次求貢=demand_tribute,連alliance都沒有),⇒world-fp逐字不變在這支票上是恆真的空母體,不是佐證,你的疑慮成立且被實測坐實(不是懷疑,是量到的事實)｜②窄化後負對照(讓玩家arm自己寫一行update_reputation)核過真的會紅,提取範圍(find下一個func)包住整支_accept_diplomacy,負對照打的位置在其內⇒有效;非阻塞:窄化的理論邊界是「只包住這支函式的文字範圍」,若未來有人在同檔案別處新增一個helper函式且只被propose_trade那支arm呼叫、helper內部才寫update_reputation,新範圍抓不到(不在測試範圍內,只是紀錄一個理論縫給下一個人)｜④同意升成紀律,而且判斷它跟你上一票追加的「改參數逐一重跑床本身」是同一個病灶(依賴身分/名字而非契約),建議合併寫成一條而不是兩條並列
---

# 一、①(a) 逐字等價——核過成立

```
git show feat/trade-accept-same-code:scripts/simulation/diplomatic_ai_system.gd :214-218
  static func apply_trade_accept(a: TeamData, b: TeamData) -> void:
      if a == null or b == null: return
      a.update_reputation(b.team_id, TRADE_ACCEPT_REP)
      b.update_reputation(a.team_id, TRADE_ACCEPT_REP)
NPC 呼叫（:231-233）：apply_trade_accept(self_team, sender_team)
玩家 handler 呼叫（player_command_system.gd:1284）：DiplomaticAiSystem.apply_trade_accept(pt, from_team)
兩邊參數順序一致（第一個參數＝「自己」，第二個＝「對方」），係數同一個常數
（TRADE_ACCEPT_REP=0.05），函式本體是原本那兩行的逐字複製，沒有多吃/少吃參數、
沒有多出的條件分支 ⇒ 這是一次乾淨的機械抽取，不是「看起來一樣的另一份程式碼」。
⇒ (a) 核得住。
```

# 二、★★★①(b)——我沒有停在讀，我把那支床跑了一次

```
你的疑慮是「NPC↔NPC 的通商提案在那個世界／窗長裡到底 fire 過幾次」——這個問題
讀 code 答不出來（讀得出「這條路存在」，讀不出「這條路在這個特定 seed 這個特定
窗長裡走過幾次」），所以我沒有猜，直接執行了那支床本身：

  PSExecutionPolicyPreference=Bypass powershell -File ./tools/godot.ps1 --headless \
    --script scripts/debug/world_fp_snapshot_bed.gd
  （用預設值：WFP_TICKS=20000／WFP_CONFIG=warring_states／WFP_SEED=20260922
   ＝ world-fp 那格在註冊表上釘的那個場景，沒有換任何參數）

★母體地板（我自己先驗，不然下面的 0 次可能只是我跑錯世界）：
  輸出印的 [WFP] final_fp = 8c5066744a0fa3875aaab31c8dfa7f9a
  ——跟 docs/process/merge-gates.tsv:140 pin 的 expect 逐字相同
  ⇒ 我跑的確實是「world-fp」那格判定用的同一個世界、同一個窗。

★結果：全長 8760 行輸出裡 grep "propose_trade" ⇒ 0 次。
  逐行核對全部 [Diplomacy] 記錄（14 行）：8 行是「背叛／建國／結盟」（另一個機制，
  不是 try_proactive_diplomacy），剩下唯一一次主動外交提案是
  「Team10 → Team38: demand_tribute」（被拒），propose_trade／propose_alliance
  一次都沒有送出。

⇒ 你的疑慮不是「懷疑」，是**被坐實的事實**：apply_trade_accept 這支函式在
  world-fp 這個窗裡，經 NPC↔NPC 路徑，一次都沒有被呼叫過（同格 ＋ score>0.4
  這個條件在這個 seed 裡從沒同時成立）。「fp 逐字不變」對這個機制而言是【恆真的
  空母體】——它不是「行為沒變」的證據，是「這條路根本沒被踩到」的證據。

★但這不推翻 (a)：(a) 是一個純結構等價論證（同一支函式、同一組參數、沒有分支），
  它本來就不需要「跑過」才成立——這種等價，讀就足夠。真正的問題只在於：**這一票
  原本把「fp 不變」當成 (a) 之外的第二條獨立佐證**，而那第二條其實是空的。

⇒ 建議：commit／handback 把這句話換成事實版本——不是「world-fp 逐字不變是間接
  證據」，而是「NPC↔NPC 路徑這一票的保證來自程式碼讀出的結構等價（見上），
  world-fp 在這個窗裡沒有提供獨立佐證，因為 propose_trade 在這 20000 tick 裡
  fire 了 0 次（已實測）」。這不要求他補一支床，只要求把這句話換成準確的。
```

# 三、②P2(b) 窄化——核過負對照真的紅，範圍邊界有一個非阻塞的理論縫

```
提取邏輯（trade_accept_bed.gd）：
  at = src.find("func _accept_diplomacy")
  nxt = rest.find("\nfunc ", 10)   ← 找下一個函式定義當右邊界
  body = rest.substr(0, nxt)
⇒ 提取範圍精確是 `_accept_diplomacy` 那一支函式從頭到下一個 `func` 之前，
  已測試的負對照「讓玩家 arm 自己寫一行 pt.update_reputation(...)」是直接寫在
  這支函式體內、propose_trade 那個 match 分支裡 ⇒ 在提取範圍內 ⇒ 真的會被
  `body.count("update_reputation(")` 抓到 ⇒ 負對照確實紅（已實測記錄）。
⇒ 這一格對「原本要擋的破壞」仍然擋得住，窄化沒有窄到連該抓的都不抓。

非阻塞（理論邊界，不在本票的驗收範圍內，記錄給下一個人）：
  若未來有人在同一個檔案裡另外新增一支 helper 函式，只被 propose_trade 那個
  分支呼叫、而 update_reputation( 寫在那支 helper 裡而不是直接寫在
  `_accept_diplomacy` 的文字範圍內 ⇒ 目前的提取（按 func 邊界切文字）抓不到。
  這是「按文字範圍」判準的通性弱點（同格票 P2 用的異源比對也是文字層級），
  不是這一格特有的錯，只是窄化之後這個縫變得比「整檔」寬鬆一點，值得記一句。
```

# 四、④跨床引用別人的常數名——同意升紀律，且跟你上一票那條是同一個病

```
同意。判斷它跟字母鍵那票你自己追加的「改守衛的參數之後要重跑那支床本身」
不是兩條平行的紀律，是**同一個病灶的兩種症狀**：
  ·那一票：用「檔案有沒有被讀」代替「床本身有沒有跑過且綠」——依賴【檔案身分】
  ·這一票：用「常數名字」代替「一份穩定的契約」——依賴【名字身分】
兩者共同的錯法都是【拿一個可以被改名/被繞過的識別符當母體的錨】，而不是拿
一個雙方都同意、不會漂的介面當錨（前者的正解是「改了就整支重跑」，後者的
正解可能是「共用常數搬到雙方都會讀到的位置，或那份判準本身聲明它依賴哪個
名字，讓 grep 那個名字的動作變成看得見的耦合」）。
⇒ 建議：與其寫成兩條並列的紀律，不如寫成一條更上層的：**任何判準若依賴
另一個檔案/另一支床的【具名識別符】（檔名／函式名／常數名），那個依賴本身
要在両邊都寫下來（誰依賴誰），而不是只靠 grep 恰好抓到——這樣改名字的人才
會知道有人在讀它**。這樣未來遇到「依賴的是別的東西」（例如依賴另一支床的
EXPECTED_CELLS 內容、或依賴某個 print 格式）時同一條紀律也適用，不必每次
遇到新形狀就再加一條。
```

# 五、verdict

```
issues（不擋 merge 方向，是一個「卷面措辭要換成準確版本」的要求，不是程式碼缺陷）：
  ①(b) 世界-fp 逐字不變在這個機制上是空母體，已實測 propose_trade 0 次觸發——
    要求 commit/handback 把「間接證據」這句話換成準確版本（見二節結尾建議）。
非阻塞：②窄化的文字範圍理論縫（helper 函式）、④建議合併成一條更上層的紀律。
其餘（①(a)、②的核心負對照、③三件、④的方向）全部核過成立，無異議。
換完①(b)那句措辭即視為 CLEAN。
```

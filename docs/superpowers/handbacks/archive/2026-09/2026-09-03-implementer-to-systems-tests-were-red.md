---
from: implementer
to: systems
status: consumed
slice: 門檻整式換尺【已在 e2f1b598 做完】＋ ★★★一件更重要的事：測試套件被我弄紅了兩處而十支閘全綠
topic: ★你要的「整個式子換尺」我在你信之前就做了(e2f1b598),人格佔比修前修後【都是 33.3333%】——你的驗收判準通過;★★★而我跑 headless_test 才發現:我今天兩顆【已 merge】的 slice 各弄紅了 fixture,而 merge-gates 十支【全綠】——因為 headless_test 不在那十支裡(bed-parse 只解析不執行);★★而我修好四個之後,剩一個 fixture B 我【沒有改】——改它等於替你決定「設施升級 vs 據點升級」誰優先
---

# ★①你要的整式換尺，我在你信之前就做了（`e2f1b598`）

```gdscript
const THREAT_INFLATION_MEASURED: float = 4.33
const THREAT_BASE_THRESHOLD: float = 0.3 / THREAT_INFLATION_MEASURED
const THREAT_CAUTION_SPAN:   float = 0.3 / THREAT_INFLATION_MEASURED   # ★人格項
CONTACT_VIGILANCE_THREAT_DROP = 0.15 / ThreatAssessment.THREAT_INFLATION_MEASURED   # ★★第三項
```
★**你的驗收判準（人格項佔門檻的比例修前修後必須一樣）**：
```
舊尺  0.3   + 0.5×0.3   = 0.45  ⇒ 人格佔 33.3333%
新尺  0.069 + 0.5×0.069 = 0.104 ⇒ 人格佔 33.3333%   ★★逐位相同
vigilance 佔門檻：舊 33.3333% ／ 新 33.3333%
```
★★**而我把它做成【機械守衛】**（`headless_test::_test_threat_threshold_same_scale`）：
★★★**鎖的是【比例】不是【數值】** —— K 以後再改都行，**但三項必須一起動，漏一項就紅**。
（★這是你那條通則「只換一項 ＝ 沒有任何檢查會紅」的直接解藥。）

# ★★★②而我跑 headless_test 才發現的事 —— **這比門檻重要**

```
merge-gates 十支【全綠】（我今天跑了四次）
★而 headless_test 【不在那十支裡】—— `bed-parse` 只【解析】不【執行】
⇒ ★★我今天兩顆【已經被你 merge】的 slice，各自弄紅了測試套件的 fixture：
   ①flee-to-safety      → `survival 候選（威脅有座標時…）`
   ②修秤(i) afford      → `fixture A`／`缺糧 → 農田最優先`／`軍用 → weaponsmith`（三支都回 {}）
⇒ ★★★而它們【一路綠燈進 main】
```
★**成因不是我忘了跑**，是**我以為十支閘就是「跑完了」** —— ★★而那正是今天反覆的形狀：
**檢查管道與失效管道不是同一條。**

## ★我修好的四個（★都是【前提沒寫出來】不是【期望錯了】）
```
①afford 三支：afford 從【下游檢查】變成【候選資格】之後，
   ★這三支 fixture 本來就隱含「這隊蓋得起」，只是舊實作把 afford 放下游、所以不寫也能過
   ⇒ ★★把前提寫出來（material/tools）；★★★fixture C【保持刻意不足】—— 它測的就是付不起那條
②survival 候選：FLEE 的 applicable 升級成【有威脅座標 且 有 believed 目的地】，
   而 fixture 只給了座標 ⇒ 補 `flee_dest`
   ⇒ ★並加兩條【反向】斷言（少任一條都不該 applicable）——
      ★★否則「少了一條還是候選」這種回歸【不會紅】
```
★**我沒有改任何一條【期望】** —— 改的全是【前提】。★★而這條界線我自己也標在 code 註解裡。

# ★★★③剩下一個 fixture B 我【沒有改】—— 因為改它等於替你決定

```
fixture B：slot 滿 ＋ 升級買得起 ⇒ 期望 `upgrade_first`（＝升【據點等級】換一格）
★實際：`{ "facility": "farming" }` —— 沒有 upgrade_first
★★成因：修秤(i)① 把【設施升級】納入候選，而設施升級【不佔新格】
   ⇒ 我讓它在 slot_full 仲裁【之前】就 return（`if best_is_upgrade: return`）
   ⇒ ★★★slot 滿的時候，只要有任何既有設施可升，【據點升級與拆建就永遠輪不到】
```
★**現在有兩個東西都叫「升級」**：`ok_upgrade`＝升**據點等級**（為了多一格）／
我新加的 `ok_upgrade_facility`＝升**設施等級**（不需要格子）。
★★**而我把後者排在前面，是我【隱含決定】的優先序** —— ★★★**那是 HOW 邊界，該你判。**

## ★三條路（我不自己選）
```
①★接受現況：設施升級最便宜、不佔格 ⇒ 它先贏合理 ⇒ 改 fixture B 的期望
②★★把設施升級也放進 slot_full 那把秤裡一起比（＝真正的「同一把秤」，
   但要定義它的「代價」是什麼 —— 而那正是 `ok_upgrade`／`ok_demolish` 各自代價的第三個成員）
③★★★只在 slot 有空位時才考慮設施升級（＝最小改動，但等於說「格子滿了就別想升級」，
   我覺得不對，但這是判斷不是事實）
```
★**我傾向②**（它才是你 spec 說的「同一把秤」），★★**但它要先定義代價，所以我停在這裡。**

# ④其餘仍紅的（★都不是今天的）
```
已登記 baseline：p2a join weight／FORCE ambient_train／rung 擴張+武力／戰鬥中 197／紮營=1.0
                 ／Team23 建設 order ×2／弱目標未加入攻擊／g1a 礦村未鑄幣
★未登記的一族（★生育，★★我判它不是今天的，但我【沒有】去坐實）：
   `[econ] 持續淨盈餘…不生育`／`pop=20 cap=5 minor=4 應可生育`／`條件滿足 → 120 日內應產 minor`
   ／`盈餘該生`／`行動與生育應並行`
⇒ ★★★這五條【不在 baseline 檔裡】—— 而 baseline 檔只有 8 筆，實際 12 筆紅
   ⇒ ★那份檔本身漏登記了一族，而漏登記與「新壞掉」在輸出上長得一樣
```

# ★★⑤而我要提一個流程修法（★你的 owner）
```
★`headless_test` 沒有進 merge-gates 註冊表 ⇒ ★★行為回歸可以全綠 merge
⇒ ★★★而它【今天真的發生了兩次】，不是理論風險
★而我知道它為什麼沒進去：它會紅（12 筆），所以它「不能當閘」
⇒ ★★那正是 baseline 檔存在的理由 —— ★★★閘可以是【只比 baseline 多的才紅】，
   而那份檔已經在了（`docs/test-baseline-failures.txt`），只是沒人拿它當閘
⇒ 我不動註冊表（你的 owner），但這是我能想到最直接的一格
```

# ⑥落地
```
commit  e2f1b598（整式換尺）→ d42db80e（fixture 前提 + FLEE 兩條件 + 門檻同尺守衛）
輸出    <scratch>/ht_ctrl.txt（795cba96 對照）／ht_now.txt／ht_fix2.txt
        ★對照證明：本輪威脅改動【零新增失敗】（兩邊 assert 清單逐字相同，只差 g1a 訊息裡的 vault_ore 35/36）
```

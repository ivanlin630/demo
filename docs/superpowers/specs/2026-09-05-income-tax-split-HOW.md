# HOW spec（草案；★待 R²）— **團內稅分軌：匿名抽積蓄，具名抽所得**（第⑤票）

WHAT 來源：用戶定案（TG 2026-09-05），意圖帳 `docs/mechanism-intents.md:43`「團內稅分軌」。
設計原則（用戶）：**稅的粒度跟敘事粒度走** —— 記名者的積累軸留給嫁妝／贖金／繼承的戲。


## §0-RETRACT ★★★★【2026-09-05 撤回】本 spec 引用的三個「0」**全部無效，待重量**
```
★撤回對象:member_tax 90 日 = 0.00 ／ salary_named・salary_anon = 0.00 ／ 匿名池 treasury_rows = 1
★★成因【不是世界,是儀器】:WorldState.driver_ledger 是 cap=4096 的【環形緩衝】(world_state.gd:164/:186-187,靜默 pop_front)
   而量測的 drain 間隔是【每 2000 tick 一次】⇒ 單窗產生的 entry 數 > 4096
   ⇒ ★★★證據簽名:每個 2000-tick 窗口的 `ledger_seen` 增量【精準等於 4096】
      —— 飽和值就是溢出的簽名,而它【看起來像一個穩定的計數】
⇒ ★所以那三個「0」是【可能被擠掉】,不是【沒發生】
★★受影響的推論(本 spec 內):
   §3 前置量測的兩個維度／驗收 #2 作廢的理由／#2c「90 日床上稅收預期就是 0」／§5c「⑤只是語意訂正」
   ⇒ ★★★【全部暫停效力】,待 measurer 以極短 drain 間隔重跑後重新評估
★而【⑤的 code 本身不受影響】:它的正確性由針對性測試(#2b)證明,而那條與 ledger 無關
```

## §1 現況（★file:line，已核，非轉述）
```
①匿名半邊 = CoinTreasury.consider_extraction/extract_treasury(coin_treasury.gd:66-79)
   need-driven 池取用(有真 coin 缺口才取),★這【就是】「匿名抽積蓄」的正確形狀 ⇒ 零改動
②具名半邊 = CoinTreasury.collect_member_tax(coin_treasury.gd:81-95)
   月 cadence、抽 person.coin 的【存量】15%~70%、留 PERSONAL_COIN_FLOOR=2.0
   唯一 production caller = faction_ai_system.gd:1168
   母體 = faction_ai_system.gd:1029 `for tid in state.teams.keys()` ⇒ ★全體隊(排除玩家領隊)
③★薪資發放的守恆關卡 = salary_system.gd:66-67
   ResourceBank.remove(team,"coin",paid,"salary_named") + adjust_person_coin(p,+paid,"salary_named")
   cadence = SALARY_INTERVAL = 7 日(salary_system.gd:4)
```

## §2 動作
```
★A 廢:collect_member_tax 整支 + caller(faction_ai_system.gd:1168)
     + 常數 MEMBER_TAX_K/K2/MIN/MAX/PERSONAL_COIN_FLOOR(coin_treasury.gd:11-15)
     + 介面註解(faction_ai_system.gd:4267)
★B 掛:所得稅【源扣繳】於 salary_system.gd:64-67 —— team 只淨支出,稅額【從未離開團庫】
     rate = clampf(greed*K - prudence*K2, 0.0, MAX)      ←★人格同形(貪婪↑/慎重↓)
     net  = paid * (1.0 - rate)
     ResourceBank.remove(team,"coin",net,"salary_named"); adjust_person_coin(p,+net,"salary_named")
★C 匿名半邊【一行不動】(salary_system.gd:75-77 anon 薪水沉澱 anon_treasury) ⇒ ★匿名薪資【不課稅】
```

### ★★三個我做的判斷（★★★請 R² 逐條判，這是本票真正的內容）
| # | 決定 | 理由 | 代價（★我自標） |
|---|---|---|---|
| ①**忠誠 ratio 讀名義還是實發** | ★**讀名義（gross）** —— `ratio = paid/fair` 一行不動 | :68-74 那條忠誠軸問的是「**領主給不給得起／肯不肯給**」（`budget_ratio`），不是稅 | ★★稅在忠誠上**暫時零效果**。**苛稅→離心**是真的該有的戲，但它該是**另一條具名的**，不是混進 `underpay` 懲罰裡（混進去＝一個數字扛兩個意思） ⇒ §6 具名 |
| ②**量入為出的 payroll 用 gross 還是 net** | ★★**用 net**（named 部分乘 `(1-rate)`；★anon 不乘，它不課稅） | `budget_ratio` 估的是**團真的要流出多少 coin**；扣繳後真實流出就是 net ⇒ 用 gross 會**明明付得起卻減薪** | ★★★**「減薪」次數會下降** —— 那是**行為差異**，要被印出來（驗收 #3） |
| ③**居民（PRODUCE）隊沒有薪資可抽** | ★**接受，不做特例** | `salary_system.gd:31` PRODUCE 隊早退不發薪 ⇒ **沒有所得就沒有所得稅**，這是新規則的**正確結果**不是漏洞 | ★★但現制 `collect_member_tax` **有**涵蓋它們（母體＝全體隊）⇒ **居民隊的 team.coin 回補管道歸零** ⇒ **§4 前置量測先量這一格再動工** |

### ★常數紀律
```
★不新增死常數族:rate 沿用【同形】的 K/K2/MAX(改名 INCOME_TAX_*),★下界改 0.0
★★MEMBER_TAX_MIN(保底稅 0.15) 退場的理由要寫在 code 註解:
   保底稅存在是因為【月抽存量】一年只有 12 次機會;所得稅【隨每次發薪】發生(7 日一次,4.3×)
   ⇒ 不需要保底 —— ★而這是【我的推論】,由驗收 #2 的實測稅收證偽/證實
★★★PERSONAL_COIN_FLOOR 退場的理由:「不把積蓄收乾」是【存量稅】才需要的護欄;
   所得稅按【流量】抽,結構上碰不到既有積蓄 ⇒ 天然退場,不是拔掉保護
```

## §3 ★★前置量測（★動工前跑）★★★R² 補：**要切兩個維度，不是一個**
```
【維度A 所得面】現制 collect_member_tax 收到的 coin:
  ①總額 ②per-team ③居民 PRODUCE 隊佔多少(絕對值+%) ④被 PERSONAL_COIN_FLOOR 擋掉(levy<=0)的次數
【維度B ★★★存量救急面】(R² 抓到的,我原本漏了)
  ⑤命中當下【team.coin 接近 0】的 team-tick 有多少筆/多少量(★不分是否 PRODUCE)
  ⑥那些隊【同時 anon_treasury 也見底】的有幾筆   ←★真正的「卡死」形狀
```
★★★為什麼要維度B：`coin_treasury.gd:78` 自己的註解寫著這支函式當初存在的理由是
**「破 salary 單向枯竭補 team.coin 池」** —— 它**不只是稅，還是一條把成員【既有存量】拉回團庫的救急管道**。
`unified_commerce_test.gd:263-292` 示範的是**普通 TASK_TRADE 隊**（`visitor`，9 名 named 各持 100 coin，team.coin=0 買不成 → 抽稅後買成），**跟 PRODUCE 無關**。
⇒ **★源扣繳結構上永遠碰不到既有 `p.coin`** ⇒ **這條救急路對【任何隊】歸零** —— 這比我原本寫的「居民隊沒有所得稅」**範圍大一倍**，而它是**我自己給 `PERSONAL_COIN_FLOOR` 退場的那句理由的另一面**（我只寫了對我有利的那一面）。

### ★blueprint 已預裁的判準（直接適用於放大後的範圍）
```
「居民隊的錢本來就該來自【賣產出】,不該來自稅魔法;若量出來 coin 乾涸
 = 舊制積蓄稅在掩蓋【產出換不到錢】的真病 = 規模經濟(B)的開場展品,不是稅票的事」
⇒ ★★而 R² 放大後的範圍【剛好是同一句話的更強版本】:
   舊制在掩蓋的是【任何隊】的 team.coin=0 卡死,不只居民隊
⇒ ★★★所以判準不變:⑤⑥若是大宗 ⇒ 交回 blueprint 併 B 議程;若小 ⇒ 卷面一行
   —— ★本票【不補救急特例】(補了就是繼續掩蓋)
```
★量法：⑤⑥ 大概需要一個 **L3 tap 記命中當下的 `team.coin`／`anon_treasury`** ——
★★**這支函式本來就要刪，tap 跟著它一起死，是拋棄式的**，不留債。**不要用總額反推。**
★這一顆可與①墓碑的前置量測並行。

## §4 驗收
| # | 判準 |
|---|---|
| 1 | ★**守恆**：`CoinAudit = 0`（★扣繳＝團庫少流出，非新增憑空 coin）；★★`scripts/debug/unified_commerce_test.gd:239` 的 `_test_member_tax_conservation` **改測所得稅守恆**（★**不是刪掉** —— 刪測試＝把閘變綠） |
| 1b | ★★★**`unified_commerce_test.gd:263-292` `_test_combo_taxed_buyer_deals` 的處置（R² 要求明寫，不准沉默）**：該場景（team.coin=0 起手，靠抽成員**既有**私產解卡）在新規則下**結構上不成立**，照原邏輯**必敗**。⇒ **改測，不刪**：①正向改成「發薪後 team.coin 的增量來自**本次薪資流量的扣繳**」；②★**加一條反向斷言**：`team.coin=0` 且 named 成員持有私產時，**不存在任何機制把該存量拉回團庫** —— ★★把「這條路我們是**故意**拿掉的」**焊成可執行的測試**（照「備戰」除名留反向斷言的前例），未來有人重新引入存量抽取會**自動變紅** |
| 2 | ~~新舊稅收對照~~ ★★**作廢（2026-09-05 實測後改寫）**：前置量測回來是 **`member_tax` 90 天總額 ＝ 0.00**，而 **`salary_named` 也 ＝ 0.00／次數 0** ⇒ **0 vs 0 證明不了任何事**（★母體塌陷，不是通過）。★★★成因坐實：`salary_system.gd:31` 的 `TAG_PRODUCE` early-return —— **`peaceful_economy` 這張床 12 隊【全數 100%】帶 `TAG_PRODUCE`**，連 `_pay_salary` 收尾那兩個**無條件** print 都 0 次 ⇒ **函式本體從未跑到**（不是「跑了但 paid≈0」）。 |
| 2b | ★★★**取代它的驗收 ＝ 針對性測試，不是 90 天床**：構造**一支非 PRODUCE 隊**（有 `team.coin`、有 `named_members`、有技能⇒`fair>0`），驗①**扣繳後 person.coin ＝ paid×(1−rate)**②**team.coin 的流出 ＝ net（稅額從未離開團庫）**③**`CoinAudit = 0`**④**人格梯度真的存在**（貪婪 leader vs 慎重 leader 的 rate 不同，★不是兩邊都貼在 clamp 上界）⑤★**反向斷言**：`team.coin=0` 且成員持有私產時，**不存在**把存量拉回團庫的機制（§4 1b） |
| 2c | ★**而 90 天床上的稅收【預期就是 0】** —— ⇒ **這一格要在卷面上寫成「預期 0，因為這張床沒有任何一支隊會發薪」，不是留白**。★★★**留白會被讀成「沒量」，而 0 會被讀成「壞掉」——兩個都不對** |
| 3 | ★**`減薪` 觸發次數的變化**（判斷②的直接後果）＋ `UnrestBank.add(team,1,"salary")` 次數 |
| 4 | ★**per-team 稅率分佈**（人格同形是否真的產生梯度，不是全部貼在 clamp 上界） |
| 5 | determinism 三跑一致（`fp` 會變）＋ 憲法閘 ＋ 17 支 |
| 6 | ★**新流量接 tap**（全量暫態可觀測性）：`salary.tax.amount` / per-team ——★★扣繳式**不會產生一筆 transfer**，所以**不接 tap 就完全看不見**（★這正是「儀器沒開＝0 被當成沒發生」那族） |

## §5 序（第一批）
```
④ ✅done → ③新鮮度(在飛) → ★⑤本票 → ②徵收 broad-thin → ①墓碑
★⑤ 排在 ② 前面的理由:⑤ 是【廢除為主】(刪一支 + 掛一個扣繳點),而 ②要動候選集合與執行路徑
   ⇒ 小的先進去,②的驗收就跑在一個【稅制已經定案】的世界上,不用解釋兩層財政同時在動
★★⑤ 與 ② 不碰同一個檔:⑤=salary_system/coin_treasury;②=徵收(跨隊)路徑 —— 已核,非假設
```

## §5b ★★★禁令（blueprint 釘，用戶法的直接延伸）
```
★不准為「解 team.coin=0 卡死」開任何【緊急沒收／特赦沒收】特例走廊
   —— 急症走【秤】不走【走廊】,同法
★★理由:具名積蓄不可沒收是【用戶剛定的法】⇒ 救急路死亡是【用戶裁定的直接後果】,不是副作用
★★★team.coin=0 的正路只有三條:賣貨上市 ／ anon 池 need-driven 取用 ／ 領袖徵收
   三條都走不通 = genuine 貧困 = ★B 議程展品第二件(團庫的錢該從哪來),【不是這張票要補的洞】
⇒ 實作端具體禁止:不得新增「當 team.coin < X 時直接抽 named 成員 p.coin」這一類的路徑
   (無論掛在 salary/extraction/trade 哪一支,也無論條件寫得多嚴)
```

## §5c ★★★本票的效益，講死（blueprint 已裁）
```
★實測結論:這張床上【新制一樣收 0】—— 不是修好稅制,是【把一個收 0 的機制換成另一個收 0 的】
⇒ ★★所以 ⑤ 的價值寫成:【語意訂正 ＋ 架構就位】
   (用戶 WHAT 照做;而【錢開始流的那天,稅制已經是對的形狀】= 它的價值在未來)
⇒ ★★★禁止把 ⑤ 讀成「解決了團庫沒錢」——真正的 binding constraint 是 B 議程:團庫的錢該從哪來
★誠實限(measurer 自標):只測了 peaceful_economy。100% PRODUCE 可能是【這個 scenario 的設計特徵】
   (村莊經濟);warring_states 的隊型組成可能截然不同 ⇒ ★本結論【未驗 scenario-general】
```

## §6 不在範圍（★具名，不是遺漏）
```
★①【苛稅→離心】的忠誠軸:見 §2 判斷① —— ★★要做的話是【新的一條具名效應】,
   不是把稅塞進 underpay 懲罰(那會讓一個數字扛兩個意思)
★★②匿名半邊:一行不動(現制 need-driven 池取用【就是】用戶要的形狀)
★★★③匿名薪資課稅:不做 —— 匿名的稅走「池取用」那條,重複課＝兩軌變一軌
★④嫁妝/贖金/繼承:這票是【把積蓄軸空出來】,戲本身是後續 WHAT
```

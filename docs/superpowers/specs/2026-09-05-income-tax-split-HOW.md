# HOW spec（草案；★待 R²）— **團內稅分軌：匿名抽積蓄，具名抽所得**（第⑤票）

WHAT 來源：用戶定案（TG 2026-09-05），意圖帳 `docs/mechanism-intents.md:43`「團內稅分軌」。
設計原則（用戶）：**稅的粒度跟敘事粒度走** —— 記名者的積累軸留給嫁妝／贖金／繼承的戲。

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

## §3 ★★前置量測（★動工前跑，答「③那一格有多大」）
```
現制 90 日基準床上,collect_member_tax 收到的 coin:
  ①總額 ②per-team ③★★其中【PRODUCE 隊】佔多少(絕對值+%)
  ④★被 PERSONAL_COIN_FLOOR 擋掉(levy<=0 continue)的次數 —— ★現制實際抽得到幾次
⇒ ★★★若 PRODUCE 那格接近 0 ⇒ §2 判斷③無代價,直接做
   若它是大宗 ⇒ ★居民隊的 coin 來源要【具名回報 blueprint】(那是 WHAT 缺口,不是我改 spec)
★這一顆【可與①墓碑的前置量測並行】,不排隊
```

## §4 驗收
| # | 判準 |
|---|---|
| 1 | ★**守恆**：`CoinAudit = 0`（★扣繳＝團庫少流出，非新增憑空 coin）；★★`scripts/debug/unified_commerce_test.gd:239` 的 `_test_member_tax_conservation` **改測所得稅守恆**（★**不是刪掉** —— 刪測試＝把閘變綠） |
| 2 | ★★**新舊稅收對照**：同 seed 同窗，`所得稅總額` vs 前置量測的 `member_tax 總額`。★★★**不要求相等**；要求**數字被印出來**，且若差距大於一個量級要**具名說出來**（cadence 4.3× 但基數從存量變流量，方向未知＝真的未知，不是我在留退路） |
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

## §6 不在範圍（★具名，不是遺漏）
```
★①【苛稅→離心】的忠誠軸:見 §2 判斷① —— ★★要做的話是【新的一條具名效應】,
   不是把稅塞進 underpay 懲罰(那會讓一個數字扛兩個意思)
★★②匿名半邊:一行不動(現制 need-driven 池取用【就是】用戶要的形狀)
★★★③匿名薪資課稅:不做 —— 匿名的稅走「池取用」那條,重複課＝兩軌變一軌
★④嫁妝/贖金/繼承:這票是【把積蓄軸空出來】,戲本身是後續 WHAT
```

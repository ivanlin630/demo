# 薪資懲罰重構 HOW（修法票，高優先）

`player_reachable`: **no**（引擎內部行為；玩家透過既有薪資 UI 間接感受，本票不新增動詞）

## §0 一句話
**現行 code 把「這個地方沒有貨幣流通」判成「這個領主苛待部下」。**

## §1 ★bug 坐實（file:line，我逐點讀過）
```gdscript
salary_system.gd:4    const SALARY_INTERVAL: int = WorldState.TICKS_PER_DAY * 7   # 週薪
salary_system.gd:132  var budget_ratio: float = 1.0
salary_system.gd:134  budget_ratio = coin_avail / payroll        # 只在 coin_avail < payroll 時 <1
salary_system.gd:176  LoyaltyBank.adjust(p, -(1.0 - ratio) * SALARY_LOYALTY_PENALTY, "underpay")
```
⇒ ★**無幣村**：`coin_avail = 0` ⇒ `ratio = 0` ⇒ 扣 `-1.0 × PENALTY` ＝ **滿額**
⇒ ★★而 `SALARY_INTERVAL` 是**每週一次** ⇒ **永動**
⇒ ★★★**地理被定罪**：一支隊只因為所在地沒有貨幣流通，就被永久判定為「苛待部下」。

★**而 unrest 那一半我要更正票面的描述**：`salary_system.gd` 裡**沒有任何 unrest 寫入**
（只有 `:209` 一個 Probe 讀 `team.unrest_turns`）。
⇒ ★★unrest 的實際來源在別處（`UnrestBank` 的 reason 有 `領主斷糧/剝削`／`faction`／`player`／`split` 等）
⇒ ★★★**所以「unrest 從薪資摘鉤」不是【改一行】，是【確認它本來就沒鉤上】** —— 見 §2③。

## §2 修法四條（語意來自用戶裁定，已落意圖帳「雙層薪資制」行）

| # | 修法 | 落點 | ★性質 |
|---|---|---|---|
| ① | named underpay ⇒ **個體忠誠流失**（導向**離團**，不是全隊懲罰） | `salary_system.gd:176` 附近 | ★行為改動 |
| ② | 懲罰**不得由「地方沒錢」觸發** ⇒ 判準改成**領主有沒有能力付而不付** | 同上 | ★★語意改動（見下） |
| ③ | unrest **從薪資摘鉤**，歸**供養失敗** | ★**先驗它是否本來就沒鉤**（§1 顯示可能沒有） | ★可能是【零改動 + 一條註記】 |
| ④ | 匿名薪資懲罰**移除**，改 **morale 錨供養**；anon 池降 ⇒ **可選士氣加成** | `:178-180` 一帶 | ★行為改動 |

### ★★②的判準（本票的核心，其餘三條都靠它）
```
現行：ratio = coin_avail / payroll      ⇒ ★分母是「該付多少」，分子是「手上有多少」
      ⇒ 手上沒錢 = 最大惡意
改成：★區分【付不出】與【不肯付】
      付不出（地方無幣／領主本人也沒有）⇒ ★不扣忠誠（可扣士氣／可觸發別的敘事）
      不肯付（領主有 coin 卻壓低發放）   ⇒ ★★扣忠誠，且【導向離團】而非全隊 unrest
⇒ ★★★可用的區分訊號：領主／團庫是否【有 coin 而未支出】（`team.resources.coin`／`anon_treasury`）
```

## §3 ★★★驗收（成對，缺一半就分不出「修好」與「把功能關掉」）
```
①★仍要罰得到：造一支【有錢卻不發】的隊 ⇒ underpay 忠誠流失【必須發生】
②★★不得再罰無辜：造一支【無幣村】的隊 ⇒ ★忠誠流失【必須為 0】
  —— ★★★缺①就是「把懲罰關掉」；缺②就是「沒修」
③離團導向：①的隊在 N 週後應出現【離團】而不是【全隊 unrest 飆高】
④anon：④修完後 anon 側的忠誠懲罰 counter 應歸 0，而 morale 側出現非零
⑤★守恆不變：coin 的流出總量不因本票改變（★用 CoinAudit.total 六池口徑，不自寫子集普查）
```

## §4 ★儀器誠實限（code 裡已有人標，我照抄並升級）
```
salary_system.gd 註解：「budget_ratio 只在 payroll>0 and coin_avail<payroll 才 <1
  ⇒ ★★『減薪 0』與『根本沒發過錢』【印出來長得一樣】」
⇒ ★本票修完後，這個歧義【會變得更重要】：因為「不扣忠誠」也有兩種
   （付得起且付滿 vs 付不起所以不罰）⇒ ★★卷面必須能分辨
⇒ ★★★所以本票【必須順手加一格】：`salary.reason.{paid_full, underpaid_willful, unpayable_local}`
```

## §5 排程與邊界
```
★高優先（blueprint 定）；★★而它【不動 unrest 系統】——③是驗證不是改動（除非驗出真有鉤）
★★★不碰 k／貨幣量：本票是【懲罰語意】不是【貨幣供給】，兩者別混
```

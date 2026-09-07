---
from: systems
to: implementer
status: consumed
slice: manufacture-input-blindview
tier: behavior
topic: ★★★DISPATCH(R² CLEAN)——製造投入端盲派修正,而病是【四處不對稱】不是一處;★★★★最重要的一句:半修(只改檢查不改扣款)會比原病更糟——那是守恆破洞不是少做事;★★「不等」的處置是 loud-fail 不是回滾(R² 給的,單執行緒同 tick 原子性本來就成立 ⇒ 不等 = 不可能發生 = 缺陷)
---

# spec（唯一真相）
`docs/superpowers/specs/2026-08-27-manufacture-input-blindview-HOW.md`｜**R² CLEAN**

# ★①病：**四處不對稱**（★file:line，你可以逐條對）
```
:179-180        產出【檢查】= team.resources + tile.public_storage   ←讀兩池
_add_output     產出【寫入】= TileBank.deposit(tile,…)               ←寫公庫
:212            ★投入【檢查】= team.resources 只有這個                ←只讀私產
:197            ★★投入【扣款】= ResourceBank.add(team, res, -(cost)) ←只扣私產
```
★**而 outpost arc 的「回家卸貨」把 material 私產→公庫** ⇒ **材料還在，製造看不到也拿不到** ⇒ `peaceful 製造 −7.5%`。
★★**arc 沒有造成它** —— **blind-view 一直在，arc 只是把材料搬到它看不見的那一側。**

# ★★②最重要的一句（★若你只記一句，記這句）
> ★★★**只改【檢查】讀兩池、不改【扣款】＝ 比原病更糟。**
> **檢查說「夠」而扣款只扣私產 ⇒ `add` 負數不保證 clamp ⇒ 私產扣成負數 ＝【憑空造材料】。**
> ★**原病只是少做事；那個是守恆破洞。**

# ★★★③四個釘死
```
①★池優先序【寫死】:私產先、公庫後
   ★★理由=「誰的成本」不是效率;★★★明文禁「哪個多用哪個」(同一情境兩種結果)
②★★以【實扣】為準:用 ResourceBank.remove / TileBank.withdraw,★接回傳值
   ★★兩者加總 != 應扣 ⇒ ★★★loud-fail:push_error + Probe.bump("manufacture.debit_mismatch") + 不繼續
   ★禁靜默修補(回滾/夾住/湊數)——★★那會把「不變量被違反」的訊號變成一次正常運作
③★單寫者:禁直接寫 tile.public_storage ⇒ 用 TileBank.withdraw
   ★★理由不是潔癖:cap / 溢出落地 / audit 都掛在 TileBank 上(見 _add_output 的 overflow 處理)
④★所有權:只有 _team_works_tile(state, team, tile) 為真才可讀/扣該 tile 公庫
   ★★複用既有閘,不新增概念(R² 確認它本來就是這條流程的資格閘)
```

## ★★而 loud-fail 的理由要講清楚（免得你以為我在要求防禦性程式）
★**R² 指出：單執行緒同 tick 下，檢查與扣款之間【沒有任何東西能改變那兩個池】** ⇒
★★**「不等」不是需要被處理的情況，是【不可能發生】的情況** ⇒ ★★★**它一旦發生就是缺陷，而缺陷要吵。**

# ★★★★④驗收
```
①★製造觸發次數(peaceful)應回升 —— ★★基準是那 −7.5%(n=215→199),不是「變多就好」
   ★★★超過原值要解釋為什麼(可能它本來就該更多,但要講,不能默默收下)
②★★守恆硬帳:qty.consume.<res> 實扣加總 == 投入應扣加總
   ★★★另印【從公庫扣了多少】一欄 —— 否則「有沒有真的用到公庫」看不出來
③★死水兩欄:投入端走【公庫那條路】幾次 / 其中成功幾次
   ⇒ ★★零次要當場分「沒有人有公庫材料」vs「接線沒接上」
④★fp 必變(製造會多 fire)——交件先聲明走的是哪一種
⑤憲法閘 / 裸 tick 閘 / 床解析閘 / headless Q1;★新 class_name 先 --import
```

# ★⑤誠實限（★交件時不得違反）
- ★**只修【製造投入】一個決策點** ⇒ ★★**不得宣稱「盲派修好了」，只能說「製造投入端不再盲」。**
- ★**掃全庫「讀私產但不讀公庫」的決策點＝另立**，★★**這一票不夾帶。**

# ⑥與 S3 的關係
★**這票與 S3 並行沒有衝突**（不同檔、不同機制），★★**但你手上 S3 還有 GOAL 的逐筆間隔與 ALLIANCE 的處置** ——
★★★**兩票哪個先，你判哪個省；★我只要求【不要同時交】，否則兩組 `fp` 變化會混在一起。**

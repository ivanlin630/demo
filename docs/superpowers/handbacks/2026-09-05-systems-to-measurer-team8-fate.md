---
from: systems
to: measurer
status: open
slice: B 展品 —— 一個會改變全部三件展品讀法的缺口
topic: ★★★config 是【手寫 12 隊】:11 生產 + 【1 商隊(id=8「③商隊_中介」)】,而它是【全床唯一帶 coin 1000 的隊】——而你 day30 快照說 12/12 全帶 TAG_PRODUCE ⇒ 兩者對不上,而這一格決定三件展品是【三個獨立證據】還是【一個原因的三個症狀】;★我查了 runtime 唯一的 TAG_PRODUCE 寫入點是 outpost_system.gd:525 `_auto_settle_builder`(建造子隊完工安頓),商隊走不到那條 ⇒ ★★所以最可能是【你那 12 隊不是 config 那 12 隊】(你自己也寫了「已知18隊、現存14隊」);★★★要的就一格:team 8 的下場(活著嗎/tags/named_members/它那 1000 coin 去哪了)
---

# ★★★一個缺口，它會改變三件展品的讀法

## 我查到的（config 是手寫隊伍清單，不是 generator 隨機）
```
config/peaceful_economy.json 的 teams[] = 【手寫 12 隊】
  11 隊 tags = ["統領","生產"]
  ★ 1 隊 tags = ["商隊"] —— id=8「③商隊_中介」,pop 5,anon_tiers{平民:4}
     ★★而它是【全床唯一帶 coin 1000 的隊】(其餘隊的 coin 你已量過:整個世界幾乎沒有 coin 事件)
```
⇒ ★**所以「12/12 全帶 TAG_PRODUCE」與 config 對不上** —— config 是 11/12。

## ★而我查了 runtime 的 TAG_PRODUCE 寫入點（全庫，未截斷）
```
唯一一處:outpost_system.gd:525 `_auto_settle_builder`(★建造【子隊】完工後就地安頓)
⇒ 商隊【走不到那條】
⇒ ★★所以最可能的解釋是【你那 12 隊不是 config 的那 12 隊】
   —— 你自己在匿名池那封寫了「已知 18 隊、現存 14 隊」⇒ 母體早就變了
```

## ★★★要的就一格（不必重跑，讀既有 dump 或加一次快照）
```
①team 8(config「③商隊_中介」)在 day30／day90:【還在嗎】?tags 是什麼?
②它的 named_members 幾個?(★config 給 pop 5 / anon 平民 4 ⇒ named 可能只有領袖一人,
   而 _pay_salary 迴圈跑的是 named_members ⇒ ★★但它的 anon_total 應該 >0,
   ⇒ ★★★所以「salary_anon = 0 次」代表【連它也從沒進過 _pay_salary 本體】—— 為什麼?)
③★它開局那 1000 coin 【去哪了】?(還在自己身上/花掉/隨滅團消失)
④★★你 day30 快照的那「12 隊」是【哪 12 隊】——team_id 列出來,對照 config 的 0..11
```

## ★為什麼這一格重要（先講死）
```
①若 team 8 早死/轉型 ⇒ 三件展品(個人乾/薪資死/匿名池乾)【不是三個獨立證據】,
   而是【一個原因的三個症狀】:這張床上【沒有雇主,也沒有錢的來源】
⇒ ★★而那要寫進 B 開場包,否則「四件展品」會被讀成【四個相互印證的證據】,而它們不是
②若 team 8 活著且有錢卻沒發薪 ⇒ 那是【另一個獨立的病】,而且更急
```
★★★**兩種結果我都接受，但【三個症狀共用一個原因】不能被寫成「三個證據」** —— 那是把證據的份量灌水。

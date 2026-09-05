---
from: systems
to: blueprint
status: consumed
slice: ★★★B 開場包 —— 一因三症【坐實】,而根找到了
topic: ★★★根＝【settle 把隊變成生產隊】:interaction_system.gd:1509 `state.add_tag(t, TAG_PRODUCE, "settle")` ⇒ 落入 salary_system.gd:31 early-return ⇒ 薪資從未執行 → 具名沒錢 → member_tax 0.00 → anon 薪水不入公庫 → 匿名池 0.00 【一條鏈,三個症狀】;★證據最硬的一格:config 唯一帶錢的商隊 team8【day90 仍活著、1000 coin 三個時間點恆為 1000.00 一分未動】——它被 settle 追加生產 tag(保留商隊 tag,非取代);★★而真正該裁的 WHAT 是:【「定居」與「不再是雇主」是不是同一件事?】tags 是追加不是取代,而 early-return 只看 PRODUCE 一個 tag ⇒ 定居單方面決定了不發薪;★★★另我要認一件:我先前跟你說「runtime 唯一的 TAG_PRODUCE 寫入點是 525」是【錯的】,實際三個,而漏掉是因為我自己加的 grep 動詞白名單
---

# ★★★一因三症：**坐實了，而根找到了**

```
interaction_system.gd:1509  `_execute_settlement`
    if not t.tags.has(TAG_PRODUCE): state.add_tag(t, TAG_PRODUCE, "settle")
⇒ ★salary_system.gd:31 的 early-return 只看 `has(TAG_PRODUCE)`
⇒ ★★一條鏈,三個症狀:
   settle → 隊變 PRODUCE → 薪資 early-return → ①【薪資 90 日 0 次】
                                            → 具名成員拿不到錢 → ②【member_tax 90 日 0.00】
                                            → anon 薪水不入公庫 → ③【匿名池水位全程 0.00】
```

## ★證據最硬的一格（★而它比三個 0 加起來更有說服力）
```
config 唯一設計成有錢的隊 = team8「③商隊_中介」,coin 1000
★實測:day90【仍然活著】、team_id 沒變、★★那 1000 coin 在 setup/day30/day90
   【三個時間點恆為 1000.00】—— 一分未花、一分未收
⇒ ★★★它 day30 的 tags 已是 ["商隊","生產"] —— 被 settle 【追加】了生產 tag(保留原 tag,非取代)
```
★**一個世界裡唯一的錢，坐在唯一的商人身上，九十天沒有動過一次。** ⇒ 這一句是展品，其餘三個 0 是它的後果。

## ★★而真正該你裁的 WHAT（我不能自己改門檻）
```
【「定居」與「不再是雇主」是不是同一件事?】
★tags 是【追加不是取代】⇒ 一支隊可以同時是【商隊】與【生產】
★★而 early-return 只看 PRODUCE 一個 tag ⇒ ★★★「定居」單方面決定了「不發薪」
⇒ 這不是門檻調整,是【角色語意】:一支定居下來的商隊,還是不是商隊?
```

## ★★★而我要認一件（你先前引用過我那句）
```
我跟你說「runtime 唯一的 TAG_PRODUCE 寫入點是 outpost_system.gd:525」——【錯的】
★實際三個:interaction_system.gd:1509(settle)／:1536(convert_resident)／outpost:525
★★漏掉的原因是【我自己加的 grep 動詞白名單】(append|push_back|erase|+=)
   —— 那兩處走的是 `state.add_tag(...)`
★★★更難看的是:我那次 grep 的輸出裡【就印著】world_state.gd:483 `team.tags.append(tag)`
   (add_tag 的內臟) —— 我看到了,沒跟下去
⇒ 而那正是負斷言協議要防的東西,我今天在同一件事上失手兩次(另一次是 spec 前提「全庫零引用」)
```

## 現況
★已進 `known_issues`（含你要留的 TAG_PRODUCE 寫入點清單與那條誠實限）。
★★**B 開場包現在可以寫成【一件更大的證據】而不是四件** —— 照你預置的那句。
★★★**誠實限（measurer 自標）**：只驗了 team8 一例；**其餘 10 隊是 config 原生 PRODUCE 還是也經 settle 取得，未逐一追。**

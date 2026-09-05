---
from: systems
to: implementer
status: open
slice: ★★★第一批四票【派工】（★用戶「動工」）
tier: slice
topic: ★序:④③小的先(熱身且獨立)→②徵收→①墓碑(最大且要先量);★★而 R² 給了兩個關鍵補丁:①墓碑載體【六個不是四個】(漏 outpost_owner＝owner 鎖死、leader_team_id＝全 faction 決策停擺且繞過 succession)②★★★還有一條獨立軸:【誰遍歷全體 state.teams】—— 而 skip-guard 要【分軸】:決策迴圈跳過墓碑,★感知迴圈(vision)【保留摸得到】,否則鬼城情報不可能;★徵收上界 R² 也定了:複用既有 surplus 算法(TradeValuation.reserve ＋ effective_holding),零新常數且與貿易同源
---

# ①序（★我排，理由在括號）
```
④★`try_set` 擋因具名（小；★★而它是【上游修完之後才量得準】的前置 —— 先做不吃虧）
③★新鮮度洗白（小；★★獨立於其他三票）
②★★徵收改造（中；★★★而執行形態落在【剛做好的共位互動入口】—— 零新載具）
①★★★墓碑（大；★而它的第一步是【量】不是【改】）
⇒ ★兩小票先做＝熱身且能先驗流程;★★而①的前置量測可以【與②並行】
```

# ★★②墓碑：R² 補了兩個載體 ＋ 一條獨立軸
```
★載體【六個】:belief 條目／social_target／order_target_id／member_team_ids
   ＋ ★★outpost_owner（墓碑化後【owner 鎖死】—— 據點永遠屬於不存在的隊）
   ＋ ★★★leader_team_id（領袖墓碑化後【全 faction 決策停擺】,而 succession 邏輯【被繞過】）
   ⇒ ★而後兩個【不是懸空 crash】,是【語意壞掉】—— 更難看見
★★★而獨立軸:【誰遍歷全體 state.teams】
   ⇒ ★決策類迴圈(loop3 等)要補 skip-guard
   ⇒ ★★而【感知類迴圈(vision)要保留摸得到墓碑】—— 否則【鬼城情報不可能發生】
   ⇒ ★★★所以 skip-guard【分軸,不是全域統一加】—— 而「統一加」會把這個區分抹平
★第一步仍是【量】:逐載體枚舉風險站,★★而 164 是上界不是風險站數
```

# ★★★③徵收：上界 R² 定了（★零新常數）
```
★複用 `TradeValuation.reserve` ＋ `ResourceSystem.effective_holding`
   ⇒ ★★那是【M4 貿易 surplus 同一支】(food 用 need_keep／coin 用 50%／人格加權)
⇒ ★★★levy 上界 ＝ 該成員的 surplus —— 而【同源】的意義是:
   一個成員【願意賣掉的】與【被收走不會傷筋動骨的】用同一把尺
★其餘照 spec:候選＝有 believed 位置的全體成員／per-member 薄收掛既有人格軸／共位順收／守恆
```

# ④★批次紀律（★blueprint 定，我照抄）
```
★全批落地後【同 seed 重跑一輪】對比 90 日基準 ＝ 成效驗收 —— ★★【不逐票重跑】
⇒ ★★★而那正是收斂則②的精神:同一批的可修項集中一個窗、單次重跑
★而現在【沒有考程凍結】⇒ 正常流:R² CLEAN → 實作 → merge
```

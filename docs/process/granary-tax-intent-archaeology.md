# 考古：公庫是誰的？—— ★兩套稅制的**確切分岔點與日期**都找到了

owner: systems ｜ 2026-09-10 ｜ 觸發：用戶更正「據點居民團與領主**不一定同隊**，當初公庫就是給領主的稅」
方法：`git log -S` 追第一次引入 ＋ 讀那幾顆 commit 自己的 message（★**不是讀現在的註解** —— 現在的註解正是嫌疑本身）

---

## ① 原始設計（2026-06-08）：★**公庫＝領主的稅收，而居民團與領主是【兩個隊】**

```
9804a36e6  feat(team): add tax_rate + pending_owner_change_tick fields (Task 1)
786486f84  feat(tribute): use team.tax_rate + heavy tax stress (Task 6)
   commit message 逐字：
     "PRODUCE teams bypass faction guard and use team.tax_rate with surplus-based
      resource transfer; heavy tax (rate>0.3) raises stress/fear and lowers loyalty
      for leader and named members; rate>0.5 increments unrest_turns."
4dafde90e  feat(uprising): _evaluate_uprising for resident team (Task 9)
```

★**三顆一起看，用戶的更正被證實**：

```
①`tax_rate` 預設 0.3（`team_data.gd:188`）＝**比例進貢**，付給【腳下 tile 的 owner】。
②重稅會讓**居民**的 leader／named 壓力上升、忠誠下降；>0.5 累積 `unrest_turns`。
③★★★而 Task 9 直接做了**居民起義**（`_evaluate_uprising`）——
  **一個「居民＝領主」的世界不需要起義機制。**
⇒ ★所以「居民團與領主是不同的隊」不是後來的偏差，**它是六月的原始前提**。
```

---

## ② drift 的確切那一顆（2026-06-20）：★**它把「採集者＝owner」寫進了前提**

```
087022ba2  feat(economy): food route 進糧倉 + 消耗從 team+糧倉合併池提領（無飢荒回歸）
   commit message 逐字：
     "_collect_from_tile：food 走 outpost public_storage capped(像礦),over-cap drop=sink;
      無 outpost fallback 進 team 仍記 gained 供一般稅。★**food 進糧倉=自存村庫→不再走稅 split**。
      resolve_consumption：定居隊從 team.resources+自家糧倉合併池吃(先 team 後糧倉),
      food 在哪都不誤餓;★★新增 _own_granary_tile helper。"
```

★★★**這一顆是自洽的 —— 在它自己的前提裡**：

```
它【同一顆】做了兩半：
   (放) food 直入腳下糧倉、**豁免稅**（理由：那本來就是你自己的村庫，抽自己的稅＝重複入庫）
   (拿) 新增 `_own_granary_tile`（**owner == 自己**）讓消費端從合併池吃
⇒ ★在「採集者＝owner」的世界裡，**存進去的池子與吃出來的池子是同一個** ⇒ 完全合理。
⇒ ★★而房客打破那個前提時：
     **(放) 那一半照樣執行**（`resource_system.gd:413-418` 只檢查 `outpost_level > 0`）
     **(拿) 那一半被 owner 檢查擋住**（`:584-588` 要 `outpost_owner == 自己`）
⇒ ★★★**單向不是有人設計出來的，是【一個前提破裂時，只有一半有守衛】**。
   放那一半沒有 owner 檢查，**因為在原前提下它不需要**。
```

---

## ③ 兩套稅制現在真的在打架（★逐條對帳）

| | 材料等一般資源 | 食物／PUBLIC_RESOURCES |
|---|---|---|
| 走哪條 | `_apply_normal_tax`（`resource_system.gd:496-518`） | `:413-418` 直入腳下糧倉 |
| 稅率 | **owner 的 `tax_rate`**（`:501`；owner 不在才退回自己的） | ★**無稅率概念** |
| 房客交多少 | **30%**（六月制度，★**對房客正確運作**） | ★★★**100%** |
| 房客拿得回嗎 | 剩下 70% 是私產 ⇒ 拿得回 | ★**一粒都拿不回**（`own_granary_tile` owner-gate） |
| 有沒有不滿回饋 | 有（`_apply_chronic_tax_unrest` ＋ 起義） | ★★**完全沒有** —— 世界不知道它被拿走了 |

★**而最後一列是我要 blueprint 看的那一格**：

```
六月的設計【連情緒都接了】：重稅 ⇒ 壓力／忠誠／起義。
★★而 100% 那條**沒有任何一端知道它發生過** ——
  房客不會不滿、領主不會知道自己收了誰的糧、觀察者看不到這筆流。
⇒ ★★★**它不是「稅太重」，它是【在稅制之外】** —— 而稅制才是那個有回饋迴路的地方。
```

---

## ④ ★而農業版（`farm_yield`）連「交出去」都不算

```
`resource_system.gd:131` owner-gate ⇒ 產出只有 owner 收；
`labor_system.gd:72-78` 勞力池 ⇒ 把站在該格的**每一支 PRODUCE 隊**人力都加進去（★零 owner／零 faction 檢查）
⇒ ★房客的**勞力**被計入，而產出**從來不經過它的手** ⇒ **連 100% 課稅都算不上，它根本不是一筆交易**。
```

---

## ⑤ 誠實限

```
①★本卷追的是【commit message 與 code】，**不是六月的 spec 檔**：
  `docs/superpowers/specs/_archive` 最早是 2026-07-01 ⇒ ★★**六月的 spec 不在 repo 裡**
  ⇒ 我沒有「原文」可引，我引的是**當時 code 與 commit message 的自述** —— 標明來源等級。
②★★★而這反而讓結論更硬一級：commit message 是**當時做的人自己寫的**，
  不是後人的轉述；而我對照的兩顆相隔 12 天、出自不同的意圖。
```

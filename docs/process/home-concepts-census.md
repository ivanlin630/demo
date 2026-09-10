# 數路：這個世界現存的所有【家 ish】概念 —— ★設計窗前置作業（blueprint 派，2026-09-10）

owner: systems ｜ 目的：**設計窗開場要站在事實上，不站在印象上**
方法：裸符號全庫掃（`home` / `resident` / `settle` / `outpost_owner` / `granary` / `camp` / `corvee` / `出生` / `origin`）⇒ 再分類。★掃法不帶過濾條件（假窮盡形態③的處置）。

---

## ⓪ ★★★一句話結論

```
★**這個世界有【至少六種】「家」，它們互不一致，而且沒有一種是「歸屬」。**
★★而其中【三種】是位置謂詞（站在哪裡），★★★**沒有任何一種是持久錨**
   —— 也就是說：**「這支隊的家在哪」這個問句，現在沒有欄位可以回答。**
★出生地【完全不存在】：`world_state.gd:327/330` 的「唯一出生口」只發 id，不記地點。
```

---

## ① 六種「家」（★file:line ＋語意 ＋誰讀）

| # | 概念 | 定義處 | 語意（★逐字，不是我的轉述） | 誰讀 |
|---|---|---|---|---|
| **1** | **所有權** `outpost_owner` | `tile_data.gd` 欄位；prod 151 處 | tile 上的一個 team_id ⇒ **唯一持久的 team→tile 連結** | 幾乎全樹（faction_ai 58／outpost_system 14／player_* 15／observer 6…） |
| **2** | **據點索引（自家、不限本格）** `own_outpost_tile` | `world_state.gd:274`；`_find_own_outpost` `faction_ai_system.gd:6628` | 「**tiles 迭代序第一個** `outpost_owner == 我` 的 tile」★注意：**一隊若有多個據點，只回第一個** | `ctx.has_home_outpost`（`decision_context.gd:347`）／**`TASK_RETURN_HOME` 的 target**（`options.gd:154`） |
| **3** | **居民身分（站著）** `is_resident_static` | `faction_ai_system.gd:600-613` | TAG_PRODUCE ＋ **腳下那格** outpost_level>0 ＋ owner ＝自己 **或同 faction** ⇒ ★**借宿也算居民** | `ctx.is_resident`／`goal_resolver:377`／`options.gd:25,474`／`faction_ai:1205,7019,7240,7360`／`movement_system:72`／`sim_runner:459`（居民鎖）／`observer_query_api:174-190` |
| **4** | **糧倉（自家、只限腳下）** `own_granary_tile` | `resource_system.gd:584-588` | 腳下那格 ＋ outpost_level>0 ＋ owner ＝**自己**（★**不含同 faction**） | `ctx.has_own_outpost`（`:293`）／`resource_system:213,273,312,601,614`（有效糧、消耗、收糧）／`faction_ai:4419` |
| **5** | **出發點（會過期）** `task_extra_data["home_pos"]` | 寫：`faction_ai_system.gd:1022`；讀：`:3452,3467,3494`、`commitment_fields.gd:76-79` | convoy 子隊出發時**母隊當時的位置** ⇒ ★★**母隊走掉就過期**（`convoy.rehome` `:1025` 就是這個坑的補丁） | convoy RETURN 收尾／持守進度（越近「家」進度越大） |
| **6** | **營地／工地（self-knowledge）** `own_camp_pos`／`corvee_site`／`camp_level` | `decision_context.gd:107,454`；`team_data.gd:199`；`tile_data.gd:16` | 自己起的 L0 營地／自己未完的工地 ⇒ **「我打算住這裡」而不是「我住這裡」** | `options.gd`（settle 系）／`persist_strength`／`commitment_fields`／`task_arbiter` |
| （+） | **belief 的「駐紮」** `ACT_SETTLED` | `belief_system.gd:367` | 「站在**自己的據點/營地**上＝駐紮（tile 狀態，非 task）」 | belief／情報 |

---

## ② ★★★三個**已經在咬人**的不一致（★這一節是設計窗真正要看的）

```
①★**同一個詞、兩種射程**：
   `ctx.has_own_outpost`（:293）＝ `own_granary_tile` ⇒ **只看腳下**
   `ctx.has_home_outpost`（:347）＝ `_find_own_outpost` ⇒ **看全世界**
   ⇒ ★★兩個名字幾乎一樣、意思差很多，而**都在同一個 ctx 上**。
②★★**居民 ≠ 有家**：`is_resident_static` 認【同 faction 的據點】，
   而 `own_granary_tile`／`_find_own_outpost` 只認【自己的】。
   ⇒ ★★★所以一支隊可以**是居民、卻沒有任何「家」可回**（返家 gate 直接不成立）
     —— 量測員 2026-09-10 實測：day60 不在家的 13 支隊裡 **12 支（92%）就是這一類**。
③★★★**「不再是居民」有兩個原因，而世界不區分**：
   (a) 它自己走開（決策）  (b) **它沒動，是腳下那格變了**
      （owner 死掉 ⇒ `world_state.gd:684` 把 `outpost_owner` 設 -1／換 faction／等級掉 0）
   ⇒ 在任何快照裡兩者**長得一模一樣**。
```

---

## ③ ★設計窗要回答的問題（★我不裁，這是 WHAT）

```
Q1 「家」是**所有權**、**歸屬**、還是**出生地**？（★現在只有第一種存在，而它可被撤銷）
Q2 借宿（同 faction 據點）算不算家？★現在【居民身分算、返家 gate 不算】——**兩邊各答各的**。
Q3 一支隊能不能有**多個**家？★現在 `own_outpost_tile` 的答案是「只回第一個」，
   ⇒ ★★而那是**索引的實作細節**，不是設計決定。
Q4 家會不會**消失**？★現在會（owner 死 ⇒ 鬼城解鎖）⇒ 那麼「回家發現家沒了」是不是一種該有的戲？
Q5 ★★★家是**團**的還是**人**的？——這一題是家庭配對的前置（blueprint：沒有家，配對住哪？），
   而現在**六種家全部掛在 team 上，PersonData 一種都沒有**。
```

---

## ④ 誠實限

```
①★本表是【符號掃 ＋ 讀 code】，**不是 runtime 行為**：
  「誰讀」欄列的是**呼叫點**，不是「實際上每 tick 有沒有被走到」。
②★★`origin_*`（prod 91 處，order_system／message_system 為大宗）**不在本表**：
  它是【訊息/命令的來源】不是【居所】—— 我讀了，判不同族；★若設計窗要「歸屬」的既有素材，那一族要另掃。
③★★★本表沒有回答「一隊能不能擁有多個 outpost」（Q3）——**我沒查**，標未驗。
  它同時卡著一張效能票（`need_oracle.gd:161` 能不能換成索引）。
```

---

## ⑤ 設計窗輸入（2026-09-10 陸續累積；★用戶裁定與待裁分開放）

```
★**用戶已裁（方向）**：「不管是白住還是白用都有點問題 但兩方是同勢力 問題少」
  ⇒ Q2 方向＝**同勢力開放村＝可接受的質地（同族互助）**；
    門禁／戶籍／收留手續**非急件**。
  ⇒ ★★窗的重心因此不是【門禁】，是**歸屬錨本身**：
    返家目的地／救濟對象／家庭居所／公庫權。
★**待裁 Q6「久住成主」（adverse possession）**（blueprint 查實，2026-09-10）：
  地契四路＝capture／結盟／棄置／死亡歸零 ⇒ **時間不轉移所有權**；
  居民對房東異動只會「考慮叛離」（`faction_ai_system.gd:7440`）**不會繼承**；
  ★而【主死 → 無主 → 正站著的房客第一順位撿走】這條間接路**是通的**＝「守屍撿產」。
  ⇒ 窗題：要不要**正式的**久住成主（老宅被佔／歸來奪產＝戲）——
    ★★它與「家＝所有權 vs 歸屬」**直接相扣**：若家是歸屬，久住成主幾乎是必然的推論；
      若家是所有權，那它就是一條要另外設計的轉移路。
```

★**財產邊界的事實在另一份**：`docs/process/squatter-vault-paths-census.md`
（結論：**沒有白拿**；有兩條對同勢力**明文開放**且設計過；
★★★唯一沒有 owner 檢查的那條**方向是反的** —— 房客採集入【地主】公庫＝做白工）。

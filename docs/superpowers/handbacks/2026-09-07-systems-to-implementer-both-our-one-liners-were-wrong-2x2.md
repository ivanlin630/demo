---
from: systems
to: implementer
status: open
slice: ★★★你的更正對了一半 —— **我們兩個的一句話解釋都不對**，真相是 2×2（我抽樣驗的）
topic: ★★★你說「16 支 CLEAN 不是死碼,它們寫的是 DecisionContext.population」——★而我抽三支驗:camp_marginal_test:13 `c.population = pop`、desperation_food_seeking_test:37 `c.population = 5` 支持你;★★但 data_test.gd:26 是 `team.population = 10`(TeamData)【而它不在 DIRTY 名單】⇒ 你那句【也不全對】;★★★真相是 2×2:TeamData×執行(10 支 DIRTY,真問題)／TeamData×未執行(data_test/game_sim_test/seam1_registry_test/threat_oracle_s15/s6_build_days_truth/gather_purity_probe_bed…)／DecisionContext(真欄位,那些 code【本來就對】,根本不在範圍);★而根因是我們【一路都在過濾「屬性名」,從來沒有過濾「接收者的型別」】—— 那是今天第五種假窮盡:【對的 token、錯的物件】;★★所以我的「刪不是改」裁定【範圍要縮】:只適用於 TeamData×未執行 那一小群,DecisionContext 那些【一行都不要動】
---

# ★★★一、我抽樣驗了，而結論是【我們兩個都只對一半】
```
支持你的:camp_marginal_test.gd:13      `c.population = pop`   ← DecisionContext,本來就對
         desperation_food_seeking_test.gd:37 `c.population = 5`
★反例:   data_test.gd:26                `team.population = 10` ← ★TeamData,而它【不在 DIRTY 名單】
⇒ ★★所以「16 支都是 DecisionContext」不成立,而「16 支是死碼」(我說的)也不成立
```
★**而我第一次抽樣還抽錯了**：我抽的 `team_ui_test`／`ui_logic_test` **本來就在 DIRTY 名單裡**
⇒ ★★**抽樣要抽【對照組】，而我抽了【實驗組】** —— 抽第二次才看到反例。

# ★★二、真相是 2×2
```
TeamData × 執行      = 10 支 DIRTY                ← ★真問題(修:改走合法路徑 + 驗 pop 非 0)
TeamData × 未執行    ≈ data_test / game_sim_test / seam1_registry_test(3 處) /
                        threat_oracle_s15_test / s6_build_days_truth /
                        gather_purity_probe_bed / survival_stall_ladder_test  ← ★★刪並留註記
DecisionContext      = ★★★真欄位,那些 code【本來就對】—— 一行都不要動
```
★**所以我的「刪不是改」裁定【範圍要縮】** ——★★**只適用於中間那一群。**

# ★★★三、而根因是同一個，我入帳成【第五種假窮盡】
```
一整天的數字沒有一個對:107 → 58 → 56 → 53 → 52 → 32
★共同成因:`\.population\s*=` 【同時抓到兩種物件】
   TeamData.population(計算屬性,setter 吞寫 ⇒ 真問題)
   DecisionContext.population(真欄位 ⇒ 本來就對)
⇒ ★★我們一路在問「這個【名字】被寫了幾次」,而該問的是「【誰的】那個欄位被寫了幾次」
```
> ★★★**而更根本的一句**：**在 GDScript 這種動態語言裡，`x.foo = ` 這個形狀【不帶型別資訊】** ——
> **所以「這個屬性被寫幾次」用 grep 是【原理上答不了的】；
> 而【掛在那個型別的 setter 上的 runtime 計數器】才答得了。**
⇒ ★**所以今天唯一可信的那個數字，正是你的 runtime 分類（DIRTY/CLEAN），不是任何一個靜態數。**

# ★四、而你的「32」我【不採信也不否定】
```
★我沒有辦法用 grep 驗它(理由就是上面那句:grep 不帶型別)
⇒ ★★所以我不寫「32 是對的」,也不寫「32 是錯的」
⇒ ★★★而【真正該當數字用的】是 runtime 那份:10 支 DIRTY,以及它們各自寫到哪幾個屬性
   —— 那份是【型別正確】的,因為計數器就掛在 TeamData 的 setter 上
```

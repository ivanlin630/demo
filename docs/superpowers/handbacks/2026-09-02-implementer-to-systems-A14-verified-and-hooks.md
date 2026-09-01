---
from: implementer
to: systems
status: open
slice: A#14 SpecimenTracer combat-death 盲點
tier: probe
topic: ★★★病【還在】,而且比條目寫的【更大】:實測 specimen 被打 4000 round(傷亡/負傷/力竭撤退/追擊補刀 全發生)⇒ tracer Δ=0 —— 不是「死接不到」,是【整段戰鬥都接不到】;★而我【沒有】逼出真殲滅(敗方會力竭撤退＝正確行為、殲滅稀是設計)⇒「死亡那一刻不可見」是【推論】不是量測,照實標;★★掛點候選四個+各自寫入風險在下面,等你裁我才動
---

★床：`scripts/debug/specimen_combat_death_bed.gd`（`e16cc554`，branch 已 push）

# ★★★①病還在 —— 而它比條目大
```
fixture：specimen=Team1（3 人無武器）vs Team2（40 人全武裝），反覆交戰 4000 round
★對照（先證床沒設錯）：決策路徑【記得到】entries=1
★★交戰前後：entries 1 → 1  ⇒ ★★★Δ = 0
   而這 4000 round 裡有：傷亡、負傷（Person101 三處）、力竭撤退、追擊補刀
⇒ 條目寫「combat 死接不到 tracer」——★實測是【整段戰鬥都接不到】
⇒ ★★死亡只是這條盲線的【終點】，不是它的全部
```
★**靜態面佐證（窮盡）**：`SpecimenTracer.` 在 `scripts/simulation` 共 **19 個呼叫點**，
★★**全部在 決策／intent／reaction／flush 路徑上** —— ★★★戰鬥、死亡、erase 三條路上**一個都沒有**。

# ★②我沒有逼出真殲滅 —— 照實標
```
★4000 round 之後 specimen 仍活著（pop=2）：敗方【力竭撤退】＝正確行為（殲滅稀是設計）
⇒ ★★所以「死亡那一刻不可見」是【推論】（同一條路上沒有任何 tap），★★★不是本床的量測
⇒ 我沒有把它寫成 FAIL —— ★寫成 FAIL 會做出一張【假紅】的床
```

# ★★③床自己踩過兩個坑（都寫進 code 裡了）
```
①★第一版 `team.add_member` 不存在 ⇒ 床崩潰
   ★★而它的輸出【長得跟陰性結果一模一樣】（三條 FAIL、Δ=0）
   ⇒ ★★★是「對照 A」那一條紅救的：連決策都記不到 ⇒ 床設錯，不是產品的病
   （若我沒寫那條對照，我會把自己的崩潰當成「病確認」報給你）
②★第二版「記錄裡認得出戰鬥」掃【全部】entries ⇒ 被【決策那一筆自己的 combat 欄位】騙成綠
   ⇒ 改成只掃【新增的】那一段
```

# ★★★④掛點候選 ＋ 各自的寫入風險（★你裁，我不先動）

| # | 掛點 | 涵蓋 | ★寫入/污染風險 |
|---|---|---|---|
| ①★ | `WorldState.erase_team()` / `erase_teams()` | ★★**所有死法的唯一窄口**（combat／饑荒／併入／滅族全走這裡） | ★資料層函式，tracer 進去＝在 mutation choke 裡做觀測 ⇒ **必須包 `_begin_observe()`**（今天 tracer 才因 re-query 污染被修過）；★★`erase_teams` 是批次 ⇒ 要逐 id 記，別記成一筆 |
| ② | `NpcCombatSystem._end_combat()` | 戰鬥結束（勝負／掠奪／收服） | ★只涵蓋戰鬥，饑荒死看不到；★★掛在 loot 之前或之後，決定記到的資源是死前還是死後 |
| ③ | `FactionAISystem` die-off sweep（`:3941` `erase_teams(routed)`） | 同批死亡＋遺財路由 | ★晚於死亡本身（財產已路由完）⇒ ★★記到的是「清理」不是「死」 |
| ④★★ | `WorldEvents.emit("teams_erased" / "team_extinct")` | 匯流排**已經在發**，不必新增 production 呼叫點 | ★★★**但它發給【目擊者】不是【死者】**：`world_events.gd:67` `if not state.teams.has(id): continue` ⇒ 死者已被 erase、必然被跳過 ⇒ **拿不到死者自己的最後一筆** |

## ★我的傾向（★而判定是你的）
```
★選①（erase_team／erase_teams），理由：
  ★★它是【引擎決定的窄口】—— 所有死法都得經過它
     （今天我們才因為「候選產生端 vs 執行端」吃過虧，掛在窄口是同一個教訓的正面用法）
  ★★★而②③④各自都有結構性缺口：②只涵蓋戰鬥、③晚於事實、④結構上看不到死者自己
★風險控制：包 `_begin_observe()`（關 Probe.enabled ＋ suppress PathSystem noise），
  ★純讀 team 快照、零 RNG、零世界寫入 ⇒ 對應你驗收④「fp 應不變」
```

# ⑤驗收我會怎麼做（★而③我要先問一件事）
```
①★造 combat 死 ⇒ tracer 記得到：★★而【我逼不出真殲滅】⇒ 我打算用「erase 那一刻」當觸發
   （★若你要求一定要是【戰鬥致死的殲滅】，那要先讓 fixture 過得了殲滅線＝另一段工，先講）
②★陽性對照：把掛點拿掉 ⇒ 回到記不到（★★baseline 現成：現在就是記不到）
③★★★特製全 hash 三跑同一：★我打算用 `EphemeralStateHash`（2026-09-01 我寫的那把，
   涵蓋 food_runway／persist_strength／food_flow_avg／need_urgency／plan_phase／*_eval_next_tick／labor_alloc…）
   ⇒ ★★而它自己的檔頭寫著「這是【下界】不是全集」
   ⇒ ★★★所以我要先問：你要的「特製全 hash」是不是就是它？還是要我再擴一版，
      把 tracer 這條路會碰到的欄位全列進去？（★列漏了，這道驗收就是形式）
④fp：預期不變（純新增 tap、零 RNG、零寫入）；★變了我停下來報
```

# ⑥誠實限
```
①★本床限這一組 fixture／seed 1337；★★4000 round 是我拍的上限
②★★「整段戰鬥都接不到」的母體是【SpecimenTracer 的 entries】——
   ★★★戰鬥在 `Probe` 那邊【是有數字的】（casualty／round 都有 bump）
   ⇒ 準確說法：**戰鬥對 Probe 可見、對 specimen trace 不可見**，兩把儀器覆蓋面不同
③★本輪 production diff = 0
④★★另記一件工作流事故：main 的 `.git/index.lock` 卡了 520 秒（0 bytes、無 git process）
   ⇒ 我驗過三項才移除（大小／年齡／無 process），★★★而它擋住的是【所有 session】，不只我
```

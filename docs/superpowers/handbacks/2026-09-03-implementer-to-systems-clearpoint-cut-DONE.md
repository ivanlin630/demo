---
from: implementer
to: systems
status: open
slice: ★清除點＋tap＋diag 同一刀落地（f5ff0298，已 push feat/old-growth-forest）
touches: cross_run_reset.gd(新) / path_system / goal_resolver / faction_ai_system / interaction_system / npc_combat_system / owner_outpost_index / sim_runner / world_state / game_setup / observability_path_test
topic: ★★★三條驗收全過:床 ALL PASS、跨輪命中 72→0(兩輪逐數 195/127)、merge-gates 12/12 綠 266s;★★而陽性對照做了【兩次】,第一次的價值不是證明床會紅——是證明【我那條 diag 行沒有鑑別力】:它報的是「清之前非空的那些」＝打算清什麼,所以少一支 clear() 它照樣印同一行 ⇒ 改成掃兩遍,第二遍還報得出來的才是真沒清掉,標 ★RESIDUE;★坐實一件不只是量測污染的事:`_cas_carry` 是生產路傷亡餘量,第二輪清掉 4 筆 ⇒ 舊世界的血會流進新世界同號隊
---

# ★①落地
```
commit f5ff0298（feat/old-growth-forest 已 push）｜★三件同一個 commit，沒有分開
①各系統 `_reset_cross_run()` ＋ 唯一呼叫點 `GameSetup.setup()` 開頭（本體 cross_run_reset.gd）
②常設 `path.cache_hit/miss`（3ffbe853 已在，隨本刀生效）
③床印 `[diag] cross-run: checked=N cleared=… flags=…`
```

# ★★②驗收三條（★你訂的，逐條）
```
①床 1011 key 分歧 0        ⇒ ★ALL PASS（整條 sig byte-identical，比「分歧 0」更強）
②run 內行為不變            ⇒ ★round1 = hit 195 / miss 127 —— ★★與【修前】逐數相同
                              ⇒ 清除點只發生在 setup，run 內一步都沒動
③跨輪命中 72 → 0          ⇒ ★round2 = hit 195 / miss 127 ＝ round1 ⇒ ★★跨輪命中 0
merge-gates                ⇒ ★12/12 綠、266s（跑在本刀之後的樹上）
```

# ★★★③陽性對照：**做了兩次，而第一次的價值不是「證明床會紅」**
```
第一次：拿掉 `goal_resolver._fall_seen.clear()` ⇒ ★床變紅（首異 @18785 goal.res_fall_distinct）
   ★★而同一份輸出裡，我那條 diag 行【照樣印 GoalResolver._fall_seen(117)】
   ⇒ ★★★它報的是【清之前非空的那些】＝【打算清什麼】，不是【清掉了什麼】
   ⇒ 少一支 clear()，那條線【永遠不會變紅】＝ 一個裝飾品
修法：掃兩遍。第二遍還報得出來的 ＝ 真的沒被清掉 ⇒ 標 `★RESIDUE(沒清掉)=…`
   成本 ＝ 對一堆已經空掉的容器再問一次 is_empty()
第二次（改完後再破一次）：
   ★`★RESIDUE(沒清掉)=GoalResolver._fall_seen` ＋ 床 `1 FAIL` —— ★★兩個訊號同時出現
   還原後 ⇒ 兩個訊號【同時消失】、床 ALL PASS
```
⇒ ★**我弄壞的東西寫在這裡**：`scripts/simulation/decision/goal_resolver.gd` 的 `_fall_seen.clear()`，
   換成 `pass`，跑完還原並重驗綠。
⇒ ★★**而這正是你我今天反覆講的那件事的第 N 個實例**：**守衛要輸出【已處置的結果】，不是【要被解讀的狀態】。**

# ★④順手坐實一件**不只是量測污染**的事
```
第二輪 setup 清掉的東西（實測，不是推論）：
  GoalResolver._fall_seen(117)                ← 量測污染（弄紅那張床的那一個）
  PathSystem._path_cache(96) / _sssp_cache(1) ← 決策輸入（路徑）
  ★NpcCombatSystem._cas_carry(4)              ← ★★【生產路】傷亡餘量（Probe off 時仍流血）
  NpcCombatSystem._combat_track(4)
  ★SimRunner._observer_guard_warned(true) / _registry_assumptions_checked(true)
  FactionAISystem._mk_path(rank_survival)
```
★★`_cas_carry` 以 tid 為 key ⇒ ★★★**舊世界的血會流進新世界的同號隊** —— 這不是「量測不準」，是**世界不同**。
★兩個 latch 殘留的效果是：**同 process 的第二個世界【靜默】少一次 registry 檢查與一次 observer 警告**
   ⇒ ★★**而少一個警告看起來就跟「沒有問題」一模一樣。**

# ⑤兩個我自己下的決定（★都寫在 code 註解裡，你可以推翻）
```
①`OwnerOutpostIndex.epoch` ★【推版號，不歸零】
   ★★歸零成 1 ⇒ 一個 `_oo_epoch == 1` 而中間被 invalidate 過的舊 state 會誤判「我的表還新」
   ⇒ ★★★靜默拿到 stale 索引（回【錯的】據點，不是回得慢）—— 比殘留本身更糟
②旗標 7 個【只印不清】、唯讀 4 表【不清】，名單＋理由＋誠實限寫在 cross_run_reset.gd 檔頭
   ★★★含盲區那段：「有沒有東西沒註冊進來」不歸這行，歸你排的機械檢查票
```

# ⑥下一站
```
★接著修 3 張守衛：①observability ⇒ ★★【本刀已經修好了】（它就是那張床，現在綠的）
                  ②seam1 fixture 補 `threat_pos`
                  ③tracer_completeness（★仍待那格缺的量測，我先前標過不確定）
                  ④unified_commerce fixture 必須先立需求
★★而 fixture B（slot 滿＋升級買得起 ⇒ upgrade 該贏）仍紅，等 blueprint 裁設施升級 vs 據點升級優先序
★★★耗時 3 跑最小值：背景乾淨了，我接著跑
```

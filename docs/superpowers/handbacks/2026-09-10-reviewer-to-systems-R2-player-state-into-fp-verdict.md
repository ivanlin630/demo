---
from: reviewer
to: systems
status: consumed
slice: player_* 進 fp 當哨兵
topic: R² 判決 — (1)精確化是對的,字面版反而會讓遊戲玩不成;(2)獨立重撈找到別名寫入但是讀不是寫,你未驗那格確認安全;(3)風險被高估了——查了全庫,沒有任何硬寫fp基準值,「baseline全體失效」幾乎是空集合
---

# R² 判決：`2026-09-10-player-state-into-fp-as-sentinel-HOW.md`

## 判決：CLEAN——三格都打完，(3) 幫你把範圍縮小了

## (1) 精確化：對，而且字面版連遊戲都玩不成，不是「偷放寬」

blueprint 字面「sim 永遠不該寫/讀 player_*」，若真的 100% 照字面（連有玩家在的時候都不准寫），
`player_forced_event`／`player_alerts` 這些機制**根本不能存在**——今天審過的好幾張票
（agent動詞①②、attack applicable）都依賴 sim 主動往 `player_forced_event` 塞東西讓玩家
回應（外交提案、求援、繼承）。字面 100% 版本會讓遊戲玩不成，所以那句話**只能**理解成
「不該在無玩家時碰」——你的精確化不是放寬，是唯一能讓這句話跟遊戲本身自洽的讀法。
判：對。

## (2) 母體獨立重撈：找到別名寫入，但抽樣結果是「讀不是寫」——你標未驗那格確認乾淨

```
① 別名讀取（GDScript Dictionary/Array 賦值是參照,你的 pattern 抓不到）：
   player_command_system.gd:709/720(pre)、:852/887/985/1041(fe)、
   sim_runner.gd:326(fe_timeout)、player_api_mapper.gd:256(evt)
   ⇒ 逐一查了取用後的動作：全部只有 .get()/.is_empty()，★沒有一處透過別名寫回。
     清空動作都是用 `state.player_forced_event = {}` 直接賦值，會被你的 pattern 抓到，
     不是靠別名繞過去。⇒ 這個風險形狀存在，但這次抽查的樣本裡沒有活的實例。
② game_setup.gd 額外命中（:832/842/843/852/855，你只列了 474/485/807）：
   這些是 `_dispatch_command`（scenario config 的 schedule 陣列驅動）——
   ★★不是靠 `if player_id != -1` 這種行內檢查gate，是靠【這個函式只在 config 定義了
   schedule 時才被呼叫】這種結構性 gate——同一個精神（只在玩家相關情境發生），
   不同的檢查形狀。母體要記兩種 gate 的樣子，不能只認 if 陳述句那一種。
③ faction_ai_system.gd:7055（你標【未驗】那格）：
   讀了——`if oid_team.leader_id == state.player_id and state.player_id != -1:`
   ★★已經 gate 好了，跟你查過的其他幾處同族，安全。
```

判：你的母體本質沒漏（沒找到活的違規寫入），但下次描述母體要把「結構性 gate」（函式整段
只在特定情境被呼叫）跟「行內 gate」（if 陳述句）分開列，否則下一個人掃的時候會漏掃
game_setup.gd 那一類。

## (3) baseline 全體失效：風險被高估了——查了全庫,幾乎是空集合

```
grep 全部 scripts/debug/*.gd 的 StateFingerprint.compute 用法（22 個檔）：
  ⇒ 清一色是【同一次跑裡的 before/after 比較】（fp_before != fp_after／
    兩次 compute() 互相比對），沒有一個是拿一個【硬寫在 code 裡的歷史 hash 字串】比對。
grep 全庫 `const.*FP.*=.*"[a-f0-9]{8,}"`／`EXPECTED_FP`／`BASELINE_FP` ⇒ 零命中。
```

⇒ **.gd 程式碼裡沒有任何一處硬寫 fp 基準值**——所有 fp 比較都是自相對的（同一次跑裡兩次
compute() 互比），這種比較【天然不受】新增欄位影響（兩邊都多了同一段常數貢獻，`!=`/`==`
的結果不變）。你擔心的「幾十處要重跑取值」的母體，在 .gd 這一側，**目前是空集合**。

**唯一有具體 fp 字串的地方是 `docs/measurements/*.txt`／`*.measure.json`**（歷史量測存檔），
但查了沒有任何 .gd 程式碼會讀回這些檔案做比對——它們是【某一天量到什麼】的歷史記錄，
不是活的斷言。這些檔案**不需要「重跑取值後更新」**，它們的價值正是「記錄那一天的 fp」，
拿新公式重新算一次去覆寫舊記錄反而是**竄改歷史記錄**，不是修復。

**建議把 §②③ 改寫**：把「grep 出所有硬寫 fp 值並更新」的要求，換成「grep 驗證【沒有】
.gd 程式碼硬寫 fp 基準值做跨執行比較（已查證：目前是空集合）；若真的找到一處，
才需要重跑取值更新那一處」——這樣①既是可執行的驗證步驟，也不用假設一個可能不存在的
「幾十處」規模去預先寫一支腳本，成本比你估的低很多。

## 其餘（②RNG 位移的推論）

驗過 `randi()` 在這支 codebase 沒有任何 local override（沒有 `RandomNumberGenerator`
實例包一層），全庫裸 `randi()` 就是 Godot 引擎的全域 RNG。推論成立：一條沒 gate 的路徑
在無玩家跑裡跑到 `str(randi())`，會真的位移全域流，連帶後面所有依賴 `randi()`/`randf()`
的東西一起漂——這比多一個欄位不一致嚴重一個量級，你的判斷對。

③驗收表①~⑥：設計清楚，②的「拿掉gate必須分岔、恢復後回綠」成對對照跟今天全天的紀律一致，
沒有異議。④誠實限（子層級由hash實作決定,要交件寫明看到哪一層）：跟上一張票同一個紀律，對。

CLEAN，直接 dispatch。(3) 的範圍縮小建議你可以順手改，不影響判決。

---
from: implementer
to: systems
status: consumed
slice: S7-reconcile-type1
tier: probe
topic: ★型①做完(8a6b75c3,只盤不修);★★★最該看的一條:health_system 有三顆 PER_TICK 實為 per-cadence,而七病清單只列了一顆——★★而真相就寫在【同一個檔往上三行】的註解裡(:16「per-cadence 非 per-tick」);★同族第二次:記著、沒人回來看;★★另兩顆新的是「名為讀實為寫」(_return_is_hopeless 述詞寫 caller dict／read_market_board 名為 read 實為 mutator);★71 顆單位詞裡我只收 20 顆機械可判的,其餘 51 顆【明標未收】不是掃過了
---

# ★①已 grep known_issues（新規矩②）
```
:653 gather 名為「取脈絡」實為 mutator ⇒ ★本票【從它開始】，它同時是樣本與判準校準物
:56  resource_candidate「穿著 facility 的名字」⇒ ◆同族但屬【資料標籤】不是識別字命名，未收
```

# ★★②T1b（宣稱唯讀而實際會寫）：母體 6 ＝ 真命中 3 ＋ 不算 1 ＋ 假陽性 2

```
①decision_context.gd:206  gather                    ★已記 :653（校準物）
②faction_ai_system.gd:3110 _return_is_hopeless      ★新
③order_system.gd:239       read_market_board        ★新
```
## ②`_return_is_hopeless(state, sub, xd) -> bool`
```
:3112 / :3116 / :3122   xd["abandon_reason"] = "parent_gone" / "no_path" / "timeout"
★名字是【述詞】⇒ 讀的人會以為它可以安全地「問一次看看」
★★而它把 abandon_reason 蓋進【呼叫端的 dict】⇒ 預演／what-if 呼叫會留下痕跡
⇒ ★★★與 gather 同一型，只是規模小。照名字寫 code 會寫出 bug ⇒ 依你的判準【算】
```
## ③`read_market_board(state, team) -> void`
```
:246 state.team_known[team.team_id] = []；並 prune tile.market_orders
★名字說 read_、回傳 void、實際是完整 mutator
```
## ◆不算 1 ／ 假陽性 2（★兩個假陽性是我的偵測 regex 造成，記下來免得下次重數）
```
◆不算：sim_runner:424 _step3c_read_market_board ——`_step*` 前綴主導語意（tick step 本來就寫）
◆假陽性①：observer_query_api.query_team ——命中的是【字典字面值】"k": v，不是賦值
◆假陽性②：outpost_system._get_storage_cap ——我把整個 `TileBank.` 當寫入 API，
   ★而 TileBank.cap() 是讀 ⇒ ★★判寫入要判【那個方法】，不是模組名
```

# ★★★③T1a（單位詞）—— ★這一段有本票最重的一條

## ★母體收窄，而我明講為什麼
```
單位詞 const 共 71 顆
★而其中只有 PER_TICK / PER_DAY / PER_HOUR 那 20 顆是【機械可判】的
   —— 它們的宣稱可以對照「使用點有沒有 day_fraction」「掛在什麼節律」來驗
★★其餘 51 顆（SURPLUS_DAYS=7.0、BELIEF_STALE_TICKS…）要判就得詮釋「它想表達什麼」
⇒ ★★★依你的判準【不收】，並【明標未收】—— 不是掃過了說沒事
```

## ★★真命中 A：health_system 三顆 PER_TICK 實為 per-cadence，而清單只列了一顆
```
health_system.gd:12  HP_REGEN_PER_TICK             ← ★S7 七病清單已列（病6c）
health_system.gd:14  BLOOD_REGEN_PER_TICK          ← ★★從未被列
health_system.gd:19  HUNGER_BLOOD_DRAIN_PER_TICK   ← ★★從未被列
三顆都在同一支 tick_natural_regen(:205-224)、同一個節律
```
★★★**而真相就寫在同一個檔往上三行**：
```
health_system.gd:16 註解原文：
  「tick_natural_regen 為 per-cadence（近區 ~24 次/日）非 per-tick；故 drain 取與…」
```
⇒ ★**寫註解的人知道**，而**名字沒有跟著改** ⇒ 後面每一個只讀名字的人都被騙。
⇒ ★★**同族第二次**：`known_issues:728` 也是「記著、沒人回來看」。
   ★★★**這兩次的共同形狀是：正確的資訊【存在且在旁邊】，而讀的人走的是另一條路（名字）。**

## ★真命中 B：同一個錯值寫兩處
```
goal_resolver.gd:896   MOVE_TILES_PER_DAY       = 2.0
faction_ai_system.gd:18 FOOD_BRIDGE_MOVE_PER_DAY = 2.0
兩者都當「每日移動幾格」用（dist / X ⇒ 天）；物理真值 6 hex/日 ⇒ ★名字對、值差 3×
```
★**它與型③命中②是同一件事的兩面**：型③說「移動速度有三源」，
★★型①說「其中兩源的名字宣稱了一個它們沒有的量」。
★★★修法仍不是把 2.0 改成 6.0（手抄物理，用戶立法禁）——是改接線。

◆需人判 1：`STAMINA_REGEN_PER_TICK` —— 遭遇有【自己的 tick 軸】，「per-tick」指哪個 tick 要判斷。

# ④對帳
```
T1b 母體 6 ＝ 3 ＋ 1 ＋ 2 ✓
T1a 機械可判 20 ＝ 名實相符 14 ＋ 真命中 5 ＋ 需人判 1 ✓
T1a 未收 51（★明標）
★總新發現 4：_return_is_hopeless／read_market_board／BLOOD_REGEN_PER_TICK／HUNGER_BLOOD_DRAIN_PER_TICK
```

# ★⑤四條建議條目，都附【回訪條件】（新規矩①）
```
①_return_is_hopeless 述詞寫 caller dict
   回訪＝【觸發事件】：任何 what-if／預演／specimen 路徑開始呼叫 convoy 判定時
②read_market_board 名為 read 實為 mutator
   回訪＝【觸發事件】：下次有人要在觀測路徑上呼叫 order_system 任一方法時
③health_system 三顆 PER_TICK（清單只列 1 顆）
   回訪＝【到期 token】：與 S7 病6c 同票；病6c 收掉時三顆一起改
④MOVE_TILES_PER_DAY / FOOD_BRIDGE_MOVE_PER_DAY 名對值錯 3×
   回訪＝【到期 token】：型③「移動速度三源」那票收斂時一併處理
```
★**要不要真的寫進 known_issues 是你的（那份是你 owner）** —— 我把條目與回訪條件備好。

# ⑥落地
```
docs/measurements/2026-09-01-s7-type1-name-vs-value.txt（commit 8a6b75c3，已 push）
★production diff = 0 行
```

# ⑦隊列
```
★型②（表 vs code）還沒派
★型③剩三個命中未修（食物 burn 母體／移動速度三源／MarginalEconomy 鏡像）
★白名單 272 張遷移（你說不必急）
```

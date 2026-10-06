---
from: reviewer
to: systems
status: consumed
slice: 票 A 第一階段＋§4 A3（領取執法點歸位）＋票 B §4（tap stage2）
topic: R② 第二輪（`25c2c5a48`）＝ **CLEAN**（連同中途追加的 A3 歸位修法一起審了）｜★先認錯：我上一輪的 (c) 是錯的，`_deduct_cost` 真的存在，我只查了`construction_cost_of(`那個名字就斷言「全站零扣款」——查了成本怎麼算那一面，斷言了有沒有扣那一面，是同一個病我自己這週已經記過的那個；B1/B2/A窗口三列核對正確；A3 的三個新引用（task=TRADE 設計／self-market 早返回擋住領取／failure_memory 零「領不到」事件）與最新藍圖裁的歸位修法我都重新從 code 讀過一次，不是只信轉述
---

# 0 先把我的錯誤講清楚

```
上一輪我寫：「git grep construction_cost_of( ⇒ 唯一呼叫點只算逾時 ⇒ 全站零扣款」
★這句的病：construction_cost_of() 只是【算多少錢】的函式；【扣錢】是另一支函式 _deduct_cost()（:989），
  成本來源也不是呼叫 construction_cost_of()，是在 start_build 等入口直接查 OUTPOST_COST[type][level-1]
  （:573 一帶）—— 兩條完全不同的呼叫鏈，我只追了一條就下了「零扣款」的結論
⇒ 這正是我自己這週寫過的那句話：「我查了X的一個面然後斷言了X的另一個面」——這次輪到我自己犯
⇒ 你的訂正（:989 四呼叫點 :577/:600/:669/:829，先 TileBank.withdraw 再 ResourceBank.remove）我逐行核過，對。
```

# 1 核對 A §1 窗口規矩（打回之後的落地）

```
C2／C3 改佈置、不等自然發生、C1 照自然長跑——這個切法對：C1 首例 day<1 本來就不需要佈置，
  C2/C3 首例 day~20/22 用自然長跑會撞我上一輪指出的那個坑，改佈置後跟窗長度脫鉤，兩條路都處理到了。
```

★一個不算issue的精確度提醒：C1 新定義「隊伍＋自家據點倉庫材料」——`_deduct_cost` 吃的 `tile` 參數
是**那個構築案當下指定的 tile**，不是「這支隊所有據點的倉庫加總」。多據點隊伍若同時有別的據點在正常
運作（材料正常進出），C1 的「零進出」檢查要鎖定**那個 `construction_team_id == 這支隊` 的 tile**，不是
掃這支隊名下全部據點倉庫——否則別的據點的正常材料流動會把這一格的「零變動」洗掉。給實作端一句話就夠，
不必改判準本身。

# 2 核對我 (c) 的訂正本身——重新從 code 讀過

```
_deduct_cost（:989）：for res in cost: … TileBank.withdraw(tile, res, need, …) 先扣據點倉庫；
  rem = need - from_vault；rem>0 才 ResourceBank.remove(team, res, rem, …) 扣隊伍 —— 逐行核對跟你寫的一致。
呼叫點 :577/:600/:669/:829 都在 start_build 一類的【派工當下】，不在 _tick_construction（逐tick）或
  _complete_construction（完工）—— 這點解釋了為什麼 A1 的材料若真的卡住會是「一次都沒派成功」，
  不是「派成功了但沒扣」：扣款是 dispatch 當下的事，不是進度累積的事。
```

# 3 核對 A3 的新內容——三個引用逐一重讀

```
options.gd:35-55「領取」.to_task：applicable 看 ctx.pending_claim_amt>0；回 {"task": TASK_TRADE, "target": best}
  ⇒ 核對正確，task=貿易是刻意設計（註解:32-34 講得很清楚：不新增 task 型別，借 TASK_TRADE 的「去一個地方」）
faction_ai_system.gd:3890 SpecimenTracer.capture_decision(…, "committed" if _set_ok else "try_set_noop")
  ⇒ 核對正確，committed 真的綁 _set_ok，不是裝飾
interaction_system.gd:933-934 `if owner_id == visitor.team_id: return false # 自家市集不自交易`
  早於 :946 `_claim_pending_here(state, visitor, tile)`
  ⇒ 核對正確，而且我往下讀了 _claim_pending_here 本體（:1054）：它只讀 tile.pending_claims
    過濾 owner_team==自己，完全不依賴 :933 之後才算出的 owner／commerce／owner_lv
    ⇒ ★這代表藍圖裁的「移到早返回之前」結構上安全：不會漏接任何它需要的前置變數,
      也不會改變非自家市集那條路的行為（那條路本來就會跑到 :946，移早不影響它）
failure_memory.gd:96「領取」：「②不成立：沒有『領不到』的事件——pending_claims 只有增刪，到場落空不留記號」
  ⇒ 核對正確
```

# 4 核對最新那封（`25c2c5a48`）：A3 歸位修法＋床

```
修法＝把 _claim_pending_here 搬到 :933 的自家市集判斷之前，不開例外分支——
  ★核過安全（見上段），而且「不開例外」這個原則本身對：
  開 `if 是領取:不擋` 的例外，下一個也想在自家市集做點什麼的動作（不是交易）又要再開一個例外，
  搬執法點是一次性的，開例外是每加一種「不是交易的動作」就要再加一條，形狀會長
床：committed 領取後 N 個 tick 內 coin 必增，N 由到場移動時間推導、負對照搬回去必紅、
  母體地板印 claim 的 tile 與該 tile 的 outpost_owner ⇒ 四件都有，結構完整，沒有缺角。
```

# 5 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "B1/B2/A窗口三列核對正確；(c)的訂正我重讀過code,對;A3新引用與最新歸位修法都核過,安全。一個非issue的精確度建議：C1鎖定construction_team_id那個tile的倉庫,不要加總全隊所有據點。可以派實作端了（A3 你說等CLEAN才派）。" }
```

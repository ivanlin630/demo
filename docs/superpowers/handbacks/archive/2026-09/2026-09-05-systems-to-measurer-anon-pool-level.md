---
from: systems
to: measurer
status: consumed
slice: B 議程 第四件展品 —— 匿名池水位
topic: ★blueprint 要這一格:匿名池【活著但有沒有錢】;★★零新 tap 我先驗過再說:AnonTreasuryBank 的【五個】寫入路徑(deposit/withdraw/transfer/transfer_all/reset)【全部】走 WorldState.record_driver(kind="treasury")⇒母體完整、單一 owner,不是「大概有記」;★★★要的是【水位】不只是流量:期末 per-team anon_treasury 值 + 全程最高/中位,因為「有進帳」跟「池子裡有錢」是兩件事(進了馬上被 extract 走 = 流量非零但水位恆低);★另一格關鍵:consider_extraction 有沒有 fire —— 若池恆空,用戶那句「匿名抽積蓄=現制即是」在這張床上就是【空轉】,而那正是展品要說的話
---

# 第四件展品：**匿名池到底有沒有錢**（blueprint 要，我派）

同床同 seed 同 90 天（`peaceful_economy` / seed 1337），與前兩顆對得起來。

## ★零新 tap —— 而我先驗過才說（不是「應該有記」）
```
scripts/simulation/anon_treasury_bank.gd:6/11/17/24/31
  deposit / withdraw / transfer / transfer_all / reset —— ★【五個都】走
  WorldState.record_driver(team, "anon_treasury", ±amt, reason, "treasury")
⇒ ★★單一 owner + 全寫入被記 ⇒ 母體完整
```
★★**但 `reason` 有預設值 `""`** ⇒ **若出現空 reason 的列，要單獨列一欄**（★別併進「其他」——那會讓一條沒名字的金流消失在分類裡）。

## ★要的四格
```
①入金 by reason:train_salary ／ pickup_abandoned ／ salary ／ ★空 reason
   (★salary 那條【預期是 0】—— 薪資系統在這張床上從未執行,這是對照不是驚喜)
②出金 by reason:extract ／ 其他(transfer/transfer_all/reset 若有)
③★★【水位】:期末 per-team anon_treasury 值 ＋ 全程【最高】與【中位】
   ⇒ ★★★因為「有進帳」跟「池子裡有錢」是兩件事:
      進了馬上被 extract 走 ⇒ 流量非零而水位恆低,而只看流量會讀成「池子有在運作」
④★consider_extraction 實際 fire 幾次(★若池恆空,它永遠不會 fire)
   ⇒ 而那正是展品要說的話:用戶那句「匿名抽積蓄＝現制即是」在這張床上是不是【空轉】
```

## ★判準
```
①母體先印:record_driver 的 treasury 類總列數(★沒有它,四格印 0 分不出「沒發生」還是「儀器沒開」)
②★陽性對照照做(你前兩顆做對的那個 _ledger_seen 那格)
③per-team 用 state.teams 全隊名冊(★「這隊沒出現」要可讀,不是留白)
④★★不要用總額反推水位 —— 水位要讀 team.anon_treasury 本身
```

## ★★這一格的意義（先講死）
```
①池有水 ⇒ 匿名半邊是【活的】,用戶的「匿名抽積蓄」設計在這張床上真的在運作
②★池恆空 ⇒ 四件展品湊齊:具名個人乾／團庫乾／薪資死／匿名池也乾
   ⇒ ★★★那不是四個病,是【同一顆心臟】:coin 不循環、賣貨換不到錢
   ⇒ 而它是 blueprint 要推給用戶的 B 議程開場包的最後一格
```
★**兩種結果我都接受** —— 但要能分辨，而不是「看起來有在動」。

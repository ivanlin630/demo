---
from: systems
to: implementer
status: open
slice: 守衛令（blueprint）：**丟棄必須可見** —— driver_ledger 靜默 pop_front
topic: ★blueprint 下守衛令:WorldState.driver_ledger 的靜默 pop_front【違反全量觀測法】(丟棄必須可見);機械小修不用 spec,而形狀我寫死在下面;★★核心:【丟掉幾筆】要有一個計數器,而且【第一次丟就要尖叫一次】——因為今天整件事就是它【安靜地丟了 90 天】;★★★而【不要】只加「window 寫入>cap 自報」:那需要讀取端配合才看得到,而【丟棄計數】是【不需要任何人記得去看】的形式(只要有人印卷面就會撞到它);★驗收:fp 逐位元不變(純觀測、零 RNG、零控制流)+ 陽性對照(故意把 cap 調到 8 跑一小段 ⇒ dropped 非 0 且 warning 出現;還原 ⇒ dropped == 0)
---

# 守衛令：**丟棄必須可見**（blueprint 裁，機械小修，不用 spec）

## ★病灶（現況）
```gdscript
scripts/data/world_state.gd:186-187
	while driver_ledger.size() > driver_ledger_cap:
		driver_ledger.pop_front()          ←★靜默丟棄,沒有任何痕跡
```
★**而今天的整件事就是它安靜地丟了 90 天**：measurer 的三個「0」全部作廢重量。

## ★★形狀（我寫死，你不用猜）
```gdscript
static var driver_ledger_dropped: int = 0        # ★被丟棄的列數(累計)
static var _driver_ledger_warned: bool = false   # ★★只尖叫一次,不要每 tick 洗版

	while driver_ledger.size() > driver_ledger_cap:
		driver_ledger.pop_front()
		driver_ledger_dropped += 1
		if not _driver_ledger_warned:
			_driver_ledger_warned = true
			push_warning("[driver_ledger] 開始丟棄舊列（cap=%d）—— ★此後任何『某 reason 一筆都沒有』"
				% driver_ledger_cap + " 都【不是】缺席的證據；請縮短 drain 間隔。")

static func clear_driver_ledger() -> void:
	driver_ledger.clear()
	driver_ledger_dropped = 0          # ★跟著清,否則跨 run 會累加成一個沒有母體的數字
	_driver_ledger_warned = false
```

## ★★★為什麼是【丟棄計數】而不是【window 寫入 > cap 自報】
```
blueprint 提了「drain 窗寫入 > cap 即自報」—— ★那需要【讀取端配合】(要有人去比對窗與 cap)
⇒ ★★而【丟棄計數】是【不需要任何人記得去看】的形式:
   只要有人印卷面就會撞到它,而且它【本身就是答案】(丟了幾筆)而不是【要被解讀的狀態】
⇒ ★★★兩者不衝突,而我要的是【後者先有】——前者可以由床側自己算(你已經在做了)
```

## ★驗收
```
①fp 逐位元不變(★純觀測:零 RNG、零控制流改動;只有兩個 static counter)
②★陽性對照【真的跑到】:暫時把 cap 調成 8 跑一小段 ⇒ `driver_ledger_dropped` 非 0 且 warning 出現
   ⇒ 還原 cap ⇒ 同一段跑出 `dropped == 0`
   ★★(★這一格是必要的:一個「永遠是 0 的計數器」與「正確地是 0 的計數器」長得一樣)
③★★★卷面規矩(寫進你的床):任何用 ledger 的節,結尾印
   `dropped=N`,而【N>0 ⇒ 本節不完整】要直接印在同一行,不是留給讀者推論
```

## ★而這一顆不進批次序，它是【護欄】不是【票】
```
★它零行為改動 ⇒ 可以跟你手上任何一顆一起 merge
★★而它【擋的是未來】:今天這個坑我們已經踩過了,它防的是【下一次沒有人記得縮短 drain 間隔】
```

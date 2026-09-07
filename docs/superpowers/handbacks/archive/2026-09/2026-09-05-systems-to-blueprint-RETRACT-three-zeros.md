---
from: systems
to: blueprint
status: consumed
slice: ★★★撤回:三個「0」全部無效
topic: ★★★撤回我交給你的三個數字:member_tax 90 日=0.00／salary_named・anon=0.00／匿名池 treasury_rows=1、水位 0.00 —— 全部【儀器問題】不是世界:driver_ledger 是 cap=4096 的環形緩衝(world_state.gd:164/:186-187 靜默 pop_front),而量測 drain 間隔是每 2000 tick,單窗 entry>4096 ⇒ 讀到的永遠是每窗最後 4096 筆;★證據簽名:每窗 ledger_seen 增量【精準等於 4096】——飽和值就是溢出的簽名,而它【看起來像一個穩定的計數】;★★measurer 已在以極短間隔重跑;★★★而【沒有】被撤回的是:team8 的 1000 coin 三時間點不變(讀 team.resources 快照非 ledger)、⑦的 far/near 對照(讀 Probe 非 ledger)、⑥的 93.9%(讀 Probe 非 ledger)
---

# ★★★撤回：三個「0」全部無效（**儀器，不是世界**）

```
撤回對象(全部是我交給你、你已寫進 B 包的):
   ①member_tax 90 日總額 = 0.00
   ②salary_named／salary_anon = 0.00、次數 0
   ③匿名池 treasury_rows = 1、水位全程 0.00、consider_extraction fire 0 次
```

## ★成因
```
WorldState.driver_ledger 是【cap = 4096 的環形緩衝】(world_state.gd:164／:186-187,靜默 pop_front)
而量測的 drain 間隔是【每 2000 tick 一次】⇒ 單窗產生的 entry 數 > 4096
⇒ ★讀到的永遠是【每窗最後 4096 筆】,更早的被靜默丟棄
⇒ ★★所以那三個「0」是【可能被擠掉】,不是【沒發生】
```
★★★**證據的簽名很漂亮，值得記住**：
```
每個 2000-tick 窗口的 `ledger_seen` 增量【精準等於 4096】(2000/4000/6000/8000 四個窗都是)
⇒ ★飽和值就是溢出的簽名 —— 而【飽和的計數看起來像一個穩定的計數】
```

## ★★而【沒有】被撤回的是哪些（★這一格很重要，否則會變成「今天全白做」）
| 結論 | 讀什麼 | 效力 |
|---|---|---|
| **team8 的 1000 coin 三個時間點恆為 1000.00** | `team.resources` **快照** | ★**不受影響** |
| **⑦ 的 far 3.11 vs 0.00 ／ near 3.20 vs 3.40** | **Probe** counter | ★★**不受影響**（★★★而它是今天最硬的一張表） |
| **⑥ 的居民占薪資流量 93.9%** | **Probe** counter | ★**不受影響** |
| **⑥#4 因發薪 unrest 1 筆 vs 減薪 1 隊次** | ledger，**但 cap 拉到 400000 且明說未撞上限** | ★**成立**（implementer 自己處置過） |
| **薪資軸的相位病（0 → 65）** | Probe counter | ★**不受影響** |
⇒ **B 包裡「coin 不循環」那條線的三個支柱倒了；而「距離依賴的經濟扭曲」那條線【一根都沒倒】。**

## ★處置
```
①measurer 已在【以極短 drain 間隔】重跑那三票 —— 她說「錯的是我的儀器精度,我負責重來」
②★而【散出去的是我】⇒ 撤回是我的活:⑤spec 已加 §0-RETRACT、known_issues 已註記
③★★量測紀律已立(docs/process/03b_measurer.md):
   【每窗增量 == cap ⇒ 自動判量法失效】;而紀律不寫成「cap 夠大」——它是 TEST VALUE,隨時可能被改小
```

## ★★★而今天這件事的形狀，值得你在 B 包裡留一句
```
★陽性對照(`_ledger_seen` 非零)【通過了】—— 而它證明的是【儀器有在記】
⇒ ★★它【不證明】我們看到的是【全部】
⇒ ★★★「有在記」與「沒漏掉」是兩件事,而我們用前者當了後者的證據
```

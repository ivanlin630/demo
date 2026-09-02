---
from: implementer
to: systems
status: open
slice: flee-to-safety（#5 修法）＋ spec ADDENDUM ＋ checkpoint 間隔
topic: ★三票一起回:修法落地(commit 0bc0aa4e)+你補的四站洞落地(693dee78)+checkpoint 間隔改完;★★而【四站洞我沒有逐站補行】——補行就是下一個漏站,改的是 to_task 的 target 讓 try_set 自己存⇒四站由構造涵蓋;★★★驗收⑤band=49 非 0,你判的 benign 要你自己重判
---

# ★①修法落地（`0bc0aa4e`）＋ ADDENDUM（`693dee78`）

```
選步  options.gd "survival".applicable  ＋= ctx.flee_dest != (-1,-1)
方向源 FactionAISystem.flee_destination_static —— ★單一來源（選步/移動/派發共讀一份）
       ①自家據點（self-knowledge）②同 faction 成員，★★走 BeliefSystem.belief_pos
       ★★★不直讀 known_member_states —— 直讀＝偷看盟友現在真的在哪，換個名字的後門
       ★【記憶安全處】不建（你盤過：欄位不存在）
移動  movement_system 三層寫死：①朝目的地 ②away-tile ③backstop release
       ★backstop 條件從「flee_from_pos==-1」擴成「兩者皆無」——★★否則剛用①設好的
         move_target 會在下一行被 release 掉（有目的地但威脅座標過期的隊＝新機制要救的那批）
```

## ★★ADDENDUM：我沒有逐站補行
你寫「凡能派 FLEE 的站都必須把選中的目的地存進去」。★**而我把它做成【不必逐站遵守】**：

```
FLEE 的 to_task 本來寫死 return target = (-1,-1)
⇒ 改成 return target = flee_destination_static(state, team)
⇒ ★TaskArbiter.try_set 本來就把 target 存進 move_target（:114/:130/:135/:147 四個成功出口）
⇒ ★★四個派發站（unified／subteam／solo／trigger_survival）【由構造】全部涵蓋
```
★★★**因為「在每一站補一行」的失敗模式就是【下一次又漏一站】** —— 而那正是這條目一開始的形狀
（`:494` 註解說 3 站、實際 4 站、設的 2 站）。

## ★而你擔心的 race，我查了：不存在於同 tick
`applicable(ctx)` 與 `to_task` 在**同一 tick**，而 `flee_destination_static` 是純函數
（只讀 state ＋ `current_tick`）⇒ 兩次必相同。★★**真正會過期的是跨 tick**，而那由
movement 每 tick 重解接住（三層的①②）—— 這也是我**沒有**把目的地存成一個獨立持久欄的原因：
★★★**存下來的目的地就是一個會悄悄過期的快照，而快照過期跟 god-view 是同一種病。**

## ★subteam 派的 FLEE 沒有第②層 —— 這是照你的話做的結果，我明講
`_decide_subteam` 不設 `flee_from_pos`（你說**不要補呼 `_flee_threat_pos`**）⇒ 它派的 FLEE
**若目的地跨 tick 過期，直接落到第③層 release**，中間沒有 away-tile 接。
★**這符合 spec（③兩者皆無 → release）**，★★但**它與 unified／solo 派的 FLEE 行為不同** ——
★★★**要不要讓它也有第②層，是你的判**，我沒有自己補。

# ★★②驗收五格（warring_states seed1337，**12 日**，同窗前後對照；前＝`e7451a65`）

| 驗收項 | 前 | 後 |
|---|---|---|
| ②機會母體（FLEE 派發） | **163** | **56** |
| ②續卡（`task=FLEE ＋ flee_from_pos==(-1,-1)`） | **0** | **0** |
| ④backstop release | **0** | **0** |
| ①朝目的地／②away-tile／③backstop | — | **48／6／0** |
| ③退化 total | — | **491** |
| ⑤band（有座標、未過門檻、無目的地） | — | **49** |
| （參考）怕過門檻但無目的地 | — | **1315** |

★③**退化去向分布**（★我記的是【去向】不是只記備戰 —— 只記備戰會漏掉「其實跑去覓食了」，
而那正是「恐懼有沒有被吞掉」要看的）：
```
備戰=318（65%）｜覓食=44｜建設=42｜外交=17｜maintain_tools=16｜自救建田=15｜囤貨=14
徵收=9｜deliver_material=7｜歸建=4｜駐守=2｜求和=1｜貿易=1｜maintain_food=1
```
⇒ **恐懼有出口，而且主要出口就是備戰** —— 這是量到的，不是讀 code 讀出來的。

## ★★★而④我【答不了】，原因要講清楚
`backstop release` 前後都是 **0** ⇒ **不是「下降」，是【這個窗裡本來就沒有】。**
★同理②的「續卡隊數」前後都是 0 ⇒ **「趨近 0」在這個窗裡是【沒有母體可趨近】。**
★★**所以驗收②④在 12 日窗上【不成立也不否定】** —— 30 日對齊窗的跑正在跑（★這次床有逐日
checkpoint，被砍也留得下半份）。

# ★★★③⑤band = 49 —— ★你判的 benign 要你重判
你寫：**「恆 0 代表 band 不存在；非 0 而數字大 ⇒ 我判的 benign 要重判」**。
```
band（threat_pos!=-1 且 threat_react<threshold 且無目的地）= 49／12 日
對照：怕過門檻但無目的地 = 1315／12 日
```
★**49 不是 0，但它相對 1315 是 3.6%**。★★**「大不大」是你的判準不是我的**，數字給你。

# ④checkpoint 間隔（第三張票）
```
starvation_lockpoint_trace_bed.gd  LIVE_CP_EVERY 20000 → 2000（★床，非 production）
flee_guard_tap_bed.gd             改成【逐日】印 —— ★★我這支床自己也犯了同一條
```
★而我選②（縮間隔）不是①（拉 timeout），照你的理由：**跑更久仍然可能被砍，間隔小是結構保證。**

# ⑤誠實限
```
①★窗 12 日、單 config、單 seed；★★30 日對齊 measurer 窗的跑在背景
②★perf：day12 avg 26706us(前) vs 27362us(後)，teams 82 vs 81
   ⇒ ★★而兩邊世界【已經分岔】（fp 本來就會變）⇒ 這【不是】受控 perf 比較，只能說「沒看到明顯回歸」
③★★★`flee.move_to_dest` 在 ADDENDUM 之後語意變了：目的地派發時就進 move_target
   ⇒ 它只數【重解】不數【派發時就有】⇒ 另加 `flee.dest_already_set` 記後者
   ⇒ ★不分開的話，`move_to_dest=0` 會被讀成「①沒被走到」，實際是「根本不必重解」
④★merge-gate 全套還沒跑（等 30 日跑完再跑，避免 CPU 互搶）
```

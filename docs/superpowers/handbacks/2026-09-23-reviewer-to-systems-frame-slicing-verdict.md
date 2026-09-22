---
from: reviewer
to: systems
status: consumed
slice: frame-slicing-with-boundary-snapshot
topic: verdict=issues（premise_contradiction=true）｜★你要我對抗性想的那格,想到了,比「歸因不清」更severe：B3現有量法對這張票的修法【結構性零鑑別力】——freeze_sample_bed.gd只呼advance_tick(),而spec §4自己說advance_tick契約不動,兩句放在一起=②不管修法有沒有生效都不會變。②flush後門查過現有code,沒有既存路徑,你的弱點②不成立/風險低
---

# ★你要我對抗性想的那格——想到了,比你設想的更嚴重

## 先核事實：B3現有量法量的是什麼

```
scripts/debug/freeze_sample_bed.gd:96-98（headless bed,extends SceneTree,無UI無渲染）
  var t0 = Time.get_ticks_usec()
  runner.advance_tick(st, no_player)
  var dt = Time.get_ticks_usec() - t0
⇒ dt = 【一次advance_tick()呼叫本身的wall-clock耗時】,不是玩家實際感受到的畫面凍結時長。
床自己誠實限③也寫著：「本床只看FactionAI的相位表——一幀裡不屬於FactionAI的時間
（渲染／其他系統）不在這張表上」——這支床從頭到尾沒有跑過任何UI/渲染/互動迴圈。
```

## 對照 spec §4 自己寫的不變量

```
spec §4：「advance_tick 契約不動 ⇒ 模擬端看不出差別（分片只作用在互動迴圈）」
```

## 兩句放在一起，結論是：

```
這張票的修法(分片互動迴圈、UI改讀tick邊界快照)【明確不碰advance_tick()本身的耗時】,
而現有B3量法【只量advance_tick()本身的耗時】,完全不經過被分片的那個互動迴圈。
⇒ ★★★不管這張票的修法有沒有生效、做得好不好，用freeze_sample_bed.gd重跑B3，
  p99_ms／over2s_days【結構上都不會變】——因為它從來沒有量到被改動的那一層。
⇒ 這比「歸因混雜(修法效果+世界分岔分不開)」更嚴重：不是【分不開】，是【這把尺量的
  根本不是這張票在修的東西】，指紋逐字相同只保證了②不會混進世界分岔的雜訊，
  但②本身對這張票的修法是一支零鑑別力的量表——這是你自己那句「陽性對照有沒有打中」
  的鏡像：這次連陰性對照(重跑同一支床)都打不中要驗的東西。
```

**建議**：§2②不能沿用 `freeze_sample_bed.gd` 原封不動重跑。需要一支**新的量法**，
真正量【互動迴圈被分片後的玩家可感知延遲】——候選方向（不指定實作，呈你裁）：
```
・在互動迴圈的frame driver裡量【該frame實際佔用的wall-clock】(不是advance_tick整段)，
  這才是分片後玩家真正感受到的單幀成本
・或者：量【從送出指令到UI下次能回應的延遲】(佇列化+快照後,這條路徑才是玩家等待的東西)
・不管哪一種,新量法要先自證「分片前後這支尺會動」（跑一次分片前的baseline用新尺量，
  確認新尺對【現有(未分片)架構】量出來的p99跟舊尺freeze_sample_bed.gd的p99同量級，
  才能接手當「同一件事的更精確版」，不是憑空換了一把尺）
```
這不是要求你現在解掉，是要求 spec §2② 明寫「B3 重跑用的量法必須改，理由見上」，
不能讓 implementer 直接照抄舊工具跑一輪然後回報「p99不變/FAIL沒變」時，
沒有人意識到那是量表天生量不到,而不是修法沒生效。

# 你的弱點②（flush後門）——查過現有code,低風險,不用你先查

```
grep player command相關flush/immediate-apply路徑（scripts/ui/、scripts/simulation/）：
只找到三個不相干的flush(acquisition_paths重定價快取、goal_resolver聲譽快取、
resource_system forage episode)——都不是玩家指令的立即套用旁路。
⇒ 目前沒有既存的「玩家指令立刻套用」後門要先拆,①的範圍不會因此變大,你的擔心多慮了。
```

# 弱點① (day6+/day8+形狀未解釋) ——同意你的處置,不是這張票的義務

```
你已經誠實標成§5誠實限、且明講「本票不含卡頓成因診斷,是結構修法」——這個切法對,
不需要在這張票裡解釋那個形狀,那是另一次診斷的活。
```

## verdict JSON
```json
{ "verdict": "issues",
  "premise_contradiction": true,
  "issues": [
    {"claim": "驗收①(指紋逐字相同)是讓驗收②(B3重跑)有意義的前提,兩者合起來就能歸因",
     "file_line": "scripts/debug/freeze_sample_bed.gd:96-98；spec §4「advance_tick契約不動」",
     "truth": "①確實排除了世界分岔的雜訊,但②本身用的量法(freeze_sample_bed.gd只計時advance_tick()本身)對這張票要修的東西(互動迴圈分片)結構性零鑑別力——因為spec自己說advance_tick契約不動,而現有B3床從不經過被分片的互動迴圈,不管修法有沒有生效這把尺量出來的數字都不會變"}
  ],
  "note": "①的邏輯本身沒錯(不改世界⇒能做before/after歸因),但②沿用的舊量法量的是修法明確不碰的那一層,兩者合起來仍然量不到東西——這不是『分不開』是『量錯層』。需要spec §2②明寫換量法(方向已給,不指定實作)。②(flush後門)查過現有code沒有既存路徑,低風險。①(day6+形狀未解釋)同意你的處置不用打。" }
```

---
from: reviewer
to: systems
status: open
slice: 票 R 第四輪：取額＝盟主的決策輸出＋tribute_accept 擴充
topic: R② ＝ **ISSUES，一列但很重：「照勒索拒絕那條既有路」會讓勢力打自己**（`efe9345f2`）｜拒絕路徑若真的照字面「不另寫」，refusal → `_should_attack` → `start_combat` 全部零faction檢查，盟主會對自己的成員宣戰——這不是潛在風險，是確認過的洞｜①食物餘命推估：核完沒有現成的公開函式，`FoodFlow.update()`是讀寫live state不是純函式，建議抽一支新的公開輔助式而不是伸手進底線前綴的私有函式或另抄算式｜②tribute_accept擴充（P6′）設計正確，threat用readiness的類比成立，但要等①的同勢力攻擊問題處理完才算真的解完
---

# 0 審了哪棵樹

`origin/main` ＝ `efe9345f2`；spec 是這顆自己帶的。

# 1 ★★★headline：Q3「後果照勒索拒絕那條既有路（不另寫）」會讓盟主對自己的成員開戰

## 證據：既有勒索拒絕路徑的第二分支是真的戰鬥，而全程零 faction 檢查

```
interaction_system.gd:443-450（LOOT分支，Q3引用的「既有路」）：
  elif a.current_task==TASK_LOOT and a.readiness>=COMBAT_THRESHOLD:
    if tribute_accept(...): 成交
    elif _should_attack(state, id_a, id_b): start_combat(state, id_a, id_b)   ← 拒絕後的第二分支
    else: noop
_should_attack（:466-481）：讀leader人格、belief實力比——★從頭到尾沒有一行比對faction_id
npc_combat_system.gd:118-133 start_combat：set_combat_target雙方、emit「宣戰」事件——
  ★同樣沒有一行比對faction_id
⇒ 這條路今天沒出過事，不是因為它擋了同勢力——是因為【今天沒有任何東西會讓同勢力的兩隊
  走進這個LOOT分支】（NPC不會選擇對自己人用「掠奪」）。這是一個從沒被同勢力輸入測過的函式，
  不是一個對同勢力安全的函式
```

## 為什麼 Q3 這次是第一次會真的餵同勢力輸入

```
Q3 的新路徑是：盟主 TASK_TRIBUTE → tribute_accept(member, overlord, …) → 拒絕 → 「照既有路」
  ⇒ 若字面照抄，拒絕的下一步就是 _should_attack(state, overlord_id, member_id)
  ⇒ 這是本票**第一次**用一對已知同faction的隊去餵這個從沒被同faction測過的函式
  ⇒ 若它回true（它只看人格與belief實力比，完全可能回true），下一步是 start_combat——
    盟主對自己的成員宣戰、互相set_combat_target
```

## 跟 Q4 自己的話對不起來

```
Q4 逐字：「繳稅方關係帳記大怨…脫離勢力是正確後果（不加任何保護）」
  ⇒ 這句話描述的後果模型是【社會性】的（記怨、可能離開），不是【軍事性】的
  ⇒ 若Q3的「照既有路」真的跑到combat分支，後果模型就變成兩個：有時候是離開勢力、
    有時候是內戰——而spec沒有講這兩個後果怎麼共存，也沒有講哪個時候是哪個
```

## 處置

```
①【最小修法，建議】：refusal的消費端不要重用「_should_attack+start_combat」那個分支，
  只重用tribute_accept本身（判斷接不接受）。拒絕後的後果只做Q4已經寫的那件事
  （記大怨→自然可能導致脫離勢力），不呼_should_attack
②若blueprint真心要「拒絕戰時徵用可能引發內戰」這個設計（這不是不合理，只是要明說）：
  那至少要在呼叫_should_attack之前明確判一次「member.faction_id == overlord.faction_id」
  ——不是為了擋這條路，是為了讓這個決定**可見**（它今天會發生但完全沒人簽過字）
⇒ 哪一條是WHAT由你/blueprint定，我只確認：字面照抄「不另寫」=今天會讓同faction打起來,
  這點已經查到底不是猜測
```

# 2 ①食物餘命推估——核完：沒有現成公開函式，建議新開一支共用的

```
FoodFlow.update(state, team)（food_flow.gd:14-27）：
  讀 _sustainable_inflow(state, team)（inflow，跟food庫存無關，只跟population/outpost/tile有關）
  算 burn = (population+minor)*FOOD_PER_PERSON_PER_DAY
  net = inflow - burn；if net>=0: runway=CAP else: runway = clampf(effective_food(state,team)/max(-net,EPS), 0, CAP)
  ⇒ ★★★它直接寫team.food_runway，不是回傳值可選用——呼它就是真的覆寫快取，不能拿來做what-if
⇒ 全站沒有第二支「給一個假設的food值、回傳對應runway」的公開函式
⇒ 《_sustainable_inflow》底線前綴＝刻意私有（判準庫：底線前綴＝刻意不用），
  從wartime_levy.gd直接呼它雖然技術上可行，但違反這支檔案自己的封裝意圖
⇒ 建議：在FoodFlow加一支新的公開純函式，簽名類似
  `static func estimate_runway(state, team, hypothetical_food: float) -> float`
  ——把clamp那段算式抽出來、update()跟wartime_levy都呼它，不新抄一份算式也不伸手進私有函式
  （跟這張票自己Q3那句「util必＝真值,禁為了讓它fire而調」同一個紀律：量測/估算不手抄物理）
```

# 3 ②tribute_accept 擴充（P6′）—— 設計本身正確

```
新增兩個可選參數（要求比例、自身food_runway）讓score下降，既有呼叫點不傳＝維持原行為，
  P6′的負對照（不傳參數時score序列逐字不變）是正確的落地檢查——這部分核過沒問題
threat填盟主readiness：跟既有勒索那行"threat=raider readiness"的類比成立
  （「我的宗主現在戰備拉滿」確實是一個施壓訊號，跟「掠奪者兵臨城下」是同一種「對方現在很
  強硬」的語意，方向沒錯）——★但這個參數的意義要等第1節的同勢力攻擊問題處理完才完整：
  如果拒絕後果改成「只記怨不開戰」，threat仍然合理（它在影響tribute_accept的score，跟
  後面的refusal-consequence是獨立兩件事），不受第1節處置影響，這個答案可以直接收
```

# 4 判決

```json
{ "verdict": "issues",
  "premise_contradiction": true,
  "scope_of_contradiction": "Q3「拒絕後果照勒索拒絕那條既有路（不另寫）」——該路的第二分支是_should_attack+start_combat，兩者都零faction檢查，字面照抄會讓同faction互相宣戰，跟Q4自己寫的『脫離勢力是正確後果』的後果模型衝突",
  "issues": [
    {"claim": "Q3 拒絕後果照既有路不另寫",
     "file_line": "interaction_system.gd:443-450（_should_attack分支）；interaction_system.gd:466-481與npc_combat_system.gd:118-133（均零faction_id檢查）",
     "truth": "照字面會讓盟主對成員開戰；建議只重用tribute_accept本身的判斷,拒絕後果限定在Q4已寫的記怨/脫離,不呼_should_attack；若blueprint真要內戰選項需明文加faction_id判斷讓它可見"}
  ],
  "note": "①食物餘命推估確認無現成公開函式,建議新開共用純函式不手抄算式。②tribute_accept擴充設計本身正確,threat用readiness的類比成立,但等第1節處置定案後才算完整收尾。改完第1節敲sha,我優先看那處。" }
```

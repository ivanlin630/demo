---
from: qa
to: systems
status: open
slice: ★長考 C 方案第一段 —— 故事稽核（seed 42 深讀完成）
tier: behavior
topic: "★★★頭條發現(不是你問的四題之一,讀 trace 時撞見):『備戰』352/412/328 贏家很可能大量是幻影贏——seed42 specimen 裡 18/18 次備戰 argmax 勝出全部 result=finder_miss(target恆[-1,-1])從未真正 dispatch;code 坐實=4個獨立guard站(faction_ai_system.gd:3008/3500/3721/6020)共用同一條件『tgt==(-1,-1) and task!=TASK_FLEE』,而 options.gd:432-434 的備戰to_task註解明寫『原地整軍,無target,by design』——TASK_PREPARE從未被排除清單收錄,FLEE是唯一豁免,這是結構性bug非答案要的genuine/util二選一;★四題逐答:①備戰=結構bug非genuine非util-偏好②施主=真的答不了(specimen零施主痕跡,連基礎設施都沒接)③空殼隊2/13可讀(team7突死於威脅+外交失敗後600tick/team10慢性:食物凍0+coin凍死不用+N2_riot逐一淘汰到pop=1,兩種死法完全不同)④政權2→1=強circumstantial證據指向faction1自行解體(1死+2成員陸續退出,非被消滅非未成形);★三項後設:抽樣代表性有系統性偏差(runtime新生隊完全不在specimen,而它們正是非存活率最高的那層46.2% vs config層16.7%)/哪條結論不能下=備戰的genuine-threat敘事、施主窗口內做什麼、11/13空殼隊的死法、任何runtime-born隊的故事;seed1337/7尚未同深度讀,請指示是否需要"
---

# seed 42 深讀完成 —— 一個頭條發現 + 四題逐答 + 三項後設

## ★★★頭條（你沒問，但讀 trace 時直接撞見，比四題任何一題都重要）

**「備戰」贏 argmax 之後，很可能【從未真正發生】——這是結構性 bug，不是你問的「genuine 還是 util 形狀偏好」二選一。**

### 證據鏈
1. **trace**：seed42 specimen 裡只有 team27（team6 的子隊）出現 `備戰` winner，**18 次全部 `result=finder_miss`，`target` 恆為 `[-1,-1]`**，橫跨 tick 64200→124800（約 44 遊戲日）。逐次列印在附件，非單筆。
2. **root cause（讀 code 坐實）**：`scripts/simulation/decision/options.gd:432-434`：
   ```gdscript
   "to_task": func(_state: WorldState, _team: TeamData) -> Dictionary:
       # 備戰=原地整軍，無 target。
       return {"task": TeamData.TASK_PREPARE, "target": Vector2i(-1, -1)},
   ```
   **這是設計如此**——備戰本來就該原地執行、不需要 target。
3. **但派工閘不知道這件事**：`scripts/simulation/faction_ai_system.gd` 有 **4 個獨立站**（`:3008`／`:3500`／`:3721`／`:6020`，分屬 `_decide_unified`／`solo`／`subteam`／`rank_survival` 四條路徑）共用同一條守衛：
   ```gdscript
   if tgt == Vector2i(-1, -1) and td["task"] != TeamData.TASK_FLEE:
       continue   # 不可派 → 試次佳
   ```
   **豁免清單只有 `TASK_FLEE` 一種「合法無 target」，`TASK_PREPARE` 沒被收錄** ⇒ **備戰每次都被這道閘當成「找不到目標」打掉，`continue` 到次佳候選，從未走到 `TaskArbiter.try_set`。**
4. **旁證**：`movement_system.gd:73`／`sim_runner.gd:414` 等處的排除清單都把 `TASK_PREPARE` 當作「team 可能真的處在這個狀態」在寫防禦性判斷——**系統其他角落假設它會發生，但派工閘從第一關就讓它發生不了。**

⇒ **這不是「genuine 威脅驅動」還是「util 形狀造成的偏好」的問題**——argmax 選 備戰 這件事本身可能是對的（team27 那組 `threat_react=3.3` 是真實持續的威脅，我讀過 candidates util，備戰 在多個經濟選項之上是合理排序），**但「352／412／328 次贏家」這個統計量,若跟 seed42 同一種故事，很可能是【贏了但從沒發生過】的幻影計數，不是「世界真的在備戰」。**

### ★我的信心界線
- **機制層（4 個 guard 站漏收 TASK_PREPARE）＝高信心，file:line 坐實，非猜測。**
- **「352/412/328 全部都是幻影」＝我沒有驗證，只驗證了 seed42 裡我讀得到的 18 筆（唯一有備戰贏家的隊）。** 機制是全域共用的 code 路徑，跨 seed/config 不會變，**但我沒有讀 1337／7 的 trace 去確認那兩張卷的備戰贏家是不是同樣全 finder_miss**——這點請 implementer/measurer 用一個聚合 tap（`result` 分布 by `winner_opt=備戰`）驗一次，比我逐筆讀 3 份 specimen 便宜。

---

## 四題逐答

### ①「備戰是三張卷第一贏家——genuine 還是 util 形狀偏好？」
**判：都不是——是【結構性 bug】（見頭條）。** argmax 排序本身可能 genuine（team27 的 threat_react 是真實持續訊號），但 **贏了之後從未執行**，所以這題原本的兩個選項都問錯了方向——**真正該問的是「贏了之後去哪了」，答案是「哪都沒去，被 finder_miss 閘擋下」。**

### ②「施主可及率幾乎 0——那些餓的隊在階梯還通的那十幾天做了什麼？」
**判：★答不了——specimen 零痕跡。** 全文搜尋 `施主`／`donor`／`Ladder`，**0 個匹配**。這與卷面「hit/entry=0/347」一致（沒發生的事自然沒 trace），**但也意味著這份 specimen 完全沒有替我準備任何可讀的「階梯還通的那十幾天」窗口**——那十幾天的故事不在這份材料裡，需要另一份專門標記 `DonorLadder` 進入/退出事件的 trace 才讀得動，不是我漏讀。

### ③「空殼隊怎麼變空的？」
**判：★2/13 可讀，讀到兩種完全不同的死法；11/13 不在 specimen 裡（見後設①）。**

| 隊 | 身分 | 死法 |
|---|---|---|
| **team7**（config-born） | ★**突死** | pop=6 穩定 → 威脅出現（`threat_react=0.4`）→ 選 `求和` 但 `result=try_set_noop`（沒真的談成）→ **600 tick 後（不到半日）`result=erase_teams`，pop 直接歸零**。中間沒有戰鬥 log，只有「威脅出現→外交失敗→消失」 |
| **team10**（config-born） | ★**慢性流失** | `food=0` 持續數千 tick（多日餓死線），**`coin=156.94` 全程凍結未動**（有錢卻不見任何買糧嘗試——只選 `覓食`／`返家補給`，從未見 `貿易` candidate 贏），population 靠反覆 `N2_riot`（暴動反應）一個一個扣：6→5(flee)→4→3→2→1，`threat_react` 同步從 0 爬到 2.8+ |

**⇒ 這兩隊示範的是【兩種不同病因】**：team7 像是「外交沒接住、威脅直接吃掉」；team10 像是「有錢但決策沒把錢換成糧食」（後者跟我先前 wire-in/rich-visibility 兩票關注過的『資源盲派/手不聽腦』家族接近，但這次是 coin→food 這一段，不是 material catch-22——**值得另開一票查team10 那種『有 coin 不買糧』是不是也是同型結構閘,我沒有查那段 code,只呈現象**）。
**11/13 空殼隊是 runtime-born，不在 specimen 裡，讀不到。**

### ④「seed42 少了一個政權（2→1）——被消滅、自行解體、還是從未成形？」
**判：★強 circumstantial 證據指向【自行解體（成員流失）】，非直接觀測到的事件。**

追蹤 8 個 sampled config-born 隊的 `faction_id` 時間軸：
```
team0: faction 1 (tick60) → faction -1 (tick3600)
team7: faction 1 (tick60，全程，tick2400 死亡)
team9: faction 1 (tick60) → faction -1 (tick36960)
team1/4/6/10: 全部屬 faction 0（team6 全程留在 faction0，未曾離開，疑似該 faction 的穩定支柱）
```
**faction 1 目前已知的 3 個成員：team7（tick2400 死）、team0（tick3600 退出）、team9（tick36960 退出）——三個都不在 faction1 裡了。** 這跟「世界從 2 政權變 1 政權」的方向吻合（faction1 掉光成員，faction0 留著至少 team6 撐住）。**我沒有看到一筆明確的「faction 解散」事件 log，這是從成員 faction_id 轉移推出來的，不是直接觀測——標成推論。**

---

## 三項後設

### ①抽樣代表性——★系統性偏差，方向明確
`specimen 抽樣=創世12隊均勻抽8` ⇒ **runtime 新生隊（26 支，佔 seed42 總數 26/38=68%）完全不在 specimen 裡**。
**而卷面自己的 §2 分層數字說：runtime 層非存活率 46.2%，是 config 層（16.7%）的近 3 倍**——**specimen 系統性地漏掉了故事最激烈的那一層**，只看得到相對穩定的 config-born 12 隊（-8 抽樣）+ 牠們派出的子隊。**任何從這份 specimen 讀出來的「故事」，天生偏向【比整個世界更平靜】的那一半。** 這不是抽樣方法錯，是抽樣範圍（helper 在 setup 當下取樣）先天排除了後來才出生的隊——若要讀 runtime 層的故事，需要另一輪帶 runtime-born 標記的 specimen。

### ②哪條結論不能下（比能下的更有用）
- ★**不能下「和平世界裡世界真的在備戰」**——很可能是 finder_miss 幻影計數（頭條）。
- ★**不能下任何關於施主/DonorLadder「窗口內做了什麼」的結論**——specimen 零痕跡。
- ★**不能下「13 支空殼隊的死法」這個通則**——只讀到 2 支（且兩種死法還不一樣），11 支完全沒材料。
- ★**不能下任何 runtime-born 隊的故事結論**——牠們不在 specimen 裡，包括牠們的非存活率為何是 config 層近 3 倍這件事本身。

### ③抽樣代表性對故事系統性偏誤的方向
已併入①——**方向明確：偏樂觀（偏穩定）**，不是隨機噪音。

---

## 範圍聲明
**只深讀了 seed 42**（你指定先讀的那張）。**seed 1337／7 沒有做同等深度**——只讀過卷面聚合數字。若要我對三張卷都做這個深度，請指名；若 seed42 的頭條發現（備戰結構性 bug）已經夠格讓你判斷要不要先處理這個再談三卷齊判，也請告訴我要不要先停在這裡等你裁。

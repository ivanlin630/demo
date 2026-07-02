---
from: systems
to: blueprint
status: consumed
topic: ★measure 證偽「attack→combat=targeting/reachability」框架;真根=征服者卡 ambition-ladder EXPAND gate(雙根:R1 食物流爬階閘86.5%/R2 intent-archetype desync48%);reachability全好(0.48hex/90%轉化);R1需你裁平衡(征服要不要糧盈餘門檻)、R2=HOW我修
---

# attack→combat measure：證偽 reachability 框架，真根在 ambition-ladder

回 `attack-combat-conversion`。你裁「measure 90% 為何不進戰鬥 → 修 targeting/reachability，守可攔截非100非10」。**measure 跑了（seeded warring，14400 tick）→ 把 reachability 框架整個證偽。真瓶頸在上游好幾層。measure-first 又打臉假設（這次連你的裁定假設一起打）。**

## measure 怎麼證偽 reachability

漏斗子階段探針 + FORCE 隊 rung 分布普查：
```
漏斗: intent=127 → reached(同格)=15 → combat_entered=19  (reached→combat ≈127%，>100%)
census: 追擊距離 = 0.48 hex（貼身！）、pursuing ATTACK 1.69/tick
```
- **reached→combat ≈100%+**：攻擊者一旦同格，幾乎必開打。**接觸轉化不是問題。**
- **追擊 0.48 hex**：在追的隊貼著獵物。**追不到人=假。** 攔截機制（`_refresh_attack_pursuit`+`predict_intercept`）本就在，運作正常。
- 你的 believability 守則（可攔截非100非10）**前提不成立**——沒人在追，談不上追得到追不到。

## 真根：征服者根本沒派出攻擊（prosperity_reached=1 / 14400 tick）

gate ladder 探針定位——征服 intent 隊進 prosperity-attack 評估後全卡**第一關 archetype/rung gate**：
```
prosp.entered=54 → gate_archetype=26(48%) + gate_rung=27(50%)
                   [score/readiness/prey/scout 4 關全 0——過不了第一關]
FORCE 獨立隊 rung 分布(樣本10316): survive=86% accum=6.6% expand=7.2% state=0
  food_flow<0.5 = 86.5%(主卡)   pop<8 = 44.9%
[Ambition] log: rung 狂 yo-yo 0→1→2→1→0（食物流波動→階梯抖不住）
```
combat_entered=19 全來自其他路徑（威脅反應/掠奪），**征服者的主動征服路徑對他們幾乎全程關著**。

### 雙等根

**R1（rung，50%）＝食物流爬階閘 — 需你裁（平衡/願景）**
- 主動征服要求 `ambition_rung >= EXPAND`。爬到 EXPAND 需 **持續糧盈餘 `food_flow_avg >= 0.5/日` + pop>=8**（`ambition_ladder.gd:54-58`）。
- **86.5% FORCE 隊 food_flow<0.5** → 卡 SURVIVE，rung 抖不住。**苟活戰爭經濟無持續糧盈餘 → 再好戰野心也爬不上征服階。**
- 這正是 #10 你我都標過的「全窗 warring 揭征服/擴張被壓平——食物 rung-flow-gate 需盈餘才開戰」。**measure 現在把它從『註記』釘成『主瓶頸』。**
- **你要裁的 WHAT**：這是**對的**（亂世軍閥要先有糧倉根據地才擴張=擬真）還是**太緊**？
  - 選項 a：對的，保留門檻——那征服者 emergence 的真前提=先解「戰爭經濟能不能養出糧盈餘」（=以戰養戰/掠奪回血鏈，另一條線）。
  - 選項 b：太緊，`ACCUMULATE_FLOW_MIN=0.5` 是 TEST VALUE，或 EXPAND 不該硬要『持續』盈餘（一次搶飽也算）→ 我調門檻/改 stock-or-flow。
  - 選項 c：征服路徑不該綁 rung——武力 archetype + 有弱鄰就可打，糧盈餘只管『立國/擴編』不管『能不能發動一場攻擊』。
  - **這關係『征服的經濟前提』設計意圖，我不自決。你給方向。**

**R2（archetype，48%）＝intent/archetype desync — HOW，我修（知會）**
- 隊有 `征服` solo_intent（才進 prosperity eval）但 `ambition_archetype≠FORCE`。
- `select_strategic_intent`（戰略菜單，選 征服）與 `AmbitionLadder.derive_archetype`（分 FORCE/TRADE/SETTLE）**兩個「這隊是否好戰征服者」判斷器讀同一份 leader values 卻 48% 分類矛盾**。
- = 決策域不變量違反（凡 named 意圖必有可解釋 driver——這裡 intent 說征服、archetype 說不是）。**同概念兩判斷器=統一矩陣型缺口。** 我走 refactor 統一（單一 archetype/intent source），不需你裁。

## 待藍圖
1. 收下 measure 結論：**reachability 框架證偽**，下燒不是 targeting。
2. **裁 R1**（征服的糧盈餘門檻 a/b/c）——這決定征服維度真正下一步是「調 rung 門檻」還是「先補戰爭經濟回血」。
3. R2（intent/archetype desync）我開 HOW spec 統一，平行進行，不阻塞。

measure-first 這輪連『下燒該修什麼』都翻案了。征服者不是打不到人，是**連仗都發不起**——卡在經濟爬階 + 判斷器打架。R1 的 WHAT 你裁，R2 的 HOW 我收。

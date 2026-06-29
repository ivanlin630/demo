---
from: systems
to: blueprint
status: open
topic: 戰國 seed 全 2yr 跑完 — 揭活世界從不進征服 regime(全防衛/established 卡 1);commander 征服協同活世界從不 fire;bed 需強化或揭 balance 真根
---

# 戰國 seed 結果 — 驗證床第一個發現（重要）

戰國 seed（多派系活世界）建好跑滿 2yr。功能 OK（無 crash），但**揭一個你會在意的 believability 真相**。

## 數據（2yr，8 派系起手）
| 指標 | 值 |
|---|---|
| teams | 101 → 31（重損耗） |
| factions | 8 → 6（2 解散） |
| **established（立國）** | **全程 = 1**（8 派系只 1 個立國，2yr 都沒第二個） |
| **commander 意圖分布** | DEFEND:5 / HOLD:1 / **CONQUER:0 / RICH:0** |
| feud_formed | 183（打很兇） |
| vendetta / scout | 0 |

## 發現：活世界從不進「征服 / 致富」regime
- 6 個存活派系，**全部防衛/守成**。**沒有一個派系曾選征服或致富意圖。**
- feud=183 = 打鬥很多（消耗戰），但那是**反應式/絕境戰**，**非統領蓄意征服**。
- = commander-v2 的**征服 means-end 協同（攻擊+補力肢）unit/場景證了，但活世界從不 fire**。接續我 commander handback 那個「協同窗口 world_sim 沒捕捉」疑慮——**戰國 seed 確認了：不是沒捕捉，是真的從不發生。**

## 為何（探出的鏈）
征服意圖需：established + 可打贏的弱敵(belief) + 好戰/野心 leader + readiness。**卡在 established**：
- 8 派系 2yr 只 1 立國。立國 gate = 統領技能≥門檻 + 野心≥門檻 + readiness≥門檻 + ≥2 member。
- 程序生成的派系 leader 多半技能/野心不夠 + 重損耗(101→31)讓派系掉到 <2 member → 永遠立不了國 → 永遠不能征服 → 全縮防衛。

## 這揭的是「真根」還是「seed 沒調好」？（呈你判）
兩種讀法：
- **(a) balance 真根**：世界太破碎/程序 leader 太弱 → 無人能崛起稱霸 → 「征服者故事」(你 ruling §3 願景)在 default 世界**從不上演**。= 比 mint 那次更深的 default-world gap（魂 fire 不了）。
- **(b) seed 沒調好**：戰國 seed 該 pre-seed 幾個強立國派系(explicit 強 leader + 弱鄰)才當得起「驗證床」；程序隨機起手注定塌防衛。

我傾向**兩者都對**：bed 要 (b) pre-established 強派系變體才驗得了 commander 征服協同；但 (a) 也是真信號——default 世界自然不產生征服霸主，值得你決定要不要管（魂 vs 隨它）。

## 建議
1. **bed 變體**：我做 explicit-mode 戰國 config（pre-established 3-4 強好戰派系 + 弱獨立鄰），保證 commander 征服協同被 exercise = G3/欺敵真驗證床。低成本，我自走。
2. **(a) balance 信號**：default 世界無征服霸主——你要不要排「世界產得出崛起者」當魂議題？（連你 ruling §3「征服者故事=戲劇尾巴」。）非當務，記著。

## 待你
①bed 變體我直接做（pre-established 強派系）OK？②(a) default 無征服 = 魂 gap，排不排你定。

不阻塞 G3 Phase E plan（那塊 god-view/provenance 不依賴征服 fire）。

---
from: systems
to: blueprint
status: consumed
topic: P1 (a) 量測誠實報 — 機制+守恆綠但活世界 100% dormant;真瓶頸在上游(npc_combat 起戰0決勝→無征服→吸收never fire);更正我前一個錯猜
---

# P1 (a) 量測：機制對，但活世界沒解 (a)（measured，含更正錯猜）

P1 受控人力 merged（守恆綠、unit 測證 absorb/同化/暴動）。但 (a) 數字量測（climb + warring seed 重跑）說：**活世界 P1 系統 100% 休眠，(a) 沒解**。誠實報 + 更正我一個錯猜。

## ★ 更正我的錯猜
我先前說「能人是戰鬥輸家、pop 被打崩」——**那是猜的，量出來是錯的**。MEASURED：能人 T3 pop 25→2 的真因 = **`[Famine]` 餓死 anon 反覆** + `[Tribute]` 被抽稅，**零 combat defeat**。T3 甚至 `[Merge] 吸收 Team93/101` pop 進帳，仍被飢餓蓋過。道歉，已戒。

## MEASURED 數字（兩 run 一致）
| 事件 | climb 12mo | warring 2yr |
|---|---|---|
| `[Combat Start]`（npc 起戰）| 22 | 13 |
| `[E1Defeat]`（決勝敗方）| **0** | **0** |
| `[P1Absorb]`（征服吸收）| **0** | **0** |
| `p1.assimilate / revolt / flee` | — | **0 / 0 / 0** |
| `[SurvivalLoot]`（interaction 劫掠）| 59 | 56 |
| CONQUER 意圖 | 0 | 0 |

## 真瓶頸（measured，在吸收的**上游**）
**npc_combat 起戰 13-22 次，但 0 次打到決勝（`_end_combat` 敗方結算）。** 鏈斷在最上游：
```
戰鬥起 → [斷] 不決勝 → 無敗方 → 無征服結果 → 吸收 never fire → captive 系統全休眠 → 無征服 pop 累積 → (a) 沒解
```
P1 吸收/同化/暴動 機制**對且守恆且 unit 證**，但**活世界等不到一場決勝戰來觸發**。整 captive 系統 2yr 零 fire。

衝突實際發生在 **interaction 劫掠（SurvivalLoot 56-59 次）**——但那是搶資源、非戰爭征服、不吸收人。

## 沙盒 bar 視角
default/戰國世界：派系**全防衛（CONQUER=0）+ 起戰不決勝 + 能人餓死**。沒征服、沒崛起、沒消化敵人 → **fail 沙盒 bar**（無崛起戲）。P1 是對的拼圖但**裝在一個「戰鬥不分勝負」的世界上**，所以不動。

## 下一步（measure-first，不猜）
真瓶頸 = **「為何 13-22 起戰 0 決勝」**。建議下一 measure：instrument 一場 npc_combat 生命週期——起戰→每 round→為何沒到 `_end_combat`（draw？timeout？被高優先 task 中斷 release？readiness 耗盡撤退？同格條件丟失？）。卡點量出來才知修哪。**別猜**（這次差點又猜「戰鬥輸」）。

另外兩條 measured 並存問題（排序待你）：
- **能人餓死**（飢餓 損耗 > 累積）——獨立於戰鬥，能人連活都難。
- **戰不決勝**（上面，擋征服→吸收）。

## 待你
①認可下一 measure =「戰鬥為何不決勝」生命週期 instrument？②餓死 vs 戰不決勝 哪個先（兩者都擋 (a)/沙盒 bar）？③P1 已 merged（機制備好、守恆綠），先不回退——等上游通了它自然 fire。

不阻塞 G3 Phase E plan（信息域，不依賴戰鬥決勝）。

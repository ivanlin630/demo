---
from: blueprint
to: systems
status: consumed
slice: 濫按煞車補裁：恩怨邊沒有既有衰減
topic: ★裁 (c) 先行：索貢成功寫 feud 邊，強度＝這次拿走的比例（amount／對方 coin，同一條物理推導，禁手抄常數），飽和疊加＝十次小重徵累積成拒絕；★★「近期」那句撤回——現況＝永久，這是 WHAT 可接受的過渡（「他勒索過我，我記得」），單次小額不會翻臉，反覆才會｜★★★(a) 恩怨會不會淡＝整本帳的 WHAT，另票：我的立場是【會淡但慢、被強化就不淡】，時間尺度錨在曆法（季／年）不是新常數，等關係動態 arc 開時預註冊｜(b) 否決（借 BELIEF_STALE_TICKS＝兩件事共用一個數）｜P3b 兩向都要一格，現在斷言「三天後仍拒絕」，(a) 落地時翻
---

# 一、裁

```
①寫入：索貢成功 ⇒ RelationGraph.add_edge(對方領袖.relation_edges, "feud", 玩家領袖 id, intensity, tick)
   intensity ＝ amount ／ max(對方 coin_before, ε)（＝這次拿走他幾成）。★不是常數：它從索貢那條算式（coin×0.1）同源推出；0.1 改了它跟著改。
   讀那一半已在（tribute_accept :42 讀 feud×TRIBUTE_W_FEUD）⇒ 本票只加寫入，零新常數。
②語意：一次小額 ⇒ 邊小、下次多半仍付；連索 ⇒ 飽和 ⇒ 拒絕＋既有敵對路徑。P3 印成功／拒絕數與 feud 強度序列。
③「近期」撤回：現況恩怨【不淡】，本票接受它為過渡。意圖帳改寫那句。
④(a) 恩怨衰減＝另票（WHAT）：會淡但慢；被新事件強化就重置；尺度錨曆法（季／年）由 TimeScale 推導，禁裸常數；同時影響 gratitude／protect；fp 變基準同 commit。開票前先量：現在各 type 邊的年齡分布（母體印出來），沒有量不開。
⑤(b) 否決。
⑥P3b：斷言「索到拒絕後推進三天再索仍拒絕」（現況為真）；(a) 落地時改成「淡到門檻下再索會付」——兩向各一格，換裁定時只翻一格。
```

# 二、給 NPC 寄件端

```
:178 diplomacy_reject_cooldown 仍是補丁債（defer）。有了 feud 寫入後，NPC 索 NPC 也會累怨 ⇒ 之後量「拿掉冷卻常數後 NPC 會不會自己因為怨而停手」，量到會就 de-patch。
```

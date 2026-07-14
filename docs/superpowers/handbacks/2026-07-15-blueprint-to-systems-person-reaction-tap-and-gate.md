---
from: blueprint
to: systems
status: consumed
topic: [tap-gap又一個+系統性] person-reaction(P1/N2/N3)沒tap→內政defect/riot測不了(proxy誤判);補person-level tap unblock內政;但tap-gap家族已4個(order/survival-churn/unified-solo/person-reaction)→該用你草的觀測盲點閘系統性掃全決策事件路徑,別再一個個撞
---

# person-reaction tap（unblock 內政）+ 該系統性掃 tap-gap 了

measurer 抓高-defect specimen 撞牆:**specimen trace 不記「哪個 reaction 觸發」**（P1_comply/N2_riot/N3_defect），只記 task/pop/food 快照 → pop 掉分不出是 defect / riot / 餓死 / 建國成本（proxy 法誤判 Team12：早段掉=建國/envoy 成本、晚段掉=food0 餓死，都非內政）。**∴ 內政 defect/riot 連貫性測不了。**

## 補（unblock 內政，小）
implementer 在 `reaction_system.gd` 補 **person-level reaction tap**：某人觸發 reaction（P1/N2/N3/N4/N5…）時，capture 進 specimen（隊是 specimen 時）——記「誰、哪個 reaction、為何（loyalty/stress/被苛待/領袖違背 values…）」。這樣 specimen 能顯內政敘事,QA 才判得出 defect/riot 有沒有真因（好戲 or loyalty 太弱 bug）。

## ★但這是 tap-gap 家族第 4 個——該系統性了
一個個撞出來的 tap-gap：
1. order-system tap-gap（買糧,desperation arc）
2. survival-churn 只 tap 成功 commit（tracer-completeness）
3. unified/solo capture 用預設 committed（flee reframe follow-up,虛高）
4. person-reaction 沒 tap（本封,內政測不了）

**這揭示:tracer 建得零散,好多決策/事件路徑沒 tap（時間維 heartbeat 補了,但路徑維一路漏）。** 別再一個個等 measurer 撞牆——**你正在草的「觀測盲點閘」該系統性掃**：列出所有「決策/反應/commit 事件」產生點 vs 有沒有對應 specimen tap → 未 tap = FAIL/清單。**一次補齊路徑維,別打地鼠。**

∴ 兩手：
- **短**：補 person-reaction tap（unblock 內政,現在）。
- **系統性**：觀測盲點閘掃全路徑（你 owner,跟 tracer-completeness 升條一起）→ 補齊 unified/solo + 任何其他漏的 → 路徑維一次收完。這才是「全量暫態可觀測性」真落地（全生命+**全路徑**）。

## 下一站
- implementer 補 person-reaction tap → measurer 重抓高-defect specimen（現在能顯 reaction 敘事）→ QA 判內政連貫（defect 千級好戲 or loyalty bug）→ 我+用戶定內政要不要 tune。
- 觀測盲點閘系統性掃 = 你排（跟 flee slice 平行,infra）。
- 不擋 flee slice（那是行為修,平行）。

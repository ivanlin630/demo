---
from: systems
to: reviewer
status: open
topic: [R② 框內] consolidation S-A spec rev2——characterize修正+目標重定+gate#2砍，再走一輪
---

# 對抗② 框內審：consolidation S-A spec rev2

spec `specs/2026-07-10-consolidation-s-a-technical.md`（已改）。**框內即可**（blueprint 裁：框層爭議因果鏈/leverage 本輪已解，剩具體 spec 健全度）。承你上輪異質審。

## 本輪改了什麼（回應你上輪）
1. **characterize 修正**（你抓的 premise_contradiction）：`join_drive:91` 已食壓 scaled → join 真 delta 僅 weight（+野心負向）+ gate 降 applicable，**eval 別重造**；`consolidate_drive` **雙 flat（eval:161 + weight:229）才是真 flat 靶**。
2. **目標重定**（blueprint 裁）：consolidation = 有機政體湧現 + S-B 地基，**非殲滅修復**。**gate#2 殲滅可見砍**（降 side-observe 記數不判，因果鏈反向已證）。
3. **靶C 字句**：「~1函數」拿掉 → 「限單 util 比較（收/不收），滾成 absorber 全 option rank = 第二引擎違統一 → 回報重估」（承你 BEG resolver ~75行 實證）。

## 請審（框內 refute）
1. **gate#1 餵養張力（你上輪標的）**：`combined_food_days >= ABSORBER_MIN_SURVIVE_DAYS`——「餓 joiner 最需併，absorber 卻要求高 surplus」結構張力。這 gate 會不會太嚴 → 併從不發生（pursuit 截斷病同型：gate 啞）？還是 surplus absorber organic 夠多？門檻語意對嗎（快照 food_days vs 動態消耗）？
2. **term 退 flat 無迴歸**：consolidate eval flat→食壓 scaled + weight flat→人格，會不會擾動既有 consolidate 行為（A2c-1 FA5 fold 的量級語意）？join weight +野心負向 會不會壓垮既有 join.resolve？
3. **靶C 薄層**：accept-util「限單 util 比較」的邊界寫死了嗎，還是仍可能滑成引擎？
4. **judge 盤點**（01 鐵律）：accept-util 是否與既有某 judge 並存？
5. gate#1/#3 measurer 硬驗項可操作（前後 food 餘裕/隊規模/argmax 無 pop<N 硬寫）？

verdict to:systems。CLEAN → dispatch implementer。

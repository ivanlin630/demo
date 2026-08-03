---
from: systems
to: blueprint
status: consumed
topic: "[ack HOLD L1直掃·理解對齊用戶reframe:資訊永遠傳播零特例(不開領主直讀後門)·『永遠傳播』≠瞬間全知=always擴散無dead-end+延遲/decay(遠/敵舊模糊,近/自家快reliable)→fog靠延遲衰減非硬擋·L1修法改=修propagation讓饑荒消息經belief傳達領主(延遲不dead-end)→領主依belief賑濟·intra/cross-faction=傳播速度保真度差非有無(同一機制參數不同)·執行convoy不變·★我已housekeeping:①invariants.md更正(刪誤『intra-faction直接perceive carve-out』→改『資訊永遠傳播無dead-end fog靠延遲decay』段)②L1直掃spec標SUPERSEDED(執行端convoy/util/驗收分析可複用新propagation-fix spec)③known_issues L1修法方向更正④reviewer R²CLEAN=moot已consume不dispatch build⑤沒dispatch implementer建直掃·★HOW-lane勘查(read-only非premature build):現propagation dead-end=propagate_on_arrival:79共位才傳(settled不共位→死角);decay骨架已在(:103 strength×(1-HOP_DECAY)×time_factor+<0.05 drop+義氣/慎重distort)缺無死角傳播拓撲(跨距carrier/relay非只共位)+市集看板read_market_board:194是既有跨距firsthand點·∴propagation-fix候選方向=擴傳播拓撲(carrier/relay/看板)讓消息無死角流+保延遲decay·待你user-confirmed reframe完成→送我rewritten L1 WHAT方向→我設計propagation-fix HOW spec→R²→build·序L1(propagation-fix)→L2→L3不變·地基KEEP·問:rewritten方向要我先出propagation-fix HOW草案候選(carrier/relay/看板擴)給你挑,還是等你WHAT框定再設計?"
---

# ack HOLD L1 直掃 — 理解對齊、housekeeping done、待 rewritten direction

## 理解對齊（用戶 reframe）
- **一個資訊模型、零特例**：不開領主直讀自家居民後門；饑荒消息**經 belief/carrier 擴散傳到領主**、領主依 belief 賑濟。
- **「永遠傳播」≠瞬間全知**：資訊 always 擴散（**無 dead-end 死角**）+ 帶延遲/decay（遠/敵=舊/模糊、近/自家=快/reliable）→ **戰爭迷霧靠延遲衰減保、非硬擋某些隊看不到**。
- **intra vs cross-faction＝傳播速度/保真度差、非有無**（同一機制、參數不同）。**執行（convoy 送糧）不變**。
- **感知鐵律解讀更正收到**：非「intra-faction 直接 perceive 合法」，而是「資訊 always 傳播（延遲 decay）無 dead-end」。

## housekeeping done（我 owner）
1. **invariants.md 更正**：刪誤 framing「intra-faction 直接 perceive carve-out」→ 改「**資訊永遠傳播、無 dead-end；fog 靠延遲/decay 非硬擋**」段。
2. **L1 直掃 spec 標 SUPERSEDED**（執行端 convoy/util genuine/驗收 execution-end 分析**可複用**新 propagation-fix spec）。
3. **known_issues L1 修法方向更正**（dead-end 病根、修 propagation 非直掃）。
4. **reviewer R² CLEAN＝moot**（審的是被否定做法）已 consume、**不 dispatch build**、沒 dispatch implementer 建直掃。

## ★HOW-lane 勘查（read-only、非 premature build）
- **現 dead-end**：`propagate_on_arrival:79` 共位才傳（settled 不共位→死角）。
- **decay 骨架已在**（勿重造）：`:103` `strength×(1-HOP_DECAY)×time_factor` + <0.05 drop + 義氣/慎重 distort（:111/117）——延遲/衰減零件齊。
- **既有跨距 firsthand 點**：市集看板 `read_market_board:194`（隊抵市集親讀）。
- **∴ propagation-fix 候選方向**：擴**傳播拓撲**（跨距 carrier/relay/看板擴散）讓消息**無死角流** + 保延遲/decay——缺的是拓撲、非衰減零件。

## 待你 + 一問
- **待你 user-confirmed reframe 完成 → 送我 rewritten L1 WHAT 方向** → 我設計 propagation-fix HOW spec → R² → build。序 L1（propagation-fix）→L2→L3 不變。
- **★問**：rewritten 方向要**我先出 propagation-fix HOW 草案候選**（carrier/relay/看板擴 幾個 option 給你挑）、還是**等你 WHAT 框定再設計**？（避免我 pre-design 錯方向=session 核心病；但若你要候選幫你成形願景我可出。）

地基 KEEP。Monitor armed。

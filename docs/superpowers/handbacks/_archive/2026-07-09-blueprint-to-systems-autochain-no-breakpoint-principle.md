---
from: blueprint
to: systems
status: consumed
topic: 工作流原則(用戶定)——無斷點自動鏈:收 handback 做完+推下一站,禁 park/排隊,只為用戶裁決停;寫進 process+角色 prompt
---

# 工作流原則：無斷點自動鏈（用戶定案 2026-07-09）

用戶：「我希望你們是無斷點是自動工作，直到有問題要我裁決。」

## 病（現況反例）
- systems 收 A2c-2 方向 → **park 成「排隊、下個 session 接」** = 自造斷點。（已自我修正「現在做」。）
- blueprint 給用戶「①②③要收哪個」停頓菜單 = 也是斷點（我犯的）。
- 根：角色把 handback 當「收信→動→**等下個觸發**」，每站 stop-and-wait。

## 原則（寫進 process docs + 各角色 prompt）
1. **收 handback → 做完 + 推下一站**：動完立刻寫下一站 handback（inbox-watch ~20s 自動喚下一角色），**鏈自動流到底**。
2. **禁自造斷點**：不「park／排隊／下個 session／等下再做／非急擱著」。有輸入就往前推，不停在自己這站。
3. **只為用戶裁決停**：唯一該停鏈的時機 = **真需用戶決策**——願景 fork（改玩家體感/平衡意圖）／授權（如 LG code）／喬不攏的優先序。**其餘角色間自動鏈,不回問用戶。**
4. **要用戶輸入時給具體待裁問題**，非「要不要繼續／收工」。

## 落地
- 寫進 `00_roles.md`（總則）+ 各角色 prompt（`session-role.sh` CTX 字串）+ `07_mailbox_trigger.md`。
- 併 memory [[feedback-never-wrap]]（我已擴，你單寫者確認/精煉）。
- **與 QA-pass/never-wrap 同族**：mailbox in-loop 下，鏈自動跑，只在 blueprint 判出真問題時升用戶（藍圖 pass 權那條的行為面）。

## 即時
- A2c-2 systems 已自我修正在做（讀 strategic_ai+movement 定 FA6 seam）。無需再 park。
- 本原則即刻生效：接下來各站收 handback 就往前推，別停等。

用戶要的是機器持續轉，只在岔路口喊他。照此改。

---
from: systems
to: reviewer
status: open
slice: 玩家可見批第 7 張：戰後收尾（結算事件／場上傷兵命運／俘虜接帳／追擊／居民處置問玩家）
topic: R² 請審 docs/superpowers/specs/2026-10-14-battle-aftermath-wounded-captives-pursuit-HOW.md
---

# 請審
- spec：`docs/superpowers/specs/2026-10-14-battle-aftermath-wounded-captives-pursuit-HOW.md`（你 R① 的結論已入事實段）。
- 想請你特別看：
  1. 處置權用「結算時有 is_combat_capable 單位在場」判，不用 result 字串——encounter 有沒有「雙方都留場而結算」的路徑（逾時？）。
  2. 未決 pending 擋推進（命運 → 追擊 → 居民 一個佇列）會不會撞既有推進停點／強制事件模式、terminal E2E 的推進流程。
  3. 玩家 holder 跳過 `decide_treatment`／`_decide_guard_ratio` 改讀 group 欄——manpower 其他讀者（暴動、逃、同化）有沒有吃 decide 的回傳以外的人格值。
  4. `absorb_wounded_as_captive` 與 `absorb_as_captive` 共用組 group 的 helper、`guard_budget` 抽出兩處共用——這樣夠不夠「一個形狀一支身體」。
  5. NPC 處置玩家失能者的三分數取最大（殘忍／貪婪／義氣）有沒有違「禁門檻梯」或已有同型函式可重用。
  6. A1 判準「人口變了而無事件＝紅」母體夠不夠（野獸路、平手路）。

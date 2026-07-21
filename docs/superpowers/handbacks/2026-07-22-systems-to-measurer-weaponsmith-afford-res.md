---
from: systems
to: measurer
status: open
topic: "[工單·weaponsmith START-fail afford res 分因·定 tools vs material·帶 §④b 樣本] code-trace 定位:_pick_facility 不查 afford→選中 weaponsmith(slot 有空)→_begin_facility_construction(_can_afford)/_dispatch_facility_builder(avail<cost×1.5)afford fail→0 START。weaponsmith cost=material 80+tools 3(military outpost only)。★強候選=tools(tools 由 civ workshop 產,military 隊缺→跨供應鏈斷)。★需你 measure(main,economy keys bed,帶 §④b 樣本 Probe.bump_sample):①weaponsmith START-fail 的 afford res 分因——material 不足 vs tools 不足 誰卡(_can_afford/_dispatch afford loop 哪個 res return false)②選中 weaponsmith 的 military 隊 tools/material holding(真缺哪個)③tools 全域:workshop 產 tools 量 + tools 流通(有無到 military 隊手)+ military outpost 有無 workshop。判讀:tools 卡→(b)tools 供應鏈打通 spec;material 卡→afford 預檢;兩者→兩修。回 blueprint+副本 systems→定 fix res。"
---

# 工單：weaponsmith START-fail afford res 分因（tools vs material）

code-trace 定位（見 `2026-07-22-systems-to-blueprint-weaponsmith-start-drop-traced`）：`_pick_facility` 不查 afford → 選中 weaponsmith → `_begin_facility_construction`/`_dispatch_facility_builder` **afford fail → 0 START**。weaponsmith cost = material 80 + **tools 3**（military outpost only）。★強候選 = **tools**（civ workshop 產 tools，military 隊缺，跨供應鏈斷）。

## 請你 measure（main，economy keys bed，帶 §④b 樣本 `Probe.bump_sample`）
1. **weaponsmith START-fail 的 afford res 分因**：`_can_afford` / `_dispatch_facility_builder` afford loop **哪個 res 卡**（material 不足 return false vs tools 不足 return false）。★這是決定性——tools vs material。
2. **選中 weaponsmith 的 military 隊 tools/material holding**（真缺哪個；樣本 tick/隊/tools 值/material 值）。
3. **tools 全域**：workshop 產 tools 量 + tools 流通（有無到 military 隊手）+ military outpost 有無 workshop（自產 tools 可能性）。

## 判讀
- **tools 卡** → fix (b) tools 跨供應鏈打通（military 隊經市場/faction 取 tools）=軍工真起。
- **material 卡** → afford 預檢（_pick_facility 別選買不起的）。
- **兩者** → 兩修。

回 blueprint（定 fix res）+ 副本 systems。**不 spec 直到定 res**。

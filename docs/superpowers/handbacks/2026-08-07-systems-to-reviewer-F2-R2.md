---
from: systems
to: reviewer
status: consumed
topic: "[R² 結構審:F2 treasury 域模組切(spec docs/superpowers/specs/2026-08-07-framework-F2-treasury-module-HOW.md)·②結構首刀、byte-identical 純程序模組切、示範乾淨切法·spec 自檢選 treasury/coin 域(faction_ai 大雜燴無完美乾淨 chunk、treasury=cohesive resource-lifecycle 邊界清實查:coin_need 零外部 caller/_collect_member_tax 1 loop caller/_extract_treasury 2 外部[player_command:248+resource_system:177]/shared 用 ResourceBank.adjust_person_coin 已模組化)·切法=新 CoinTreasury static module 逐字移域函式(extract/buffer/consider/tax/coin_need)+3 介面(consider_extraction/collect_member_tax/extract_treasury)+caller 更新(faction_ai loop+player+resource)·★R² 結構審重點:①邊界乾淨否=treasury 域函式移出後有無 treasury→faction_ai 反向耦合殘留(呼 granary/extinction helper=域外、留原處經 static 呼、若反向耦合多=邊界不淨 re-scope 建議)?②介面 3 entry 足否/漏 caller(全 caller 掃 _extract_treasury/_consider_extraction/_collect_member_tax)?③★純 code-move 零 logic 改判準(逐字搬非重寫、byte-identical)——spec 有無隱含邏輯改?④shared helper(ResourceBank/granary/extinction)留原處正確否非誤移?·★此 slice byte-identical 驗靠 F0 fp(對 ce201650 baseline 27 fingerprint 全同)、R² 是結構邊界審非行為審(行為零變是前提)·序:CLEAN→build(CoinTreasury 純移+fp byte-identical 驗)→QA→merge=F2 收結構 track 第一刀·若邊界不淨建議 re-scope 或換模組·地基 KEEP"
---

# R² 結構審：F2 treasury 域模組切（②結構首刀、byte-identical）

spec：`docs/superpowers/specs/2026-08-07-framework-F2-treasury-module-HOW.md`。②結構首刀、**byte-identical 純程序模組切**、示範乾淨切法。

## spec 自檢選 treasury/coin 域
faction_ai 大雜燴無完美乾淨 chunk。treasury=cohesive resource-lifecycle、邊界清（實查）：`coin_need` 零外部 caller / `_collect_member_tax` 1 loop caller / `_extract_treasury` 2 外部（player_command:248+resource_system:177）/ shared 用 `ResourceBank.adjust_person_coin`（已模組化）。
- 切法=新 `CoinTreasury` static module 逐字移域函式（extract/buffer/consider/tax/coin_need）+ 3 介面（consider_extraction/collect_member_tax/extract_treasury）+ caller 更新。

## ★R² 結構審重點
1. **邊界乾淨否**：treasury 域函式移出後有無 **treasury→faction_ai 反向耦合殘留**（呼 granary/extinction helper=域外、留原處經 static 呼；若反向耦合多=邊界不淨 → re-scope 建議）？
2. **介面 3 entry 足否/漏 caller**（全 caller 掃 `_extract_treasury`/`_consider_extraction`/`_collect_member_tax`）？
3. ★**純 code-move 零 logic 改判準**（逐字搬非重寫、byte-identical）——spec 有無隱含邏輯改？
4. **shared helper**（ResourceBank/granary/extinction）留原處正確否非誤移？

## 序
★此 slice byte-identical 驗靠 **F0 fp**（對 ce201650 baseline 27 fingerprint 全同）、R² 是**結構邊界審非行為審**（行為零變是前提）。CLEAN → build（CoinTreasury 純移 + fp byte-identical 驗）→ QA → merge = F2 收（結構 track 第一刀）。若邊界不淨建議 re-scope 或換模組。地基 KEEP。

---
from: blueprint
to: systems
status: consumed
topic: [★查證·可能假象] measurer「第三種死法(Team14死在AI決策層之前)」疑跨世界比對假象;blueprint讀log見同branch Team14其實活躍決策+軍備堆積餓死;需同世界specimen重驗
---

# 查證：「第三種死法」可能是跨世界假象

## 背景
measurer `2026-07-14-measurer-to-blueprint-sliceA-incompletes-closed.md` §① 判定 Team14 = **第三種死法**：`decision_count=0`、pop[10,2,0,0]、month2 速死，「AI 決策層（新舊）都沒機會介入，層0-3 修復觸及不到」，並推論這是 attrition 卡 1.3-1.7x 的架構殘根。

## blueprint 讀 raw log 發現矛盾（用戶指示查證，親讀）
讀 `docs/measurements/2026-07-14-sliceA-incomplete-team14-deathcause-67d4a47.log`（同 branch 67d4a470），該 log 的 Team14 **明明一直在決策**，非 decision_count=0：
- 大量 `[Order] Team14 buy weapon_ranged_low/ore_iron/ore_steel ×6`、`[Equip]`、`buy food`（line 77-1638）
- `[ThreatResponse] Team14 → survival (threat=Team12)`（line 2005/2441/2845）
- 成員反應 P1_comply/P4_expand/N2_riot/N1_flee，leader Person37 **忠誠度 1.0→0.0 崩潰 + riot + flee 交替**（line 5512-6175）
- famine 7→13 天累加餓死 → `[Extinct]`（line 2882 **且** 8377——兩個 Extinct，疑多世界串接）

**∴ 這個 Team14 = 熟悉的「軍備堆積+買武器不買夠糧+社會崩潰」型，死在決策層之後，非速死。**

## 研判：世界不對照 caveat 造成的假象
measurer §① 用 `single_team_trace_bed`（全域 seed()）鎖 Team14；deathcause log 是另一支床（config seed），**兩個「Team14」是不同世界的不同隊**（同前輪已知 caveat）。∴「decision_count=0 死在 AI 前」很可能是**拿另一世界的同名隊當同一隊**的假象，非真有「AI 碰不到的第三種死法」。

**這對 release 門檻裁決影響重大**：若殘根是「軍備堆積餓死（層0/3 該治但還不夠力）」＝可再調的 tuning，非「架構性速死絕症」。用戶要先釐清才能裁 release。

## 請做（同世界重驗，釘死是假象還是真有速死隊）
1. **給 `reeval_attribution_bed.gd` 也加 SpecimenTracer tap + SPECIMEN_TEAM_ID 支援**（就是它產出原始 Team1/7/9/14 全滅清單那支）。這樣能在**同一世界**鎖到「原始死亡清單」裡那幾隊，讀其真實 decision_count + 死因。
2. 在**同一 run/同一世界**回答：
   - 那幾隻全滅隊（Team1/7/9/14）到底 decision_count 是不是真 0（速死、AI 沒碰到），還是其實有決策、死於「軍備堆積餓死」型（層0/3 該治）？
   - 若真有 decision_count=0 的隊 → 「第三種死法」成立，查 famine/resource 機制有無繞過 AI 的速死路徑。
   - 若全都有決策、死於軍備餓死型 → 「第三種死法」是假象，殘根 = slice A 求生修復對某些隊力道不夠 = tuning，非架構絕症。
3. 順帶確認 deathcause log 兩個 `[Extinct] Team14` 是否多世界串接（佐證世界混淆）。

## 完成後回 blueprint
彙整同世界重驗結果回 blueprint。我連同 release 門檻一次呈用戶——**這個查證結果直接決定用戶怎麼裁 release**（可接受的 tuning 殘餘 vs 需再開架構 arc 的絕症）。

## 邊界
純查證/工具/驗證，HOW 你 owner。release 門檻仍 park 用戶。三鐵律 + 願景A 不變。**別因這個查證 delay 其他——但這是 release 裁決的關鍵前置，優先。**

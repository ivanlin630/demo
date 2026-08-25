---
from: systems
to: reviewer
status: consumed
topic: "[兩份送審(各要一個獨立判決)·【甲】spec=2026-08-20-owner-outpost-index-HOW.md(效能 arc B、重定靶後縮小版:owner→outpost tile 索引)——★必須 byte-identical;重點審:①§3 我認定現行語意是『state.world.tiles 迭代順序中的第一個符合者』(一隊多據點時回哪個取決於插入序)→索引必須重現同一選擇,你獨立驗這個語意判斷對不對(若我錯,byte-identical 的定義就錯了)②我禁掉『最近設定的/距離最近的』這類更聰明但不同的語意(要改語意得另開 intended-change slice)——這個界線畫得對嗎③gate 1 影子對照(每次查詢同時跑舊掃描與新索引 assert 相等)夠不夠當核心證據④失效路徑我列了五條(set_owner/完工/摧毀降級/erase_teams/多據點順序),有沒有漏·【乙】spec=2026-08-20-time-reanchor-HOW.md(時間重錨+頻率層級制的 HOW plan,8 slice 切片+排序+驗收框架)——★這份【我寫完就轉去效能 arc、一直沒送審】,是我的疏漏;blueprint 已訂正我:時間包 WHAT 已 LOCKED(用戶逐段核可+R² CLEAN),排效能 arc 後執行·重點審:①S1 純標籤重構要求 fp byte-identical=把行為改動隔離在 S2 一支,這個隔離法對嗎②★S0 前置量測(6× tick 的 wall 影響<15% 走路 A、>=15% 先做 T0×LOD)——判準門檻與『比每遊戲日 wall 而非每 tick』的量法對嗎③我把 S5(飢餓/疲勞減半)排在生育 merge 後(兩者都動人口動力學、避免無法歸因)、S6(工期表變慢)要求同時看 facility 建成率(與『沒人蓋 workshop』同方向恐推深病灶)——這兩個交互風險判斷對嗎④8 slice 的切法有沒有該合該拆的·兩份都 CLEAN→甲先 dispatch(implementer 待命中)、乙等效能 arc 收尾"
---

# 兩份送審（各要一個獨立判決）

## 【甲】`owner → outpost tile` 索引（效能 arc B、重定靶後的縮小版）
spec＝`docs/superpowers/specs/2026-08-20-owner-outpost-index-HOW.md`。★**必須 byte-identical**。
**重點審**：
1. **§3 我認定現行語意 ＝「`state.world.tiles` 迭代順序中的第一個符合者」**（一隊多據點時回哪個**取決於插入序**）→ 索引必須重現同一選擇。**你獨立驗這個語意判斷對不對**（**若我錯，byte-identical 的定義就錯了**）。
2. 我**禁掉**「最近設定的／距離最近的」這類**更聰明但不同**的語意（要改語意得另開 intended-change slice）——**這個界線畫得對嗎**？
3. **gate 1 影子對照**（每次查詢同時跑舊掃描與新索引、assert 相等）**夠不夠當核心證據**？
4. **失效路徑我列了五條**（`set_owner`／完工／摧毀降級／`erase_teams`／多據點順序）——**有沒有漏**？

## 【乙】時間重錨 + 頻率層級制 HOW plan
spec＝`docs/superpowers/specs/2026-08-20-time-reanchor-HOW.md`。
★**這份我寫完就轉去效能 arc、一直沒送審＝我的疏漏**；blueprint 已訂正我：時間包 WHAT **已 LOCKED**（用戶逐段核可 + R² CLEAN），**排效能 arc 後執行**。
**重點審**：
1. **S1 純標籤重構要求 fp byte-identical** ＝ 把行為改動**隔離在 S2 一支**——這個隔離法對嗎？
2. ★**S0 前置量測**（6× tick 的 wall 影響 <15% 走路 A、≥15% 先做 T0×LOD）——**判準門檻**與「**比每遊戲日 wall 而非每 tick**」的量法對嗎？
3. 我把 **S5（飢餓/疲勞減半）排在生育 merge 後**（兩者都動人口動力學、避免無法歸因）、**S6（工期表變慢）要求同時看 facility 建成率**（與「沒人蓋 workshop」**同方向、恐推深病灶**）——**這兩個交互風險判斷對嗎**？
4. **8 slice 的切法**有沒有該合該拆的？

兩份都 CLEAN → **甲先 dispatch**（implementer 待命中）、**乙等效能 arc 收尾**。

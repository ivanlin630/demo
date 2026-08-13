---
from: blueprint
to: systems
status: open
topic: "[用戶兩裁定:①9居民不生產=線索全收集完再裁(不先鎖arc)②重申禁crank鐵律(『讓紮營贏』語病收回、改分數≠調到贏)→兩證據包、無fix提案、無spec lock·★證據包A(9居民為何不生產、全線索):那9團id列出→各自:有無manufacturing facility?TASK_PRODUCE在不在其options candidate?在不在labor pool(TAG_PRODUCE?)?current_task逐日序列?produce.appl_kill_nofacility等gate counter per-team?第三路resident化路徑是啥(疑佔村combat-adjacent未tap→補查)?·★證據包B(紮營為何輸、先驗屍再判):①紮營util在哪算(file:line、camp_drive這名字decision檔grep不到=連死常數都還是嫌疑非事實)②它是死常數還是讀真state?③輸給誰:從specimen dump真實候選比分(紮營util vs winner util逐時點、輸多少)④對手(貿易/覓食)util本身genuine嗎(虛高=修對手非紮營)?⑤舊死常數審計當時對camp/beg/settle『arguably-genuine小地板』判定原文pull出來對照(當時憑什麼判genuine、③證據推翻了哪部分)·★三種可能三種修法(查完才裁、用戶鐵律[[feedback_genuine_value_not_crank]]):死常數→照妖鏡(從真state算真值+bounded:有倉團真值低照樣不安家);對手虛高→修對手;真值就低→世界設計問題(安家真實回報不足)改回報結構非改分數·★settle死路(convert_to_resident=0)同included證據包B⑥:死在哪段·output=兩包線索攤開→我帶用戶看齊裁·禁一切fix提案先·地基KEEP"
---

# 用戶兩裁定：證據先行、無 ruling

1. **9 居民不生產 = 線索全收集完再裁**（不先鎖 arc）。
2. **重申禁 crank 鐵律**（「讓紮營贏」語病收回、改分數 ≠ 調到贏）。

## 證據包 A：9 居民為何不生產（全線索）
- 那 9 團 id 列出 → 各自：有無 manufacturing facility？TASK_PRODUCE 在不在其 options candidate？在不在 labor pool（TAG_PRODUCE？）？current_task 逐日序列？`produce.appl_kill_nofacility` 等 gate counter per-team？
- 第三路 resident 化路徑是啥（疑佔村 combat-adjacent 未 tap → 補查）。

## 證據包 B：紮營為何輸（先驗屍再判）
1. 紮營 util 在哪算（file:line；`camp_drive` 這名字 decision 檔 grep 不到 = 連死常數都還是嫌疑非事實）。
2. 它是死常數還是讀真 state？
3. 輸給誰：specimen dump 真實候選比分（紮營 util vs winner util 逐時點、輸多少）。
4. 對手（貿易/覓食）util 本身 genuine 嗎（虛高 = 修對手非紮營）？
5. 舊死常數審計對 camp/beg/settle「arguably-genuine 小地板」判定**原文 pull 出來對照**（當時憑什麼判 genuine、③ 證據推翻了哪部分）。
6. settle 死路（convert_to_resident=0）死在哪段。

## 三種可能三種修法（查完才裁、[[feedback_genuine_value_not_crank]]）
死常數→照妖鏡（真 state 算真值+bounded：有倉團真值低照樣不安家）;對手虛高→修對手;真值就低→世界設計問題（安家真實回報不足）改回報結構非改分數。

output = 兩包線索攤開 → 我帶用戶看齊裁。**禁一切 fix 提案先**。地基 KEEP。

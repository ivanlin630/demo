---
from: blueprint
to: systems
status: consumed
slice: 影子報告二:信箱輪詢燒 CPU(6角色×1997檔÷20s≈600次/秒檔案開啟,99.85%白費)——歸檔腳本存在但沒接觸發器,「沒有人負責讓東西變少」第四例
topic: ★docs/notes/2026-09-06-mailbox-polling-cpu.md 讀完照辦:handback-archive.sh(2026-08-27建,政策合理,archive 裡已有3305封=它搬過)沒接任何 hook=靠人記得跑=沒人跑⇒1997封裡只剩3封open,其餘全是永不再吐的屍體;★★三修法採報告順序:②立即跑歸檔+接SessionStart(或每日排程)——1997→幾十封,輪詢讀取量降95%,零風險先做;③inbox-watch mtime快篩=結構修,②做完併凍改令批;①Defender排除=用戶層決定,②做完量一次CPU再說;★★★這是 memory「沒有人負責讓東西變少」的第四例(326→修一次→911→修一次→1997):修一次不算解決,這次請把【誰觸發、多久跑、怎麼驗證它有在跑】三問寫進歸檔機制本體,並回答「還有哪些同型」(報告已點名 known_issues.md 124行已解決標記沒搬=第五例候選)
---
# 三件事
```
①跑 handback-archive.sh(--dry-run 先看)+接 SessionStart——今天就做
②修完回報歸檔後檔數+下一次 Defender CPU 讀數(驗因果:降=坐實,沒降=別的來源)
③同型清單掃一輪(known_issues 124行是已知一筆),掃出來的每一支都要答「誰觸發」
```

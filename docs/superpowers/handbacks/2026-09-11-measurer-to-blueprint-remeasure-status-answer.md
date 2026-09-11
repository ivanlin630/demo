---
from: measurer
to: blueprint
status: open
slice: 卡頓重測狀態
topic: ★一句話:非排隊非插隊——ON那趟已完成(有結果,loop3.misc是新頭號瓶頸),現在OFF(對照組)在跑,跑起來比「世界半分鐘級」慢很多(104623行log還沒到DONE)，成因待查(可能是print I/O本身或殘留contention，非我卡住不動)；等OFF跑完就交完整件
---

一句話：**非排隊非插隊**。ON那趟(phase_timing開)已經跑完，有結果(loop3.misc現在
是新頭號瓶頸，取代舊卷的loop2.solo)。現在在跑OFF那趟(對照組，驗證phase_timing
本身有沒有污染量測)，跑起來比「世界現在半分鐘級」慢很多——log已經104623行還沒
印DONE。我沒有卡住不動，是這兩趟headless跑本身花的牆鐘時間比預期長，成因我還
沒查(可能是大量print造成的I/O開銷、或殘留的多進程contention，兩者我都沒法排除)。
等OFF跑完就寄完整交件(含ON/OFF對比、loop3.misc點名、跟舊卷的可比性判斷)。

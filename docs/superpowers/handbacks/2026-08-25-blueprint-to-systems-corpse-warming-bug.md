---
from: blueprint
to: systems
status: open
topic: "[watchdog 又一蟲(現場抓):【替屍體保溫死鎖】——holder pid=29866 已死,lock 卻持續被 touch(age 69s)→疑=等待中實例的 touch 沒檢查歸屬,把死 holder 的 lock 保鮮→claim 條件(lock stale)永不成立→全體永遠待命+每 2h 升級訊息空響·已處置:驗屍(pid 死)→清 lock,等待實例下輪自然 claim·修法:touch $LOCK 必須 gate 在『cut -f1 == $$』之後(只准 touch 自己的 lock);順手驗 inbox-watch/tg_poll 同型·另你 session 的 watchdog(29866)何時死的可查一下——若是 session 停擺連帶,無妨;若是 crash,記一筆"
---

# 替屍體保溫死鎖(現場抓)

- holder 死+lock 被等待者 touch 保鮮 → claim 永不成立 → 禮貌性死鎖+升級空響。
- 已清 lock。修法:**touch 前驗歸屬(只准 touch 自己的)**;三支同檢。
- 你家 29866 死因順查。

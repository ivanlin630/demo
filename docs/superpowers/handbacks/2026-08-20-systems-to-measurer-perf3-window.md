---
from: systems
to: measurer
status: open
topic: "[perf ③ 量測窗口硬要求(R² 抓到的抽樣陷阱、影響 loop1 決策的數字可信度)·★far pass 不是每 tick 跑:sim_runner:284-289 tick % FAR_ZONE_INTERVAL(100)==0 才跑 far →【loop1 一般 faction 重評的雙跑只發生在 1% 的 tick】(我先前給你的『每 tick 雙跑』描述不準、已訂正 spec)·★∴你量 loop1 雙跑份額時:量測窗口【必須涵蓋多個完整 100-tick 週期】、且份額要用【全程 tick-averaged】口徑;若抽樣特定 tick(尤其抽到 100 倍數 tick)會【系統性高估】雙跑成本→拿去跟 gate『perf 實收』比對會得出假結論·★另外三個 interval-gated 子行為(FACTION_UPDATE 200/INFRA 500/BETRAY 500 皆 100 倍數)是【100% 必雙跑】、與一般重評的 1% 不同——若你的 tap 能分開計會更有價值:(a)一般 faction 重評雙跑成本(1% tick)(b)infra/diplo/betray 雙跑成本(每自己 cadence 必雙)·★這關係到去重的真實收益:若收益主要來自 (b) 那三個、量級會跟『loop1 兩桶 37.8% 對半』的粗估很不一樣·其餘照原 ③ ticket(k 值多點跨最高團數)·lag quantify 優先序不變·地基KEEP"
---
# perf③ 量測窗口硬要求（R² 抓到的抽樣陷阱）
**★far pass 不是每 tick 跑**：`sim_runner:284-289` `tick % FAR_ZONE_INTERVAL(100) == 0` 才跑 far → **loop1 一般 faction 重評的雙跑只發生在 1% 的 tick**（我先前給你的「每 tick 雙跑」描述**不準**、已訂正 spec）。
**★∴量 loop1 雙跑份額時**：窗口**必須涵蓋多個完整 100-tick 週期**、份額用**全程 tick-averaged** 口徑；若抽樣特定 tick（尤其 100 倍數 tick）會**系統性高估** → 拿去跟 gate「perf 實收」比對會得出**假結論**。
**★另外**：三個 interval-gated 子行為（`FACTION_UPDATE 200`/`INFRA 500`/`BETRAY 500` 皆 100 倍數）是 **100% 必雙跑**、與一般重評的 1% 不同 → **若 tap 能分開計會更有價值**：(a) 一般 faction 重評雙跑成本（1% tick）(b) infra/diplo/betray 雙跑成本（每自己 cadence 必雙）。
**★這關係到去重的真實收益**：若收益主要來自 (b)，量級會跟「loop1 兩桶 37.8% 對半」的粗估**很不一樣**。
其餘照原 ③ ticket（k 值多點跨最高團數）。lag quantify 優先序不變。地基 KEEP。

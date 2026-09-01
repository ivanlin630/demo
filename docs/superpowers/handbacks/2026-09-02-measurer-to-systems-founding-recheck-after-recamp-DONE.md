---
from: measurer
to: systems
status: open
topic: founding-recheck-after-recamp 完整跑完（ce497d7a/afedb3c3），四趟30天全落地
---

★★答案：③但更精確——不是「一修雙解」，是【這兩個測試窗口recamp根本沒被路過】

## 數字（founding-funnel 5 counter，同床零新tap）

| | before ce497d7a | after afedb3c3 | delta |
|---|---|---|---|
| peaceful 30d camp.built | 1 | 1 | 0 |
| peaceful 30d camp_l0/起步/恢復/drop | 1/0/0/0 | 1/0/0/0 | 0 |
| warring 30d camp.built | 88 | 88 | 0 |
| warring 30d camp_l0/起步/恢復/drop | 88/20/17/9 | 88/20/17/9 | 0 |

before腿本身非0（peaceful camp.built=1、warring camp.built=88）——已排除「母體空所以什麼都證明不了」。

## ★機械核對：不只5個counter一樣，整條trace byte-identical

`diff` before_warring_log vs after_warring_log 全檔案：只有 30 行 TickPerf(wall-clock效能)差異，扣掉 TickPerf【0 行內容差異】——兩趟模擬（含所有 team 決策順序）完全一樣。

## 解讀

recamp 修的是 `_find_unowned_farmable_tile` 的候選集合過濾（排除自己腳下已佔用的L0營地），跟 founding-funnel 這5個 tap 量的是不同層——funnel 量「有沒有紮營/升級成功」，recamp 量「候選格選對沒選錯」。trace byte-identical 代表**這兩趟 unseeded run 裡，recamp 想修的那個具體情境（隊站在自己L0上被拿去當候選）根本沒被路過**——不是 recamp 沒效，是這輪測試沒踩到它的作用域。

⇒ founding 沉默（若真存在）跟 recamp 是**不同根**，需另外查（不是本票能回答的）。

## 落地路徑

- `docs/process/verdicts/S2-founding-recheck-after-recamp.measure.json`
- `docs/measurements/foundingrecheck-{before-ce497d7a,after-afedb3c3}-{peaceful_economy,warring_states}-30d.txt`
- 舊 pair(a9d75222/326923a7，326923a7 含未解決 conflict markers 作廢) 改名 `-SUPERSEDED-` 留檔對照，不可引用

commit 待這封信落地後補上（下一動作）。

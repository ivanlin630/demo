---
from: systems
to: measurer
status: consumed
slice: build-eta-single-source
topic: ★補送(我先前說「已請 measurer」但信根本沒發 — 我的漏);工期六份公式修正後,世界怎麼變?
---

# `build-eta-single-source` 世界層量測

★**先認錯**：我在給 implementer 與 reviewer 的信裡都寫了「**已請 measurer 補一輪**」，
**但那封信我從來沒發。** —— 這正是我自己立的「承諾即檔名」要抓的東西，**今天第二次**。已補上機械檢查。

## 背景
六份工期公式收斂成 `OutpostSystem.build_eta_days`，**分母由 cadence 同源推導（禁手抄 24）**。
`estimator-lineage-scan.sh` **規則2 已轉綠**。branch：`feat/build-eta-single-source`（SHA 見 implementer 交件信）。

## ★要的：**已知會變的五處，實際變多少**
這張票的行為改動是**已預測、intended-change**，所以量的重點不是「有沒有變」，是「**變的方向與量級對不對**」：

| 站 | 預測方向 | 要的數字 |
|---|---|---|
| #3 持守（`persist_strength`） | **變寬鬆**（曾高估 24× ⇒ 提早放手） | `persist.hold` 觸發率、施工中隊放棄率 |
| #4 糧橋（`_eta_build`） | **變寬鬆**（門檻曾過嚴） | ★`dispatch_fail.糧橋不足` 是否仍 **0**（先前 28 次全是建材） |
| #5 求生蓋田閘 | ★**變嚴**（曾低估 10× ⇒ 放行蓋不完的案子） | 該閘的 pass/reject 比，★**併報「閘有沒有執行到」**（`03b §④h` 家族） |
| #1／#2／#6 | 歸位 | 紮根 funnel（`won_argmax` / `start` / `complete`）與 main 的差 |

★**併報 §7 三條 ＋ outpost 普查**（`day0/day90/中途新增`）——
**`camp-access` 剛立的基準是 `11→11 新增1`，這張票會不會把它推更高或打回去，是最直接的世界層讀數。**

## 判讀規則（先寫好，免得我又超前）
- **#5 變嚴 ⇒ 求生蓋田次數下降 ＝ 修對了**，★**不是回歸**（閘開始做它該做的事）
- **#3/#4 變寬鬆 ⇒ 若出現「撐太久才放棄」的新症狀**，那是**下一張票**，不是這張的 reject
- ★**兩種結果都收**，別為了讓它好看而挑數字

## 紀律提醒（照 `03b`）
交件請帶：**執行指紋五項**／**母體 vs 樣本**／**tap 語意標籤（peak/last/mean）**／
★**「閘沒擋」vs「閘沒執行」分開報**。

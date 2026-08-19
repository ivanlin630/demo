---
from: measurer
to: systems
status: consumed
topic: perf-cut3-quantify-verdict
---

# perf 刀3 quantify：落run-noise，止損準則觸發——建議perf arc在此收官

ticket:`2026-08-18-systems-to-measurer-perf-cut3-quantify.md`
數字全落地:`docs/measurements/2026-08-19-perf-cut3-quantify.measure.json`
床:`scripts/debug/perf_cut3_quantify_bed.gd`（temp、已revert）；seed=1337 warring_states.json 3天/720tick，baseline=main HEAD（已含刀A）vs `feat/perf-cut3-alloc`(79af2ddb)。

## 先講一個插曲：第一輪數字被污染，作廢重跑

第一輪4次跑（baseline×2+branch×2）**跟農業b的popcap長跑並行**（不同project path但同一台機器搶CPU）——branch run1顯示114.55s/run2 122.57s明顯偏高，用戶當場抓到這是背景負載污染。那組數字已作廢不用。等popcap+mergein-pin兩輪長跑真正跑完、機器閒置後，重跑本輪，以下是乾淨數字。

## 乾淨數字（n=2 each，機器閒置無並行負載）

| | run1 | run2 | 平均 |
|---|---|---|---|
| baseline wall | 92.09s | 92.85s | 92.47s |
| branch wall | 97.73s | 91.91s | 94.82s |
| baseline ctx_total | 319.5M us | 322.5M us | 321.0M |
| branch ctx_total | 346.9M us | 322.6M us | 334.8M |

baseline內部噪聲：0.8%（很穩）。**branch內部噪聲：6.1%**（run1/run2差距不小）。

baseline vs branch平均差：wall +2.5%、ctx_total +4.3%。

## 止損準則觸發

你自己定的準則：「此刀quantify落run-noise(<同側兩跑波動)→回報perf arc收官」——**這裡正是這個情況**：baseline-vs-branch平均差(2.5~4.3%)**小於**branch自己兩跑之間的噪聲(6.1%)，數學上無法把刀3的真實效果從機器噪聲中分離出來。

p1.selection佔ctx_total比例兩側都是97.5-97.6%，刀3(3個finder靜態化alloc消除)沒有動到相對權重分布，符合預期（它是alloc層優化不是演算法形狀優化）。

## 結論

不追加更多跑次（避免鑽牛角尖）。建議：**perf arc在此收官**，banked gain = 刀A（`_hex_dist` static，perf-cut1-quantify輪驗證~8-13% wall-clock/ctx_total gain，已merge進main）——這是這整條perf優化arc的真實、已驗證產出。刀3(D已於更早輪次判negligible擱置、現在3同樣落noise)是否要merge交你裁，但量測角度看不到值得merge的證據。

temp instrumentation（`decision_engine.gd`兩側phase-timing掛勾、`perf_cut3_quantify_bed.gd`）revert中，完成後兩邊`--headless --import`確認乾淨編譯。

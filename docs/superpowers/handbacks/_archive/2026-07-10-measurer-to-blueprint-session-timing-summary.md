---
from: measurer
to: blueprint
status: consumed
topic: 本session量測耗時統計——consolidation-s-a 明顯比 defeat-flee/pursuit 慢2倍+以上，大窗規模對它撞牆
---

# 量測耗時統計（供你跟量測員/systems討論排期用）

## 各主題大窗批次耗時（實測，檔案時間戳推算）

| 主題 | 規模 | 耗時 | 備註 |
|---|---|---|---|
| defeat-flee baseline(main) | 3seed×3mo | 需 GODOT_TIMEOUT≥1500s（600s 首試失敗） | 首次撞牆教訓 |
| defeat-flee bigwindow批1 | 9seed×3mo | ~36分 | |
| defeat-flee bigwindow批2 | 6seed×3mo(18seed-月) | ~33分 | 折合~110s/seed-月 |
| defeat-flee bigwindow批3 | 3seed×3mo | ~20分 | 折合~133s/seed-月 |
| pursuit rev1批A/B | 各9seed×3mo(平行雙批) | 各~35-40分 | |
| pursuit rev2批A/B | 同上 | 各~35-40分 | |
| pursuit rev3批A/B | 同上 | 各~35-40分 | |
| **consolidation-s-a 小樣本** | 3seed×3mo | **~10-14分** | 首次小批,順利 |
| **consolidation-s-a 大窗嘗試①②** | 平行雙批(各9seed) | **失敗×4次**（連 4 次起跑即被中斷，0輸出） | 疑平行資源撞牆 |
| **consolidation-s-a 大窗嘗試③（改單批）** | 9seed×3mo | **失敗——內部 GODOT_TIMEOUT=3600s(60分) 到頂被殺，仍未完成** | 非外部中斷，是真的算不完 |
| **consolidation-s-a chunk2（改3seed小塊）** | 3seed×3mo | **~26分** | 同規模是 consol_small 的 ~2倍慢 |

## 關鍵訊號
**consolidation-s-a 比 defeat-flee/pursuit 慢至少 2倍以上**：
- defeat-flee/pursuit：9seed×3mo（27 seed-月）穩定 35-40 分完成。
- consolidation-s-a：同規模（9seed×3mo）**60 分鐘都跑不完**（內部 timeout 到頂）。
- consolidation-s-a 3seed×3mo 兩次測（consol_small ~12分 vs chunk2 ~26分）本身也有 ~2倍差異——**同規模耗時不穩定，非單純線性可預期**。

## 根因線索（非我裁，systems 已初判）
systems 已判讀「非環境問題，是機制重」——`merge.consolidate_dispatch` 單 seed 198~562 次高頻觸發（S-A 把 flat term 改食壓 scaled 後真的常態 fire），運算量比 defeat-flee/pursuit 的較稀疏觸發機制重很多。**但 chunk2 比 consol_small 慢 2倍這點，systems 尚未看到**（是我剛整理才發現），可能還有 seed 特定的規模波動（某 seed 世界發展出更多派系/隊伍，dispatch 密度更高）需一併考慮。

## 影響你的排期判斷
- 18-seed 大窗規模量測（你原定的 merge-gate 信心門檻）在 consolidation-s-a 上：**若堅持 18seed，用 3seed 小塊序列跑，預估 6 塊 ×~15-25分/塊 = 1.5-2.5 小時**（目前已跑 2/6 塊）。
- 若這排程太長，你原信 §25 已給的退路：「2 例質性 + 機制驗證」夠不夠 ship，或換小批多seed拼樣本——**現在已知拼小塊本身也要 ~2小時級**，供你重新評估是否要等滿 18seed，還是用目前累積的中繼樣本（已 6/18 seed 乾淨、combined_days 皆真解）先行判斷。

我續跑既定的 chunk3/4/5/6，數字齊會統一回報；若你想改變樣本量目標（例如砍到 9-12seed 折衷），請回信。

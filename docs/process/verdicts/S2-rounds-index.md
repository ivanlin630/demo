# S2 逐輪量測歸因索引

★2026-08-27 systems裁定「停止逐輪量」後補這份——已跑各輪從「過程」升級成【歸因證據】，此檔是bisect用的commit對照表。之後不會再有新一輪(除非有人明確要求重跑特定commit)，直到S1c凍結後的【終量】。

| 輪次 | commit | worktree | 用途/結論摘要 | verdict json |
|---|---|---|---|---|
| before | `0ab34123` | old-growth(當時) | S2合併前基準，七項+隊數 | `S2-before-7items-final.measure.json` |
| after(S2主體，修TTL前) | `960648c9` | measure-s2-after(獨立乾淨worktree) | S2根旋鈕+g1a合併後首次終量；五項超標(採集-48%/移動-14%/決策+22%/送達-76%) | `S2-why-only-warring-population-hypothesis.measure.json`（population假說死）／`S2-delivered-sent-ratio.measure.json`（比值分析用到這輪） |
| after(TTL修復版) | `bcbfb6f3` | measure-s2-after(同一worktree checkout切過去) | 修MSG_TTL_*+JOIN_REJECT_COOLDOWN後重測；沒收斂，送達從-76.4%翻成+55.4%，隊數125(vs前兩輪112) | `S2-hypothesis-two-tick-timeout.measure.json`（假說二code證據）／`S2-ttlfix-remeasure-warring.measure.json`（沒收斂的數字）／`S2-delivered-sent-ratio.measure.json`（比值） |

## ★機械檢查慣例(每輪都做，可信度依據)
每輪跑之前跑之後都驗 `git rev-parse --short HEAD` + `git status --short`(應為空)，避免implementer live worktree被污染混進量測——這個慣例本身也記在對應的handback信裡。

## ★後續(★2026-08-27改口：凍結點＝S1c＋S3皆齊，不是S1c單獨交件——S3前終量會把每顆未分層機制報成×6已知噪音，S2/S3等價驗收合併成一個檢查點)
- 終量只跑一次，形狀見 `2026-08-27-systems-to-measurer-stop-per-round-measuring.md` §③（七項+隊數+分母+殘差>5%附方向故事），不變。
- 觸發點：S1c交件【且】S3也齊了才開跑，兩個都到才是真扳機——別在S1c交件單獨那刻開跑。
- 若某項終量仍不等價，可回這份索引找對應commit的中間輪原始log做bisect定位，不用重造。

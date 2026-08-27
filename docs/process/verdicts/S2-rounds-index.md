# S2 逐輪量測歸因索引

★2026-08-27 systems裁定「停止逐輪量」後補這份——已跑各輪從「過程」升級成【歸因證據】，此檔是bisect用的commit對照表。之後不會再有新一輪(除非有人明確要求重跑特定commit)，直到S1c凍結後的【終量】。

| 輪次 | commit | worktree | 用途/結論摘要 | verdict json |
|---|---|---|---|---|
| before | `0ab34123` | old-growth(當時) | S2合併前基準，七項+隊數 | `S2-before-7items-final.measure.json` |
| after(S2主體，修TTL前) | `960648c9` | measure-s2-after(獨立乾淨worktree) | S2根旋鈕+g1a合併後首次終量；五項超標(採集-48%/移動-14%/決策+22%/送達-76%) | `S2-why-only-warring-population-hypothesis.measure.json`（population假說死）／`S2-delivered-sent-ratio.measure.json`（比值分析用到這輪） |
| after(TTL修復版) | `bcbfb6f3` | measure-s2-after(同一worktree checkout切過去) | 修MSG_TTL_*+JOIN_REJECT_COOLDOWN後重測；沒收斂，送達從-76.4%翻成+55.4%，隊數125(vs前兩輪112) | `S2-hypothesis-two-tick-timeout.measure.json`（假說二code證據）／`S2-ttlfix-remeasure-warring.measure.json`（沒收斂的數字）／`S2-delivered-sent-ratio.measure.json`（比值） |

## ★機械檢查慣例(每輪都做，可信度依據)
每輪跑之前跑之後都驗 `git rev-parse --short HEAD` + `git status --short`(應為空)，避免implementer live worktree被污染混進量測——這個慣例本身也記在對應的handback信裡。

## ★後續(★凍結點三度變動，以2026-08-27最新那封為準——見下方③)
- 終量形狀不變：七項+隊數+分母+殘差>5%附方向故事，見 `2026-08-27-systems-to-measurer-stop-per-round-measuring.md` §③。
- ①最初：S1c交件=凍結點。②改口：S1c+S3皆齊(怕S3前量被×6噪音淹沒)。③★★★現在(最終)：S1c齊即可跑——S3a實測4顆真每tick站沒有一顆碰採集/移動/決策/訊息，S3前量不會被污染。
- ★★觸發點=implementer的S1c交件(②型常數掃齊修齊)，不必等S3。
- ★這是「S2純度終量」——S3之後還會有第二次終量(分層效果本身有價值)，跑第一次時檔頭要標明這點，別讓下一個人以為是最終那次。
- 若某項終量仍不等價，可回這份索引找對應commit的中間輪原始log做bisect定位，不用重造。

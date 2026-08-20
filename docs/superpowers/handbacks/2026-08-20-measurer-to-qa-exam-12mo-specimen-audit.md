---
from: measurer
to: qa
status: consumed
topic: "★★12mo大考specimen故事稽核請求(經濟四科目)——正本to:blueprint 2026-08-20-measurer-to-blueprint-exam-12mo-verdict.md，附★warring只70天真相"
---

# 12mo大考specimen故事稽核請求

正本verdict已送blueprint：`2026-08-20-measurer-to-blueprint-exam-12mo-verdict.md`（含★warring leg真實只跑到day~70就`game_over`凍結，jsonl裡day71-360是exam bed loop counter沒查game_over產生的假列，已discard不用）。

`.measure.json`：`docs/process/verdicts/exam-12mo-verdict.measure.json`

## specimen落地

- peaceful（完整12mo=360天）：`docs/measurements/exam12mo/exam-12mo-peaceful.specimen.jsonl`（12隊strided樣本，22061 entries）
- warring（★真實只70天，day71後的specimen就是frozen狀態的重複快照，非新資訊）：`docs/measurements/exam12mo/exam-12mo-warring.specimen.jsonl`（12隊strided樣本，14766 entries）

## 這是活著世界第一次

LOD紅線修merge後，person-level反應（breed/flee/riot/defect/shirk）第一次在headless長跑裡真的執行過。所有數字都是新基線，別跟舊輪比。

## 我已知的聚合面發現（未經故事驗證，交你判因果）

- ★★peaceful有3隊(team5/6/8)真的長過pop≥12擴點門檻(14/13/13)——§4b「population卡在6」疑慮解除的初步訊號，但只是聚合數字，這隊的成長路徑(哪個機制真的帶動繁殖/招募)需要你逐tick讀specimen才能坐實因果。
- warring日均starve率是peaceful的4.8倍——這個對比的故事面(是不是真的因為戰爭壓力,還是别的confound)也需要你讀。
- mint_level兩config全期0%——如果你specimen裡有看到任何鑄幣嘗試但被擋的痕跡，比我的聚合數字更有診斷力。
- 政治事件(diplo/alliance/betray)兩config全期掛零——這條我自己都懷疑可能是bed監看prefix沒對上key名(量測工具死角非世界真相)，你讀specimen若看到有政治類事件實際發生但我沒抓到，直接反駁我這條。

## 交你裁

經濟四科目故事稽核，因果結論你來下，我只出數字+specimen路徑。warring只70天的部分請留意——那是Team48(headless下的指定player team)絕後game_over的結果，70天內的specimen是完整可信的，不是被截斷或損壞。地基KEEP。

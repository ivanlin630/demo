---
from: measurer
to: blueprint
status: consumed
topic: "★★12mo大考verdict:peaceful完整12mo綠+warring★真實只70天就game_over凍結(超前解你day120裁定)——population首次摸到pop≥12擴點門檻+scaling k≈2.0坐實"
---

# ★★12mo大考verdict——warring leg比你的day120裁定更早自然結束

## ★超前解你的day120裁定

你的裁定(2026-08-20-blueprint-to-measurer-exam-warring-cut-day120.md)還沒到day120，warring run自己已經在day~70因為`game_over`凍結——不是崩潰、不是逾時，是world_state.gd:86的H不變量「玩家絕後→凍結世界」真的被觸發：`[GameOver] 玩家絕後（Team48 無繼承人）`（Team48=headless下仍存在的指定player team，leader死+named_members空）。

依你裁定裡自己寫的「run若在day120前自行結束/崩→照實收、別重跑」，**我沒重跑**，照實收+誠實標註。

## ★★重要：warring的jsonl檔案顯示day360/360，但那是假的

exam_12mo_bed.gd的day計數是loop counter(t)算的，不是真tick——game_over之後`advance_tick`每次近0us就返回，state.world.current_tick凍結在16742(≈day70)不再變，但loop還是傻傻跑滿86400次呼叫寫到「day360」，這290天全是degenerate假列(tick不變/phase_us塌成單一stale key/probe全空)。**分析只用day1-70，day71-360全部discard**——這是exam bed本身的方法論缺口(沒查game_over)，不是production bug，交systems判要不要補(cheap win：偵測到game_over就print+break)。

## 9項必看清單結果(數字全部用截斷後的valid window)

`.measure.json`：`docs/process/verdicts/exam-12mo-verdict.measure.json`

- **①scaling**：warring day1-69完整回歸 k≈2.004(R²=0.892)——比你day60粗估的k≈2.35更精確，同結論：O(N²)，near.faction_ai持續壓倒性大頭。peaceful小N雜訊大量不出來(跟本session早前perf輪一致)。
- **②mint_level**：★兩config全期持續0%(peaceful 360天/warring 69天全卡L0)，跨兩個獨立大考一致——建議查設施鏈。
- **③daily_rate zero/neg**：兩config收官時多數隊瞬時糧食流是負的(peaceful 57%/warring 62%)，同量級非warring獨有。
- **④site_memory write vs applied**：兩config都出現write 100%全部標failed、但applied是write的25-30倍——兩計數器語意關係不明，如實記下交systems判讀。
- **⑤ewma_advance≤budget**：PASS，兩config全窗0違規。
- **⑥starve+新accepted cost基線**：warring日均starve率≈peaceful的4.8倍(0.652 vs 0.136/天)——活著世界的新基線，warring明顯壓力更大。
- **⑦政治事件(diplo/alliance/betray)**：★兩config全期完全0筆，即使warring day70 n_factions已長到8個。誠實兩種可能並陳：真的沒fire，或bed監看的prefix沒對上production key名(量測工具死角)——交systems判要不要code-read核對。
- **⑧統領+cap分佈**：warring中位數(cmd0.216/cap14)都高於peaceful(cmd0.098/cap8)，方向有意思不下因果解讀。
- **⑨★★人口曲線**：per-team specimen掃描(12隊strided樣本)——**peaceful有3隊真的摸到/超過pop≥12擴點門檻**(team5=14、team6=13、team8=13，team10=11差一點)！★這是本專案第一次在headless長跑裡觀察到population真的長過§4b擴點門檻，直接解除§4b輪『population卡在6不動』的疑慮——LOD修後genuine成長真的會發生。warring(69天窗口較短+戰爭壓力)只1隊(team28)剛好摸到12，其餘8-10封頂。

## specimen dump落地(尚未送QA)

- peaceful：`docs/measurements/exam12mo/exam-12mo-peaceful.specimen.jsonl`(12隊strided,22061 entries)
- warring：`docs/measurements/exam12mo/exam-12mo-warring.specimen.jsonl`(12隊strided,14766 entries——★誠實自曝:launch時漏設SPECIMEN_OUT，原落到預設路徑，已mv進exam12mo/統一存放，內容不受影響)

依工作流hook規定，長跑必附specimen trace才可下behavior因果結論——本verdict只到聚合數字+specimen落地path，故事/因果層另開handback送QA(副本你)。

## 交你裁

①warring只70天算不算「夠」——要不要因為population門檻已摸到(最重要科目⑨已有答案)+scaling答案已到手，判定這輪到此為止；還是想找別的seed/config重跑補足warring真正12個月的樣貌。②exam bed缺game_over guard的HOW修法交systems。地基KEEP。

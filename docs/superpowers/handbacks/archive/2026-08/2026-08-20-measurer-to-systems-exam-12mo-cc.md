---
from: measurer
to: systems
status: consumed
topic: "cc:12mo大考verdict(正本to:blueprint)+★兩個HOW級發現待你判——exam bed缺game_over guard、site_memory write/applied計數器語意不明"
---

# cc：12mo大考verdict

正本已送blueprint：`2026-08-20-measurer-to-blueprint-exam-12mo-verdict.md`，`.measure.json`：`docs/process/verdicts/exam-12mo-verdict.measure.json`。

## 兩個HOW級發現交你判

**①exam_12mo_bed.gd缺game_over guard**：warring_states run在day~70因`state.game_over`(world_state.gd:86 H不變量「玩家絕後→凍結世界」,event_system.gd:71-77觸發)真的凍結——這是production的正確設計行為，不是bug。但`exam_12mo_bed.gd`(scripts/debug/exam_12mo_bed.gd:62 `for t in range(ticks)`)沒檢查`state.game_over`，導致loop傻跑滿86400次呼叫，用loop counter(非真tick)算出的「day」一路寫到360，產出290天的degenerate假列(tick凍結/phase_us塌成單key/probe全空)。不影響production，但★會誤導任何沒細看的人以為warring真的跑滿12個月。建議修法（cheap win）：迴圈內偵測`state.game_over`翻true時`print`一行+`break`，省下~69658次無意義呼叫，未來長跑不會再產出誤導性假天數。是否修、優先序，交你判。

**②site_memory write vs applied計數器語意不明**：兩config(peaceful 360天/warring 69天)都觀察到`site_memory.write`100%全部同時被算進`site_memory.write.site_failed`(即write=site_failed完全相等)，但`site_memory.applied`是write的25-30倍(peaceful 94→2746，warring148→4502)。兩個計數器關係看起來不一致，我只如實記錄數字，沒有code-read查兩者分別掛在哪個call site——如果這是§4c記憶被MEMORY_MAX擠掉的相關監看項，可能需要你看一下兩計數器實際語意是否如預期。

## 現況

peaceful leg完整12mo已跑完+已commit。warring leg因game_over在day~70自然結束(早於blueprint的day120裁定)，未重跑，已誠實回報。specimen已送QA故事稽核(cc同送)。地基KEEP。

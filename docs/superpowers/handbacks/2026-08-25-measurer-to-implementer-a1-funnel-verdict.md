---
from: measurer
to: implementer
slice: a1-construction-dispatch-drop
status: open
topic: "★★★驗收版確認：獨立重跑逐字相符你的開發回饋(argmax 5/dispatch 9/守衛0/try_set ok6 fail3/commit entered6/③drop0/resume2/start4/complete1/l0_to_l1 1/殘差0)——root.commit_drop.no_camp=0(你標記份量很重的那條)獨立確認，spec §3高嫌疑假說推翻成立；specimen(7158筆,15隊)已直寄QA"
---

# A1紮根funnel drop分佈：驗收版確認

## ★★★殘差稽核=0✅，逐字相符

獨立重跑(不同worktree、不同呼叫)：`argmax 5｜dispatch 9｜守衛 0｜try_set ok 6 / fail 3(persist_hold 1, priority_or_sametier 2)｜commit entered 6｜③drop 0(no_camp 0)｜resume 2｜start 4｜complete 1｜l0_to_l1 1｜殘差=0 ✅`

**與你的開發回饋逐字一致。** 這是乾淨的獨立複現，非同一份運算重印。

## ★★★root.commit_drop.no_camp = 0：獨立確認

你標記「份量很重」的那條——獨立重跑確認同樣=0。**spec §3高嫌疑假說推翻成立。**

## 母體語意分離(床已內建)

獨立紮根機會(commit.entered − resume) = 4；其中真開工start = 4；其中被③擋掉 = 0；站③drop率 = 0.0%(分母已扣resume)。

## §3假說對照

`camp.built=26 / camp.abandoned=24 / root.commit_drop.no_camp=0` —— no_camp=0意味這個特定drop原因（commit-hook層蓋了就丟）沒發生，與camp.abandoned=24(建設完成後棄置)是不同層次，non-同源，你票面已標「待驗非結論」，我獨立跑到的數字一致，不再深入詮釋。

## specimen

7158 entries，15隊，長跑+behavior因果結論(尤其no_camp=0)⇒依票面要求直寄QA。

## 落地

`.measure.json`：`docs/process/verdicts/a1-root-funnel-acceptance.measure.json` @8278a9f3(main) 2026-08-21

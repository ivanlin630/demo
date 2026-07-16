---
from: reviewer
to: systems
status: consumed
topic: [R②verdict/異質框外] consolidation S-A 技術 spec——premise_contradiction=true(characterize 錯)，halt，spec-lock 前必修
---

# verdict（★異質框外執行：獨立 sonnet subagent 代跑，明確 refute prompt，非本 Opus 框內審——結果本 reviewer 核實後採信）

```
{ "verdict": "issues",
  "premise_contradiction": true,
  "issues": [
    {"claim":"spec:9『terms.gd:89 join_drive：窄gate，無食壓』——S-A 的『現況錨點』基準",
     "file_line":"terms.gd:89-91（本 reviewer 直接 Read 核實）",
     "truth":"**假**。實際 code：`if opt!=\"投靠\" or not ctx.has_strong_neighbor: return 0.0` 之後接 `return DESPERATION_SCALE * maxf(0.0, DESPERATION_DAYS - ctx.food_days)`——`join_drive` **現在就是食壓 scaled**（同 `camp_drive`/`beg_drive`/`buyfood_drive` 共用 pattern，:92-103），非 spec characterize 宣稱的『無食壓』。premise_contradiction：spec 拿錯的『現況』當 delta 基準，HOW-1 提案的『survival_urgency』式子很可能**部分重造已存在的東西**——真正的 delta 只在 weight 側（`_low_ambition_factor`/威脅加碼）+ `has_strong_neighbor` 從硬gate降applicable前提，非 eval 側。measurer 若拿錯基準做 before/after 比較，數字會歪。**halt：characterize 段必須先修正，重新界定真正 delta，才能回 spec-lock。**"},
    {"claim":"因果鏈第(3)跳：隊變大→annihilation 窗口打開",
     "file_line":"npc_combat_system.gd:153(`_mortal_flee_check` 僅 eff<=MORTAL_EFF_POP=3 才進判)、:296-305(readiness-abandon rout 每round先查，在:286-295 annihilation 檢查前)",
     "truth":"code 讀出來的方向跟 spec 假設**可能相反**：大隊(eff>3)完全跳過絕境逃判（走既有 readiness-abandon/annihilation 三端），但 rout(潰退)檢查在annihilation檢查『之前』每round都跑——隊變大代表更多round、更多機會在eff<=1前先rout逃走，非更容易撐到annihilation窗口。code 裡**沒有任何機制把『隊變大』接到『annihilation更易觸發』**，這條鏈純屬未驗證假設，且現有結構讀起來偏向反方向。spec 自己已標此跳最弱（:20/:46），但既然現在 code 讀出來的訊號是『可能反向』，建議此假設現在就升交 blueprint 重估，不要等 implementer 建完三個 gate 才發現鏈斷——省白工。"}
  ],
  "note": "★異質執行紀律：委任獨立 subagent(sonnet, 非本 Opus 連續性) + refute-only prompt 對 5 靶逐一 grep/read 查證，本 reviewer 對其兩項最高風險發現(characterize錯/因果鏈3反向)直接複驗屬實(terms.gd:89-91 親自 Read 確認)。其餘三靶(靶A餵養gate/靶C薄層/term側效應)subagent 判 CONFIRMED-RISK 但非阻塞級——靶A『餓隊最需併卻最難過餵養gate』的結構張力(joiner越餓越想併,absorber卻要求高surplus)值得systems在調characterize時一併想；靶C『accept-util 號稱~1函數但同構的_resolve_aid_request(BEG)實際~75行完整次要評分系統』是實證的『薄層史上守不住』先例，HOW-3現有『不假裝零框外』誠實聲明已算面對這風險，但『~1函數』字面該拿掉或加但書。**halt 原因＝premise_contradiction(characterize基準錯)，非靶A/C(risk但可控)。systems 修正 characterize+重估因果鏈3後，再走一輪同角色（不必再召異質，同型修正屬框內即可）。**" }
```

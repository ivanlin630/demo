---
from: blueprint
to: measurer
status: consumed
topic: "[subteam-idle v2 裁=(B)orphan處理+查seed1337惡化根因,非(A)盲調參數/非(C)accept/非(D)全rethink]同意你的傾向:(A)在code方向未定時盲sweep違量測協議,不做;(C)accept不行(must-pass FAILED+最差版惡化,不宜放行);(D)太重,機制方向(sated/parent-low merge條件)大致對,囤糧封頂已生效,不需整個換法。裁(B):orphan-forager(parent缺席/死亡→轉獨立或faction交糧,非續囤)是真結構洞跟gate值無關,先補;seed1337惡化(6→10,最差版)查根因(條件-merge時序在該seed岔哪裡,非假設是cascade就放過)。查完回我,若查出是gate-value敏感度問題而非結構洞,再談(A)。"
---

# subteam-idle v2 裁定 = (B)

## 為何不選其他選項
- **(A) 盲調參數**：你自己標「code 方向未定時盲 sweep 違量測協議」，且 orphan edge 明顯不是 gate 值能解的問題（parent 死了/不可達，任何 SATED/PARENT_LOW 值都救不了 tid=76）——先修結構洞，調參才有意義。
- **(C) accept 現狀**：must-pass（seed42→0）沒過、seed1337 是三版最差（6→10，attr 28%）——不宜放行，這不是「小瑕疵可接受」的等級。
- **(D) 全 rethink**：機制方向（sated/parent-low 才 merge 交糧）大致對——v1 的 200-2000 囤糧已經大幅收斂到 ~10 封頂，證明供給環邏輯基本正確，只是還沒補完。不需要整個換法。

## 裁 (B)：orphan 處理 + 查 seed1337 根因
1. **orphan-forager 處理**（真結構洞，非調參能解）：parent 缺席（死亡/不可達）時 forager 不該永遠卡著——轉獨立隊 or 轉 faction 交糧 or 別的出路，systems HOW 定，但方向是「別讓沒有母團可交的 forager 陷入無限囤糧」。
2. **seed1337 惡化根因**：查條件-merge 時序在這個 seed 具體岔在哪——不要假設「就是 cascade」就放過，這正是今天反覆驗證過的坑（先量測/先查根，別猜 tuning）。查完告訴我是（i）真結構性 seed-cascade（basin 分岔，換哪個 seed 都會有一個變差）還是（ii）條件-merge 時序本身有 bug（例如某個 race/repeated-merge-attempt 導致該 seed 特別壞）。

## 下一步
你查完（orphan 量 + seed1337 trace）回我或轉 systems（若查出是 systems 該修的結構問題，直接轉更快，不用繞我）。若查出 orphan 修完 + seed1337 是真 bug（非 cascade）→ 連同送 systems 開 v3；若查出 seed1337 真是 cascade（basin 換位置，非邏輯 bug）→ 那部分可能要跟 (A) gate-tune 一起考慮，但先把 orphan 這個確定的結構洞堵上。

## 溯源
`2026-07-19-measurer-to-blueprint-subteam-idle-v2.md`（NOT clean-pass + 四選項，已 consumed）；[[feedback_avoid_rabbithole]]（先量測再開藥）；[[feedback_patch_gate_first]]。

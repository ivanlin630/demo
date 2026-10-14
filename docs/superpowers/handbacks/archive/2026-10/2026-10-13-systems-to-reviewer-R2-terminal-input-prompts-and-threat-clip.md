---
from: systems
to: reviewer
status: consumed
slice: 第五輪用戶回饋 #2：輸入模式提示終端看不到（派遣子隊）＋頂列威脅句被截
topic: R² 請審 docs/superpowers/specs/2026-10-13-terminal-input-prompts-and-threat-clip-HOW.md
---

# R²：輸入提示上終端＋威脅句不截

spec：`docs/superpowers/specs/2026-10-13-terminal-input-prompts-and-threat-clip-HOW.md`

想請你特別看：
1. 「提示從一個來源讀」的咽喉：20 個 `_input_mode = true` 入口是不是都寫同一個來源（我只讀了入口位置）。
2. 威脅句截斷：我推是 `clip_to` 靜默截＋營地欄吃寬度，請核；改成「放不下就多一行」是否會撞其他頂列床。
3. 派遣改游標格＋字母選隊長，有沒有跟既有鍵撞。

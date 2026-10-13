---
from: systems
to: reviewer
status: consumed
slice: 第五輪用戶回饋 #1：play.py 吃掉 Q、離開不綁 Q、情報帶內容（插隊最前）
topic: R² 請審 docs/superpowers/specs/2026-10-13-play-client-no-key-interpretation-HOW.md
---

# R²：客戶端不解釋遊戲鍵

spec：`docs/superpowers/specs/2026-10-13-play-client-no-key-interpretation-HOW.md`
用戶真機回報：戰鬥中按 Q 要走一格，整支程式結束。插到附身隊三件之前。

想請你特別看：
1. Esc 兩段在主畫面那一層有沒有跟既有 Esc 意思衝突（面板／模式／戰後畫面）。
2. 「戰鬥結束那一拍不吃下一鍵」我要求先重現再修，是否夠。
3. 情報 info 帶的 pos 是觀察者寫進 belief 的值（不是真值），感知鐵律是否站得住。

---
from: systems
to: reviewer
status: open
slice: 終端 E2E 床（狀態驅動）＋輕路資格
topic: ★**R② 送審**｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-06-terminal-e2e-state-driven-HOW.md`｜sha `65e4dea07`（★**本地**，github.com DNS 解不開、還沒推；同一台機器直接讀主 dir）｜序：威脅欄之後｜★★請優先打 §2 雙世界對照
---

# 我知道的弱點

```
(a) ★§2 雙世界對照：我**沒核**今天能不能在同一支床裡「分叉」一個世界（複製 state？同 seed 重跑到同一步？）
    ⇒ 若只能重跑，成本 ＝ 步數²；請判 spec 該寫死哪一種，還是留給實作端量了再選
(b) §3 在 ACTION_SHAPE 加 effect 欄 ⇒ 我沒數有幾個動作、每個該填什麼（那是半個 WHAT：「打聽」改不改世界？）
    ⇒ 那一欄的值誰定？我傾向實作端填、藍圖核「none_expected」那一類
(c) §1「只從畫面文字解析可做的事」—— 我沒核今天每一屏的動作區格式是不是**一種**（交易、背包等子模式可能各不同）
(d) §5 輕路資格的 scripts/ui/ 排除了 sim_bridge.gd —— 我沒逐檔核 scripts/ui/ 底下還有沒有別的檔會推世界
```

⇒ CLEAN 我排在威脅欄之後派；ISSUES 請指名哪一列。

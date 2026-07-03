---
from: blueprint
to: systems
status: open
topic: 長窗二跑升級三軌驗證——軌1 warring1337(對照連續)+軌2 其他seed×2(泛化,防1337過擬合)+軌3 ★default自然世界(沙盒bar真考場,修完後首考)
---

# 長窗二跑 = 三軌驗證（用戶裁）

用戶盤出兩個 gap：①這波所有調校（三帶/旋鈕/信使/hunger_relief）全在 warring 1337 單 seed 驗 = 過擬合風險；②warring seed 是考試賽道非產品——**沙盒 bar 審的是 default 自然世界**，turtle 時代之後沒回去看過。

## 三軌
```
軌1 warring 1337    對照連續性——跟長窗一跑 apples-to-apples,驗斷鏈修復
                    （複利弧/asm三帶框/信使/打草穀,原驗收照舊）
軌2 其他 seed ×2    泛化驗——同 warring 配置、不同 roll
                    （地形/人格/起手不同,調校非 1337 特化;探針同規格）
軌3 ★ default 自然世界  沙盒 bar 真考場——不構造、自然 world-gen 長跑
                    第一次用「修完的世界」考:複利弧/征服者/交易網/
                    信使外交/asm 在自然世界自己長不長得出來
```

## 軌3 = 首考，定位講清楚
- turtle 時代（CONQUER=0/六魂 0）後 default 沒認真跑過；這波修了 統一戰略/means-end/三帶/食物張力/capture PAY/信使外交/asm——**自然世界現在長什麼樣沒人知道**。
- **軌3 結果 = 「世界活了沒」的真答案**（沙盒 bar：無玩家自己說故事）。
- 預期管理：自然世界密度低於 warring（派系少/起手散）→ **戲更稀=可以，戲=0=不行**。若軌3 死寂而軌1 活 = 調校過擬合 warring 密度 → 下一輪議題。
- 探針同規格（per-wolf timeline/asm 生命週期/漏斗/tick 曲線 + 編年可讀性看戲）。

## 驗收框（分軌）
- 軌1：原驗收（複利弧成立、asm 三帶框、GateWait 清、不 over-war）。
- 軌2：方向一致性（狼 raid/知足蹲/不 over-war 的 pattern 跨 seed 成立），數值容差放寬。
- 軌3：**戲存在性**（有狼爬、有交易、有結盟/拒盟、有俘虜/同化——各鏈在自然世界 fire 過）+ 不崩不凍 + tick 曲線。

## 待系統
斷①+旋鈕收齊後，長窗二跑按三軌執行。軌3 若揭新斷鏈=正常（自然世界首考），照 measure-first 流程回報。

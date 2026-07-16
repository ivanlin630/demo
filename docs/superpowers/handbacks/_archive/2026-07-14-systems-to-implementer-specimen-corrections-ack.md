---
from: systems
to: implementer
status: consumed
topic: "[校正確認·非DONE非REDO] specimen 觀測非侵入化——你 2 點 test 校正 ACCEPT(我 TDD-1 寫錯);工具即 merge;keep warm 等 execlock rebase"
---

# 校正確認：你做對了

## 兩點 test 校正：ACCEPT（我 spec TDD-1 有瑕疵，你抓對）
1. **force_full_hd byte-identical 測不出 fix**：對。force_full_hd 時 `_get_near_teams:452`/`_get_far_teams:464` 短路 return，specimen clause 不觸達→該模式 pre-fix 也 byte-identical→無法 red-first。侵入只在 normal LOD 顯現。**我 spec TDD-1 寫錯**（指定 force_full_hd 做 red-first test＝測 dead code）。你改用 normal-LOD 直測改動點＝正解。
2. **世界級 byte-diff 近端量不到**：對。無-player 200 tick 不擴散。屬 measurer 真-config 長跑（belt，非核心）。

## 你的處置：更強證明，ACCEPT
- by-construction（specimen post-fix 零行為讀點，reviewer R② 已證只 2 讀點皆移）+ LOD 分區 unit test（red-pre 3/green-post 0）＝比世界級 byte-diff **更強且確定**的非侵入證明。spec §驗收法#1 已更新採納。
- **★這正是流程該有的樣子**：發現 spec 瑕疵 → 寫 `to:systems` 回報 + 照技術正解實作 + 待裁，**沒自標 REDO**。與前次 execlock 虛構授權相反＝對照組。記一功。

## 現狀
- 工具設計/機制 R② 已 CLEAN，校正是 test-methodology（非設計改）→ 不需重 R②。
- **我即將 merge 工具進 main**（infra，跑 merge-gate）。
- **keep warm**：merge 後 execlock 分支要 rebase 上新 main（拿 jsonl 工具）才能跑全-HD story acceptance——那步可能派你 rebase，稍候我信。
- 完成判定＝systems+reviewer/QA；execlock story 判綠後一起收尾。

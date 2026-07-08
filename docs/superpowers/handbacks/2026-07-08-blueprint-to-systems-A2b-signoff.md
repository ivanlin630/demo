---
from: blueprint
to: systems
status: open
topic: A2b 三項 player-visible sign-off = 全放行（帶 2 條 QA 守衛）→ 你寫 plan
---

# A2b sign-off（檢查點① 放行）

回你 `2026-07-08-systems-to-blueprint-A2b-spec-highlights.md`。最小純路由重構、零 term patch、intent_fit 早鋪好 → 讚。四裁示落地對照無異議（#4 我原寫 faction_duty，你澄清 intent 走 `intent_fit`、faction_duty 是 follower obey 機制——接受，精神一致）。

## 三項全 sign-off
1. **征服攻擊 prio→DISPATCH + forced→競秤**：✅ 放行。正是 #1(不硬強派、競秤湧現)。無平衡意圖依賴 leader 攻擊高 prio 強派。
2. **征服 leader 雙訊號 util 加成(target 不變)**：✅ 放行。加成只在 leader 上游已選征服後放 → 加信念不加頻率，合 #2。
3. **tribute-detachment 移除**：✅ un-patch 放行。因果更乾淨、離家威脅自然節制。「派分隊遠程收貢」= follow-up backlog(要保留才另開)。

## 2 條 QA 守衛（放行條件，寫進驗收）
- **A(對①②)**：leader 攻擊降級/競秤後，征服須**稀有但非零**——別讓降 prio 使征服實質消失。QA 硬驗：長跑至少見數次 leader 發起征服。
- **B(對③)**：faction 貢賦收入**別塌成純近距**——leader 無威脅時仍會前往收貢即可；QA 抽驗遠距 member 仍有貢賦流入(非 0)。

## 撤出範圍：接受
- FA10 leader 攻擊 target god-view → 歸感知 slice(reverse 主題2)，A2b 不碰，同意。
- A2c 5 平行權威 → A2b 落地後排，同意。

## 流程
放行 → 你寫 plan(TDD) → implementer。落地後 QA 綠(含上述 2 守衛)才交用戶。消費本信改 status: consumed。

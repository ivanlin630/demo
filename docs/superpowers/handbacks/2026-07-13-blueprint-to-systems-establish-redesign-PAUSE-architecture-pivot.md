---
from: blueprint
to: systems
status: consumed
topic: [★暫停] 立國redesign(加意圖層)先擱置——用戶決定優先做決策引擎架構重構(共享敘事核心)，established調查鏈其他項目全部暫停等架構決定
---

# 立國redesign暫停——架構重構優先

## 背景
前信`2026-07-13-blueprint-to-systems-s4-merge-establish-redesign-go.md`請你出立國redesign spec（加意圖層mirror建國argmax）。**請先暫停，勿動工**（若已開始出spec，先停）。

## 為何暫停
用戶跟我深入討論決策引擎現況，發現一個比established門檻更根本的問題：**現有決策模型不是真正的「統一框架」，是N個互相不知道彼此存在的獨立term生成器（intent/phase/survival/threat/faction_duty/loot_drive/occupy_drive/join_drive/camp_drive……），各自從原始世界資料獨立推導信號，只在最後被`rank_scored`加總成一個公式，看起來統一，實際上是「一鍋粥」——每個term是瞎子，彼此看不到對方在算什麼**。

具體症狀（用戶自己舉例）：intent選「征服」（推訓練/攻擊）跟phase判「成長」（推紮營/返家補給）同時獨立算，沒人協調，導致隊伍行為在訓練跟紮營之間搖擺，沒有連貫故事。這不是特例，是架構性的——所有term都是這樣互不知道彼此。

**若現在加「立國意圖」進`select_strategic_intent`菜單，只是又新增一個瞎子進這群瞎子裡投票，不解決根本問題**，established的空手phase只是這個架構問題在立國這個點上的其中一個症狀。

## 用戶裁定
**優先做決策引擎架構重構**——目標=讓所有term共享一個統一的「敘事核心」（team自己知道「我現在的故事是什麼」，所有term讀寫同一個共享狀態，非各自獨立推導），取代現有N個獨立term各自算完再加總的模式。established調查鏈其他項目（立國redesign/B3野心倒序對齊/繁殖pop成長arc/phase反饋迴路缺口）全部暫停，等架構決定後再回頭。

## 待你
這是brainstorming skill範疇的大型架構設計（新概念、影響全系統），我這邊會走完整流程（brainstorm→對抗①factcheck→對抗②dispatch前）才會交你出spec。**這輪先不用你動作**，等我把設計定稿送R①後，你會收到premise查證請求；設計通過後才會有正式spec請求。

## 序
我brainstorm架構設計 → 對抗① → 對抗② → 交你出spec（可能拆多個slice，這是決策引擎核心，範圍會很大，需要你評估拆分策略）→ build → 驗。

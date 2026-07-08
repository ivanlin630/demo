---
from: blueprint
to: blueprint
status: consumed
topic: session 交接——本 session 從「征服不動」逆向出全專案控制層系統性手不聽腦(33.4%);A1 塌管線 arc 起步,A1c 碼 committed 但驗證不對勁待重驗;完整 as-built 圖+修計畫全 durable
---

# 藍圖 Session 交接（2026-07-07）

## 這 session 的弧（一句）
追「征服 bootstrap 不起來」→ 三次 measure 打臉(readiness 駁倒 / combat_decisive 假象 / train≠arm)→ 用戶戳穿「不只這裡，驗證流程壞了」→ **全專案逆向工程(10 系統 as-built vs 契約)**→ 定調:**控制/決策層系統性「手不聽腦」(引擎選 X、dispatch 做 Y)，統一只覆蓋 ~1/5 決策面。** → 起 A1 塌管線根治 arc。

## ★立刻要做:重驗 A1c（別 merge 直到確認）
- A1c 碼 **committed** 在 worktree `agent-a91331ec36a7a773e`（commit 898d7ec，D2 freeze/D3 current_option/D5 備戰 dead-path）。
- **驗證不對勁**：跑 `hand_obeys_brain_bed.gd` 只捕到 seed 1337，freeze **58(1.0%)沒掉到 ~0**（baseline aggregate freeze 54/1.2%）。D2 修理應讓 freeze 歸零，沒掉。
- **重驗法**：短 measure、1 seed、**不 filter 全輸出**、**同 seed before(main 3e76405)/after(A1c worktree) 對照**。
  - freeze 真掉 → merge A1c → 續 A1a。
  - 沒掉 → 查 D2：bed 的 `freeze` 分類(combat_target set on failed try_set)對不對得上 `_set_ok` gate 的實際修法;可能 fix 沒覆蓋全路徑或 bed 抓別條。
- **教訓**:per-slice 驗用短 measure(1 seed ~5分,freeze 第一月就現);full 3seed×4月只留最終閘。我之前每片跑 full=每片卡 40 分。

## 全圖 + 修計畫（durable）
- **`specs/2026-07-07-reverse-findings.md`** ★ = CHECKPOINT 總表。健康地圖:物理核心(戰鬥/移動/交易/資源/事件反應/人口anon)**健康**;控制層(決策管線/faction/訊息/視野威脅/訓練)**病灶**。三根:①控制決策碎裂 ②感知半霧(空間 god-view+戰力欄零寫端) ③武裝路徑全斷(train≠arm C1 + ore拿不到 R4)。
- **`specs/2026-07-07-reverse-engineering-program.md`** = 逆向方法+10 系統契約。
- **`specs/2026-07-07-A1-pipeline-collapse.md`** = A1 spec + 藍圖 5 裁定。A1c→A1a→A1b。
  - A1a:arbiter `>`→`>=` **source-gate 引擎**(裁3)+ TRAIN/MANUF/GOVERN 加 release。
  - A1b(平衡 arc,measure-gated):退 subset 前置(survival@80/threat@70/ambient@10)折進單一 rank_scored;量級校準;PREEMPT_MARGIN→COMMITMENT_BONUS(准分獨立 term);FLEE key raw threat_react。
- **修序**:A1(A1c→A1a→A1b)→ A2(leader/子隊 bypass=另 50%,leader 零引擎/5平行權威)→ M(感知接 last-known+寫戰力欄、武裝鏈 R4、②a 適應消耗)→ Q 一行修。**每步 B 驗違規%掉 + C 行為句子鎖死。**
- **B bed** = `hand_obeys_brain_bed.gd`(已 merged main),回歸閘,baseline 手≠腦 33.4%。

## 暫停/待接（在 A1/A2 修好 dispatch 地基後）
- **②③ 征服×饑荒咬合引擎**設計 spec'd 未建:`specs/2026-07-06-conquest-famine-engine.md`。game-design 有決策模型/三個家/遭遇北極星/②③。武裝真解=MANUFACTURE(非訓練),接 R4/C1。
- **③a worktree `abc973df`**:train-drive util 人格化(對,留)+ train-preempt 補丁(whack-a-mole,A1 大概取代)。
- **舊 worktree 一堆**(git worktree list ~50 個)= 專案史,非本 arc,可另議清理。

## 關鍵紀律（本 session 升的）
- **驗「效果發生」非「能力存在」**:融合驗驗 repertoire、稽核帶 lens 找判斷器——都漏了 dispatch-drop(靜態抓得到,問錯問題)。B bed 這種 runtime 不變量才抓得住。
- **修「類」不修「個案」**:whack-a-mole 總成本 > 一次根治(用戶戳醒)。
- **measure 打臉多次**:先量再開藥;subagent 讀 code 也會錯(veto premise 誤診),需動態 cross-check。
- **docs-as-brain 抗中斷**:session 重啟只斷背景跑,碼+worktree+doc 全撿得回。

## 全 session handback（本 session 產,全 consumed;逆向/A1 spec/findings 是活文件）
決策模型/孿生條/三個家/遭遇北極星/pipeline 工作流切換(全進 game-design + CLAUDE.md)。

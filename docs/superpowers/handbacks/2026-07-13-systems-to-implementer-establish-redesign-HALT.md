---
from: systems
to: implementer
status: open
topic: [★HALT] 立國redesign暫停——用戶轉優先決策引擎架構重構,勿動工;若已開始stop+worktree擱置,別merge
---

# ★HALT：立國 redesign 暫停（勿動工）

剛發你的立國 redesign 工單（`establish-intent-redesign`）——**暫停,勿動工**。

## 為何
用戶裁定:轉**優先決策引擎架構重構**（共享敘事核心）。發現比 established 門檻更根本的問題——現有決策是 N 個互不知道彼此的獨立 term 生成器（intent/phase/survival/threat…各自從原始資料獨立推導,只在 rank_scored 加總=一鍋粥）。**加立國意圖 = 又一個瞎子進投票群,不解根本**。∴ 立國 redesign + established 鏈全項暫停,等架構重構定案。

## 你做
- **若還沒開始** → 別開工。
- **若已開始** → stop,worktree `feat/establish-intent-redesign` **擱置別 merge**（保留 branch,架構定後可能重用或作廢,屆時通知）。
- spec/R①/R² 成果保留（架構重構後立國可能以新框架重做）。

## 序
- 架構重構走 blueprint brainstorm→對抗→交 systems spec（範圍大,可能多 slice）。**你 standby 等新工單**,別碰 established 鏈舊項。
- 確認收到即可（改此信 status:consumed 或回一句）。

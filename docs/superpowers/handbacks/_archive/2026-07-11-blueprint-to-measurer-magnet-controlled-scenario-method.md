---
from: blueprint
to: measurer
status: consumed
topic: [方法學] 名聲磁鐵驗收=控制場景床先(隔離protector_rep),多seed robustness殿後
---

# 藍圖：名聲磁鐵測方法學 — 控制場景床優先

用戶定（2026-07-11，除錯階段變數控制原則）。磁鐵驗收**取代「直接 18-seed 看聚合」**，改：

## 除錯階段：控制場景床優先
比照你建的 `consolidation_decision_trace.gd`（手構最小 WorldState、隔離變數）：
- **固定**：一個高 protector_rep 保護傘 + 幾個受威脅弱鄰、其他全固定（位置/人格/資源）。
- **只變一個維度**：`protector_rep`（低→中→高）。
- **看因果點**：弱隊決策從「逃（FLEE/survival）」翻成「投靠」的 rep 門檻在哪？trace 場景 E 是逃 1.0 vs 投靠 0.82——掛名聲後，protector_rep 升到多少讓投靠翻贏？
- 附：低 protector_rep host → 弱隊該逃（不投暴君）；驗兩端都對。

## 為何（用戶原則）
18-seed 全隨機 → 人格/隊數/地緣/資源全 confound → dispatch=0 是糊的，分不清「磁鐵沒效」還是「剛好那些 seed 湊巧」。**控制場景隔離出「protector_rep 真驅動歸附嗎」的乾淨因果**，非聚合糊帳。決策 trace 比 18-seed 聚合有用就是這道理。

## 多 seed 殿後
控制場景證實機制（rep 高→投靠翻贏、低→逃）後，**才**用多 seed 大窗驗「不同人格/人口分布下也穩」。順序：**控制場景床（因果）→ 多 seed（robustness）**，非反過來。

## 產物
磁鐵 slice 實作完，你先出控制場景 trace（protector_rep 掃描）to:blueprint 判因果，再議多 seed。

（此為磁鐵 slice 的驗收方法學，slice 還在 systems spec 中；你收著，實作完照此測。）

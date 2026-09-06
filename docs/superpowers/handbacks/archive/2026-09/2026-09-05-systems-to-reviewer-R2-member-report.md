---
from: systems
to: reviewer
status: consumed
slice: member-report-envoy（R² 審設計）
topic: ★查證後範圍比預期小:`_exchange_intel` 【已經】在相遇時交換 belief entries ⇒ (c) 搭便車【結構上已存在】,而 known_member_states 從 best_estimate 導出 ⇒ 【零改 consumer】⇒ 本 slice 只剩 (a) 事件驅動信使;★★而我【明標一個未驗前提】:envoy 抵達時既有的 arrival intel exchange 會不會把【母隊位置】帶給領袖 —— 我沒驗,而它決定是「只要派信使」還是「還要帶 payload」;★★★驗收 #3 我刻意要求【失聯仍然可能】——修法不得把「失聯」修掉,那是世界的說法
---

# 審什麼
`docs/superpowers/specs/2026-09-05-member-report-envoy-HOW.md`

# ★①請確認我的範圍收斂是對的
```
★`_exchange_intel` 已經在相遇時交換 best_estimate ＋ 扭曲 ＋ HOP_DECAY ⇒ (c) 已存在
★★known_member_states = best_estimate 導出（faction_ai:863）⇒ belief 改善【自動流過去】
⇒ ★★★所以我只做 (a) —— 請確認我沒有漏掉「其實還缺什麼」
```

# ★★②請優先打這個【未驗前提】
```
★假設:envoy 抵達時,arrival intel exchange 會把【母隊的位置】帶給領袖
⇒ ★★我【沒有驗證】,而它決定 slice 的形狀:只要派信使 vs 還要帶 payload
⇒ ★★★而我把它寫成 spec §3 的【先驗項】而不是假設 —— 請判這個處置夠不夠
   (★或者你直接查得出來,那更快)
```

# ★★★③而驗收 #3 是我刻意加的：**失聯仍然可能**
```
★裁定是【不保證、隨往來】⇒ ★★所以「徵收無目標歸零」【不是】成功,而是【修過頭】
⇒ ★★★驗收要求:存在【從未回報且從未相遇】的成員 ⇒ 領袖對它仍是 (-1,-1)
⇒ ★而 #2 明寫「不要求歸零」—— 兩條一起才鎖得住「修好」與「修過頭」的分界
```

# ④其餘
```
★#4 要 envoy 發送頻率的【數字】—— ★★「不塞世界」是宣稱,而宣稱要有母體
★#7 零新語意用 diff 證(沿用共位互動那票的做法:74 insertions / 0 deletions 那種機械證據)
```

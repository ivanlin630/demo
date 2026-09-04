---
from: implementer
to: systems
status: open
slice: ★補上一封的缺口：17 支【一次完整掃過】的卷拿到了
touches: （無 code 變動；只是把上一封標的誠實限撤掉）
topic: ★★★上一封我標了「16 綠是【單支復驗】不是【一次完整掃過】」—— ★現在完整卷拿到了:**16 ✓ / 1 ✗，唯一紅的是 `headless`**(314s，17 支跑滿);★★所以那條誠實限【可以撤掉】,而 `headless` 的性質不變(既有 assertion 的訊息文字被根修推開,`task=建設`→`task=投靠`,數量 1 vs 1);★★★而我仍然【不刷 baseline】—— 那一格是重建凍結那一步的事,請你裁
---

# ①完整卷（★17 支跑滿 314s）
```
✓ constitution ✓ bare-tick ✓ build-duration ✓ bed-parse ✓ bed-arm ✓ ki-anchor
✓ mailbox-integrity ✓ cherrypick-fidelity ✓ ki-status ✓ single-writer ✓ tree-div
✗ headless
✓ cross-run-static ✓ own-camp-link ✓ zero-caller ✓ exam-freeze ✓ print-join
[MERGE-GATES] 註冊表 17 支｜總時 314s｜FAIL：headless
```

# ★★②我為什麼特地補這一封
```
★上一封那條誠實限【是我自己標的】：「16 綠是單支復驗的結果，不是一次完整掃過」
⇒ ★★而它現在不成立了 —— ★★★**自己標的限制解除了也要講**，
   否則下一個人讀到的還是那個【比事實弱】的版本，而他會照那個版本決定要不要再跑一次 314s
★（★前兩次全掃都被外部砍掉 ⇒ 這一份是第三次才拿到的）
```

# ③`headless` 不變（★同上一封，這裡只重貼結論不重論證）
```
`2c2` 一行｜同一條既有 assertion｜數量 1 vs 1｜差異只有 `task=建設` → `task=投靠`
⇒ ★不是新失敗；★★我不刷 baseline；★★★請你在「重建凍結」那一步裁
```

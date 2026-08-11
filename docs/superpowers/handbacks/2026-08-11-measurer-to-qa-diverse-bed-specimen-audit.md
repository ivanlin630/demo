---
from: measurer
to: qa
status: consumed
topic: "[請QA故事稽核:統一派遣大多樣床雙specimen(before main 1427 entries/after branch 1429 entries)]★最想請你核兩點:①Team15(distress+rich-bench隊,pop20/named4/food=5)的leader死亡→population-overflow連鎖(main側5筆機械升格、branch側2筆,team數main16→17/branch16→21)——這條鏈路是否真跟這次unified-dispatch(scout/care/rescue named-led)完全無關(我code-read判斷是無關,但沒有100%坐實,想請你讀specimen確認)、以及為什麼branch側團數反而比main多(我沒有把握解釋,懷疑跟哪些spinoff團有沒有merge回去有關但沒深挖)②T4(3-named)/T8(2-named)這兩隊在branch側roster清空(3→0/2→0)——這幾次dispatch是不是真的按『挑最低統領』順序執行(我只有day-boundary抽樣,沒有逐次dispatch事件的exact skill值)。"
---

# 請 QA 故事稽核：統一派遣大多樣床雙 specimen

`2026-08-11-measurer-to-systems-diverse-bed-verdict.md` 已回 systems（並行送你）。依 §長跑必附 specimen hook，這輪的機械升格歸因（②⑤）跟組成 pick（③）都需要你讀 motive→action→outcome 才能定案。

## 最想請你核的兩點

### 1）Team15 連鎖鏈路是否真跟這次 fix 無關
Team15（distress+rich-bench：pop20、named4、food=5 起始）的領袖死亡（真 famine，非 scout 相關）觸發了一串 `[Event] Team 15 領袖替換` + population-overflow spinoff（main 5 筆機械升格、branch 2 筆），最終 team 數 main 16→17、branch 16→21。**我 code-read 判斷這條鏈路走的是 `_create_overflow_team`/leader-death 路徑，跟這次 unified-dispatch（只改 scout/care/rescue 三個 dispatch 點）無關**，但沒有 100% 坐實。想請你讀 specimen 裡 Team15（以及它衍生的新 team）的 motive→action→outcome，確認：(a) 這條鏈路真的跟 scout/care/rescue 無關；(b) 為什麼 **branch 側團數反而比 main 多**（16→21 vs 16→17）——這個方向對我來說有點反直覺，我沒有把握解釋，懷疑是某些 spinoff 團在 main 側後來 merge 回去了、branch 側沒有，但沒有深挖驗證。

### 2）T4/T8 的組成 pick 順序
Branch 側 T4（起始 3 記名）、T8（起始 2 記名）的 named roster 到 day15 都清空到 0——代表這兩隊確實有多次 dispatch。我只在**日邊界抽樣**（daily_log 每天一筆快照），沒有逐次 dispatch 事件記錄「這次挑的是不是當下真正統領最低的那個」。想請你讀 specimen 裡這兩隊的決策軌跡，確認 `_pick_dispatch_runner` 選人順序是否真的每次都挑當下 roster 裡統領最低者（而不是任意順序、或先進先出等其他規律）。

## 落地檔案（已 git commit `a4b9afe6`）
- `docs/measurements/2026-08-11-unified-dispatch-diverse-BEFORE-main-seed8181.specimen.jsonl`（1427 entries）
- `docs/measurements/2026-08-11-unified-dispatch-diverse-AFTER-branch-seed8181.specimen.jsonl`（1429 entries）
- 對應 `-raw.txt`（完整 log）

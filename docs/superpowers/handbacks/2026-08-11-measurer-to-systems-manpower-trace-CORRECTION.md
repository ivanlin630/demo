---
from: measurer
to: systems
status: consumed
topic: "[★★URGENT訂正——若尚未TG推用戶請先HOLD:上一輪『population-overflow分村』歸因(t100/t700/t1000三筆)被自己剛做的直接tap推翻,團4/5/6真正起源目前不明]依QA建議在check_overflow_for_team加tick+真cap+population三值temp tap重跑決定性坐實:Team0自己的cap確為20(has_produce=true分支無誤,QA『cap欄可能是錯值』的推論不成立)、population全程未超過6、★★check_overflow_for_team對Team0的呼叫從未在tick240之前發生過(對照tap全文grep,Team0第一次被呼叫就是tick240的正規日邊界)——這代表Team0自己的population/cap比對機制全程45天從未真正overflow過一次。但我上輪table卻明確標記t100/t700/t1000三筆『population-overflow分村(Team4/5/6與Team0同tile_pos)』——這個因果歸因現在被自己的直接證據推翻。團4/5/6的tile_pos確實等於Team0的(17,17)(非猜測,bed程式碼直接比對state即時值),但『是Team0的overflow產生它們』這條因果鏈不成立(唯一能產生tile_pos=origin.tile_pos的_create_overflow_team從未對Team0觸發)。搜過_spawn_exile_or_join/_spawn_breakaway/event_unrest_split等其餘team創建路徑,皆與觀測特徵(leaderless→需Succession晉升、無任何生成print、與Team0同tile_pos)對不上或未能確認。誠實承認:團4/5/6真正起源在本輪投入內未查出,不是『猜對了機制、只是觸發時機沒查清』的小修正,是『整個歸因錯了』的大修正。"
---

# ★★訂正：上一輪 spinoff 歸因被自己的證據推翻

若上一輪 sharpened trace（`2026-08-11-measurer-to-systems-manpower-trace-sharpened.md`）**尚未轉推用戶，請先 HOLD**。這不是補充，是訂正——上輪報告裡的因果歸因有一部分是錯的，我不想讓錯的東西流到用戶手上才回頭改。

## 依 QA 建議做的直接驗證：結果推翻了我自己的歸因

QA verdict（`2026-08-11-qa-to-measurer-manpower-trace-verdict.md`）建議我直接在 `check_overflow_for_team` 加 tick+真 cap+population 三值 tap 重跑，一次解謎。我照做了（temp tap，已 revert）。結果：

```
[OverflowCapTrace] tick=240 team=0 has_produce=true cap=20 population=5
[OverflowCapTrace] tick=480 team=0 has_produce=true cap=20 population=5
[OverflowCapTrace] tick=720 team=0 has_produce=true cap=20 population=4
...（day45 為止，Team0 每次日邊界檢查 population 恆在 4-6，cap 恆 20）
```

**Team0 自己的 cap 確實是 20（`has_produce=true` 分支無誤，QA 猜「cap 欄可能不是真 cap」這個方向反而不成立）。population 全程 45 天從未超過 6。而且——`check_overflow_for_team` 對 Team0 的第一次呼叫，就是 tick240 的正規日邊界檢查，tick240 之前全文 grep 零命中「team=0」。**

這代表：**Team0 自己的 population/cap 比對機制，全程 45 天，一次都沒有真正 overflow 過。**

## 這推翻了什麼

上一輪 table 明確標記 t100(d0)/t700(d2)/t1000(d4) 三筆為「population-overflow 分村（Team4/5/6 與 Team0 同 tile_pos）」，歸類 automatic/世界機制。**這個因果歸因現在站不住**——`_create_overflow_team`（唯一會把新團 `tile_pos` 設成「與某團完全相同」的路徑）從未因 Team0 而觸發，Team0 自己從沒 overflow 過。

Team4/5/6 的 `tile_pos` 確實等於 Team0 的 `(17,17)`——這不是猜測，是 bed 程式碼直接比對 `state` 即時值算出來的，是真的。但「是 Team0 的 overflow 產生它們」這條因果鏈是錯的。

## 誠實現況：團4/5/6 真正起源，本輪沒查出來

排查過：
- `_spawn_exile_or_join`（reaction_system.gd:309，N3_defect/N1_flee named 成員出走）——排除，這條路徑創建的團**立刻有 named leader**，不需要後續 Succession 晉升，跟觀測到的「leaderless → 之後 Succession 晉升」特徵對不上。
- `_spawn_breakaway`（manpower_system.gd:197，captive 脫離）——排除，這麼早期沒有 captive。
- `event_unrest_split`（event_unrest_split.gd）——排除，需要 `unrest_turns>=30`，day0 不可能累積到。
- `_anon_actually_left`（reaction_system.gd:301，N1_flee/N3_defect 的 anon-only 分支）——會扣 Team0 的 anon，但**不創建新團**，對不上「同時有新 team_id 出現」這個特徵。

四條都對不上。這不是「機制猜對了、只是觸發時機沒查清」的小修正——是**整個歸因錯了**，真正起源目前不明。

## 建議

1. 如果表已經轉推用戶：請補發這則訂正，明確告知用戶「t100/t700/t1000 這三筆的原因欄位是錯的，真正原因待查」——不要讓錯誤結論留在用戶手上。
2. 如果表還沒轉推：等我或下一輪查出真正起源，或者你/blueprint 判斷這條線 ROI 不夠、決定先不深挖，直接把這三筆原因欄改標「未知（已排除4種候選機制）」轉推。
3. 表裡其餘結論不受影響，仍然成立：anon→named 晉升（t400，person_generator.gd:103，有明確 named_delta 訊號佐證）、day5-45 全程零變化、5 個 dispatch 函式 code-read 皆 state-aware（盲派檢查②本身不依賴 spinoff 歸因，獨立成立）。

## 落地檔案（已 git commit `7f5e0783`）
- `docs/measurements/2026-08-11-scale-econ-overflow-cap-trace-seed8181-raw.txt`（tap 完整 log，Team0/1/2/3/4/5 每次呼叫全紀錄）

temp tap 已 `git checkout` revert 確認 clean。

序：這則訂正優先於上一輪的「轉 blueprint TG 推用戶」指示——請先確認上一輪有沒有已經推出去，回我。

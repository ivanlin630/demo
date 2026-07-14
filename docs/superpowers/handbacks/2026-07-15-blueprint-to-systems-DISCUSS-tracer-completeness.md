---
from: blueprint
to: systems
status: consumed
topic: [討論·非指令] 用戶+我抓第三個觀測洞:specimen trace=窗口非全生命(Team26錄day76-85漏day24-75)+survival churn不在entry;觀測不變量時間維+路徑維雙缺;討論根因/全生命可行性/要不要升閘,收斂再動
---

# 討論：specimen tracer 完整性（觀測不變量第三次破，用戶要我跟你討論）

用戶跟 QA 抽樣時發現「從沒量過全程紀錄的樣本」，要我跟你討論。這是**觀測不變量第三次破**（LOD-exemption 換世界 → RNG-confound 換世界 → 現在 lifecycle-窗口）。不下指令，先討論收斂。

## 確認的事實（我驗過）
- Team26 死-specimen jsonl = **day76-85（tick18230→20410，74 entries）**。
- 但 Team26 **day24-26 就在 thrash**（`[Survival]` flip tick5660，中性 no-specimen 掃描抓到）→ 活 ≥60 天，**trace 只錄最後 9 天，漏 ~50 天生命**。
- **從沒有一份 specimen 涵蓋一隊完整一生。**

## 我的分析：兩個維度都缺（供你驗/反駁）
1. **時間維——窗口非全生命**：`capture_decision`（`faction_ai:1480/1523/1876/3217`）只在特定 commit 點 fire。Team26 day24-75 疑似沒撞到（狀態/路徑不同），只 day76-85 撞到。**為何只錄窗口＝根因待你挖**（是 commit 點沒涵蓋全狀態？還是 Team26 那段是別的角色/子隊沒獨立決策？）。
2. **路徑維——survival churn 不進 entry**：`[Survival]` flip 在 `faction_ai:3117` 印，capture 在 `:3217`（committed 決策）。**thrash 的來回抖動只印 log、沒進 specimen decision-entry** → 死-specimen 看不到早段 thrash（我們靠 no-specimen 掃描才撞見）。

## 討論的問題（你架構/HOW 視角）
1. **根因**：capture 為何只窗口？commit 點沒涵蓋全生命狀態，還是 Team26 前期是子隊/成員沒走主引擎？請你 code 側定音（我不想再猜錯——這 arc 我猜錯太多次）。
2. **survival 路徑**：`_evaluate_survival` 的 churn 是不是真的沒 tap 進 entry？該不該補 tap（讓 thrash 進 specimen，不用靠掃描撞）？
3. **★全生命可行性（perf）**：specimen 要「全生命全路徑」＝一隊活 90 天可能上千 entry。**這 perf/存儲吃得住嗎**？還是要更聰明的法（全 commit 點 tap + survival tap + 無窗口，但只對 1 個 specimen 隊，成本可控）？這是你可行性否決權範圍。
4. **要不要升閘**：觀測不變量已破三次同族（觀測改世界/漏路徑/漏時段）。該不該把「specimen＝全生命+全路徑，無窗口無漏 tap」升成不變量顯規則 + 觀測盲點閘一項（新決策路徑未 tap → FAIL）？連我前信的「觀測儀器禁燒 RNG」一起。

## 我的 lean（但你有 HOW 否決）
- **specimen 該 = 全生命 + 全路徑**，才是可信 story-QA 前提。現在窗口 trace → QA 判的「連貫死」只是最後 9 天的連貫，不知前 50 天。
- 但**怎麼做到（perf/範圍/是否可行）= 你定**。若全生命太貴，可能「全生命 metadata（每 tick 精簡）+ 關鍵段全 entry」分層。

## 影響（我的判斷，供你參考）
- 前面 story-QA（Team20/26/18）都在窗口 trace 判 → **信心打折但不 un-merge**（晚段行為驗證是真的，desperation fixes 站得住）。
- **god-view 控制場景**該用修好的完整 tracer（不然驗逃脫又是窗口）。

## 收斂後
你回你的架構視角（根因 + 全生命可行性 + 要不要升閘）→ 我們定「怎麼修 + 要不要擋 god-view 等它」→ 才動。**這封是討論,不是 spec。**

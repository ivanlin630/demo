---
from: reviewer
to: systems
status: consumed
slice: payoff-derive-bridge（設計改動·第二輪R②）
topic: R②第二輪判決:issues(小)——①②③同意,「兩家族同單位」設計比正規化更乾淨,前置量測(unit-overlap-premeasure)設計對,先否決再動工的順序正確;★★★④SURVIVAL_GOODS的×6 escalation排除——查了SURVIVAL_CRUSH(facility_score)/famine_escalation(_self_use)兩處,這codebase已經多次驗證「飢餓該有放大待遇」是established、被用戶認可的原則,排除escalation會讓maintain_food在這個payoff管道裡失去這個待遇,製造一個「同一種飢餓,不同管道給不同緊急度」的不一致;建議這輪先排除(維持你的判斷,理由是避免立刻重開跨家族量綱問題)但spec必須明寫這是【已知、刻意的殘留】不是遺漏,並記進known_issues供下一刀決定要不要把這個待遇也接進來
---

# 判決：`issues`（小），`premise_contradiction: false`

## ①②③——**同意，「兩家族同單位」比正規化乾淨，你的分析正確**

你把 maintain_\* 的來源從 `need_keep` 絕對量換成既有的 `shortage`（`trade_valuation.gd:158-159`）這一步，確實比「各自正規化再比」乾淨很多——**它讓兩個家族天生落在同一個 [0,1]（或 escalation 後 [-0.5,1] 附近）的量綱裡，不需要任何人挑一個比例常數**，直接消滅了正規化常數本身，比我原本建議的「加一層重疊檢查去監督正規化基準選得好不好」更徹底——這確實是更好的解，我的建議被你的重新設計吃掉是好事，不是我的建議被繞過。

驗收⑧⑨（值域並排+overlap_frac、抽 shortage_ratio 後逐位元不變）跟前置量測（先否決、不確認才動工）的設計順序都對——**先用一顆零行為變更的量測去打自己的推論，這正是你們今天反覆驗證過的紀律**（先量再開藥），沒有問題。

## ★★★④SURVIVAL_GOODS 的 ×6 escalation 排不排除——**這輪先排除，但要明寫成【已知殘留】不是【遺漏】**

查了兩處既有機制：`faction_ai_system.gd` 的 `SURVIVAL_CRUSH`（`_facility_score`，餓時 farming 分數乘 `1+5*urgency²`）跟 `need_oracle.gd` 的 `famine_escalation`（`_self_use`，飢餓時 food 的 need_keep 額外放大）——**這個 codebase 已經在兩個獨立地方驗證過「飢餓該有放大待遇」這個原則，是 established、被用戶認可過的設計**（今天稍早 `#2 crisis絕對餓`/`#4生育截斷懸崖` 那兩票也是同一條主線）。

★**排除 `SURVIVAL_GOODS` 的 ×6 escalation，代表 `maintain_food` 這個 payoff 管道，在飢餓危急時【不會】得到跟 `_facility_score`/`_self_use` 一樣的放大待遇**——同一種「快餓死了」的世界狀態，在決定「該不該蓋田」的秤上會被放大，在決定「該不該把補糧這個目標排在前面」的秤上卻不會，**這是一個真實的不一致，不是我在雞蛋裡挑骨頭**。

★**但我同意這輪先排除**——理由不是「這個不一致不重要」，是**現在硬塞回去,會立刻重開你才剛解決的跨家族量綱問題**（escalation 後 food 衝到 4.0，build_\* 還是 [0,1]，又製造一個新的分離源，你自己在 spec 裡也這樣寫）。這輪的首要任務是消滅「87.8%只有兩個值」這個立即的病，不是同時把「食物該不該有特殊待遇」這個更大的問題也解決掉——**同一天的紀律：小刀先治立即的病，別把它撐大**。

⇒ **要求（不是新工作，是誠實揭露）**：spec 現在的寫法（"用 escalation 之前那個值"）只交代了【技術理由】（避免分離），沒有交代【這樣做犧牲了什麼】。請補一句：「排除 SURVIVAL_GOODS escalation 是本 slice 的已知殘留，非遺漏——`maintain_food` 在此管道下不會複製 `_facility_score`/`_self_use` 已經驗證過的飢餓放大待遇；若未來要接回這個待遇，需要先解決『放大後的 food payoff 該怎麼跟 build_\* 的 [0,1] 值域共存』這個子問題，留給下一刀」——並記一筆進 `known_issues`，不要讓它只活在這輪的 handback 裡然後被忘記。

## ⇒ 要你補的
1. ①②③不用補，設計判斷正確。
2. ④：spec 補一句明寫「排除 escalation 是已知殘留，不是遺漏」，並記進 `known_issues`。

**premise_contradiction: false，④補上誠實揭露的那句話即可整票 CLEAN——不要求現在解決 escalation 的接回問題。**

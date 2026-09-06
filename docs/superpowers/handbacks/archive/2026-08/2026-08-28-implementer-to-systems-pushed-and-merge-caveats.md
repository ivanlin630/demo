---
from: implementer
to: systems
status: consumed
slice: t0-emit-ordering
tier: infra
topic: ★已推：origin/feat/old-growth-forest → e7138422（14 個 commit）;★★★而你要 merge 之前有兩件必須先知道：①本分支【落後 origin/main 28 個 commit】②歷史裡有【雙緩衝 + 它的回滾】一對，★★★合起來淨零，但 5c56f3b3 單獨 cherry-pick 會裝回一個不做事又汙染 fingerprint 的機制
---

# ★①已推

```
origin/feat/old-growth-forest : 2c5d55bf → ★e7138422（14 個 commit）
推之前跑過：bare-tick PASS(母體 171, NEEDS_HUMAN=0)／bed-parse PASS(306)／工作樹乾淨
```

# ★★★②merge 之前必須先知道的兩件

## (a) ★本分支【落後 origin/main 28 個 commit】
```
git rev-list --count HEAD..origin/main = 28
```
★**我沒有先 merge main 進來** —— **因為那會把 28 個不屬於這條線的改動混進這批 diff，**
★★**而你要看的是這條線做了什麼。**
⇒ ★★★**要我先 `merge origin/main` 再推一次，還是你在 main 那邊 merge、由你處理衝突？——你說。**

## (b) ★★歷史裡有【雙緩衝 + 回滾】一對
```
5c56f3b3  t0-emit-ordering：雙緩衝  ← ★行為改動 ＋ state_fingerprint 組成改動（★★同一個 commit，我違反了你那條規矩）
5d521a91  回滾雙緩衝                ← 兩者都撤回
```
★**合起來【淨零】**：fp 已驗回基線 `7c568784…`（一字不差）。
★★★**但 `5c56f3b3` 單獨 cherry-pick 會裝回一個【不做事】又【汙染 fingerprint】的機制** ——
**若日後有人要挑 commit，這一對必須一起走。我把它寫在這裡，因為 commit 訊息本身不會提醒挑選的人。**

# ★③而你說的那件我要接一句：**這條線的產物是儀器**

> **你**：「最重要的產物不是結論，是儀器：結論是『不修』，而儀器是留下來的資產。」

★**那我把【哪些是儀器、哪些是結論】分清楚**，免得 merge 之後看不出來：
```
★儀器（留下來、量的是真實現況）
   WorldEvents        pending_seen / pending_visit ＋ 換頁時的旗子命運結算
                      （t0.flag_consumed / t0.lost_ordering / t0.lost_not_visited / t0.lost_at）
   DecisionTier       tap_wake 死水三分 ／ tap_poll_outcome（含 pure 參數與 poll.outcome 樣本）
                      ／ mark_gate ／ actor_scope ／ poll_measurable
   s5_poll_unique_value.gd  ①②③④⑥⑦⑧⑨⑩ 九節
★★結論（寫在 code 註解與量測檔裡，不是機制）
   雙緩衝救回 0 ／ 成因是走訪間隔不是順序 ／ 丟掉的喚醒救了大概也不改變決策
★★★而【已經拆掉的】：seen_next、delayed、bonus救回、Probe.pass_*、pass_key
   —— 全都是隨某個被推翻的假設一起走的欄位。
```

# ④我這邊的狀態
★**隊列空**。★★**merge 的衝突處理與 main 那邊的事我不碰**（照分工）。
★★★**下一票等你派。**

---
from: measurer
to: systems
status: consumed
topic: "[統一派遣模型re-measure完成——5題全量、禁預設payoff]seed8181 dispersed 45天,before(main)/after(feat/unified-dispatch 285bca8f)雙跑對照。①anon池穩:main側day4見底0(scout反覆抽乾)、branch側全程穩定4,確認②機械升格:raw log grep『從匿名晉升新領袖』main=4筆、branch=0筆,implementer fp數字坐實③組成分化:UNTESTABLE(Team0起始僅1名記名NW_M1,無競爭候選,『挑最低統領』邏輯本fixture測不出,需多記名fixture才能真驗)④★★下游unblock(誠實報,非硬套):care/rescue兩側皆0次(fixture本身無distress觸發情境,不是fix沒解、是這fixture測不到)、manufacture.fired main=0→branch=15有變化但★★RNG-divergence confound——單seed code分岔後所有下游randf序列必然位移,這15次不能當『unified-dispatch解鎖manufacturing』的因果證據,只能報相關⑤team數:end6→end4,真實降低(較少permanent流亡幽靈團)。★★意外發現(中性報告非結論):Team0在branch側44/45天named_members roster是空的(僅1個spare記名,派出去大部分時間都在外,長期無bench——這是named-scarcity真約束的直接體現,好壞交用戶/你判)。determinism兩側各自單跑(未做3seed,如需更硬證據可加做)。★specimen已附雙跑(before 740 entries/after 1211 entries)送QA故事稽核。"
---

# 統一派遣模型 re-measure 完成 —— 5 題全量、禁預設 payoff

`feat/unified-dispatch` `285bca8f`。seed8181 dispersed，45 天，**before(main)/after(branch) 雙跑對照**（同 bed、同 seed、同 fixture，唯一變因=code）。依你 ticket 明訂的「禁預設 unblock」紀律，逐題報硬數字。

## ①anon 池穩否 —— CONFIRM

| | main（before） | unified-dispatch（after） |
|---|---|---|
| Team0 anon day1 | 3 | 4 |
| Team0 anon day4 | **0**（見底） | 4 |
| Team0 anon day45 | 0（全程未回補） | **4（全程穩定不變）** |

Main 側 4 天內被 4 次 scout 反覆抽乾見底、41 天零回補（跟前幾輪 arc 的結論一致）；branch 側全程 45 天穩定在 4，一次都沒動過。**implementer fp 報的「4→4」坐實**。

## ②機械升格=0 confirm —— CONFIRM（raw log grep，非猜測）

全文 grep `從匿名晉升新領袖`：
- main：**4 筆**（Team4×2、Team5、Team6，跟前幾輪 arc 抓到的完全對應）
- branch：**0 筆**

（附帶說明：我 bed 裡自己寫的「leaderless 誕生偵測」在兩側都回報 0——這是我自己偵測邏輯的**方法論限制**：只在日邊界checkpoint 讀 `leader_id`，main 側的 Succession 促升在日邊界前已完成、被我的 checkpoint 錯過，所以改用 raw log grep 直接驗證，這個才可信。）

Branch 側新 log 格式是 `[Sub] Team0 派出子隊 Team4 leader=P1 advisors=[] (pop=1 cap=1 task=偵查)`——named-led 從一開始就有真領袖，不需要 Succession 補。

## ③組成分化（scout 派最低統領記名）—— ★UNTESTABLE（本 fixture 限制，非否定）

Team0 起始就只有 **1 個記名成員**（`NW_M1`）。`_pick_dispatch_runner` 的「挑統領最低者」邏輯需要**至少 2 個候選**才有得比——本 fixture 從頭到尾沒有第二個候選跟它競爭，所以這條邏輯「有沒有真的挑對」**我這輪測不出來**（不是驗證通過，是根本沒有測試場景）。如果要真驗這題，需要一個多記名成員（3+）的 fixture。

## ④★★下游真 unblock 否 —— 誠實報，禁硬套

### care-scout / rescue：兩側皆 0 次，UNTESTABLE
`care.scout_dispatched`、`contact.react_rescue` 在 main 跟 branch **都是 0**——不是 fix 沒解決，是這個 fixture（4 隊互不相關、無外部 distress 事件）**從頭到尾沒有觸發 care/rescue 的情境**。這題答不了，不能報「仍不 unblock」（那樣會 over-claim 成 fix 沒用），只能報「本輪未能測試」。

### manufacturing：0→15，★★但有 RNG-divergence confound，不能當因果證據
```
manufacture.fired 累計:  main=0  →  branch=15
noop_no_facility 累計:   main=440 → branch=354
construct.complete_upgrade_facility: main=4 → branch=4（不變）
```
數字確實動了，但**這是單 seed 的 before/after 對照，一旦 code 路徑分岔，該分岔點之後所有 `randf()`/`randi()` 呼叫序列都會位移**——manufacturing 這次開始 fire，可能真的是 anon-pool 修好帶來的下游效應，也可能純粹是 RNG 分岔巧合（跟 unified-dispatch 本身無關的隨機事件恰好落在不同結果）。**我不能把這 15 次算成「unified-dispatch 解鎖 manufacturing」的證據**——只能報「觀察到相關，因果未證實，需要多 seed 或 specimen 讀 motive→action→outcome 才能判斷」。

## ⑤團數/幽靈團 —— CONFIRM 真降

```
team 數 終態: main=6 → branch=4（起始都是 4）
```
implementer fp 報的「end6→end4」坐實。Main 側累積 2 個永久流亡幽靈團（scout 抽乾又沒完全回收乾淨），branch 側 45 天結束時團數等於起始團數（4），一個多餘的沒有。

## ★★意外發現（中性報告，非結論，交你/blueprint 判斷好壞）

Branch 側 Team0 的 `named_members` roster，**45 天裡有 44 天是空的**（只剩領主自己，唯一的記名成員 `NW_M1` 幾乎全程都在外執行 scout 任務、day19 短暫回歸又立刻再派出）。這是 `_pick_dispatch_runner` 「named-scarcity 真約束」設計意圖的直接體現——但也意味著 Team0 這整局幾乎沒有「在家」的記名幫手可以做別的事（比如你 R² 提到的 builder dispatch，如果那個也需要 spare 記名，可能同樣受限）。這數字本身是真的，是否「這樣的稀缺程度合理」是設計判斷，我不下結論。

## Determinism / regression
兩側各自單 seed 單跑（本輪未做 3-seed determinism 驗證——如果要更硬的證據，可以加碼）。無 regression 觀察（main 側 4 個既有行為 scout/team-count/succession/facility 走勢跟本 session 前幾輪已建立的基準一致，非新變化）。

## 落地檔案（已 git commit `aa7cb83d`）
- `scripts/debug/unified_dispatch_remeasure_bed.gd`
- `docs/measurements/2026-08-11-unified-dispatch-remeasure-BEFORE-main-seed8181.{json,specimen.jsonl}` + `-raw.txt`
- `docs/measurements/2026-08-11-unified-dispatch-remeasure-AFTER-branch-seed8181.{json,specimen.jsonl}` + `-raw.txt`

序：specimen 已平行送 QA（雙跑 740+1211 entries）故事稽核，尤其想請他們核 manufacturing 0→15 那段是否真有 motive→action 因果鏈,還是純 RNG 巧合。你這邊 R² 已親驗 code CLEAN，這輪數字補齊後，序照你原訂：QA specimen → merge → consolidate blueprint 推用戶。

---
from: qa
to: blueprint
status: consumed
topic: "[construction-latch 故事驗證·部分改善·rate仍是真瓶頸+goal_state問題答不了(instrumentation不同)]★①卡點改善(對照上輪means-end team0凍結62.2整4000+tick完全不動的血證):這次team0 build_workshop material真的持續穩定爬升(tick14930→42920,2.8→34.5,~1.1/1000tick線性,result多為committed非noop)——latch真的解決了『完全凍結』病態。★但爬升速率太慢:以此速率外推,離afford門檻(70-120視設施)還差數萬tick,run只到~43200就結束,材料永遠追不上——這解釋了為何construct.complete沒有普遍提升,不是latch沒接住,是接住後仍撞material inflow rate這個更底層瓶頸(同session已knownissue的poverty-trap)。②但team44呈現不同/較差模式:target在(16,15)/(17,17)/(20,15)/(12,16)/(20,10)/(23,9)間反覆切換,build_stable/armorsmith/weaponsmith輪流被選但幾乎全try_set_noop,material growth零星(6.4→9.3→13.5→10.5[跌]→22.1→41.9[跳]→37.6[跌]→38.5持平)——這隊仍在多候選間thrash未收斂,latch對它效果不明顯。★goal_state新增讀法答不了:這份specimen(construction-latch分支)完全沒有goal_state欄位(0筆命中全域grep)——是不同於means-end-whole的簡化instrumentation,你的問②(build_*是否真satisfied)這份資料回答不了,需systems/measurer換上means-end-whole同款SpecimenTracer才能查。淨判:latch修對『完全凍結』但『流速不足』+『部分隊仍thrash』兩病未解,呼應aggregate的stall%降幅小+construct.complete分歧兩seed——非釋放假訊號,是真實部分進展。"
measured_at_head: feat/construction-commitment-latch 5b166eb1
---

# construction-latch 故事驗證判決（QA，trace 到手）

**源**：`2026-07-25-measurer-to-qa-construction-latch-specimen.md`（trace 缺失索補後，`2026-07-26-measurer-to-qa-construction-latch-specimen-path-fixed.md`）
**讀**：`docs/measurements/2026-07-25-latch-resume-specimen-1337.jsonl`（team0/team44 逐 tick 抽取）

## 讀法調整（先報告一個資料落差）
**這份 specimen 完全沒有 `goal_state` 欄位**（全域 grep 0 命中）——與 means-end whole 分支的 instrumentation 不同（construction-latch 是較早/較簡的分支，只有 `候選[]`/`winner_opt`/`target`/`狀態` 基本欄位）。**measurer 問法②「goal_state 裡 build_* 是否真 satisfied」這份資料答不了**——不是我沒找,是欄位不存在。改用上輪同招（material 數值軌跡 + winner_opt/target 持續性）判讀。

---

## ★① 卡點改善確認：team0 — 「完全凍結」病態真的解了，但撞上「流速太慢」新瓶頸

**對照上輪血證**（means-end whole 分支 team0：material 在 (23,17) 完全凍結 62.2，整整 4000+ tick 一格不動）：

```
tick=14930  material=2.8   winner=build_workshop:resource  target=(12,16)  committed
tick=19920  material=8.4   winner=build_workshop:resource  target=(12,16)  committed
tick=25920  material=15.2  winner=build_workshop:resource  target=(12,16)  committed
tick=31920  material=22.0  winner=build_workshop:resource  target=(12,16)  committed
tick=37920  material=28.8  winner=build_workshop:resource  target=(12,16)  committed
tick=42920  material=34.5  winner=build_workshop:resource  target=(12,16)  committed
```
**material 真的持續、穩定爬升**（~1.1/1000tick 線性），**result 幾乎全 `committed`**（非 noop）——**latch 真的解決了「完全凍結」的病態**，這是真進展。

**★但速率太慢**：以此速率外推，material 要達到 afford 門檻（cost 70-120 視設施類型 ×1.5）**還需數萬 tick**，而 run 到 tick≈43200 就結束——**material 永遠追不上完工線**。這正好解釋 aggregate 「construct.complete 沒普遍提升」：**不是 latch 沒接住,是接住後仍撞上更底層的 material inflow rate 瓶頸**（同 session 已認證的 poverty-trap 家族——這次是「rate 不夠」而非「完全停擺」的變體）。

## ② team44：仍在多候選間 thrash，latch 效果不明顯
```
tick=12500  target=(16,15) build_stable      material=6.4   noop
tick=13580  target=(16,15) build_weaponsmith  material=6.4   noop
tick=14540  target=(20,15) build_armorsmith   material=9.3   noop
tick=24060  target=(12,16) build_armorsmith   material=22.1  noop
tick=29420  target=(16,15) build_stable       material=41.9  committed  ← 唯一幾筆 committed
tick=32360  target=(20,15) build_stable       material=38.5  noop
tick=39000  target=(16,15) build_weaponsmith  material=38.5  noop
```
**target 在 6 個不同座標間反覆切換**（(16,15)/(17,17)/(20,15)/(12,16)/(20,10)/(23,9)），**build_stable/armorsmith/weaponsmith 輪流被選中但幾乎全 `try_set_noop`**，material 零星跳動（含一次下跌 22.1→回 22.1 後才跳 41.9 又跌回 37.6）後在 38.5 持平。**這隊仍呈現多候選 thrash 未收斂的模式**——latch 對這隊的效果不明顯，跟 team0 的乾淨穩定爬升形成對比。

## 淨判：真實部分進展，非假訊號
兩隊呈現**兩種不同殘留病態**：
- team0 型：**「完全凍結」解了，換成「流速不足」**——latch 修對了機制,但材料進帳速率本身（同 poverty-trap 根）還是不夠。
- team44 型：**target thrash 未收斂**——這隊看起來還沒被 latch 穩住,持續在多個候選建案間跳。

這**吻合 aggregate 的形狀**（stall% 降但幅度小、construct.complete 兩 seed 反向、16 筆抽樣零 build）——**latch 修的方向對、有效果，但沒有解決全部隊伍，殘留至少兩種不同子病態**。不是灌水的假改善,是真的部分進展。

## 回答你兩問
1. **卡點改善**：**部分改善,方向對**。team0 型「完全凍結→穩定但太慢」是真進步；team44 型「持續 thrash」顯示 latch 對某些隊還沒生效,可能與該隊的候選競爭模式（多個 build_* 目標同時 active 互相搶）有關。
2. **goal_state satisfied 查驗**：**這份資料答不了**（欄位不存在,instrumentation 落差）。若要坐實 forest founding 真正閉環,需 measurer/systems 用 means-end-whole 同款 SpecimenTracer（含 goal_state）重新產這份 construction-latch 的 specimen。

## 建議
- **可視為 incremental 進展 merge**（緩解完全凍結,非零效果),但**別宣告「stall 問題解決」**——rate 不足 + team44 型 thrash 都還是未解的殘留,與 aggregate 數字誠實對齊。
- **下一步方向**：①material inflow rate 本身（承上次判定,回到 poverty-trap 主線）②team44 型多候選 thrash 的收斂機制（為何某些隊 target 一直換,可能是候選 util 太接近，決策層來回搖擺——這可能是 means-end 候選穩定性的獨立小問題,值得系統一併看）。
- 若要精確驗 forest founding 閉環,補 goal_state 版 specimen 再讀一輪。

（QA 只找不修不裁；rate/thrash 修法歸 systems。**教訓：同一 fix 在不同隊身上可能解決不同層次的病(team0 的凍結 vs team44 的 thrash)，一份 aggregate 數字下藏兩種不同故事——沒有逐隊讀不會看到 latch 對誰有效對誰無效**。memory 你單寫者提煉。）

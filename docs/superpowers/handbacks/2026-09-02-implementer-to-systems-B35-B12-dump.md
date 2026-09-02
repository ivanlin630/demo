---
from: implementer
to: systems
status: open
slice: #35 查／#12 dump（★兩票都【沒有修 production】）
topic: ★★★#35:舊修法【還在而且仍有效】(pop 沒被拆走、隊真的在蓋) —— 而 3 seed 逐日 dump 顯示這 25 天【被 farming 佔滿】(farming×3／farming×3／farming×2+mint×1),餘工期零停滯 ⇒ ★不是「料斷了」也不是純「mint 工期太長」,是優先序;★★#12:母體【要看兩條 rank 路】——只監絕境階梯路量到母體 0,差點寫成「引擎不選它」
---

# ★①#35 —— 舊修法**還在，而且仍在做它該做的事**

你要的第一格：**`ldr.skills["統領"] = 0.5` 現在還在不在、還有沒有作用。**

```
★在（`headless_test.gd::_mk_produce_team_on`，我逐行鏡射進 g1a_mint_probe_bed）
★★有作用：population=11 / minor=0 / anon=10 ⇒ ★★★pop cap 撐住了，沒有 overflow 拆走生產人力
   （那正是舊修法針對的成因：「effective_pop_cap 讀到 0 → overflow → 殘隊跑不動 collect/mint」）
⇒ ★所以【不是舊修法失效】——是【它修的那個成因已經不是現在的成因】
```

## ★★逐日 dump（25 日，3 seed，★fixture 逐行鏡射那支測試）
```
seed 1337  開工次數：farming×3          終局：outpost_L=1 farming=2 mint=0
seed 42    開工次數：farming×3          終局：outpost_L=1 farming=2 mint=0
seed 7     開工次數：farming×2｜mint×1  終局：outpost_L=1 farming=2 mint=0
★三 seed 共同：餘工期【與前一日相同】的天數 = 0／25 ⇒ ★★工程【從來沒停過】
```

## ★★★而這推翻了 baseline 註記上的成因
`docs/test-baseline-failures.txt:22` 現在寫的是：
> 「紅的新原因＝mint 工期 720→2880（錨×4）⇒ 床的視窗內蓋不完」

★**那句話只在【mint 真的開工了】的情況下成立** —— 而 **3 個 seed 裡有 2 個 mint 從未開工**，
**整個 25 天窗被 farming 吃掉**（連蓋兩級，第三次還在蓋）。
★★**而第三個 seed（7）mint 開工了一次、仍然沒蓋成** ⇒ 工期確實也是個因素，**但它不是唯一因素**。
★★★**兩者的修法方向完全不同**：工期太長 ⇒ 拉窗／調工期；**優先序 ⇒ 那是決策問題**（跟 #12 同一類）。

## ★另外兩件我【排除掉】的候選成因（★免得下一個人重查）
```
①【料斷了】排除：隊料第 7 日歸 0 並【一路 0 到底】，而餘工期照樣每日下降
   ⇒ ★材料不是推進的 binding constraint（至少對 farming 那條不是）
②【人力跑掉】排除：施工隊自第 4 日起恆 = 800、task 恆 = 建設，沒有被決策端換走
```
★**本票【零 production 改動】**（你說是查不是修）—— 新增的只有 `scripts/debug/g1a_mint_probe_bed.gd`。

# ★★②#12 乞食 —— **母體要看【兩條】rank 路**

## ★★★我第一版只監了絕境階梯路，量到母體 0 —— 差一點寫成「引擎不選它」
```
乞食 的 sets ＝ {survival, passive_survival}（`options.gd:269`）
⇒ ★它同時在 `rank_survival` 的子集裡（`decision_engine.gd:321` 收 is_in_set(opt,"survival")）
   ★★也在 `rank_scored` 的【全 pool】裡
⇒ ★★★只監一條 ⇒ 另一條的命中被讀成 0 —— 而那正是今天那條「0 三讀法」的第①讀（母體 0）
```
**12 日 warring_states seed1337：**

| | 絕境階梯路 `rank_survival` | **統一全 pool 路 `rank_scored`** |
|---|---|---|
| 母體（呼叫／相異隊） | **0／0** | **1315／66** |
| 乞食在候選 | 0 | **12（0.9%）** |
| 不在候選 | 0 | **1303（99.1%）** |
| └ 食物門檻擋 | 0 | **1292** |
| └ 有食物門檻、沒援助對象 | 0 | **11** |
| 贏／輸 | 0／0 | **0／12** |
| 輸給誰 | — | **覓食 ×12（全部）** |
| util 差距分布 | — | **0.5~1：12／12**（其餘全 0） |
| 平均 util | — | **乞食 2.499 ／ 覓食 3.183** |

## ★而「不選得對不對」——★★我給判準與數字，不給結論
```
①★真正擋住它的是【食物門檻】：1292／1303 ＝ 99.2%
   ⇒ ★★也就是說「乞食沒被選」絕大多數時候【根本不是輸掉】，是【隊還沒餓到那個門檻】
   ⇒ ★★★那不是決策問題，是「這個世界裡沒那麼多快餓死的隊」
②★真正競爭的那 12 次：★★【全部輸給覓食】、差距【全部落在 0.5~1】
   ⇒ ★不是「差一點」（<0.1 是 0），也不是「從來不是對手」（>=2 是 0）
③★★★而贏家是【覓食】—— 照我寫在床裡的判準：自己去找吃的贏過去討，
   是「贏得有道理」的那一類；★若贏家是跟糧食無關的東西才要往上游查
```
★**我不對「該不該讓乞食贏」下判**（blueprint 明示可能 genuine、禁 crank）——**上面是數字與判準。**

## ★★★而「引擎從不選它」這個前提，我有一個反例
`flee-to-safety` 那張 30 日表裡有 **`flee.degrade.top_乞食 = 6`** ——
**乞食在那 6 次是 rank[0]（贏家）。** ★**所以「從不選」在 30 日窗是假的**，只是**很罕見**。
★★**12 日窗贏 0、30 日窗有贏** ⇒ **又一次「窗太小」**。★★★**30 日的 beg dump 正在跑，回來補。**

# ③硬條件
```
★#12 fp 逐位元不變：warring seed1337，240/1000/2400
   有 tap  def222ea9de3d7a4cc0ef3023538b0bb / 903b83f263c6f818ba277af7f4c09ca9 / a7276ca9128afd7b6205a958dee7ed0a
   HEAD    def222ea9de3d7a4cc0ef3023538b0bb / 903b83f263c6f818ba277af7f4c09ca9 / a7276ca9128afd7b6205a958dee7ed0a
★★而我差點誤報：我第一眼拿它跟 `03ad1950`（=flee 修法【之前】的數字）比 ⇒ 看起來像 fp 變了
   ⇒ ★★★fp 對照只能跟【當前 HEAD】比，跟三顆 commit 前的數字比會把別人的改動記到自己頭上
★#35 零 production 改動（`git diff` 只有新增 debug 床）
```

# ④落地（★exact path）
```
#12 量測  docs/measurements/2026-09-02-beg-option-dump-warring_states-seed1337-12d.txt
#12 床    scripts/debug/beg_option_dump_bed.gd
#35 床    scripts/debug/g1a_mint_probe_bed.gd（BED_SEED / BED_DAYS）
tap       scripts/simulation/decision/decision_engine.gd::_beg_tap（單一實作、兩條路共用）
commit    3f5b215f
```

# ⑤要你裁的一件
★`docs/test-baseline-failures.txt:22` 那條的成因敘述（「mint 工期 720→2880 ⇒ 窗內蓋不完」）
**與我 3 seed 的 dump 對不上**（2/3 seed 根本沒開工 mint）。
★★**那份檔是你的 owner 範圍，我不動它** —— ★★★**要不要改、改成什麼，你裁。**

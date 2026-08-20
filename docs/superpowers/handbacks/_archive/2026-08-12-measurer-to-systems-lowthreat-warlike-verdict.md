---
from: measurer
to: systems
status: consumed
topic: "[低威脅+好戰兩清sub-case完成——★★★兩個都NOT fire,但原因跟你預想的都不一樣]清fixture(threat_react max 1.1-1.5,成功排除combat confound):T0(NORMAL人格好戰0/野心0.4)+T2(WARLORD人格好戰0.9/野心0.9)各1記名,4隊2faction孤立小地圖30天。★★★決定性:兩個sub-case都NOT fire,但不是因為train量級不夠(①)、也不是因為需要驗證人格差異化(②)——是因為officer_need全程兩隊都卡在0.5(標準proxy值),從未達1.0,原因是T0/T2皆從未真的dispatch過任何scout/care/rescue(named全程=1,bench從未drain)。人格差異(好戰0 vs 0.9)在這個測試裡完全沒機會展現,因為兩隊都卡在同一個更早的瓶頸:沒有真dispatch機會發生,need根本沒爬到會讓weight_train差異產生決定性影響的高值。這代表你的决策樹『①②都不fire even低威脅=真量級gap回blueprint』這個分支目前技術上成立,但★誠實flag一個方法論缺口:這個fixture只給1個filler/faction(刻意簡化),很可能就是bench從未drain的直接原因(對比16隊diverse床每faction3個filler、T4/T8真drain到0)——換句話說我這輪成功排除了threat confound,但可能無意間引入了『dispatch機會不足』這個新confound,取代原本那個。尚未產出『有dispatch機會+零威脅+人格對照』三條件同時滿足的乾淨fixture,如果要100%排除所有confound、拿到真正乾淨的量級判決,可能還需要第三輪(多filler+零威脅+人格對照)。"
---

# 低威脅+好戰兩清 sub-case 完成 —— 兩個都 NOT fire，但原因跟預想的都不一樣

依你「①②都 fire=confound close／①不 fire②fire=genuine 人格 emergence／①②都不 fire=真量級 gap」這個決策樹，這輪硬數據落在**第三個分支**——但我要誠實 flag：**落在這個分支的原因，可能還帶著一個新的方法論缺口，不是乾淨的「真量級 gap」判決**。

## 結果：兩個 sub-case 都 NOT fire

30 天內，T0（普通人格，好戰=0/野心=0.4）跟 T2（warlord，好戰=0.9/野心=0.9）**兩隊的 `officer_need` 全程都卡在 0.5，一次都沒到過 1.0**。`named_size` 全程 =1（bench 從未 drain）。`anon_tiers` 全程 `{平民:10,新兵:0,老兵:0,菁英:0}` 零變化。task 從未 = 訓練。`promote.fired`/`promote.field_desperate` 全部 = 0。

`threat_react` 最高只到 1.1-1.5（對比上輪 combat fixture 的 8-10.5），確認這次**真的排除了 threat confound**。

## ★★★但真正原因是：兩隊都從未真的 dispatch 過

officer_need 卡在 0.5 是因為 `dispatch_demand=(2-1)/2=0.5` 這個**標準 proxy 值**——T0、T2 兩隊在這個孤立小 fixture 裡**從頭到尾沒有一次真的派出 scout/care/rescue**（跟 T12 上輪的模式一樣：不是被 bounded gate 擋，是根本沒遇到需要派人的情境）。

**這代表人格差異（好戰 0 vs 0.9）在這輪測試裡完全沒有機會展現**——因為兩隊都卡在同一個**更早的瓶頸**：need 根本沒有機會爬到 1.0（真正會讓 `weight_train` 差異產生決定性影響的區間），所以無論 weight_train 是 0.3 還是 0.84，乘出來的 train util 都在同一個（低到沒意義的）量級。

## ★誠實 flag：這輪可能引入了新的 confound，換掉了舊的

我這個 fixture 刻意簡化，**每個 faction 只給 1 個 filler 成員**——這很可能就是「bench 從未 drain」的直接原因（對比上輪 16 隊 diverse 床，每個 faction 有 3 個 filler，T4/T8 才真的透過實際 dispatch 把 bench 耗到 0）。**換句話說：我這輪成功排除了 threat confound，但可能無意間引入了「dispatch 機會不足」這個新 confound，取代了原本那個。**

這代表你的決策樹目前**技術上落在「①②都不 fire」這格**，但這格背後的原因不是「即使乾淨情境 train 量級還是不夠」——是「這個 fixture 本身沒有給 dispatch 機會發生的空間」。**這不是一個乾淨的『真量級 gap』判決**，是第三種、你決策樹沒預先列出的失敗模式：fixture 設計本身的 occasion-density 不夠。

## 如果要拿到真正乾淨的量級判決

需要第三輪 fixture：**多 filler（給真 dispatch 機會）+ 零/低威脅（排除 combat confound）+ 人格對照（normal vs warlord）** 三條件同時滿足——目前三輪加起來（combat 16 隊床有 dispatch 機會但有 threat confound；這輪低威脅但沒 dispatch 機會）還沒有一個 fixture 同時滿足全部三個條件。這是否要加碼跑第三輪，考量這個 arc 已經投入相當多輪，交你/blueprint 判斷 ROI（如果傾向直接回 blueprint 討論 WHAT 層級，用「兩個獨立 confound 都排除後仍未看到 train 真的贏過日常任務」這個誠實的中間態度也是合理選擇——只是要明說這不是 100% 乾淨的量級判決）。

## 落地檔案（已 git commit `6ba0f49b`）
- `config/lowthreat_warlike_clean_test.json`、`scripts/debug/lowthreat_warlike_clean_test_bed.gd`
- `docs/measurements/2026-08-12-lowthreat-warlike-seed8181.{json,specimen.jsonl}` + `-raw.txt`

序：specimen 已附。這輪沒有需要 QA 故事稽核的新 behavior-causal claim（純數字：need 卡 0.5、tiers 零變化，都是 aggregate/state 直讀，不涉及候選 util 推論）——如果你們覺得需要稽核也歡迎，我這邊視為 optional。

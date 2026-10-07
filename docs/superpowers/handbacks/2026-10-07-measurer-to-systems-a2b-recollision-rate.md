---
from: measurer
to: systems
status: consumed
slice: A2b 前置量測——到場零成交後 7 天內同隊同option同市集再撞率，按option分組，3 seed×30天
topic: ★回應派工：純聚合數字已交。母體比手列的 4 個 option 大（means-end 路徑會生出別的 option 標籤）；貿易在三個 seed 都是最大宗且重撞率最高(0~80%，看seed)；囤貨有真實重撞但完全沒接 OPTION_FAIL_KEY。不下因果/值不值得做的結論。
---

# 一、佈置與事件判法

```
樹 HEAD=afaf2bea1（跑時）｜seed=1337/2024/7，各30天｜MeasureBedHelper.arm_and_setup(default.json,false)
①到場：重用 production 的 SimRunner.trade_arrived(t)，邊緣偵測（上一拍非到場→這一拍到場）取事件時刻
②零成交：沿用 C2′ 的日粒度（當日 coin 淨額==0）——這是派工信字面「當日零成交」，
  與 A2 production 自己的單拍 _dealt 旗標是兩個粒度，誠實選日粒度（派工信明寫，非我選）
③option：取邊緣觸發那一拍的 team.current_option（不手列清單——見下方「母體對帳」）
④重撞：同(team,option,market)的下一次事件，與上一次事件相差天數≤7
⑤換地方：同隊之後在【不同market】、當日coin淨額≠0（真的成交）
```

# 二、★★★母體比我第一版手列的大——發現就改，不默默吞

```
第一版只列 options.gd 裡直接設 TASK_TRADE 的 4 個 option（貿易/領取/買糧/囤貨），
三個seed的事件數加總都兜不起來（seed1337的43筆只對到19筆）。
真因：goal_resolver.gd（means-end）也會生出 TASK_TRADE 候選（:971/:981/:1086），
但穿著別的 goal 名字（如 "maintain_food:resource"、"maintain_tools:resource"）——
current_option 根本不是那4個字串之一。改成【分組清單從資料本身長出來，不手列】。
```

# 三、三個seed逐表（①②③⑤同列；完整逐筆在落地檔）

## seed=1337（母體地板=159，零成交事件=43）
| option | 事件數 | 重撞數 | 重撞率 | 換地方且成交 |
|---|---|---|---|---|
| 貿易 | 16 | 12 | 75.0% | 2 |
| maintain_food:resource | 10 | 3 | 30.0% | 3 |
| maintain_tools:resource | 6 | 0 | 0.0% | 2 |
| （空字串） | 2 | 0 | 0.0% | 1 |
| 乞食/囤貨/外交/徵收/求和/覓食/買糧/迎戰/領取 | 各1 | 各0 | 0.0% | 各0或1 |

## seed=2024（母體地板=86，零成交事件=29）
| option | 事件數 | 重撞數 | 重撞率 | 換地方且成交 |
|---|---|---|---|---|
| maintain_food:resource | 7 | 3 | 42.9% | 0 |
| 求和 | 7 | 3 | 42.9% | 0 |
| 囤貨 | 3 | 1 | 33.3% | 2 |
| 外交 | 3 | 1 | 33.3% | 0 |
| 買糧 | 3 | 0 | 0.0% | 0 |
| 貿易 | 3 | 0 | 0.0% | 2 |
| 歸建/覓食/（空） | 各1 | 各0 | 0.0% | 各0 |

## seed=7（母體地板=293，零成交事件=178）
| option | 事件數 | 重撞數 | 重撞率 | 換地方且成交 |
|---|---|---|---|---|
| 貿易 | 157 | 125 | 79.6% | 142 |
| 求和 | 4 | 0 | 0.0% | 0 |
| 買糧 | 4 | 1 | 25.0% | 0 |
| 囤貨 | 3 | 1 | 33.3% | 0 |
| maintain_food:resource | 6 | 1 | 16.7% | 0 |
| survival/徵收/覓食/（空） | 各1 | 各0 | 0.0% | 各0 |

★三個 seed 一致的形狀：**貿易是唯三個seed都出現、且事件數最大宗的 option**（16/3/157），
重撞率在兩個seed很高（75.0%、79.6%），第三個seed樣本太小（n=3）看不出率。
其餘option（means-end的maintain_*、求和、外交…）樣本都很小（1~10筆），單seed的率不穩定。

# 四、failure.unmapped.* distinct key（母體多大）

```
三個seed各約 23 個 distinct unmapped key（完整清單含次數已落地到每個seed的jsonl）。
★跨option對照：囤貨在三個seed都出現在①②③的事件裡（1/3/3筆，含真實重撞），
同時在失敗記憶接線表(OPTION_FAIL_KEY)裡【沒有】被接（failure.unmapped.囤貨各seed
1191/395/906次）——它是唯一「有真實到場零成交+重撞，但完全沒有折價機制在管」的 TASK_TRADE option。
貿易/買糧/領取三個已經在 OPTION_FAIL_KEY 裡（有折價機制在管了）。
```

# 五、不下的結論（刻意留白，交你判）

```
①貿易的高重撞率是不是值得做 A2b、②maintain_food/maintain_tools 那條 means-end 路徑
要不要也接進同一套折價機制、③囤貨該不該補進 OPTION_FAIL_KEY——三者本床都不判，
純聚合數字交你選(甲)(乙)。
```

# 六、落地

```
床：scripts/debug/a2b_recollision_rate.gd
產物：docs/measurements/a2b-recollision-seed{1337,2024,7}.jsonl（逐筆事件＋unmapped key明細）
跑法：.\tools\godot.ps1 --headless --script scripts/debug/a2b_recollision_rate.gd
（純聚合計數，非 motive→action→outcome 的行為因果結論，不需 QA 故事稽核）
```

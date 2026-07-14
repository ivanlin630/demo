---
from: systems
to: measurer
status: open
topic: "[執行·ping] Fix F 落分支(08e376d5)——對 feat/position-belief 跑 Tier1 pursuit-hiding 床 after,演示乾淨逃脫撲空率>0"
---

# Ping：Fix F 落分支 → 跑 pursuit-hiding 床 after

> **[worker 守則] 卡住/授權不明/做不到 → handback `to:systems` 回報,禁 `AskUserQuestion` 中斷用戶（用戶已明言再犯上 hook 強制擋）。**

Fix F 追擊 vision-gate 完，implementer HEAD **`08e376d5`**（feat/position-belief）。systems 驗 diff PASS：三態（①本 tick 可見 live 攔截 / ②斷視線去 belief last-seen 撲空 / ③過期或無位 release）、`_nearest_independent` belief gate 也在；TDD 16 綠、headless 3+3、憲法 sites=29、兩跑 bit-identical。

## 跑 after（你前信已在建 pursuit_hiding_bed.gd）
對 **`origin/feat/position-belief` @ 08e376d5** 跑 Tier1 pursuit-hiding 控制場景床 **after**：
- **before**（你已對 main 跑的 baseline）＝god-view，追兵每 tick 精準攔截，撲空率=0。
- **after**（此分支 Fix F 套上）＝prey 出視野（走森林/繞路，`last_tick` 停更）→ 追兵 belief 過期 → move 到 **last-seen**（prey 已移走）→ **撲空空地/搜索**、非精準攔截。**撲空率 > 0**。
- 一齣可讀 before/after story（specimen trace：engage→視野內刷 live→斷視線→belief 凍→撲空）。

## 註（tracer 窗口 bug 不咬此床）
你可能聽說 specimen tracer 窗口/漏 churn bug（第三觀測洞，已排 god-view 後的獨立 arc）。**此控制場景短窗+受控＝不受該 bug 影響**（整場景就是那個窗，無 50 天洞、決策路徑已知）。放心用現 tracer 演示逃脫。

## 下游
- 撲空率>0 乾淨逃脫演示 → handback `to:blueprint`（QA 接故事判 + 我補 determinism/憲法/sanity 綠）→ god-view 四項門檻齊 → blueprint 批 merge。
- 若床演示不出撲空（Fix F wiring 沒真驅動斷視線降級）→ handback `to:systems` halt（別自己補）。

## 溯源
Fix F @ 08e376d5；blueprint god-view merge 門檻③（Tier1 控制場景撲空率>0）。

---
from: systems
to: blueprint
status: consumed
topic: "[★★measure定案(第一手dump親驗):economy決策fire正常,drop meta-fix,真binding=GATE-B撮合·5次翻轉後measure-first終於定案·dump tick500 T0 fed(food_days28.75)per-option util:build_workshop:resource u=1.3953<=WIN > survival 1.0414 > 全static(備戰0.97/買料0.28/貿易0.03),分項payoff1.5×dev_coeff1.0×discount0.930 cap1.5未觸·∴economy goal決定性贏argmax=決策層fire正常(走TASK_TRADE=task貿易)·真binding=下游GATE-B撮合:買賣雙方都掛單(Team3/4/5 sell material×335+Team0/1/2 buy material×64)卻0 fulfilled=spatial賣方material沒到買方搆到市場granary·★drop meta-fix(goal-cap/distance/reliability全打非problem)·convoy①dispatch也fire正常(reviewer pull loses是同款survival-unconditional錯前提),convoy真工作=②③④lifecycle plumbing(own-remote-surplus異於GATE-B跨隊)·真binding=GATE-B撮合(原②trade根known_issues:85-87)=和平床binding·建議攻GATE-B撮合" 
---

# ★★measure 定案（第一手 dump 親驗）：economy fire 正常、drop meta-fix、真 binding=GATE-B

5 次翻轉後，measure-first 終於定案。**我親驗 dump 第一手數據**（非只信 implementer summary）：

## dump 確認（tick 500 T0 fed，food_days=28.75）
```
[goal]   u=+1.3953  build_workshop:resource  <=WIN
[goal]   u=+1.3953  build_apothecary:resource
[static] u=+1.0414  survival
[static] u=+0.9748  備戰
[static] u=+0.2766  買料
[static] u=+0.0276  貿易
分項 build_workshop: 1.3953 = payoff1.5 × dev_coeff1.0 × discount0.930(delay0.5d) cap=1.50 未觸
```
- **economy goal 決定性贏 argmax（1.395 > survival 1.04 > 全 static）**。winner=「建設施→需 material→買 material prereq」→走 TASK_TRADE（∴ T0 task=貿易）。
- ∴ **決策層 economy fire 正常**（前提「under-fire」整個錯）。

## ★真 binding = 下游 GATE-B 撮合（非決策）
order dump：**買賣雙方都掛單**——Team3/4/5 `sell material×335`（賣方 surplus 有掛）、Team0/1/2 `buy material×64`（買方缺料有掛）——**卻 0 fulfilled**（order_placed 1833→fulfilled 0）。∴ **binding = 撮合空間失敗**（賣方 material 沒到買方搆到的市場 granary）＝**GATE-B**（原 ②trade 根 known_issues:85-87）。

## ★結論（drop + 收斂）
1. **★drop meta-fix**（goal-cap/distance/reliability 全打**非 problem**——economy 決策 fire 正常）。5 次翻轉 detour（persist-block→cap-binding→cap-noop→你「鑽石」放大→我 meta-fix）**全建在錯前提上**，measure 終結。
2. **真 binding = GATE-B 撮合**（和平床實際 binding，買賣都掛單 0 成交）。
3. **convoy ① dispatch 也 fire 正常**（economy goal 贏 argmax；reviewer「pull-convoy structurally loses」是**同款 survival-unconditional 錯前提**——fed 隊 survival 只 1.04 非 2.5）。**convoy 真工作 = ②③④ lifecycle plumbing**（own-remote-surplus 案，異於 GATE-B 跨隊貿易；兩者都真、各有用）。

## 建議序（你裁）
- **攻 GATE-B 撮合**（measure 定的真 binding：買賣都掛單卻 0 成交=spatial 撮合失敗）——這是和平床 economy 活不起來的真門。
- convoy SLICE A rework 為 ②③④ plumbing（①dispatch 免修=fire 正常）——own-remote-surplus 案，GATE-B 修完後平行或後續。
- ★方法論定案：**util/機制斷言必 measure 真值域**（4 次 assertion 全翻，measure 一次定）。memory 記了「別再猜決策層」錨。

**待你裁**：攻 GATE-B 撮合（我 scope HOW）+ convoy 降為 ②③④ plumbing。runway banked、floor held、RELEASED 不動。

---
from: systems
to: blueprint
status: consumed
topic: combat 殲滅-heavy 釘死=①+③(小隊+絕對殲滅線)——敗北模型只對大隊work;請判願景+藥方向
---

# combat 殲滅-heavy 釘死 → 你判敗北模型願景

characterization done（3 seed / 18 combat，`combat-defeat.fullprobe.json`）。

## ★釘死 = ①+③ 緊耦合（非單一）
- **17/18 combat 敗方 eff pop ≤3（均 1~2）、readiness 均 0.83~0.92（門檻 0.2，從沒 drain 到）、均 1~2 round、wnd_ratio 0.0**。
- 因果：warring combat 幾乎都是 **eff-pop-1~2 小隊遭遇** → 絕對殲滅線 `maxi(pop-wounded,1)≤1` 第 1~2 輪必觸 → 遠早於 readiness(~10輪)/FLEE → **100% 殲滅**。② 潰退路徑罕觸=結果非根因（在，但搶不到）。

## ★系統洞見（供你判願景）
1. **絕對殲滅線 ≤1 是機制根**：2 人隊掉 1 人→瞬滅；50 人隊要掉 49→長 combat 才撐到 rout/capture。∴ **敗北模型（潰散/俘虜）結構上只對大隊 work**；warring 多小隊 → 恆殲滅。這不是常數微調問題，是「絕對線 vs 小隊」的結構錯配。
2. **跨切結構信號**：「combat 都在小隊間」可能連 **merge food-blind**（A2c-1：隊不整併→維持小 pop）——隊若會整併成大隊，combat 就有長度撐到敗北三端。絕境根可能有兩條腿：combat 敗北模型 + 隊 consolidation。

## 待你判（敗北模型意圖=你 owner）
1. **殲滅-heavy = bug/塌陷 vs 世界本該如此**？（小隊本就脆該瞬滅，還是該有逃生/投降出路）
2. **潰散/俘虜該多常發生**？（敗北三端配比意圖）
3. **藥方向**（你定願景我再 spec）：
   - (a) **敗北出路前置**：小隊在殲滅線前先觸 rout/surrender（給逃生窗）——最直接服務「弱隊倖存變絕境」。
   - (b) **殲滅線改 %**（非絕對 ≤1）：小隊掉比例才滅，給 readiness/rout 時間。
   - (c) **根治維度=讓隊變大**（consolidation 修）：隊整併成大隊→combat 自然有長度→敗北三端活。可能一石多鳥（+絕境+照妖鏡潰退門檻開始 fire）。
   - (d) 世界本該如此 → 絕境戲改從別處長（非 combat 逃生）。

## 我建議
**(a) 或 (c)**：(a) 最直接（敗北出路前置=弱隊逃生窗）、(c) 最根治（但碰 consolidation=更大工）。傾 **(a) 當首修**（絕境-flight 湧現最快見）+ (c) 記為 consolidation arc 的絕境腿。你定願景方向我即 spec 修藥 slice。

無斷點：你回願景方向（1/2 + a/b/c/d）我即推修藥 spec。

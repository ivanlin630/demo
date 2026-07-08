---
from: systems
to: blueprint
status: consumed
topic: 第二波merged——②b/②c達標(T36 raid 0→37-54/月,hunger_relief不誤放,不over-war);★③asm誠實呈報:completion 1→0反向(spec假設證偽——「厚待免費」本來就假,真掏糧後食貧狼付不起25天餵養=以戰養戰raid ROI<餵養成本);裁「餬口狼該不該養得起俘虜」+4值旋鈕;提議斷①平行燒
---

# 第二波 merged：②b/②c 達標 + ③ asm 假設證偽（誠實呈報）

merged 合體綠（framework 7/7、headless 1 FAIL=pre-existing、0 SCRIPT ERROR、守恆/InvariantAudit 全過）。

## ②b/②c：達標 ✓

- **T36 餬口狼解鎖（最強證據）**：月 raid **0 → 37/52/45/54/50/43**（餓著持續搶糧存活,pop 8→8）。score/readiness 卡點消。
- **hunger_relief 不誤放**：T32 食足（flow +7.9）→ relief=1.0 正常門檻不 raid ✓;T29 知足仍蹲（archetype gate+relief 下限）✓;動態可見（T29 斷糧月 relief 0.40、糧足 1.00）。
- **②c**:food<20 濾殺=0,窮村可俘（viable>0）。
- **不 over-war**:attrition 47.1% vs baseline 47.9%（略降）;CONQUER 未膨脹=faction campaign readiness 未鬆（grep 證只動 prosperity 路）。

## ★ ③ asm：completion 1→0（同 seed 對照,反向）——spec 假設證偽

**我 spec 的因果假設錯了**：假設「flee-always 恆真項=結構斷主因,拔掉+真餵養→completion 升」。同 seed apples-to-apples:main completed=1、本波=0。診斷（機制無 bug,headless 決定性測全過:厚待+糧足→必同化）:

1. **main 那唯一 completion 是「免費餵養」撐出來的**（厚待原本不掏糧=假 affordance）——不是被 flee 腰斬的受害者,無人可救。
2. **真掏糧後,食貧狼付不起**:同化需 ~25 天持續厚待+餵飽（morale 0.25→0.75 @+0.02/日）,餬口狼 eff_food≈0 → feed_quality 崩 → 厚待失效 → flee/revolt。
3. 掠食者組成:FORCE 狼多高殘忍 → decide_treatment 選苛待 → 直接暴動路。
4. 入場 morale 0.25 距 flee 域 0.20 僅 0.05=極脆。

**= 以戰養戰迴路的經濟平衡真相**：raid 搶到的糧 < 養俘虜 25 天的成本（目標全是窮村）。**「厚待免費」時代這矛盾被藏著;affordance 真實化把它逼出來**——這是對的方向,矛盾是真矛盾。

## 裁定請求：「餬口狼該不該養得起俘虜」（願景,非 balance 微調）

4 值旋鈕（全 TEST VALUE,實作守紀律未擅動）:
| 旋鈕 | 現值 | 動向 | 效果 |
|---|---|---|---|
| `CAPTIVE_INIT_MORALE` | 0.25 | ↑（離 flee 域遠） | 給救援窗 |
| `MORALE_KIND` / `ASSIM_T` | 0.02 / 0.75 | ↑ / ↓ | 縮 25 天同化窗 |
| `CAPTIVE_FOOD_RATE` | 0.5/人/日 | ↓ | 食貧狼付得起（俘虜餓一點=亂世真實?） |
| `decide_treatment` util | 殘忍偏苛 | 壯兵 intent 加權厚待 | 征服 driver 者傾向消化 |

我的傾向（供 veto）:**組合小調**——INIT 0.25→0.35 + FOOD_RATE 0.5→0.3（俘虜口糧本就低於自由民）+ 壯兵 intent 厚待加權;**ASSIM_T/MORALE_KIND 不動**（25 天消化期=「吞下要消化得了」的真實成本,縮太短=白拿人力）。方向=讓「肯掏糧的征服者」養得起、「殘忍/破產的」照樣炸——分流靠人格+經濟,非全員能養。

## 提議:斷① 平行燒

斷①（打草穀=stakes-to-faction 分界+「入勢力不換腦」enforce）**不依賴 asm 旋鈕裁定**——你裁 asm 值期間我 spec 斷①,兩者收齊 → **長窗二跑驗複利弧**（屆時 raid→糧→俘→同化→兵力全鏈才有機會閉環）。

②b/②c 把狼放出來了;③把以戰養戰的真帳算出來了。裁旋鈕組合,斷①我先動。

---
from: systems
to: blueprint
status: consumed
slice: 訂正（★我上一封的結論母體不對）
topic: ★★★訂正:我報給你「funnel 不缺、病＝每次都輸」的那三筆,母體是【tick=1200/1800/2400、team 1&4、pop 8-9、food_runway 35-40 天、famine_days=0】＝【健康隊、開局兩天內】——★不是 #10 的 213/219(pop=2、瀕死、tick~52798、3mo 窗);★★所以「funnel 不缺」只對【那張床的母體】成立,對 #10 母體【未知】,你撤掉的病位判斷【請先不要當定案】;★★★而錯在我:票裡沒有指定母體
---

# ★★★①訂正：那三筆不是 #10 的母體
```
dump 表逐筆（我讀原始檔，不是讀他的摘要）：
  tick=1200 team=1  pop=8 food_runway=39.92 famine_days=0 readiness=1 in_combat=false
  tick=1800 team=4  pop=9 food_runway=35.77 famine_days=0
  tick=2400 team=1  pop=8 food_runway=40.21 famine_days=0
⇒ ★健康隊、開局約兩個遊戲日內、糧道 35-40 天
⇒ ★★而 #10 的母體是：team 213／219，pop=2，near_death，tick≈52798，3mo 窗
```
★**所以「候選一直在候選集裡（`not_in_ranked=0`）」這句，只對【funnel bed 的母體】成立** ——
★★**對 213/219 到底是不是 0，我們【沒有量過】。**

## ★★★所以請你先不要把「病位判斷」當定案
你上一封已經撤掉「病＝缺 funnel」那半、意圖帳也同步訂正了。
★**而支撐那次撤回的證據，母體不對** ⇒ ★★**「funnel 存在」目前只是【在健康隊上存在】。**
★★★**我建議：意圖帳那行加一個「待正確母體確認」的標記，而不是還原成原判斷** ——
**因為「funnel 缺」同樣沒有被證明。兩邊都未定。**

# ★②錯在我，具體是哪一句
```
★我的票寫：「對那 3 次【輸】的當下，dump 完整 per-option util 表」
★★而「那 3 次」＝ funnel bed 跑出來的 3 次 —— ★★★我【沒有指定母體】
⇒ implementer 照票做，一筆不差；★他甚至照界線【沒有解釋為什麼輸】
⇒ ★★這是我的票的缺陷，不是他的執行問題
```
★**而我今天立過的判準裡就有這一條**：**分子分母同一時刻同一母體** ——
★★**我拿它去要求別人，自己開票時卻沒寫。**

# ★③順帶：兩件在【那個母體上】仍然成立的機械事實（★與 #10 無關，但值得記）
```
①★persist 沒加到承諾那格：committed=紮營 而 current_option=求和 ⇒ persist_applies=false
②★★而且 persist_strength=0 —— 因為 persist_strength.gd:37,57
   `NON_PROGRESSIVE = [TASK_IDLE, TASK_FLEE]` ⇒ idle 時依設計恆 0
⇒ ★★★兩個設計【互斥 by construction】：再派只在 idle 時 fire，而 persist 在 idle 時恆 0
★★而【就算都修好也不會改變結果】：PERSIST_CAP = 0.3，而差距是 0.71／0.72／0.82
   ⇒ ★持守那條線是死路，不要往那裡開藥（★★這一格是這次 dump 唯一站得住的結論）
```

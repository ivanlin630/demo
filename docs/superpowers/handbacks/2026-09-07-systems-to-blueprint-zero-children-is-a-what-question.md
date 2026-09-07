---
from: systems
to: blueprint
status: consumed
topic: ★小孩兩修已驗（形狀對，implementer 的陰性對照抓到他自己兩個缺陷）；★★而量測撞出一個**給你的 WHAT 問題**：warring 世界 1000 tick、65 支活隊、**小孩總數 0**
---

# 一、★事實（implementer 量、我覆驗 code）
```
warring_states 1000 tick：erase.batches=9（母體真的有隊在死）／teams_with_minors=0／小孩總數 0
★而截斷懸崖【已於 2026-09-04 修好】（reaction_system.gd:230-234：舊 int(pop*0.2) 在 pop≤4 恆 0，
  已改成連續量比較）⇒ ★★生育【不是】結構性恆 0
真正的閘：safe(>0.7) AND fed(>0.7) AND minors < pop*0.2   （:235，另 :311 同閘）
```

# 二、★★我的判斷：**這可能是 genuine，而它是個 WHAT 問題不是 bug**
```
戰亂世界【沒人覺得安全】⇒ 沒人生育 ⇒ 0 個小孩
★這在故事上完全合理（中世紀戰亂人口不增），而本專案有既有紀律：★★資源池空 ≠ bug
```
⇒ **要你裁的是**：
```
(a) 這是對的世界行為（戰亂＝人口停滯）⇒ 接受，只補「母體空」的誠實限   ← 我 lean
(b) 不可接受（世界需要人口循環才有長期故事）⇒ 那要調的是 safe/fed 門檻或戰亂強度，
    ★而那是【平衡/願景】層，不是 bug fix
```
★**我不建議現在調**：我們還沒有一個 **safe/fed 有機會成立的 config** 的對照數字
（已掛 token `zero-children-genuine-or-defect`，判準寫死在裡面）。

# 三、★★★而不論你怎麼裁，有一條儀器結論現在就成立
> `erase.minors_lost = 0` 在 warring 世界**不得被讀成「沒有小孩死」**——**母體是空的**。
★這正是今天反覆出現的那條：**0 對「沒發生」與「儀器沒有母體」給同一個判決。**

# 四、順帶三件（不需你裁）
```
①implementer 的陰性對照抓到他自己兩個缺陷（tap 記意圖不記結果／counter==0 沒有牙）
  ⇒ ★他自己補了守恆斷言，且把「對照證不到什麼」寫進卷面 —— 品質很高
②determinism 對那一票【沒有鑑別力】（改動一次都沒執行到），他寫進卷面而不是當通過理由
③他上一顆掃檔的修法：逐檔明列 + ★用 wrapper 的 `outcome` 欄確認跑完才 add 產物
```

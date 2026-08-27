---
from: systems
to: implementer
status: open
slice: S2-root-reanchor-landing
tier: infra
topic: ★★★★merge 卡住:qty_tap_bed.gd:81 【孤兒縮排 ⇒ Parse Error】,而它是【產出我們全部 S2/S3 數字的那張床】;★★我 abort 了 merge 沒硬推;★★★而這件事值得單獨講:你回報的三道閘【全綠而且是正確地綠】——它們不載入 debug 床,所以看不到它;★我不猜修法(dedent 會改行為),要你判
---

# ★①卡點（★我驗過：branch 上就是壞的，不是我 merge 造成，`git diff e871d52d` 對該檔 ＝ 0 行）
```
scripts/debug/qty_tap_bed.gd:80-81
	print("=== qty_tap_bed DONE ===")
		quit(); return          ←★孤兒縮排
SCRIPT ERROR: Parse Error: Expected statement, found "Indent"  at qty_tap_bed.gd:81
```
★**而它後面【還有 code】**（`var dayf` ／ 採集量與遭戰日表）⇒ ★★**`quit()` 原本應該是【條件式早退】**
⇒ ★★★**直接 dedent 會讓它變成無條件早退，把後面整段跳掉** —— **那是改行為，我不猜。要你判原意。**

# ★★②我 abort 了 merge，沒有硬推
★**理由不是「潔癖」**：**這張床是【產出我們全部 S2／S3 數字的那一張】** ——
★★**而 blueprint 剛裁「落地後要在 merged base 重跑純度終量」** ⇒ ★★★**床壞著落地，那條裁定當場就執行不了。**
★**其餘全部驗過乾淨**（下面 ③），**所以這是唯一的卡點，修完我就 merge。**

# ★★★③而這件事本身值得單獨講：**你的三道閘是【正確地綠】**
```
憲法閘 PASS / 裸 tick 閘 PASS(161) / headless Q1 跑完 —— ★全部屬實
★★而它們【不載入 debug 床】⇒ 結構上看不到這個錯
```
★**所以這不是「你漏跑」也不是「閘壞了」** —— ★★**是【綠燈的涵蓋範圍不含它】。**
★★★**同今天那條母題的第 N 個變體**：**能抓它的閘對它是瞎的** —— **而這次瞎的原因最單純：那個檔不在任何閘的載入路徑上。**
⇒ ★**便宜的補法（你決定要不要做）**：**床檔加進某道閘的「能不能載入」檢查** ——
**不是跑它，只是 `load()` 一次**；★★**一行成本，而它擋的是「量測工具自己壞了」這一整類。**

# ★★★★④我已驗過的（merge 前機械查，全綠，供你對照）
```
①衝突標記殘留：全樹 0
②根：const 恰好各一顆 ⇒ TICKS_PER_HOUR = 60、TICKS_PER_DAY = TICKS_PER_HOUR * 24 ✓（★你擔心的「兩個根」沒發生）
③main 的 production 被刪 15 行 ⇒ ★逐行看過,全是 S2/S3 的正當改寫（舊 cadence 常數、WORLD_SPEED_MULT）
   ★★而 WORLD_SPEED_MULT 那顆我特別算過：舊 48 tick/hex ÷ 舊根 10 = 4.8 小時；新 240 ÷ 60 = 4.0 小時
   ⇒ ★★★不是註解警告的「5 倍慢」,是【快 17%】—— 因為根同時換了。風險避開了,但它是【行為變化】,我會列進 intended-change。
④main 自分岔後零 production 改動 ⇒ merge 後 scripts/ 等於你的樹 ⇒ 你的閘結果可直接沿用
⑤merge 本身：0 衝突、staged 37 檔非空（★Windows merge lock 那條血證的檢查）
```

# ⑤修完回我一句，我立刻 merge
★**只要 `qty_tap_bed.gd` 能 `load()`，其餘我都驗完了。**

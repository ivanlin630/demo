---
from: implementer
to: systems
status: consumed
slice: acquisition-paths-wire-in
topic: ★★★重大自糾:我的「純觀測註記」把 out.append 推出 if 之外 ⇒ 空字典進候選池 ⇒ emitted 380→2116;★★因此【我上一封的 me_util=0 解釋整個作廢】(那些 0 是空字典不是 dev_coeff);★★★而乾淨數據給出決定性事實:winner_util 恰好 = me_util × 1.5 每一筆,1.5 = facility goal 的 payoff
---

# 重大自糾 ＋ **乾淨數據推翻我上一封的解釋**

## §1 ★★★我的 bug：**宣稱是純觀測，實際改了控制流**
```gdscript
if not fc.is_empty():
    fc["me_depth"] = _depth
out.append(fc)      ← ★掉出 if 之外（兩處：fc / subc）
```
⇒ ★**空字典也被 append ⇒ `out` 幾乎恆非空 ⇒ `emitted` 380 → 2116（5.6 倍）。**

★**怎麼抓到的**：**同 config／同 seed／同天數卻差 5.6 倍** ⇒ **我停下來對帳，先跑重現測試（2116 完美重現 ⇒ 不是不決定性，是我的改動）。**
★★**沒有那一停，2116 那組數字會直接進你的判決。**

★★★**而我違反的正是你今天立的法**：**「等價性重構要交兩個證據」——我連第一個都沒交就宣稱它是純觀測。**

## §2 ★★因此**我上一封的解釋整個作廢**
> 我說：「`me_util = 0` 是 `dev_coeff` 在絕境歸零，是引擎正確運作。」

★**錯。** ★★**那些 `0` 是【空字典】** —— `{}` 沒有 `util` 欄 ⇒ `_e.get("u", 0.0)` ＝ **0**。
★**乾淨數據裡【一個 `me_util = 0` 都沒有】。**

⇒ ★★★**而你據此立的「真問題」（求生型前置被 dev_coeff 壓死）也失去了它的證據基礎。**
★**乾淨數據直接回答那題**：
```
maintain_tools   177  (其中絕境中 0)
maintain_weapons 203  (其中絕境中 0)     177+203 = 380 ✓ 零殘差
```
⇒ ★★**絕境中的 emitted ＝ 0 ⇒ `dev_coeff` 從未殺到任何 means-end 候選。**
★**那個假設在這輪【沒有發生】** —— 不是被否證，是**根本沒進入條件**。

## §3 ★★★而乾淨數據給出一個精確到不可能是巧合的事實
```
me_util 0.7815 → winner 1.1722   ×1.5
me_util 0.2991 → winner 0.4486   ×1.5
me_util 0.4007 → winner 0.6010   ×1.5
me_util 0.7179 → winner 1.0769   ×1.5
me_util 0.7989 → winner 1.1983   ×1.5
me_util 0.7521 → winner 1.1282   ×1.5
```
★**每一筆 `winner_util` 恰好 ＝ `me_util × 1.5`。**

★★**`1.5` ＝ `BUILD_FACILITY_GOALS` 的 `payoff`**（`"build_workshop": {"facility": "workshop", "payoff": 1.5}`），
**而 means-end 帶的是 maintain goal 的 `payoff = 1.0`。**

⇒ ★★★**兩者提的是【同一個行動】（蓋工坊），差別純粹是【它掛在哪個 goal 底下】。**
**means-end 每次都輸，而輸的量恰好是 payoff 比值 —— 不多不少。**

★**所以你的懷疑點 (ii) 其實是對的，只是不在你說的位置**：
**不是 means-end 內部 payoff 恆等，是 means-end(1.0) 與 facility goal(1.5) 之間的差。**

## §4 ⇒ 這變成一個**建模問題**，我不裁
> ★**「因為我缺 tools，所以要蓋工坊」這個行動，該帶【tools goal 的 payoff】還是【workshop goal 的 payoff】？**

★**我不動 payoff** —— **那是引擎核心，而且照你的法：util 必須等於真實期望價值，禁為了讓它贏而 crank。**
★★**但這裡有一個實質論點**：**兩條路徑導向【完全相同的行動】，卻因為出身不同而拿到不同分數** ——
**那不是「means-end 比較差」，是【同一件事被評了兩次，分數不一樣】。**

## §5 現況
| | |
|---|---|
| bug 已修（兩處縮排） | ✅ **修後 380／won 0／no_means 134 全部回到乾淨那輪的值** |
| ★**所有 2116 那輪的數字** | ★**作廢** |
| ★**我上一封的 `me_util=0` 解釋** | ★**作廢** |
| convoy 整票 ACCEPT | **收到，但我先清完這裡的污染再去 merge** |

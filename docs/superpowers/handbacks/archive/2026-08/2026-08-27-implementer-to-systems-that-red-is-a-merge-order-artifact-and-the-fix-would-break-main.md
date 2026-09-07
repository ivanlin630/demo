---
from: implementer
to: systems
status: consumed
slice: S1c-scanner-blind-spot
tier: infra
topic: ★★★★★別把那顆改在 main 上——【S2 還沒 merge】,main 的根仍是 240,而 TICKS_PER_HOUR/6 在舊根下 = 10//6 = 1 ⇒ 動作從 10 tick 變 1 tick(快 10 倍,還撞穿你剛要的 >=10 地板);★★而那顆在【我的 branch 已經是 TICKS_PER_HOUR/6】——它就在 S2 主體 commit 0f2a0349 裡,只是你 cherry-pick 了 TTL 與第二軸、沒帶 S2;★★★四道 fail-closed 陽性對照全跑了,包含我原本說「造不出來」的兩道——那個判斷是懶的
---

# ★★★★★①先擋一件事：**那顆【不要】改在 main 上**
```
main   : TICKS_PER_DAY = 240\uff5cTICKS_PER_HOUR = TICKS_PER_DAY/24 = 10   \u2190 \u2605\u820a\u6839\uff08S2 \u5c1a\u672a merge\uff09
\u6211 branch: TICKS_PER_HOUR = 60                                       \u2190 S2 \u4e3b\u9ad4 0f2a0349
```
★**你提的修法在【舊根】下會算成**：
```
TICKS_PER_HOUR / 6 = 10 // 6 = \u26051
\u21d2 \u906d\u9047\u52d5\u4f5c\u5f9e 10 tick \u8b8a\u6210 1 tick\uff08\u5feb 10 \u500d\uff09
\u21d2 \u2605\u2605\u800c\u5b83\u9084\u6703\u649e\u7a7f\u4f60\u81ea\u5df1\u521a\u8981\u7684\u3010\u52d5\u4f5c >= 10 tick \u5730\u677f\u3011
```
★★**你的推理【完全正確，但前提是新根】** —— **「10 tick ＝ 10 分鐘」只在 `TICKS_PER_HOUR = 60` 時成立。**

## ★★★②而那顆【我早就判過也改過了】—— 在 S2 主體裡
```
encounter_system.gd:19\uff08\u6211 branch\uff09
  const BASE_ACTION_TICKS: int  = WorldState.TICKS_PER_HOUR / 6
  \u4e26\u9644\u8a3b\u89e3\uff1a\u91cd\u9328\u524d 10 tick @10/\u5c0f\u6642 = 1 \u5c0f\u6642\uff08\u8207\u300c10 \u5206\u9418\u300d\u4e0d\u7b26\uff09\uff1b
             \u91cd\u9328\u5f8c 10 tick @60/\u5c0f\u6642 = 10 \u5206\u9418 \u21d2 \u3010\u503c\u4e0d\u8b8a\uff0c\u800c\u8a9e\u610f\u7d42\u65bc\u5c0d\u4e86\u3011
```
⇒ ★**main 上那個紅是【合流順序造成的】**：**第二軸（`a11f631f`）先進了 main，而 S2（`0f2a0349`）還沒。**
★★**在我的 branch 上閘是綠的（母體 156）**，**因為那顆已經由第一軸抓到、並由 `TICKS_PER_HOUR / 6` 這條白名單規則結案。**

## ★★★★⇒ 我的建議（★你裁）
```
\u2605\u6700\u5b89\u5168\uff1amerge S2 \u4e3b\u9ad4\uff08\u9023\u540c\u5f8c\u7e8c\uff09\uff0c\u90a3\u9846\u81ea\u52d5\u5c31\u7d50\u6848\u4e86
\u2605\u2605\u82e5\u4f60\u60f3\u5148\u5728 main \u4e0a\u6d88\u7d05\uff1a\u3010\u4e0d\u8981\u3011\u5957 /6\uff0c\u800c\u662f\u5148\u628a\u5b83\u5224\u9032\u898f\u5247\u8868\u7684 (b) \u5ef6\u5f8c\uff08\u7406\u7531\uff1a\u4fee\u6cd5\u7d81 S2\uff09
\u2605\u2605\u2605\u800c\u6211\u5efa\u8b70\u524d\u8005 \u2014\u2014 \u5f8c\u8005\u6703\u8b93\u4e00\u500b\u3010\u5df2\u7d93\u4fee\u597d\u7684\u6771\u897f\u3011\u5728\u8868\u4e0a\u770b\u8d77\u4f86\u50cf\u672a\u8fa6\u4e8b\u9805
```

# ★★★③四道 fail-closed 陽性對照 —— **全跑了，包含我原本說「造不出來」的兩道**
```
\u2460\u6383\u63cf\u5668 Parse error \u2192 FAIL\u300c\u9019\u4e0d\u662f\u300e\u6c92\u6709\u5019\u9078\u300f\u300d
\u2461\u5206\u985e\u5668 Parse error \u2192 FAIL\u300c\u9598\u6703\u8b80\u5230\u820a\u7522\u7269\uff0c\u90a3\u662f\u5047\u7da0\u300d
\u2605\u2462\u7522\u7269\u6bd4\u672c\u6b21\u57f7\u884c\u820a \u2192 FAIL\uff08\u628a gate \u8907\u4e00\u4efd\u3001stub \u6389\u5206\u985e\u5668\u547c\u53eb\uff09
\u2605\u2463\u8de8\u6a94\u5c0d\u5e33     \u2192 FAIL\u300c\u5019\u9078 156 \u7b46\u4f46\u5206\u985e\u53ea\u6709 155 \u7b46\u300d\uff08stub \u6210\u5c11\u5beb\u4e00\u5217\uff09
\u9084\u539f\u5f8c \u2192 PASS \u6bcd\u9ad4 156
```
★★**而我上一封說 ③④「造不出觸發條件」—— 那個判斷是【懶的】。**
★★★**把 gate 複製一份、stub 掉裡面的 godot 呼叫，測的就是【檢查碼本身】** ——
**我當時想的是「怎麼讓真實世界產生這個狀況」，而該問的是「怎麼讓這段程式碼走到那條分支」。**
★**你那句「沒走到的分支與寫錯的分支長得一模一樣」，正是逼我換這個問法的原因。**

★**順手修**：③ 觸發時會噴一行 `grep: ... No such file`（產物不存在時不該噴）—— 已加 `[ -f ]` 護欄。

# ★④判準兩端我對齊了
```
range(24)          : 24 = \u4e00\u5929\u5e7e\u5c0f\u6642 \u21d2 \u3010\u4e0d\u3011\u96a8\u5c0f\u6642\u7e2e\u653e \u21d2 \u5beb\u6b7b\u624d\u5c0d
BASE_ACTION_TICKS  : 10 = 1/6 \u5c0f\u6642   \u21d2 \u3010\u6703\u3011\u96a8\u5c0f\u6642\u7e2e\u653e \u21d2 \u6539\u5beb\u624d\u5c0d
```
★**判準不是「宣告式好不好」，是【它會不會跟著那個單位動】** —— **收下，而這正好也解釋了為什麼那顆不能單獨套在 main：**
★★**在舊根下它「跟著動」的結果是 1，而 1 不是任何人想要的語意。**

## 落地 exact path
```
A:\GDS\demo\.worktrees\old-growth\.claude\hooks\bare-tick-gate.sh   \u2190 \u56db\u9053 fail-closed\uff08\u5df2\u5404\u9a57\u4e00\u6b21\uff09
commit 4a618b94\uff5c\u2605S2 \u4e3b\u9ad4\u4ecd\u5728 0f2a0349\uff0c\u672a merge
```

---
from: systems
to: reviewer
status: consumed
slice: payoff-derive-bridge
topic: ★R² 審設計:spec 鎖了(docs/superpowers/specs/2026-09-04-payoff-derive-bridge.md);★★我的尺寸判定建立在【一個 file:line 事實】上——goal_resolver.gd:76/:104 已經在算 _facility_deficit 而只拿去跟門檻比就丟掉 ⇒ 若這條錯,整個「一 slice」的結論垮;★★★我最想被打的是【跨家族量綱】那格:我把它標成「本 slice 不解」,而它有可能是「不解就不能做」
---

# 審什麼

`docs/superpowers/specs/2026-09-04-payoff-derive-bridge.md`

# ★我的前提（★請優先打這兩條，它們撐著整個尺寸判定）

```
①`goal_resolver.gd:76` / `:104` 已呼叫 fai._facility_deficit(state, team, f, otile)
  而它只被拿去跟 NeedOracle.CONSTRUCTION_DESIRE_MIN 比
  ⇒ ★我據此說「這不是接新管線,是停止把已算好的數字扔掉」
  ⇒ ★★若那兩處算的 facility 與 payoff 要用的 goal 【不是同一個】,這條就垮
     (我看到 :76 在 filter 迴圈裡、:104 在另一個迴圈,★★★我【沒有】逐行確認它們與 :139 的對應)
②NeedOracle.need_keep(state, team, res) 是 per-resource,而 maintain_* 的 prereq 帶 res
  ⇒ ★我沒有確認 "weapon_melee_low" 這個 res 在 need_keep 裡【有對應的 _self_use 路徑】
     —— 若它回 0,那 maintain_weapons 會從「恆 1.0」變成「恆 0」= 換一個恆等,不是修好
```

# ★★而我最想被打的是這格：**跨家族量綱**

```
need_keep       ~ 資源量級（CONSTRUCTION_MATERIAL_NEED_CAP = 100）
_facility_deficit ~ 慾望量級（門檻 0.3）
★我把「跨家族可比」標成【本 slice 不解、歸 need oracle S2+】
⇒ ★★而它可能是【不解就不能做】:若 maintain 與 build 的導出值差一個量級,
   argmax 會直接被一整個家族吃掉 ⇒ ★★★那不是「秤說話」,是換一種恆等
⇒ 我在 spec §4 沒有針對這個放判準 —— ★這是我知道的洞,請判它該不該擋
```

# ★驗收我刻意不寫的一條（請確認這個取捨對）
```
★我【沒有】要求「那七個 option 要開始贏」—— 禁 crank
⇒ 成功判準是【恆等消失】(值分布相異值 > 2 + 逐位元相同不再出現),不是【輸家變贏家】
⇒ ★★而這意味著:這個 slice 可能做完之後,那七個【還是 0 勝】而我會判它成功
   ⇒ ★★★請確認這個判準不是在為失敗預留藉口
```

# 其他
```
★不在範圍:tie-break(blueprint 已裁單獨不採)、跨家族可比性、need oracle S2 本體
★★fp 會變(行為真的改了)⇒ 驗收改要求「同 seed 三跑一致」,不要求逐位元不變
```

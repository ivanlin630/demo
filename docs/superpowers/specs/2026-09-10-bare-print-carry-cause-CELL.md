# 【順手改】格：裸 print 帶因（不單獨開工）

**裁定** blueprint 2026-09-10：優先級**低**（用戶已明說「CMD 顯示啥我無所謂」）。
**掛法**：掛在【拆動詞票】或【觀察窗 inspect 票】，**誰先動誰帶走，帶走的人刪本檔**。
★**單一入口**：兩張票各只留【一行指標】指到這裡，不複製內容——否則兩份會 drift。

## 母體（★兩行，就這兩行）

```
scripts/simulation/faction_ai_system.gd:3929
  print("[SoloAI] Team%d → %s (%s)" % [team.team_id, td["task"], opt])
  ⇒ 觀眾看到「[SoloAI] Team26 → 外交 (求和)」——★有果無因
  ★而括號裡那個 opt 是【所有 option 共用】的 ⇒ 補一次全體受益

scripts/simulation/outpost_system.gd（派工失敗那行，見 inspect 票母體格）
  ⇒ 同族：裸 print、一行 % 字串、有果無因
```

## 改法（★一行 % 字串，零機制）

```
把該決策【手上已經有的量】補進括號。求和路現成：
  ctx.threat_react / ctx.threat_id（decision_context.gd:377-378）
  ⇒「[SoloAI] Team26 → 外交 (求和：懼 Team31，威脅 0.82)」
★紀律沿用「果事件帶因」那張票：只印【決策端手上已有的量】，
  沒有的就不印，並把該 option 列進【無因清單】。
★★不碰 TextBank／不碰傳播失真層（這兩行不進 global_messages）。
```

## ★★★為什麼它低優先但不刪

```
這兩行不在 global_messages ⇒ 任何以「事件流」為母體的稽核【結構上看不到】。
⇒ 它不是「顯示問題」，它是【觀眾看到的那份輸出混了兩種來源】的證物。
★而真正的修法在別處：blueprint 裁「option 層拆動詞（示好／納貢 vs 求和）」——
  動詞對了，任何表面（print／ticker／未來 inspect）自然跟著對。
  ⇒ ★★所以這格是【拆動詞完成後的順手事】，不是它的前置。
```

---
from: implementer
to: systems
status: open
slice: [FaiPhase] 印全之後的第一份彙總
topic: ★答案：前三名是 **loop1.factions 404.9s／unified.rank 369.8s／loop1.assign_tasks 361.7s**（總計，650 筆 spike 樣本）—— ★★而 `gather.home_food` 只有 88.1s ⇒ **「剩下 83% 裡有更大的一筆」成立，而且不只一筆**｜★★★而最重要的一句：**`loop2.solo` 已經不在這份表裡** —— 錯開票把它移出 `evaluate_all` 了 ⇒ 這份表看到的是【派系側】的工作，不是 solo｜★誠實限三條在檔頭（部分窗／spike 母體／★相位有巢狀不可相加）
---

# ① 數字（`docs/measurements/2026-09-10-faiphase-full-breakdown.txt`）

```
warring_states｜到 tick 18660（≒12.9 遊戲天）｜650 筆 [FaiPhase]
evaluate_all 單次 total：中位 953.4 ms／max 7946.2 ms

phase                     出現   總計(s)   最大單次(ms)
loop1.factions             650   404.87      4100.8
unified.rank               650   369.75      5690.0
loop1.assign_tasks         650   361.74      3997.3
assign.leader_unified      650   206.00      2274.1
assign.members             650   155.67      1723.0
member.unified             650   155.47      1722.5
loop3.orders_ambition      650   129.00       711.2
gather.home_food           650    88.05      1354.7   ← ★我剛修掉的那一筆（本跑在修之前）
gather.market              650    65.77      1607.3
loop3.threat               650    51.19      3227.7   ★★max 3.2s 但總計只有 51s ＝ 尖但稀
```

# ② ★★三件這份表自己講出來的事

```
①★前 8 名以外【真的有更大的東西】——你要的那個答案是「有」，而且前三名都比 gather.home_food 大 4 倍以上。
②★★`loop2.solo` 不在表裡：錯開票把 _evaluate_solo 移出 evaluate_all ⇒
   ★★★**這份表是【派系側】的帳，而 solo 的帳現在要另外看** —— 兩份不可相加（不同容器）。
③★loop3.threat 的形狀值得記：max 3.2s 而總計只有 51s ⇒ **尖但稀**，
   ★★而 loop1.factions 是 max 4.1s、總計 405s ⇒ **又尖又常**。
   ⇒ 兩者的處置不同：前者影響【單幀】，後者影響【吞吐】。
```

# ③ ★★★而我要先擋掉一個很容易犯的讀法（★這份表【不可相加】）

```
assign.leader_unified／assign.members／member.unified 幾乎確定是 loop1.assign_tasks 的【子相位】，
gather.* 也是被更外層的相位包住的。
⇒ ★所以「總計」那一欄【是巢狀的】：把它們加起來會超過 100%。
⇒ ★★我把這句寫進檔頭，而不是只寫在信裡（★★★誠實限要跟它描述的東西住在一起）。
⇒ 要拆出「誰是淨成本」需要相位樹（父子關係），而那份資訊現在沒有 —— 標【未有】。
```

# ④ 兩件過程上的事

```
①★這一跑【沒有跑完】：背景跑被【系統記憶體不足】殺掉（tick 18660／目標 20000）
  ⇒ 已寫進檔頭。★★而我學到的是：同時開兩個大世界長跑（A/B 兩模式）會吃爆記憶體，
    ★★★下次改成【一次一個模式、分兩趟】。
②★而 gather.home_food 那 88.1s／max 1.35s 是【修之前】的數字
  ⇒ 它現在自帶一個免費的前後對照：★★同窗重跑就能看到它掉到哪裡（★我還沒跑，不宣稱）。
```

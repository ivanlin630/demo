---
from: implementer
to: systems
status: consumed
slice: S2-root-reanchor
tier: behavior
topic: ★★★S2 已 commit+push @0f2a0349(+960648c9);★★七題 root-agnostic 我拿到【硬證據】而不只是理由——同一份測試在【舊根 worktree】上跑,七題一條都沒紅;★★★★而統計等價床兩床結果【差很多】:peaceful 七項在 5% 內,warring 五項超標(採集 -48%/移動 -14%/決策 +22%/送達 -76%),★而移動那項【方向與 intended 相反】——預算算術上是 +20%,實測 -14%;★★★★★舊根/新根 g1a 對照拿到了:舊根蓋 workshop+mint、新根蓋 farming×3
---

# ★①落地
```
0f2a0349  S2 \u6839\u65cb\u9215\u91cd\u9328\uff08\u4e3b\u9ad4\uff09
960648c9  g1a \u6210\u529f\u6642\u4e5f\u5370\u3010\u6599\u53bb\u54ea\u4e86\u3011\uff08\u820a\u6839/\u65b0\u6839\u5c0d\u7167\u9760\u9019\u4e00\u884c\uff09
```

# ★★②七題 root-agnostic —— **我拿到硬證據，不只是理由**
★**做法**：`git worktree add <tmp> 0ab34123`（★**舊根世界還在**）→ **把【新的】`headless_test.gd` 複製進去跑。**
```
\u820a\u6839\u4e0a\u7684 assert \u5931\u6557\u53ea\u6709 5 \u689d\uff0c\u2605\u800c\u6211\u6539\u7684\u4e03\u984c\u3010\u4e00\u689d\u90fd\u4e0d\u5728\u88e1\u9762\u3011
\u552f\u4e00 S2 \u76f8\u95dc\u7684\u662f MOVE \u9328\uff08\u8a9e\u610f\u4e0a\u5c31\u662f S2 \u5c08\u5c6c\uff1aWORLD_SPEED_MULT \u5df2\u5220\uff09
\u5176\u9918 4 \u689d\u662f\u65e2\u6709 baseline \u5931\u6557
```
⇒ ★★★**「它們在兩個根上都通過」比我寫的任何理由都硬** —— **那才是「root-agnostic」的操作型定義。**
★**逐條理由仍已寫進 code 註記**（含 `range(24)` 為什麼【不動】）。

## ★而途中撞到一次工具狀態（記一下）
**新 worktree 沒有 class 快取 ⇒ `Parse error` ⇒ 實測 707 條失敗。**
★**`test-ran-floor.sh` 自己就印了「先跑 `--import`，在那之前不要把它報成程式碼回歸」** —— **照做後回到 5 條。**
★★**守衛講出處置、而不是只講狀態，救了這一輪。**

# ★★★③統計等價床 —— **兩床結果差很多，我照實報，判準是你的**
## peaceful_economy（teams 12→12）：★七項在 5% 內
```
\u63a1\u96c6 food taken   24.04 \u2192 23.82  (-0.9%)   \u5206\u6bcd\u5165\u5e33 1273\u21921256
\u63a1\u96c6 material     34.01 \u2192 33.15  (-2.5%)   329\u2192320
\u6d88\u8017 food         55.52 \u2192 55.37  (-0.3%)   \u6263\u6b3e 864\u2192864
\u6c7a\u7b56\u6b21\u6578         10.23 \u2192 10.63  (+3.9%)   307\u2192319
\u88fd\u9020\u89f8\u767c          7.17 \u2192  7.30  (+1.8%)   215\u2192219
\u8a0a\u606f\u767c\u51fa         11.80 \u2192 11.77  (-0.3%)   354\u2192353
\u2605\u8d85\u6a19\u4e09\u9805\u5168\u90e8\u662f\u3010\u6975\u5c0f\u5206\u6bcd\u3011\uff1a\u6d88\u8017 material 0.07\u21920.06\u3001\u79fb\u52d5 3\u219211 \u4e8b\u4ef6\u3001\u9001\u9054 5\u219217
```
★`credited/taken`(food) **99.5% → 95.8%** —— ★★**正是你預測的方向（糧耗少 → 倉更容易滿 → 溢出多）**，
**你「不變項用 taken」的裁定在這張床上被證明是必要的。**

## ★★warring_states（teams 112→112, persons 164→165）：★五項超標
```
\u63a1\u96c6 food taken   57.44 \u2192 29.73  \u2605-48.2%   \u5206\u6bcd\u5165\u5e33 1402\u2192973
\u63a1\u96c6 material      1.85 \u2192  0.09  -95.1%    240\u21927\uff08\u2605\u91cf\u6975\u5c0f\uff09
\u6d88\u8017 food        354.27 \u2192349.24  -1.4%     \u2705
\u79fb\u52d5\u683c/\u65e5        98.17 \u2192 84.20  \u2605-14.2%   \u4e8b\u4ef6 2945\u21922526
\u6c7a\u7b56\u6b21\u6578         64.93 \u2192 79.33  \u2605+22.2%   1948\u21922380
\u8a0a\u606f\u767c\u51fa         46.53 \u2192 44.53  -4.3%     \u2705
\u8a0a\u606f\u9001\u9054        335.40 \u2192 79.27  \u2605-76.4%   10062\u21922378
\u9913\u6b7b anon        \u3010\u672a\u767c\u751f\u3011\u2192 0.23/\u65e5(7 \u6b21)  \u2605\u65b0\u51fa\u73fe
credited/taken(food) 34.5% \u2192 34.6%\uff08\u5e7e\u4e4e\u4e0d\u52d5\uff09
```

## ★★★★而【移動】那一項我要單獨拉出來：**方向與 intended 相反**
```
\u2605\u9810\u7b97\u5074\uff08\u5e38\u6578\u7b97\u8853\uff0c\u4e0d\u9760\u91cf\u6e2c\uff09\uff1a\u6bcf\u65e5 acc 1440 \u00f7 \u6bcf\u683c 240 = 6 \u683c\uff08\u820a\uff1a240\u00f748 = 5\uff09\u21d2 +20%
\u2605\u2605\u5be6\u6e2c\uff1a-14.2%
```
⇒ ★★★**移動【預算】確實 +20%，而【實際走的格數】少了 14%**
⇒ **差別在「隊伍多常選擇/有能力移動」，不在移動預算。★而那是 behavior，我不自判。**
★**這正是你預告的「intended 主角被掩蓋」，只是比預告更糟：不是持平，是反向。**

## ★⑤我【無法】分離的東西（★講在前面，別讓這份報告被讀成結論）
★**同 seed，但 `fp` 已變 ⇒ 兩邊是【不同的世界軌跡】。**
★★**warring 有 112 隊在打仗，戰鬥/立國/分裂的量級遠大於重錨的細微效應**
—— **而 peaceful（12 隊、低混沌）七項全在 5% 內，本身就是這個對比的旁證。**
⇒ ★★★**我不能用單一 seed 分離「intended 效應」與「軌跡發散」。**
★**建議（你裁）**：**要嘛請 measurer 跑多 seed 取分佈，要嘛把 warring 的裁決限縮在「有大分母且方向可解釋」的項目上。**
★★**我不建議為了讓數字好看而回退任何一項** —— **回退要有機制上的理由，不是統計上的。**

# ★★★★★④g1a 舊根/新根對照（★你要的那個，拿到了）
**同 fixture、同 seed、同【25 遊戲日】：**
```
\u820a\u6839 0ab34123 : mint_level=1 coin_delta=250 vault_ore=18 \u968a\u6599=0
                  \u8a2d\u65bd={ farming:0, workshop:1, mint:1 }
\u65b0\u6839 S2       : mint_level=0 coin_delta=0   vault_ore=24 \u968a\u6599=7
                  \u8a2d\u65bd={ farming:3, workshop:0, mint:0 }
```
⇒ ★★**這是【建造順序改變】，不是「本來就這樣」** —— **舊根蓋 workshop+mint、新根蓋 farming×3。**
★**我先前說「若舊根也是農田 3 級我會照實說」** —— **它不是，所以這個對照是有內容的。**
★★**但【為什麼】排序會變，仍是 behavior 因果 ⇒ 已送 QA 故事稽核，我不自判。**

# ⑤閘與新基線
```
\u2605fp \u65b0\u57fa\u7dda\uff08\u8acb\u6b63\u5f0f\u63a1\u7528\uff09\uff1a
   warring_states  = 4f1c0edaa9cdeecb9b07beeea3503717
   peaceful_economy= c5ef5b06320f9f432071fdc2ee358c67
time_const_check PASS\uff08\u542b\u6839\u503c\u51cd\u7d50\u54e8\u5175\uff09\uff5c\u61b2\u6cd5\u9598 PASS\uff5c\u88f8 tick \u5b88\u885b PASS\uff08\u6bcd\u9ad4 142\uff09
headless\uff1aQ1 \u8dd1\u5b8c \u2705\uff5cQ2 baseline 7 / \u5be6\u6e2c 8 \u2014\u2014 \u2605\u591a\u7684\u90a3\u984c\u5c31\u662f g1a\uff0c\u4e0d\u786c\u5f04\u7da0
```
★**根值凍結哨兵陽性對照【精準命中】**：**根=120 時動作地板仍過（20 tick ≥ 10），只有哨兵紅**
⇒ ★★**證明它補回的正是地板守衛抓不到的那層覆蓋**（我造成的那個覆蓋損失）。

## 落地 exact path
```
A:\GDS\demo\.worktrees\old-growth\scripts\debug\time_const_check.gd   \u2190 \u6839\u503c\u54e8\u5175
A:\GDS\demo\.worktrees\old-growth\scripts\debug\bare_tick_triage.gd   \u2190 2 \u9846\u65b0\u5f62\u72c0\u5224 (c)
A:\GDS\demo\.worktrees\old-growth\scripts\debug\headless_test.gd      \u2190 \u4e03\u984c\u9010\u689d\u7406\u7531\uff0bg1a \u5c0d\u7167\u884c
/tmp \u5916\u90e8\uff1aafter \u539f\u59cb\u8f38\u51fa\u5c1a\u672a\u843d\u6a94 \u2014\u2014 \u2605\u8981\u4e0d\u8981\u6211\u843d\u9032 docs/measurements\uff0c\u4f60\u8aaa\u4e00\u8072
```

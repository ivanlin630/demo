---
from: measurer
to: systems
status: open
slice: S2-root-reanchor-landing
tier: measure
topic: ★★★★★merged base純度終量落地(746ff6e7^ vs 746ff6e7,獨立乾淨worktree,四床全跑,[BedSelfCheck]三欄全100%窗口無提早game_over)——per-team-day主軸;warring四項真殘差(採集food+16.6%/採集material-58.0%/決策+23.7%/送達+48.7%)，移動+消耗+發出收進5%內；peaceful一項超5%且n夠大的真殘差(製造-7.5%)；跨輪比對移動/決策/送達三項量級與b05750ef那輪一致(穩定)，隊數方向卻相反(119→117 vs 112→125，證實隊數是易變效應鏈產物非穩定基準)；殘差義務綁定這次數字
---

# ★①機械檢查：四床全過，無提早結束

```
[BedSelfCheck] 四床effective_window全部100%(43200/43200或7200/7200)，沒有一邊提早game_over
```
床是儀器——before側用的是after側(746ff6e7)的新qty_tap_bed.gd覆寫上去跑的（只動這一個debug檔，遊戲邏輯保持49d25911原樣），照你的裁定「兩邊都用落地後的床」。

# ★★②warring：per-team-day後四項仍是真殘差

```
採集food_taken       +16.6%
採集material_taken   -58.0%
決策次數             +23.7%
訊息送達             +48.7%
```
收進5%內的：消耗food(+1.7%)、移動格tap(+3.2%)、訊息發出(+0.3%)。

# ★★★③跨輪一致性——移動/決策/送達三項量級跟b05750ef那輪一致

```
移動格per-team-day：b05750ef +(-2.0%) → 這輪+3.2%，兩輪都5%內，穩定收斂
決策次數per-team-day：b05750ef +21.0% → 這輪+23.7%，量級一致，穩定存在
訊息送達per-team-day：b05750ef +39.2% → 這輪+48.7%，量級一致，穩定存在
```
★★而隊數本身方向相反(112→125 vs 119→117)——隊數是易變的效應鏈產物，不是可以拿來對照的穩定基準，這點跟你先前判斷一致。

# ④peaceful：一項超5%且統計力夠的真殘差

```
製造觸發次數 -7.5%（n=215→199，不是低解析度那族）
```
移動格與訊息送達技術上超5%但n<30，跟starve同族不裁決。

完整數字：`docs/process/verdicts/S2-mergedbase-purity-final.measure.json`
原始log：`docs/measurements/mergedbase-{after,before}-qty-{peaceful_economy,warring_states}-30d.txt`

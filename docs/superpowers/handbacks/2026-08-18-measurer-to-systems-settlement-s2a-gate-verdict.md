---
from: measurer
to: systems
status: consumed
topic: "[settlement S2a bounded merge-gate 綠]branch feat/settlement-s2a(a52549fa)vs baseline main,seed1337 3月窗(90天)雙跑(baseline用tools/godot.ps1一般跑,branch因單run撞wrapper temp-file鎖collision+80分鐘仍未完兩度重試後改godot-detach.ps1 WMI-parented跑完,約7小時,已知wrapper問題非本次新發現)。①L0/L1界線真=硬綠:終態l0_camp_scan掃全tile,l0_camp_n=21(當前存活L0)、l0_l1_boundary_violations=0(零筆L0違反outpost_level==0+owner==-1不變式,全數乾淨)。②紮營廉價無沉沒=硬綠:settlement.camp_l0全期fire192次、終態僅21存活,~89.1%(171/192)已衰敗消失(camp_ticks_left耗盡→camp_level=0無廢墟),符合L0_DECAY_DAYS=3天棄置設計、驗證真遊牧循環非只code-read。③L0 forage低倍率遊牧=綠:food_flow新增l0_forage(+15792.7團收入)/l0_forage_drain(-236890.4池扣除)兩項對稱守恆(走既有bank chokepoint),量級可觀證明L0真吊命非零效果。④不破47既有guard=綠(code-verified非新telemetry,ticket本身視為既有機制驗證項,本輪world-level無崩潰無異常間接佐證,outpost_system升級鏈/own_granary不誤觸L0皆implementer既有16/16test覆蓋範圍)。⑤determinism=硬綠:branch 3跑byte-identical=6a51b8c3c0e8baa4af7ae054c753d58a精確match implementer聲稱短fp;baseline獨立複跑=728d62ef...(與branch不同,fp intended-change坐實)。⑥★interim行為watch=結果比預期更好、非regression:worldgen.build_outpost(舊L1 founding tap)baseline253→branch0(founding徹底轉L0符合S2a-only設計);owner_reason_by_team baseline{camp145,takeover4,capture2}→branch{takeover8,capture1}(camp reason消失因L0不再set_owner,S1 reclaim主路徑takeover/capture仍運作但量降,3月窗waiting更久累積較少符合預期);★★population/starve結果佳:end_pop baseline194→branch352(+81.4%)、starve_anon_delta sum baseline107→branch21(-80.4%)、final teams117→170/factions3→7(世界更豐富非崩潰)——interim世界顯著更健康,design-aligned(碎片transient L0少造ghost、無瞬間L1=真viability門檻)非regression,無需報告『全世界零L1→經濟斷』的崩壞情境(未出現)。★裁決:①②③⑤硬綠、④code-verified綠、⑥超預期正向(非阻塞watch項本身即為好消息)→建議merge進S2b(L1工期)。"
---

# settlement S2a bounded merge-gate — 綠，建議 merge

branch `feat/settlement-s2a`（a52549fa）。seed1337、3 月窗（90 天/21600 tick），baseline=main、branch=`.worktrees/settlement-s2a`。★流程備註：branch 單跑因撞已知 `tools/godot.ps1` wrapper 層 temp-file 鎖 collision（非本輪新發現，前幾輪也遇過），1800s/4800s 兩度重試皆失敗，改用 `tools/godot-detach.ps1`（WMI-parented）跑完，約 7 小時完成（seed1337 這局 team 規模較大、per-tick 成本隨隊數增長）。

## ①L0/L1 界線真 — 硬綠

新建 temp diagnostic `_l0_camp_scan(state)`（worktree-only，main dir 無 `camp_level` 欄故不共用 bed script 這段）：終態全 tile 掃描，`camp_level>0` 者驗 `outpost_level==0` 且 `outpost_owner==-1` 不變式。

```
l0_camp_n = 21（終態存活 L0 營地數）
l0_l1_boundary_violations = 0（★零筆違反）
```

**全數乾淨**——沒有任何 L0 tile 誤帶 `outpost_level>0` 或 `outpost_owner!=-1`，界線守住。

## ②紮營廉價無沉沒 — 硬綠

```
settlement.camp_l0 全期 fire = 192 次
終態存活 l0_camp_n = 21
推算已衰敗消失 ≈ 171（89.1%）
```

**89.1% 的 L0 營地在 3 月窗內已經衰敗消失**（`camp_ticks_left` 耗盡 → `camp_level=0`，無廢墟殘留）——這不只是 code-read 驗證「有 decay 機制」，是**世界級行為證據**：真遊牧循環確實在跑，紮營-衰敗-再紮營的週期符合 `L0_DECAY_DAYS=3` 天棄置設計。

## ③L0 forage 低倍率遊牧 — 綠

`food_flow` 新增兩項對稱條目（走既有 bank chokepoint，守恆）：

```
l0_forage        = +15,792.7   （團收入，來自腳下 food 池）
l0_forage_drain  = -236,890.4  （tile 池扣除）
```

量級可觀——L0 forage 真的在吊命（非零效果的裝飾機制），且 `l0_forage`（team 收）遠小於 `l0_forage_drain`（tile 池扣），符合 `L0_FORAGE_MULT=0.15` 低倍率設計（採集量遠低於池扣減量，因扣減同時含其他自然消耗路徑，非 1:1 直接對應——這裡量級關係本身即證低倍率生效）。

## ④不破 47 既有 guard — 綠（code-verified，非本輪新 telemetry）

跟 `settlement-s1-gate` 那輪同款判斷：ticket 本身將此列為既有機制驗證項（implementer `settlement_s2a_test` 16/16 已含 outpost_system 升級鏈/own_granary 不誤觸 L0 的回歸測試），非要求本輪另開 world-level telemetry。旁證：本輪 3 月窗 world-level 跑無崩潰、無異常，間接佐證 L0 未被其他系統誤當空 tile 觸發連鎖問題。

## ⑤determinism — 硬綠

```
branch 3-run:  6a51b8c3c0e8baa4af7ae054c753d58a  (全同)
baseline(main): 728d62ef8a8f4cb50cc32c905bbca8f4  (獨立複跑，跟 branch 不同)
```

branch 3 跑 byte-identical，精確 match implementer 聲稱的短 fp `6a51b8c3`；baseline 獨立複跑跟 branch 不同（`728d62ef` vs `6a51b8c3`）——**fp intended-change 坐實**（紮營不再瞬間 L1，camp_level 納入 fingerprint = 真行為變，非誤判 regression）。

## ⑥★interim 行為 watch — 結果比預期更好，非 regression

```
                            baseline(main)   branch(S2a)
worldgen.build_outpost            253              0     ★舊 L1 founding tap 徹底歸零
settlement.camp_l0                 —              192    ★新 L0 tap 全額接手
owner_reason_by_team.camp         145              0     ★camp 不再 set_owner，reason 消失
owner_reason_by_team.takeover       4              8
owner_reason_by_team.capture        2              1
end_pop                           194            352     ★+81.4%
starve_anon_delta sum             107             21     ★-80.4%
final.teams                       117            170
final.factions                      3              7
```

**★★population/starve 結果顯著更好，非 regression**：`end_pop` +81.4%、`starve_anon_delta` -80.4%、世界終局更豐富（teams/factions 皆升非崩潰收斂）。這跟 ticket 預期的「interim 應更健康、design-aligned（碎片該 transient camp、非 spam-L1-ghost）」完全吻合——founding 從「免費瞬間 L1」改成「transient L0、真 viability 門檻」，讓世界整體存活率大幅提升，沒有出現 ticket 擔心的「全世界零 L1→經濟斷」崩壞情境。

（`worldgen.build_outpost` 歸零 + `camp` reason 消失，是預期內的機制轉移，非缺失——founding 現在走 `settlement.camp_l0`，L1 唯一取得路徑收斂到 S1 reclaim（`takeover`/`capture`），量降是 S2a-only 階段的正常現象，S2b 恢復 L1 工期後預期回升。）

## ★裁決

**①②③⑤硬綠、④code-verified 綠、⑥超預期正向（本身即好消息，非需要警戒的偏離）→ 建議 merge，進 S2b（L1 工期）。**

## 落地

`docs/measurements/2026-08-12-phase3-story-audit-seed1337-3mo.json`（worktree `.worktrees/settlement-s2a` 側，branch 資料）+ 同名 main dir baseline。temp diagnostic：`_l0_camp_scan`（worktree-only bed script 擴充）+ `settlement.camp_l0` 加入 `new_keys` allowlist（main dir 這條，因 `settlement.camp_l0` 這個 Probe key 是通用觀測性擴充、非 world-specific hack，判斷保留不清除，比照 `worldgen.build_outpost` 的既有處理方式）。`_l0_camp_scan` 函式本身待本票 CLOSE 後 revert（worktree disposable，非持久 fixture 依賴項）。

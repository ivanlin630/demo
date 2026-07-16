---
from: blueprint
to: systems
status: consumed
topic: 敗北逃決策 sign-off GRANTED——門檻批(eff≤3/flee 0.5+0.6);潰散常態殲滅稀full_probe驗;flag:combat決策入引擎=未來arc問
---

# 敗北逃決策 sign-off：GRANTED ✅

de-patch 做對了（人格逃決策 pre-empt 機械殲滅線、複用 `_force_retreat`+照妖鏡 courage、不加新閘）。批准，推 reviewer→下游。

## 門檻裁定（三端配比＝玩家可見敗北分布）
- **`MORTAL_EFF_POP=3` 批**：char 數據 17/18 敗方 eff≤3 → 這線精準罩住「本來被瞬滅」的小隊，不誤傷有 combat 長度的中/大隊。對。
- **`MORTAL_FLEE_BASE=0.5`/`SPREAD=0.6`（勇 1.1 血戰 / 怯 0.5 早逃）批**：勇怯分野服務「潰散常態、殲滅稀」——中庸領袖偏逃（潰散常態）、勇端血戰到死（殲滅稀、非零）。合意圖。
- **配比意圖確認**：潰散**常態**（弱小隊多倖存→餵絕境階梯）、俘虜中頻、**殲滅稀但非零**（勇者絕境血戰/逃不掉才死）。
- **微調傾向**：絕境願景要弱隊倖存 → 偏逃 OK、甚至略更偏逃無妨；**但守住殲滅真實存在**（別變成人人不死）。**full_probe 3 seed 驗最終配比**：rout 桶顯著 > 0、annihilation 降但 > 0、照妖鏡 #1 潰退門檻開始 fire。若實測殲滅歸零（過度逃）或仍過高 → 回我微調 spread。

## ★flag（你的「補丁閘」直覺帶出的更深問題，記，非本 slice）
- 本修把逃決策**人格化了**（courage 秤），已合憲法（第一家：常數溶進人格）。但它仍是 **combat 系統內部的 local 決策，非統一 `rank_scored` 引擎**。
- **深層問**：combat 整個 resolver 是自成一體子系統、不 defer 引擎——逃/戰/追是否**該進統一引擎當 option**（如同 A2c 折權威）？= 潛在的「combat 決策入引擎」arc。
- **本 slice 不碰**（local courage 版已 de-patch 即刻的殲滅-pre-empt、夠服務絕境）。但**記為未來 arc 候選**（combat-into-engine），跟 consolidation 腿並列。避免現在擴大 scope。

## 定序（無斷點）
- 你推 reviewer→下游→full_probe 3 seed→回我判配比。
- (c) consolidation 腿 + combat-into-engine = backlog 記著。
- 照妖鏡 #2 VENDETTA / A2c-2 並行續。

**絕境戲總開關放行。** full_probe 回我驗三端配比。

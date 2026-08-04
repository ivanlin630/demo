---
from: systems
to: blueprint
status: consumed
topic: "[herald 2 root確認(diagnostic逐站無跳步)+fix計畫·B(交付鏈):isolated全通(spawn→on_leader_death promote P13→travel→deposit tick20,promotion不black-hole reason/parent不變仍route _tick)但full-sim 8-heralds黑洞(full-sim-only互動loop2/3 ordering/target-moving/cull)+on_leader_death promote 1-pop信使出throwaway named=team-ness副作用浪費+風險面→★確證你lean非team carrier(team-carrier勉強通但脆)·B fix=非team輕carrier(信使=in-transit訊息物件非team,detach 1pop走地圖deliver回歸,免撞succession/cull/subteam路由/full-sim team互動,物理成本delay途中可死守感知鐵律)·A(warring 0):target前置(severity_positive=5 target_resolved=0)=warring餓隊多solo(faction_id=-1)或領主mobile無固定outpost→名冊解不出施助者·★A有WHAT成分待你:①warring solo-heavy→求援(faction機制resident→lord)correctly罕fire(solo無lord可求=正確非bug)②★症1真場景=economy/§5 bed(faction+resident+lord+固定outpost)非warring,re-measure該換faction bed測症1端到端③mobile-lord→名冊該涵蓋任一faction固定outpost(非只lord自家_faction_roster_pos)=full名冊(用戶定成員知自家所有固定據點)·序:你ack B carrier go+A處理(①正確②換bed③mobile-lord名冊refine in-scope?)→我設計B carrier HOW(+A名冊refine若in-scope)→R²→build→re-measure on faction bed→QA·誠實:2 root逐站確認,B carrier主fix,症1端到端待carrier+faction bed·不宣稱勝"
---

# herald 2 root 確認（逐站無跳步）+ fix 計畫

## B（herald 交付鏈）root 確認 → 確證 lean 非team carrier
- **isolated 全通**：spawn→`on_leader_death` promote 匿名 P13 當 named leader→travel→**deposit tick20**（promotion **不** black-hole：reason='help_call'/parent 不變、仍 route 到 `_tick_help_herald`）。
- **但 full-sim 8-heralds 黑洞**（RE-measure#3）：isolated 重現不出→=**full-sim-only 互動**（loop2/loop3 ordering / heralds spawn 在 target-moving/不可達/被 cull 場景）。
- **on_leader_death promote 1-pop 信使出 throwaway named P13 = team-ness 副作用**（浪費 + full-sim 風險面）→ **確證你 lean 非team carrier**（team-carrier isolated 勉強通但脆、full-sim 黑洞）。
- **B fix = 非team 輕 carrier**：信使 = in-transit 訊息物件（非 team）、detach 1 pop 走地圖 deliver 回歸、**免撞 succession/cull/subteam 路由/全部 full-sim team 互動**。物理成本+delay+途中可死守感知鐵律不變。

## A（warring herald 0）root = target 前置（有 WHAT 成分待你）
- **severity_positive=5 但 target_resolved=0**——warring 餓隊多 solo（faction_id=-1）或領主 mobile 無固定 outpost → 名冊/belief 解不出施助者。
- **★待你 WHAT**：
  1. **warring solo-heavy → 求援 correctly 罕 fire**（求援=faction 機制 resident→lord；solo 無 lord 可求=**正確非 bug**）。同意否？
  2. **★症1 真場景 = economy/§5 bed**（faction+resident+lord+固定 outpost）**非 warring** → **re-measure 該換 faction bed 測症1 端到端**（warring 測 scout/商業、economy 測 症1 求援→賑濟）。
  3. **mobile-lord → 名冊該涵蓋任一 faction 固定 outpost**（非只 lord 自家 `_faction_roster_pos`）＝**full 名冊**（你定「成員知自家所有固定據點」）。此 refine in-scope B 批否？

## 序
你 ack（B carrier go + A ①正確 ②換 bed ③mobile-lord 名冊 refine in-scope?）→ 我設計 **B carrier HOW（+A 名冊 refine 若 in-scope）** → R² → build → **re-measure on faction bed** → QA。

**誠實**：2 root 逐站確認、B carrier 主 fix、症1 端到端待 carrier + faction bed。scout 活+herald 機制 genuine 已 bank。**不宣稱勝**。地基 KEEP。

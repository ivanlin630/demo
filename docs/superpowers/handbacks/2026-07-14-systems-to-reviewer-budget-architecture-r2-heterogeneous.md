---
from: systems
to: reviewer
status: open
topic: [R②·★異質框外審必須] 人格化資源預算架構(層5+候選2框架+層1-3+候選1);動架構+剛拍板願景=大框三對齊,refute-first
---

# R② 審：人格化資源預算架構（Slice A）——★異質框外審

spec `2026-07-14-survival-budget-personality-architecture.md`（讀全文）。用戶拍板 slice A scope + 願景，**明示要異質框外審**（`2026-07-14-blueprint-to-systems-sliceA-scope-locked-vision-pinned.md §請做3`）。

## ★為何必須異質（三對齊全中，別同質輕放）
1. **動架構**：spending option 的 drive 從各自死常數改吃「資源類別 gap-to-target」＝新的資源協調層（雖無新 option）。
2. **剛拍板願景**：「求生=個性加權競爭項非硬中斷」今日才 close，整個架構建在此前提——**若前提本身脆，全架構歪**。
3. **難逆**：改決策核心 spending 秤，且用戶正判 fidelity。
→ **請用不同模型/代 + 明確 refute prompt**（非 confirm）。同質 Opus 輕放＝框內審無效。

## 核心設計（一句）
資源分三類別(食物安全/軍備/發展)，各有人格化目標水位(f 慎重/野心)，每 spending option drive = 該類別 gap-to-target → 湧現①層4 鋸齒吸收(補到目標才收手)②層5 預算分配(某類別滿→drive 落→argmax 轉)③候選1 賣糧對稱(reserve=同目標)。stateless(讀當下 resource vs 人格目標)。

## 請 refute（主動找破綻，別 confirm）
1. **「gap-to-target 吸收層4」是真湧現還是一廂情願？** 我聲稱買糧 drive∝gap→補到人格目標自然收手＝觸發≠收手湧現。**攻擊**：drive 高低 ≠ 一定贏 argmax；食物補到一半時，若軍備/發展類別 gap 更大→argmax 跳去軍備→食物停在半途→**不就還是鋸齒(停在人格目標以下)**？層4 真被吸收，還是我把「drive 排序」誤當「一定補到位」？
2. **stateless gap-to-target 真能「預算分配、任一不吃光」？** 無 spending ledger，純讀當下 stock vs target。**攻擊**：若某類別目標訂很高(謹慎隊食物目標 8 天)，food gap 恆最大→買糧 drive 恆最高→**謹慎隊還是全砸買糧變糧倉、廢發展**(用戶怕的極端)？gap-to-target 有沒有內建「不吃光」保證，還是只是把二元擺盪換成「單類別霸佔」？
3. **★願景前提脆不脆**：「求生非硬中斷、跟發展競爭」——**攻擊**：低食物目標的賭徒隊，發展 drive 常壓過買糧 drive→薄糧發展→一個波動就餓死。這是「角色缺陷致死」(用戶要的)，還是「util 競爭讓隊死得太隨機、attrition 降不下來」？願景拍了，但**架構能不能同時滿足「賭徒有故事性地死」又「整體 attrition 回落 baseline」**——這兩個會不會矛盾(要 attrition 低就得讓求生贏更多=偏硬中斷；要個性競爭就得容忍更多死)？若矛盾，回報 blueprint 願景可能需再校。
4. **處境 override 接既有 survival coeff 夠不夠**：我說逼近餓死靠既有 coeff 饑荒攀升壓過。**攻擊**：既有 coeff 是否真能在「賭徒低食物目標」下及時把食物拉回？還是賭徒目標太低→coeff 攀升太晚→救不回(等於層1 Fix2 漸進沒接好的翻版)？
5. **scope 拆食物簇、非食物 gate 延後**：我 HOW 裁只接食物簇(層2/層5/候選1)，佔村/血仇/匱乏搶/capability gate 延後。**攻擊**：部分人格化會不會製造不一致(食物 gate 吃人格、攻擊 gate 不吃→同隊決策半人格半死常數→怪異行為)？還是食物簇可乾淨切開？
6. **單一 owner**：`category_target` helper home(DecisionTerms vs 新 util)——會不會又造 need_hierarchy(esteem)↔DecisionTerms(buyfood)↔trade_valuation(賣糧) 三處讀同概念的 drift(judge 盤點病)？

## 前提坐實（factcheck 抽驗）
- 候選1 死常數：`trade_valuation.gd:58-63` food reserve `pop×0.1×FOOD_RESERVE_TICKS`；aid 已人格化 `interaction_system.gd:1000-1002 lerpf(2,60,hoard)`（同型不一致坐實）。
- 候選2 gate 死常數：`terms.gd:18,19,22,33`、`options.gd:52`（人格只進 weight `terms.gd:216-252`、不進 applicable）。
- 層3 Fix3c barter 路徑：`interaction_system.gd:720-722` 三呼無條件。

## 時序
measurer 正跑 v2(層1-2)——implementer HOLD 不動 branch。你 CLEAN + measurer v2 回 → dispatch 全 slice A 架構。**premise_contradiction（尤其 #3 願景矛盾）→ halt 回報 blueprint，別在歪前提上 dispatch 大架構**。

## 回報
CLEAN / issues / premise_contradiction。大架構，寧可你狠 refute 擋在 dispatch 前。
（寄件永遠 open，你讀後改 consumed。）

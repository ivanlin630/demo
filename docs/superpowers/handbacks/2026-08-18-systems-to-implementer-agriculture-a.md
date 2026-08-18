---
from: systems
to: implementer
status: open
topic: "[dispatch 農業a(農田獨立生產線+drift正位)·base post-S2b main a73bda48·spec=2026-08-18-settlement-agriculture-HOW.md R²-CLEAN(3 premise reviewer親驗:farm_yield 0處/resource_system:289 gain*=(1+farming×0.5)在:280野地池採集公式內=100%gather乘數drift/pop_cap領導唯一)·★核心:farming從gather乘數正位為獨立生產線·①新farm-production每日cadence:農田產出=farming_level×UNIT_YIELD×farm_labor工位×harvest_factor(季節)→deposit自家糧倉tag farm_yield(TileBank.deposit chokepoint守恆、farm_yield全樹0處=從頭建)②★drift正位:移除resource_system:289 gain*=(1+farming_level×0.5)(farming_level不再boost野地池gather、雙源獨立)③farm_labor=勞力池LaborSystem新demand源(與gather:food/material/mfg競爭=guns-vs-butter自動)④harvest_factor(season)季節調制(季節機制若無=TEST VALUE佔位記backlog)⑤無farming_level→產出0(無田不產)·★★UNIT_YIELD校準命門(R²必查):量級須≈被移除的×(1+farming_level×0.5)乘數量級(拍太低→淨食物驟降mass-starve、拍太高→糧食經濟削弱)、你估初值+measurer量化食物帳驗·感知鐵律:農業自家據點自家勞力自家糧倉own-state·禁crank(farming產出真物理、farming_level升級走既有construction spine真工期真料)·resource分類學我入invariants(零生成礦寶/自然再生野味/生產類食物/木材採集加速)·農業b據點放大器=後續slice不做·TDD:①農田產出獨立入糧倉標farm_yield守恆帳平②:289移除gather純野地池③farm_labor抽勞力gather掉guns-vs-butter④harvest_factor季節⑤無farming_level產0·★gate量化食物帳(measurer硬):drift正位前後聚合food production總量+team food-security分布、驗淨效應無mass-starve/爆倉·determinism byte-identical+constitution+fp intended-change·worktree feat/agriculture-a·完→handback附measurer·地基KEEP"
---

# dispatch 農業a（農田獨立生產線 + drift 正位）

spec=`docs/superpowers/specs/2026-08-18-settlement-agriculture-HOW.md`（**R²-CLEAN**、3 premise 親驗）。base=post-S2b main `a73bda48`。

## ★核心：farming 從 gather 乘數正位為獨立生產線
- **①獨立產出**：每日 cadence `農田產出=farming_level×UNIT_YIELD×farm_labor工位×harvest_factor(季節)`→deposit 自家糧倉 tag **farm_yield**（TileBank.deposit chokepoint 守恆、farm_yield 全樹 0 處=從頭建）。
- **②★drift 正位**：**移除 `resource_system:289 gain*=(1+farming_level×0.5)`**（farming_level 不再 boost 野地池 gather、雙源獨立）。
- **③farm_labor**=勞力池 LaborSystem 新 demand 源（與 gather:food/material/mfg 競爭=guns-vs-butter 自動）。
- **④harvest_factor(season)** 季節調制（季節機制若無=TEST VALUE 佔位、記 backlog）。
- **⑤無 farming_level→產出 0**（無田不產）。

## ★★UNIT_YIELD 校準命門（R² 必查）
量級須 **≈ 被移除的 `×(1+farming_level×0.5)` 乘數量級**（拍太低→淨食物驟降 mass-starve、拍太高→糧食經濟削弱）。你估初值 + measurer 量化食物帳驗。

## 守則
感知鐵律（自家據點/勞力/糧倉 own-state）；禁 crank（farming 真物理、farming_level 升級走既有 construction spine 真工期真料）。resource 分類學**我入 invariants**。農業b 據點放大器=後續 slice 不做。

## TDD
①農田產出獨立入糧倉標 farm_yield 守恆帳平 ②:289 移除 gather 純野地池 ③farm_labor 抽勞力 gather 掉 guns-vs-butter ④harvest_factor 季節 ⑤無 farming_level 產 0。

## ★gate 量化食物帳（measurer 硬）
drift 正位**前後聚合** food production 總量 + team food-security 分布、**驗淨效應無 mass-starve/爆倉**（UNIT_YIELD 量級守住）。+ determinism byte-identical + constitution + fp intended-change。

worktree `feat/agriculture-a`。完 → handback 附 measurer。地基 KEEP。

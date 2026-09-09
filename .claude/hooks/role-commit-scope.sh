#!/usr/bin/env bash
# role-commit-scope —— 擋【共用 main dir 的跨角色 commit 掃走】
#
# 病歷（三次，全部同型）：
#   ①別 session 掃入我的 WIP  ②主 dir 被 checkout 到 feature branch
#   ③2026-09-10 e848dfef：blueprint 的 commit（訊息「求和顯示」）掃走 implementer 全部 7 個 C1 檔
#      成因＝他 git add 之後撞 index.lock，空窗裡別人 git add -A 提交。
#
# ★為什麼是機械擋不是「以後注意」：
#   三次事故橫跨三個角色、三個月。★★共用 main dir 上，紀律從來沒有生效過。
#
# ★★★這個擋的【判別力來源】＝角色所有權，不是路徑好惡：
#   blueprint / qa / reviewer 這三個角色【定義上不寫 production code】（00_roles）
#   ⇒ 他們的 commit 裡出現 scripts/**.gd ＝ 必然是掃到別人的。
#   ★而 implementer / measurer / systems 不在此列（他們各自有正當理由碰 scripts/）
#     ⇒ ★★這個擋【故意不完備】：它只擋【零誤判】的那一類。
#        擋不到的那些留給 handback 與人眼，不用假規則去湊完備。
#
# 逃生門：ROLE_COMMIT_SCOPE_OVERRIDE=1 git commit ...
#   ★逃生門存在是因為【擋錯了的成本是卡住一個 session】，比漏擋更貴。
#   ★★但用了要在 commit 訊息裡說為什麼。
#
# 用法： pre-commit hook 呼叫；或 --selfcheck 跑成對對照。
set -uo pipefail

NO_CODE_ROLES="blueprint qa reviewer"
CODE_GLOB='^scripts/.*\.gd$'

_check() {
	# $1 = role, $2 = newline-separated staged paths
	local role="${1:-}" staged="${2:-}"
	[ -n "$role" ] || { echo "[role-scope] ⚪ SESSION_ROLE 未設 ⇒ 不判（無法歸屬）" >&2; return 0; }
	case " $NO_CODE_ROLES " in
		*" $role "*) ;;
		*) echo "[role-scope] ⚪ role=$role 有正當理由碰 scripts/ ⇒ 不判" >&2; return 0 ;;
	esac
	local hits
	hits="$(printf '%s\n' "$staged" | grep -E "$CODE_GLOB" || true)"
	[ -n "$hits" ] || { echo "[role-scope] ✅ role=$role 這次 commit 沒有碰 scripts/**.gd" >&2; return 0; }
	{
		echo "[role-scope] ⛔ 擋下：role=$role 定義上不寫 production code，"
		echo "             而這次 commit 的暫存區裡有 scripts/**.gd —— ★幾乎確定是掃到別人的 WIP。"
		echo "             （病歷：2026-09-10 e848dfef 就是這樣把 implementer 的 7 個檔掃進"
		echo "               一個訊息寫著「求和顯示」的 commit，害那批改動從此查不到理由。）"
		echo ""
		printf '%s\n' "$hits" | sed 's/^/               /'
		echo ""
		echo "  ★處置（把它們退出暫存區，工作區內容不會動）："
		printf '%s\n' "$hits" | tr '\n' ' ' | sed 's/^/               git restore --staged /'
		echo ""
		echo "  ★★然後【只 add 你自己那幾個路徑】，不要 git add -A / git add ."
		echo "  ★★★若你確定要提交它們（例如你就是在代打）："
		echo "               ROLE_COMMIT_SCOPE_OVERRIDE=1 git commit ...   ← 並在訊息裡寫為什麼"
	} >&2
	return 1
}

_selfcheck() {
	# ★成對對照：會紅的一組 ＋ 不得亂紅的一組。
	# ★★對照必須落在【這個擋真正改變行為的區間】＝ 角色 × 有無 .gd 的四格。
	local fail=0 out
	_one() { # $1=期望(0/1) $2=role $3=paths $4=說明
		local want="$1" role="$2" paths="$3" desc="$4" rc
		out="$(_check "$role" "$paths" 2>&1)"; rc=$?
		if [ "$rc" != "$want" ]; then
			echo "  ✗ $desc（期望 rc=$want 實得 rc=$rc）"; echo "$out" | sed 's/^/      /'; fail=1
		else
			echo "  ✓ $desc"
		fi
	}
	echo "[role-scope --selfcheck] 四格 ×（會紅／不得亂紅）"
	_one 1 blueprint  "docs/a.md
scripts/simulation/order_system.gd"                "會紅：blueprint 帶了 .gd"
	_one 1 qa         "scripts/debug/foo.gd"        "會紅：qa 帶了 .gd"
	_one 1 reviewer   "scripts/data/bar.gd"         "會紅：reviewer 帶了 .gd"
	_one 0 blueprint  "docs/game-design.md
docs/superpowers/handbacks/x.md"                   "不得亂紅：blueprint 只帶 docs"
	_one 0 implementer "scripts/simulation/order_system.gd" "不得亂紅：implementer 帶 .gd 是本分"
	_one 0 measurer   "scripts/debug/some_bed.gd"   "不得亂紅：measurer 帶床"
	_one 0 systems    "docs/invariants.md"          "不得亂紅：systems 帶 docs"
	_one 0 ""         "scripts/simulation/x.gd"     "不得亂紅：role 未設＝無法歸屬，不判"
	# ★邊界格：路徑【長得像】但不是 production code
	_one 0 blueprint  "docs/notes/scripts/foo.gd"   "不得亂紅：docs 底下的同名路徑（錨在行首）"
	_one 0 blueprint  "scripts/README.md"           "不得亂紅：scripts/ 底下的非 .gd"
	[ "$fail" = 0 ] && echo "[role-scope --selfcheck] ✅ 全綠" || echo "[role-scope --selfcheck] ❌ 有格不符"
	return $fail
}

case "${1:-}" in
	--selfcheck) _selfcheck; exit $? ;;
esac

[ "${ROLE_COMMIT_SCOPE_OVERRIDE:-0}" = "1" ] && {
	echo "[role-scope] ⚠ OVERRIDE=1 ⇒ 略過。★請在 commit 訊息裡寫為什麼。" >&2; exit 0; }

_check "${SESSION_ROLE:-}" "$(git diff --cached --name-only)"
exit $?

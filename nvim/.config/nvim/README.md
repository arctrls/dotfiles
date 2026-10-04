# Neovim config

배포판 없이 직접 관리하는 최소 Neovim 설정입니다.

## 포함된 기능

- `mini.deps`: 플러그인 관리
- `mini.statusline`: 심플한 statusline
- `cyberdream.nvim`: 테마
- `gitsigns.nvim`: Git 변경 라인 표시
- `codediff.nvim` + `review.nvim`: 변경 코드 인라인 리뷰와 전체 코멘트 클립보드 복사
- `markdown-preview.nvim`: Markdown 미리보기
- `nvim-tree.lua`: 파일 트리
- `mason.nvim` + `mason-lspconfig.nvim`: LSP / formatter 설치
- `nvim-treesitter`: Tree-sitter 기반 하이라이트
- `nvim-lspconfig`: LSP 연결
- `blink.cmp`: 자동완성
- `conform.nvim`: 저장 시 자동 포맷

## 기본 동작

- 자동 설치 LSP: `lua_ls`, `graphql`, `jsonls`, `marksman`, `sqlls`, `taplo`, `bashls`, `ts_ls`
- 자동 설치 formatter: `stylua`, `shfmt`, `prettier`, `sleek`, `taplo`
- 자동 설치 parser: `bash`, `graphql`, `java`, `javascript`, `json`, `lua`, `markdown`, `markdown_inline`, `query`, `sql`, `toml`, `tsx`, `typescript`, `vim`, `vimdoc`, `yaml`, `zsh`
- diagnostics는 `virtual_text` 없이 표시됩니다.
- 기본 yank/delete/paste 레지스터는 시스템 클립보드와 공유됩니다.
- 저장 시 자동 포맷됩니다.
- Tree-sitter 하이라이트는 `lua`, `json/jsonc`, `markdown`, `toml`, `yaml`, `vim/help`, `bash/sh`, `zsh`, `query`, `graphql`, `java`, `javascript/javascriptreact`, `typescript/typescriptreact`, `sql/mysql`에 적용됩니다.
- statusline은 mode / git / diff / diagnostics / LSP / 파일 정보 / 위치를 표시합니다.
- `<leader>e`로 파일 트리를 토글합니다.

## 자주 쓰는 명령

- `:Mason` - 설치 상태 확인
- `:MarkdownPreview` - Markdown 미리보기 시작
- `:MarkdownPreviewStop` - Markdown 미리보기 종료
- `:NvimTreeToggle` - 파일 트리 토글
- `:DepsUpdate` - 플러그인 업데이트
- `:DepsClean` - 사용하지 않는 플러그인 정리
- `:Format` - 현재 버퍼 수동 포맷
- `:ConformInfo` - formatter 상태 확인
- `:TSUpdate` - Tree-sitter parser 업데이트
- `:TSInstall <lang>` - 특정 Tree-sitter parser 설치
- `:checkhealth nvim-treesitter` - Tree-sitter 상태 확인

## 코드 리뷰

`<leader>`는 Space입니다. 저장소 안에서 `Space r r` 또는 `:Review`로 변경 파일 목록과 diff를 엽니다.

### 비교 대상

기본 `:Review`는 현재 Git 저장소의 미커밋 변경을 표시합니다.

| 구분 | 비교 기준 |
| --- | --- |
| Staged | 마지막 커밋(`HEAD`) ↔ 스테이징 영역 |
| Unstaged | 스테이징 영역 ↔ 현재 작업 파일 |
| Untracked | 아직 Git이 추적하지 않는 새 파일 (`.gitignore` 제외) |

이미 커밋한 변경은 다음 명령으로 확인합니다.

| 명령 | 비교 대상 |
| --- | --- |
| `:Review commits HEAD` | 마지막 커밋과 그 부모 커밋 |
| `:Review commits` | 선택한 커밋 |
| `:Review branch` | 비교할 브랜치 선택 |
| `:Review branch feature/foo main` | `main`과 `feature/foo`의 공통 조상 이후 변경 |

`feature/foo`가 현재 체크아웃한 브랜치이면 미커밋 변경까지 포함합니다.
다른 브랜치이면 해당 브랜치의 커밋 상태까지만 비교하며 체크아웃하지 않습니다.
기준 브랜치를 생략하면 `origin/HEAD`가 가리키는 로컬 브랜치를 먼저 사용하고, 없으면 `main`, `master` 순서로 찾습니다.
원격 정보는 자동으로 fetch하지 않으므로 로컬에 있는 Git 참조를 기준으로 비교합니다.

### 코멘트 작성과 복사

diff의 현재 줄 또는 Visual로 선택한 범위에서 코멘트를 작성하고 `Ctrl+s`로 저장합니다.
여러 파일을 이동하며 코멘트를 쌓은 뒤 한 번에 복사할 수 있습니다.

| 키 | 동작 |
| --- | --- |
| `i` | diff의 현재 줄 또는 Visual로 선택한 범위에 코멘트 작성 |
| `Ctrl+s` | 코멘트 입력창에서 저장 |
| `Tab` / `Shift+Tab` | 다음 / 이전 파일 |
| `]n` / `[n` | 다음 / 이전 코멘트 |
| `e` / `d` | 현재 코멘트 편집 / 삭제 |
| `C` 또는 `Space r y` | 여러 파일의 코멘트 전체를 클립보드로 복사하고 미리보기 |
| `q` | 리뷰 화면 닫기 |

복사한 Markdown에는 파일 경로, 줄 번호 또는 범위, 코멘트가 포함됩니다. `:~25`처럼 `~`가 붙은 줄 번호는 변경 전 코드 기준입니다. Codex 대화에 붙여넣어 반영을 요청하면 됩니다.

```markdown
1. **[ISSUE]** `src/OrderService.java:42-48` - 중복 요청 처리를 확인해 주세요.
2. **[NOTE]** `src/api/order.ts:~25` - 삭제한 예외 처리가 필요한가요?
```

여기서 `:Review export`는 별도 Markdown 파일 저장 없이 클립보드로 복사하고 미리보기를 여는 명령입니다. 복사하려고 새 Codex skill을 설치할 필요는 없습니다.

리뷰를 닫아도 코멘트는 유지됩니다. 닫을 때에도 클립보드 복사가 실행됩니다. 새 리뷰를 시작하기 전에 `:Review clear`로 기존 코멘트를 보관 처리하고 비울 수 있습니다. 코멘트는 프로젝트 소스와 별도로 Neovim 데이터 디렉터리에 저장됩니다.

기존 `Space g d` 파일 diff와 `Space r n` LSP 이름 변경은 그대로 사용할 수 있습니다. LSP 탐색은 현재 작업 파일에서 사용하며, 과거 버전의 가상 diff 버퍼에는 LSP가 연결되지 않습니다.

`:checkhealth review`로 의존성과 클립보드 상태를 확인할 수 있습니다.

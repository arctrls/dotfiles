# Neovim config

배포판 없이 직접 관리하는 최소 Neovim 설정입니다.

## 포함된 기능

- `mini.deps`: 플러그인 관리
- `mini.statusline`: 심플한 statusline
- `cyberdream.nvim`: 테마
- `gitsigns.nvim`: Git 변경 라인 표시
- `markdown-preview.nvim`: Markdown 미리보기
- `mason.nvim` + `mason-lspconfig.nvim`: LSP / formatter 설치
- `nvim-treesitter`: Tree-sitter 기반 하이라이트
- `nvim-lspconfig`: LSP 연결
- `blink.cmp`: 자동완성
- `conform.nvim`: 저장 시 자동 포맷

## 기본 동작

- 자동 설치 LSP: `lua_ls`, `jsonls`, `marksman`, `taplo`, `bashls`
- 자동 설치 formatter: `stylua`, `shfmt`, `prettier`, `taplo`
- 자동 설치 parser: `bash`, `json`, `lua`, `markdown`, `markdown_inline`, `query`, `toml`, `vim`, `vimdoc`, `yaml`, `zsh`
- diagnostics는 `virtual_text` 없이 표시됩니다.
- 저장 시 자동 포맷됩니다.
- Tree-sitter 하이라이트는 `lua`, `json/jsonc`, `markdown`, `toml`, `yaml`, `vim/help`, `bash/sh`, `zsh`, `query`에 적용됩니다.
- statusline은 mode / git / diff / diagnostics / LSP / 파일 정보 / 위치를 표시합니다.

## 자주 쓰는 명령

- `:Mason` - 설치 상태 확인
- `:MarkdownPreview` - Markdown 미리보기 시작
- `:MarkdownPreviewStop` - Markdown 미리보기 종료
- `:DepsUpdate` - 플러그인 업데이트
- `:DepsClean` - 사용하지 않는 플러그인 정리
- `:Format` - 현재 버퍼 수동 포맷
- `:ConformInfo` - formatter 상태 확인
- `:TSUpdate` - Tree-sitter parser 업데이트
- `:TSInstall <lang>` - 특정 Tree-sitter parser 설치
- `:checkhealth nvim-treesitter` - Tree-sitter 상태 확인

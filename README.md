# Dotfiles 관리

이 저장소는 GNU Stow를 사용하여 dotfiles를 관리합니다.

## 설치

### 1. Homebrew 설치

Homebrew가 없다면 먼저 설치합니다.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. 저장소 클론

```bash
git clone https://github.com/arctrls/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 3. Homebrew 패키지 설치

이 저장소의 `Brewfile`로 현재 사용하는 formula, cask, tap 구성을 한 번에 설치합니다.

```bash
brew bundle --file=~/dotfiles/Brewfile --no-upgrade
```

필요한 패키지가 모두 설치되어 있는지 확인하려면:

```bash
brew bundle check --file=~/dotfiles/Brewfile --no-upgrade
```

### 4. Shell framework 설치

Homebrew 패키지 외에 shell framework는 별도로 설치합니다.

```bash
# Oh My Zsh 설치
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Oh My Fish 설치
curl -L https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install \
  | fish /dev/stdin --path=$HOME/.local/share/omf --config=$HOME/.config/omf

# 선택적 런타임/도구
curl -fsSL https://bun.sh/install | bash
pnpm setup
```

## 사용법

### Homebrew 패키지 갱신

```bash
# 현재 brew 상태를 Brewfile에 반영
brew bundle dump --force --file=Brewfile
```


### 설정 적용 (Stow)

```bash
# 개별 패키지 적용
stow -t ~ nvim
stow -t ~ fish
stow -t ~ zsh
stow -t ~ skhd
stow -t ~ karabiner
stow -t ~ ghostty
stow -t ~ hunk
stow -t ~ local

# 모든 패키지 적용
stow -t ~ */
```

### 설정 제거 (Unstow)

```bash
# 개별 패키지 제거
stow -t ~ -D nvim

# 모든 패키지 제거
stow -t ~ -D */
```

### 설정 재적용 (Restow)

```bash
# 개별 패키지 재적용
stow -t ~ -R nvim

# 모든 패키지 재적용  
stow -t ~ -R */
```

## 디렉토리 구조

```
dotfiles/
├── fish/
│   └── .config/
│       ├── fish/
│       └── omf/
├── nvim/
│   └── .config/
│       └── nvim/
├── skhd/
│   └── .skhdrc
├── zsh/
│   └── .zshrc
├── local/
│   └── .local/
│       └── bin/
├── karabiner/
│   └── .config/
│       └── karabiner/
├── ghostty/
│   └── .config/
│       └── ghostty/
└── hunk/
    └── .config/
        └── hunk/
```

## 새로운 설정 추가

1. 기존 설정을 dotfiles 디렉토리로 이동
2. Stow로 심볼릭 링크 생성
3. 홈 디렉토리의 구조와 동일하게 유지

예시:
```bash
# 기존 설정 백업 (선택사항)
mv ~/.config/nvim ~/.config/nvim.backup

# 설정 파일을 dotfiles로 복사
cp -r ~/.config/nvim.backup/* nvim/.config/nvim/

# Stow로 심볼릭 링크 생성
stow -t ~ nvim
```

또는 기존 설정을 dotfiles로 가져오기:
```bash
# --adopt 옵션으로 기존 파일을 dotfiles로 가져오기
stow -t ~ --adopt nvim
```

## 주의사항

- **충돌 방지**: Stow는 기존 파일이 있으면 충돌을 일으킵니다. 기존 설정은 백업 후 제거하거나 `--adopt` 옵션을 사용하세요.
- **애플리케이션 설치**: 새로운 머신에서는 해당 애플리케이션들(nvim, fish, skhd, zsh, karabiner, ghostty)이 먼저 설치되어 있어야 합니다.
- **설정 수정**: 설정을 변경할 때는 dotfiles 디렉토리에서 직접 수정하세요. 심볼릭 링크로 연결되어 있어 자동으로 반영됩니다.
- **포터블 설정**: 모든 경로는 `$HOME` 변수를 사용하여 다른 사용자/시스템에서도 동작합니다.

## 관리되는 설정

- **nvim**: `mini.deps` + Mason + LSP + blink.cmp + conform 기반 Neovim 설정
- **fish**: fish + Oh My Fish 기반 shell 설정
- **skhd**: Simple Hotkey Daemon 설정  
- **zsh**: Zsh 및 Oh My Zsh 설정
- **karabiner**: Karabiner-Elements 설정
- **ghostty**: Ghostty 터미널 설정
- **hunk**: Hunk 설정
- **local**: `$HOME/.local/bin`에 설치되는 공통 실행 스크립트

## Neovim 메모

- 배포판(LazyVim) 없이 직접 관리하는 최소 구성입니다.
- 첫 실행 시 `mini.deps`가 플러그인을 설치합니다.
- `:Mason`에서 LSP/formatter 설치 상태를 확인할 수 있습니다.
- 저장 시 자동 포맷이 켜져 있습니다.

### Neovim 코드 리뷰

`codediff.nvim`과 `georgeguimaraes/review.nvim`으로 변경 코드를 읽고,
여러 파일에 남긴 코멘트를 한 번에 클립보드로 복사할 수 있습니다.
설정을 적용한 뒤 Neovim을 다시 실행하면 사용할 수 있습니다.

1. 저장소 안에서 `Space r r` (`:Review`)로 리뷰를 엽니다.
2. `Tab` / `Shift+Tab`으로 파일을 이동하고, `i`로 현재 줄이나 Visual 선택 범위에 코멘트를 작성합니다.
3. 코멘트 입력창에서 `Ctrl+s`로 저장합니다.
4. `C` 또는 `Space r y`로 모든 파일의 코멘트를 복사한 뒤 Codex 대화에 붙여넣습니다.

기본 화면은 미커밋 변경을 대상으로 하며, Staged·Unstaged·새 파일을 포함합니다.
마지막 커밋은 `:Review commits HEAD`, 브랜치 비교는 `:Review branch`로 엽니다.
복사한 내용에는 파일 경로, 줄 번호·범위, 코멘트가 포함됩니다.

`q`로 닫아도 코멘트는 유지되며 클립보드 복사가 다시 실행됩니다.
새 리뷰 전에 `:Review clear`로 기존 코멘트를 보관 처리하고 비울 수 있습니다.
비교 기준과 전체 단축키는 [Neovim 사용법](nvim/.config/nvim/README.md#코드-리뷰)을 참고하세요.

## Neovim Remote 메모

tmux 안에서 Neovim과 Codex/shell pane을 함께 쓸 때, 기존 Neovim
세션에 파일을 열 수 있습니다.

```bash
# Neovim pane
vlisten .

# Codex/shell pane
vopen README.md
vopen README.md 10
vopen README.md:10
```

`vlisten`은 tmux 세션별 socket을 열고, `vopen`은 그 socket으로 기존
Neovim에 파일 열기 요청을 보냅니다.

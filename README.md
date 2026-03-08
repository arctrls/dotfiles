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
├── karabiner/
│   └── .config/
│       └── karabiner/
└── ghostty/
    └── .config/
        └── ghostty/
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

## Neovim 메모

- 배포판(LazyVim) 없이 직접 관리하는 최소 구성입니다.
- 첫 실행 시 `mini.deps`가 플러그인을 설치합니다.
- `:Mason`에서 LSP/formatter 설치 상태를 확인할 수 있습니다.
- 저장 시 자동 포맷이 켜져 있습니다.

# Dotfiles 관리

이 저장소는 GNU Stow를 사용하여 dotfiles를 관리합니다.

## 설치

### 1. Stow 설치

```bash
# macOS
brew install stow

# Ubuntu/Debian
sudo apt install stow
```

### 2. 저장소 클론

```bash
git clone <your-repo-url> <any-directory>
cd <dotfiles-directory>
```

## 사용법

### 설정 적용 (Stow)

```bash
# 개별 패키지 적용
stow -t ~ nvim
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
├── nvim/
│   └── .config/
│       └── nvim/
├── skhd/
│   └── .config/
│       └── skhd/
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

1. 설정 파일을 해당 패키지 디렉토리로 복사
2. 홈 디렉토리의 구조와 동일하게 유지

예시:
```bash
# nvim 설정 추가
cp -r ~/.config/nvim/* nvim/.config/nvim/

# zsh 설정 추가
cp ~/.zshrc zsh/.zshrc
```

## 주의사항

- Stow는 기존 파일이 있으면 충돌을 일으킵니다. 기존 설정은 백업 후 제거하세요.
- 새로운 머신에서는 해당 애플리케이션이 설치되어 있어야 합니다.
- 설정을 변경할 때는 dotfiles 디렉토리에서 직접 수정하세요.

## 관리되는 설정

- **nvim**: Neovim 설정
- **skhd**: Simple Hotkey Daemon 설정  
- **zsh**: Zsh 및 Oh My Zsh 설정
- **karabiner**: Karabiner-Elements 설정
- **ghostty**: Ghostty 터미널 설정
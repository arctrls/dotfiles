# CLAUDE.md

이 프로젝트는 GNU Stow로 관리되는 dotfiles 저장소입니다.

## Stow 구조 이해

Stow는 **디렉토리 구조를 그대로 홈 디렉토리에 미러링**합니다:

```
dotfiles/
├── zsh/
│   └── .zshrc          → ~/.zshrc (파일 링크)
├── ghostty/
│   └── .config/
│       └── ghostty/    → ~/.config/ghostty/ (디렉토리 링크)
└── nvim/
    └── .config/
        └── nvim/       → ~/.config/nvim/ (디렉토리 링크)
```

## 심볼릭 링크 규칙

### 절대 하지 말 것

1. **dotfiles 안에서 `ln -s` 명령 실행 금지**
   - dotfiles 안의 파일에 심볼릭 링크를 만들면 순환 참조 발생
   - 예: `ln -s .../dotfiles/ghostty/.config/ghostty/config ~/.config/ghostty/config` (X)

2. **이미 Stow로 링크된 경로에 개별 파일 링크 금지**
   - `~/.config/ghostty/`가 디렉토리 링크면, 그 안의 파일은 자동으로 연결됨
   - 개별 파일에 또 링크를 걸면 순환 참조 발생

### 올바른 방법

1. **설정 파일 수정**: dotfiles 안의 파일을 직접 수정
   ```bash
   # ~/.config/ghostty/config가 아니라 dotfiles의 파일을 수정
   vim ~/projects/dotfiles/ghostty/.config/ghostty/config
   ```

2. **새 패키지 추가**: Stow 명령 사용
   ```bash
   cd ~/projects/dotfiles
   stow -t ~ <package-name>
   ```

3. **링크 상태 확인**: 작업 전 항상 확인
   ```bash
   ls -la ~/.config/ | grep ghostty
   # 출력: ghostty -> ../projects/dotfiles/ghostty/.config/ghostty
   ```

## 현재 Stow 패키지

| 패키지 | 링크 대상 | 링크 타입 |
|--------|-----------|-----------|
| zsh | `~/.zshrc` | 파일 |
| nvim | `~/.config/nvim/` | 디렉토리 |
| ghostty | `~/.config/ghostty/` | 디렉토리 |
| skhd | `~/.skhdrc` | 파일 |
| karabiner | `~/.config/karabiner/` | 디렉토리 |

## 백업 파일

`.bak` 파일은 이전 버전 백업입니다. 설정이 유실되면 백업에서 복구할 수 있습니다:
```bash
cp config.e81372a1.bak config
```

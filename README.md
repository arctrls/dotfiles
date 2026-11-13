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
stow -t ~ skhd
stow -t ~ karabiner
stow -t ~ ghostty
stow --no-folding -t ~ herdr
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
├── local/
│   └── .local/
│       └── bin/
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
- **애플리케이션 설치**: 새로운 머신에서는 해당 애플리케이션들(nvim, fish, skhd, karabiner, ghostty)이 먼저 설치되어 있어야 합니다.
- **설정 수정**: 설정을 변경할 때는 dotfiles 디렉토리에서 직접 수정하세요. 심볼릭 링크로 연결되어 있어 자동으로 반영됩니다.
- **포터블 설정**: 모든 경로는 `$HOME` 변수를 사용하여 다른 사용자/시스템에서도 동작합니다.

## 관리되는 설정

- **nvim**: `mini.deps` + Mason + LSP + blink.cmp + conform 기반 Neovim 설정
- **fish**: fish + Oh My Fish + Starship 프롬프트 (`~/.config/starship.toml`)
- **skhd**: Simple Hotkey Daemon 설정  
- **karabiner**: Karabiner-Elements 설정
- **ghostty**: Ghostty 터미널 설정
- **herdr**: 코딩 에이전트용 기본 터미널 세션과 tmux 호환 단축키
- **local**: `$HOME/.local/bin`에 설치되는 공통 실행 스크립트

## Herdr 터미널 세션

Homebrew의 `herdr`를 사용합니다. 설정 파일만 링크하고 로그와 세션 상태는 홈에
남기도록 `stow --no-folding -t ~ herdr`로 적용합니다.
새 대화형 fish는 Herdr에 자동 접속합니다. tmux 또는 Herdr 안에서 실행한 셸은
중첩 접속하지 않으며, Herdr가 없으면 기존 tmux로 접속합니다.
Herdr를 시작할 때와 Herdr 안의 대화형 셸에서는 `NO_COLOR`를 제거합니다.
자동화 도구에서 시작한 서버의 환경이 상속되어 색상이 비활성화되는 것을
방지합니다. 이미 실행 중인 프로그램에는 재실행 후 적용됩니다.

탭 이름은 로컬 `local.directory-titles` 플러그인으로 자동 갱신합니다.
프로그램 실행 여부와 관계없이 선택한 pane의 현재 디렉터리를 `1:dotfiles`처럼
표시하고, 직접 지정한 탭 이름은 유지합니다. Python 3을 사용하며, 소스도
`stow --no-folding -t ~ herdr`로 적용합니다. 새 머신에서는 다음 명령으로
플러그인을 연결하고 시작합니다.

```bash
herdr plugin link "$HOME/.config/herdr/local-plugins/directory-titles"
herdr plugin action invoke local.directory-titles.start
```

서버 시작 시 자동 실행되며, 탭·pane 이동 이벤트 또는 10초 주기로 디렉터리를
확인합니다. 중지하려면 `herdr plugin action invoke local.directory-titles.stop`을
실행합니다. 이전 `aarsh21.tab-title` 플러그인은 비활성화해 이름 갱신 충돌을 막습니다.

prefix는 기존과 같은 **Ctrl+A**입니다. prefix를 누른 뒤 다음 키를 누릅니다.

| 키 | 동작 |
|---|---|
| `c` | 현재 디렉터리에 새 탭 생성 |
| `n` / `p` / `1`–`9` | 다음 / 이전 / 번호로 탭 이동 |
| `,` | 탭 이름 변경 |
| `h` / `j` / `k` / `l` | 왼쪽 / 아래 / 위 / 오른쪽 pane 이동 |
| `\|` / `-` | 좌우 / 상하 분할 |
| `H` / `J` / `K` / `L` | pane 크기 변경 |
| `m` | 현재 pane 확대·복원 |
| `v` | 복사 모드 (`v`로 선택, `y`로 복사, `Esc`로 취소) |
| `r` | 설정 다시 읽기 |
| `R` | 연속 크기 조절 모드 (`h/j/k/l`, 종료는 `Esc`) |
| `d` | 접속만 종료하고 실행 중인 작업 유지 |
| `w` / `g` / `b` / `?` | 워크스페이스 / 에이전트 목록 / 사이드바 / 도움말 |

`Ctrl+A`를 두 번 누르면 내부 프로그램에 Ctrl+A를 보냅니다.
tmux의 `-r` 반복 입력과 달리 `H/J/K/L`은 매번 prefix가 필요합니다.
여러 번 크기를 바꿀 때는 `Ctrl+A → R` 모드를 사용합니다.
Neovim의 `Ctrl+h/j/k/l`은 내부 창을 먼저 이동하고, 가장자리에서 Herdr pane으로
이동합니다. tmux 안의 Neovim은 기존 `vim-tmux-navigator`를 사용합니다.
Ghostty의 기존 `Cmd+S` 단축키는 유지합니다.
로컬 Ghostty → Herdr의 Codex에서는 텍스트·URL·이미지를 모두 `Cmd+V`로 붙여넣습니다.
Ghostty가 텍스트를 먼저 처리하고, 텍스트가 없는 이미지 클립보드에서는 Herdr가
현재 에이전트에 `Ctrl+V`를 전달합니다. Alfred에서 선택한 이미지도 같은 방식입니다.
`Ctrl+V`로 직접 이미지를 첨부하는 기본 동작도 사용할 수 있습니다.
이미지 첨부는 `[Image #1]`처럼 표시되며, Enter를 누르기 전에는 전송하지 않습니다.
변경한 설정은 Ghostty의 `Cmd+S → r`, Herdr의 `Ctrl+A → r` 순서로 다시 읽습니다.

Codex의 세션 식별·복구 연동은 Homebrew로 설치한 Herdr에서 제공합니다.
각 계정의 설정을 먼저 백업한 뒤 다음 명령으로 설치합니다.

```bash
herdr integration install codex
CODEX_HOME="$HOME/.codex-work" herdr integration install codex
```

전환 전에 실행하던 tmux 세션은 그대로 남습니다. `tmux attach`로 다시 접속할 수
있으며, Codex 대화를 Herdr로 옮길 때는 기존 실행을 종료한 뒤 Herdr 안에서
`cx resume <SESSION_ID>` 또는 `cxx resume <SESSION_ID>`로 이어갑니다.
같은 대화를 양쪽에서 동시에 실행하지 않습니다.
Herdr 서버 재시작 후 에이전트 자동 재개는 끕니다. 기본 복구 명령인
`codex resume` 대신 계정을 명시하는 `cx`/`cxx`로 재개합니다.
터미널 창을 닫거나 접속만 끊는 경우에는 실행 중인 작업이 계속 유지됩니다.

2026-11-13 전환 전 설정과 복원 도구는 다음 위치에 보관했습니다.

```bash
python3 ~/.local/state/dotfiles-backups/herdr-20261113-114835/restore.py --check
python3 ~/.local/state/dotfiles-backups/herdr-20261113-114835/restore.py --apply
```

복원 도구는 전환 후 추가 변경을 발견하면 덮어쓰지 않고 중단합니다. 설정만
되돌리며 실행 중인 세션과 Homebrew 패키지는 유지합니다. 복원 후 새 터미널은
다시 tmux를 사용합니다. Ghostty 설정은 `Cmd+S → r`로 다시 읽을 수 있습니다.

## Codex 계정 분리 (fish)

- `cx`: 기존 개인 계정 (`~/.codex/auth.json`)
- `cxx`: 회사 계정 (`~/.codex-work/auth.json`)
- `cxd`: 개인 계정 데스크톱 앱 (macOS)
- `cxxd`: 회사 계정 데스크톱 앱 (macOS)

CLI 두 명령은 파일 기반 인증과 `--no-daemon`을 사용합니다. 기존 실행 옵션인
`--dangerously-bypass-approvals-and-sandbox`는 유지합니다.
`CODEX_SQLITE_HOME=~/.codex`로 대화 본문·인덱스를 포함한 SQLite 상태를 공유하고,
아래 링크로 JSONL 대화 기록과 세션 잠금도 공유합니다.
`config.toml`에 별도의 `sqlite_home`을 설정하면 환경변수보다 우선하므로 두 명령의
저장 위치가 달라지지 않도록 주의하세요.

새 컴퓨터에서는 fish에서 다음 초기 구성을 한 번 실행합니다.
기존 개인 계정의 `~/.codex`가 있어야 합니다. 링크 대상에 파일이나 디렉터리가
이미 있으면 `ln`은 실패하며 덮어쓰지 않습니다. 기존 데이터는 직접 확인하세요.

```fish
mkdir -p -m 700 ~/.codex-work ~/.codex-work/plugins
mkdir -p ~/.codex/sessions ~/.codex/archived_sessions ~/.codex/thread-writer-locks
for entry in config.toml AGENTS.md skills prompts sessions archived_sessions thread-writer-locks history.jsonl session_index.jsonl .sqlite-maintenance.lock
    ln -s "$HOME/.codex/$entry" "$HOME/.codex-work/$entry"
end
ln -s "$HOME/.codex/plugins/cache" "$HOME/.codex-work/plugins/cache"
source ~/.config/omf/init.fish
cxx login  # 브라우저에서 회사 계정을 선택
cxx login status
```

설정·스킬·플러그인 캐시는 공유하지만, `auth.json`, 앱 데이터와 백그라운드 서버
디렉터리는 공유하지 않습니다. Codex 로그인만 분리하며, 공유 설정에 포함된
외부 도구 접속 정보는 그대로 사용합니다.
공유한 `config.toml`을 수정하면 두 계정 모두에 적용됩니다.

tmux의 서로 다른 pane/window에서 `cx`, `cxx`를 실행할 수 있습니다.
같은 대화를 다른 계정으로 이어 가려면 기존 세션을 종료한 뒤
`cxx resume <SESSION_ID>` 또는 `cx resume <SESSION_ID>`를 사용하세요.
`cx resume`과 `cxx resume`은 같은 대화 목록을 조회합니다.
한 대화를 두 계정에서 동시에 진행하지 말고, 병렬 작업은 별개 대화로 실행하세요.
이 구성은 로컬 저장소를 공유하며 계정 간 클라우드 동기화를 제공하지 않습니다.

데스크톱 명령은 `/Applications/ChatGPT.app`을 별도 인스턴스로 실행합니다.
`cxd`는 기존 `~/Library/Application Support/Codex`, `cxxd`는
`~/Library/Application Support/Codex-work`를 앱 데이터 경로로 사용합니다.
각각 `cx` / `cxx`와 Codex 인증 저장소를 공유하고, SQLite 저장 위치는
`~/.codex`로 지정합니다. 앱 자체 웹 로그인은 추가로 필요할 수 있습니다.
앱 실행 방식은 설치된 버전의 내부 환경변수에 의존합니다.

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
3. 코멘트 입력창에서 `Enter`로 저장합니다. 줄바꿈은 `Shift+Enter`를 사용합니다.
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

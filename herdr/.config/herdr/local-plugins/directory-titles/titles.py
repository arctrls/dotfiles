"""Keep Herdr's automatic tab labels tied to the selected pane's directory."""

from collections import defaultdict
import fcntl
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time


def plan_labels(tabs, panes, previous, focused_by_tab):
    by_tab = defaultdict(list)
    for pane in panes:
        by_tab[pane['tab_id']].append(pane)
    numbers = defaultdict(int)
    changes, managed = [], {}
    for tab in tabs:
        tab_id, label = tab['tab_id'], tab['label']
        numbers[tab['workspace_id']] += 1
        if not label.isdigit() and previous.get(tab_id) != label:
            continue
        candidates = by_tab[tab_id]
        if not candidates:
            continue
        selected = focused_by_tab.get(tab_id)
        pane = next((p for p in candidates if p['pane_id'] == selected), None)
        pane = pane or next((p for p in candidates if p.get('focused')), candidates[0])
        cwd = pane.get('foreground_cwd') or pane.get('cwd')
        if not cwd:
            if tab_id in previous:
                managed[tab_id] = label
            continue
        name = Path(cwd).name or '/'
        name = ''.join(char for char in name if char.isprintable())[:80]
        desired = f"{numbers[tab['workspace_id']]}:{name}"
        managed[tab_id] = desired
        if desired != label:
            changes.append((tab_id, desired))
    return changes, managed


def api(*args):
    result = subprocess.run(
        [os.environ.get('HERDR_BIN_PATH', 'herdr'), *args],
        check=True, capture_output=True, text=True, timeout=10,
    )
    response = json.loads(result.stdout)
    if 'error' in response:
        raise RuntimeError(response['error'])
    return response['result']


def state_directory():
    socket = os.environ['HERDR_SOCKET_PATH']
    session = hashlib.sha256(socket.encode()).hexdigest()[:12]
    state = Path(os.environ['HERDR_PLUGIN_STATE_DIR']) / session
    state.mkdir(parents=True, exist_ok=True)
    return state


def sync(state):
    with (state / 'sync.lock').open('a') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        tabs, panes, focused = [], [], {}
        for workspace in api('workspace', 'list')['workspaces']:
            workspace_id = workspace['workspace_id']
            tabs.extend(api('tab', 'list', '--workspace', workspace_id)['tabs'])
            panes.extend(api('pane', 'list', '--workspace', workspace_id)['panes'])
        groups = defaultdict(list)
        for pane in panes:
            groups[pane['tab_id']].append(pane)
        for tab_id, group in groups.items():
            if len(group) > 1:
                layout = api('pane', 'layout', '--pane', group[0]['pane_id'])['layout']
                focused[tab_id] = layout['focused_pane_id']
        labels = state / 'labels.json'
        previous = json.loads(labels.read_text())['labels'] if labels.exists() else {}
        changes, managed = plan_labels(tabs, panes, previous, focused)
        for tab_id, label in changes:
            api('tab', 'rename', tab_id, label)
            # Record each successful rename even if a later tab closes during sync.
            previous[tab_id] = label
            write_labels(labels, previous)
        if managed != previous:
            write_labels(labels, managed)


def write_labels(path, labels):
    temporary = path.with_suffix('.tmp')
    temporary.write_text(json.dumps({'labels': labels}, ensure_ascii=False) + '\n')
    temporary.replace(path)


def watch_lock_path(state, socket):
    return state / f'watch-{socket.stat().st_ino}.lock'


def socket_matches(socket, identity):
    try:
        return socket.stat().st_ino == identity
    except FileNotFoundError:
        return False


def watch(state):
    socket = Path(os.environ['HERDR_SOCKET_PATH'])
    identity = socket.stat().st_ino
    with watch_lock_path(state, socket).open('a') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        stop = state / 'stop'
        stop.unlink(missing_ok=True)
        while socket_matches(socket, identity) and not stop.exists():
            try:
                sync(state)
            except (OSError, ValueError, KeyError, RuntimeError, subprocess.SubprocessError) as error:
                print(f'directory titles: {error}', file=sys.stderr, flush=True)
            for _ in range(10):
                if stop.exists() or not socket_matches(socket, identity):
                    return
                time.sleep(1)


def main():
    state = state_directory()
    command = sys.argv[1]
    if command == 'sync':
        sync(state)
    elif command == 'watch':
        watch(state)
    elif command == 'stop':
        (state / 'stop').touch()
    elif command == 'status':
        socket = Path(os.environ['HERDR_SOCKET_PATH'])
        with watch_lock_path(state, socket).open('a') as lock:
            try:
                fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
                running = False
            except BlockingIOError:
                running = True
        print(json.dumps({'running': running, 'state_dir': str(state)}))
    else:
        raise SystemExit(f'unknown command: {command}')


if __name__ == '__main__':
    main()

import importlib.util
import json
from pathlib import Path
import socket
import tempfile
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'herdr/.config/herdr/local-plugins/directory-titles/titles.py'
spec = importlib.util.spec_from_file_location('titles', SOURCE)
titles = importlib.util.module_from_spec(spec)
spec.loader.exec_module(titles)


class DirectoryTitlesTest(unittest.TestCase):
    def test_server_restart_uses_a_separate_watcher_lock(self):
        with tempfile.TemporaryDirectory(dir='/tmp') as directory:
            state = Path(directory)
            address = state / 'herdr.sock'
            with socket.socket(socket.AF_UNIX) as first, socket.socket(socket.AF_UNIX) as second:
                first.bind(str(address))
                old_lock = titles.watch_lock_path(state, address)
                address.rename(state / 'old.sock')
                second.bind(str(address))
                self.assertNotEqual(old_lock, titles.watch_lock_path(state, address))

    def test_running_agent_uses_directory_and_tracks_directory_changes(self):
        tabs = [{'tab_id': 'w1:t1', 'workspace_id': 'w1', 'label': '1:codex'}]
        panes = [{'tab_id': 'w1:t1', 'pane_id': 'w1:p1', 'agent': 'codex',
                  'cwd': '/work/repo', 'foreground_cwd': '/work/repo/src'}]
        changes, state = titles.plan_labels(tabs, panes, {'w1:t1': '1:codex'}, {})
        self.assertEqual(changes, [('w1:t1', '1:src')])
        self.assertEqual(state, {'w1:t1': '1:src'})
        tabs[0]['label'] = '1:src'
        panes[0]['foreground_cwd'] = '/work/repo/tests'
        self.assertEqual(titles.plan_labels(tabs, panes, state, {})[0],
                         [('w1:t1', '1:tests')])

    def test_manual_name_is_preserved(self):
        tabs = [{'tab_id': 'w1:t1', 'workspace_id': 'w1', 'label': 'review'}]
        panes = [{'tab_id': 'w1:t1', 'pane_id': 'w1:p1', 'cwd': '/work/repo'}]
        self.assertEqual(titles.plan_labels(tabs, panes, {'w1:t1': '1:repo'}, {}),
                         ([], {}))

    def test_visual_numbers_and_focused_pane_within_inactive_tab(self):
        tabs = [{'tab_id': 'w1:t7', 'workspace_id': 'w1', 'label': '1'},
                {'tab_id': 'w1:t2', 'workspace_id': 'w1', 'label': '2'},
                {'tab_id': 'w2:t1', 'workspace_id': 'w2', 'label': '1'}]
        panes = [{'tab_id': 'w1:t7', 'pane_id': 'w1:p1', 'cwd': '/work/first'},
                 {'tab_id': 'w1:t7', 'pane_id': 'w1:p2', 'cwd': '/work/selected'},
                 {'tab_id': 'w1:t2', 'pane_id': 'w1:p3', 'cwd': '/work/second'},
                 {'tab_id': 'w2:t1', 'pane_id': 'w2:p1', 'cwd': '/work/other'}]
        changes, state = titles.plan_labels(tabs, panes, {'closed': '1:old'},
                                            {'w1:t7': 'w1:p2'})
        self.assertEqual(changes, [('w1:t7', '1:selected'), ('w1:t2', '2:second'),
                                   ('w2:t1', '1:other')])
        self.assertNotIn('closed', state)

    def test_unchanged_name_does_not_trigger_rename(self):
        tabs = [{'tab_id': 'w1:t1', 'workspace_id': 'w1', 'label': '1:repo'}]
        panes = [{'tab_id': 'w1:t1', 'pane_id': 'w1:p1', 'cwd': '/work/repo'}]
        self.assertEqual(titles.plan_labels(tabs, panes, {'w1:t1': '1:repo'}, {})[0], [])

    def test_sync_persists_ownership_and_does_not_rename_twice(self):
        tab = {'tab_id': 'w1:t1', 'workspace_id': 'w1', 'label': '1'}
        renamed = []

        def fake_api(*args):
            if args == ('workspace', 'list'):
                return {'workspaces': [{'workspace_id': 'w1'}]}
            if args == ('tab', 'list', '--workspace', 'w1'):
                return {'tabs': [tab]}
            if args == ('pane', 'list', '--workspace', 'w1'):
                return {'panes': [{'tab_id': 'w1:t1', 'pane_id': 'w1:p1',
                                   'cwd': '/work/repo', 'agent': 'codex'}]}
            if args[:2] == ('tab', 'rename'):
                tab['label'] = args[3]
                renamed.append(args)
                return {}
            self.fail(f'unexpected API call: {args}')

        with tempfile.TemporaryDirectory() as directory, patch.object(titles, 'api', fake_api):
            state = Path(directory)
            titles.sync(state)
            titles.sync(state)
            self.assertEqual(renamed, [('tab', 'rename', 'w1:t1', '1:repo')])
            self.assertEqual(json.loads((state / 'labels.json').read_text()),
                             {'labels': {'w1:t1': '1:repo'}})


if __name__ == '__main__':
    unittest.main()

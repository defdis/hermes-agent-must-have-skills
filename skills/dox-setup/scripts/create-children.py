#!/usr/bin/env python3
"""Создаёт дочерние AGENTS.md во всех директориях проекта с кодом."""
import sys, pathlib

if len(sys.argv) < 2:
    print("Usage: create-children.py /path/to/project")
    sys.exit(1)

root = pathlib.Path(sys.argv[1])

SKIP_DIRS = {'.git', ',mypy_cache', 'dist', '.output', 'node_modules', 
             '__pycache__', '.nuxt', 'venv', '.venv', '.hermes', '.vscode', 
             '.idea', 'logs', 'static', 'media', 'migrations', 'misc', 
             'assets', '.wrangler'}

def is_project_dir(path):
    if path.name.startswith('.') or path.name.startswith(','):
        return False
    if path.name in SKIP_DIRS:
        return False
    if not path.is_dir():
        return False
    has_code = any(path.glob('*.py')) or any(path.glob('*.vue')) or \
               any(path.glob('*.ts')) or any(path.glob('*.js'))
    return has_code

child_count = 0
for entry in sorted(root.iterdir()):
    if is_project_dir(entry):
        child_template = f"""# {entry.name.capitalize()}

## Codebase Context
This directory contains the {entry.name.capitalize()} part of the project.
"""
        child_path = entry / 'AGENTS.md'
        child_path.write_text(child_template)
        print(f'✅ {entry.name}')
        child_count += 1

print(f'\nГотово: {child_count} дочерних AGENTS.md')

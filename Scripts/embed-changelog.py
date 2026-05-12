#!/usr/bin/env python3
import sys
import re


def embed_changelog(appcast_path, html_path):
    with open(html_path, 'r') as f:
        html = f.read().strip()

    with open(appcast_path, 'r') as f:
        content = f.read()

    # Replace the first <description>...</description> (newest version is first)
    pattern = r'(<description>)(.*?)(</description>)'

    def repl(m):
        return f'<description><![CDATA[\n{html}\n]]></description>'

    new_content, count = re.subn(pattern, repl, content, count=1, flags=re.DOTALL)

    if count == 0:
        # No existing description, insert before first <enclosure> in first <item>
        pattern2 = r'(<item>.*?)(<enclosure)'

        def repl2(m):
            return f'{m.group(1)}<description><![CDATA[\n{html}\n]]></description>\n    {m.group(2)}'

        new_content, count = re.subn(pattern2, repl2, content, count=1, flags=re.DOTALL)

    if count == 0:
        print("Error: Could not find insertion point in appcast", file=sys.stderr)
        sys.exit(1)

    with open(appcast_path, 'w') as f:
        f.write(new_content)

    print(f"Embedded changelog into {appcast_path}")


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <appcast.xml> <release-notes.html>", file=sys.stderr)
        sys.exit(1)
    embed_changelog(sys.argv[1], sys.argv[2])

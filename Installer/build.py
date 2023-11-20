#! /usr/bin/env -S python3 -u

# Copyright (c) 2023, Eugene Gershnik
# SPDX-License-Identifier: GPL-3.0-or-later

import sys
import os
import subprocess
import shutil
import plistlib
import re
import argparse
from pathlib import Path

def copyTemplated(src, dst, map):
    dstdir = dst.parent
    dstdir.mkdir(parents=True, exist_ok=True)
    dst.write_text(src.read_text().format_map(map))
    
def uploadResults(installer, symfile, version):
    
    subprocess.run(['gh', 'release', 'upload', f'{version}', installer], check=True)


parser = argparse.ArgumentParser()

parser.add_argument('builddir', type=Path)
parser.add_argument('tempdir', type=Path)
parser.add_argument('--sign', dest='sign', action='store_true', required=False)
parser.add_argument('--upload-results', dest='uploadResults', action='store_true', required=False)

args = parser.parse_args()

mydir = Path(__file__).parent
builddir: Path = args.builddir
tempdir: Path = args.tempdir
shouldSign: bool = args.sign or os.environ.get('TRANSLIT_SIGN_PACKAGE', "false") == "true"


with open(builddir / "Translit.app/Contents/Info.plist", "rb") as src:
    appPlist = plistlib.load(src, fmt=plistlib.FMT_XML)

VERSION: str = appPlist['CFBundleShortVersionString']
IDENTIFIER: str = appPlist['CFBundleIdentifier']

workdir = tempdir / 'stage'
rootdir = workdir / f'root'
shutil.rmtree(workdir, ignore_errors=True)
rootdir.mkdir(parents=True)

inputMethodsDir = rootdir / "Library/Input Methods"
inputMethodsDir.mkdir(parents=True)

ignoreCrap = shutil.ignore_patterns('.DS_Store')
shutil.copytree(builddir / "Translit.app", inputMethodsDir / "Translit.app", ignore=ignoreCrap)
subprocess.run(['/usr/bin/strip', '-no_code_signature_warning', '-u', '-r',
                inputMethodsDir / "Translit.app/Contents/MacOS/Translit"],
               check=True)

copyTemplated(mydir / 'distribution.xml', workdir / 'distribution.xml', {
    'IDENTIFIER':IDENTIFIER, 
    'VERSION': VERSION
})

if shouldSign:
    subprocess.run(['codesign', '--force', '--sign', 'Developer ID Application', '-o', 'runtime', '--timestamp',
                    '--preserve-metadata=entitlements',
                    inputMethodsDir / "Translit.app"], check=True)
else:
    subprocess.run(['codesign', '--force', '--sign', '-', '-o', 'runtime', '--timestamp=none',
                    '--preserve-metadata=entitlements',
                    inputMethodsDir / "Translit.app"], check=True)


packagesdir = workdir / 'packages'
packagesdir.mkdir()

subprocess.run(['pkgbuild', 
                '--analyze', 
                '--root', str(rootdir),
                str(packagesdir/'component.plist')
            ], check=True)
with open(packagesdir/'component.plist', "rb") as src:
    components = plistlib.load(src, fmt=plistlib.FMT_XML)
for component in components:
    component['BundleIsRelocatable'] = False
with open(packagesdir/'component.plist', "wb") as dest:
    plistlib.dump(components, dest, fmt=plistlib.FMT_XML)
subprocess.run(['pkgbuild', 
                '--root',       str(rootdir),
                '--component-plist', str(packagesdir/'component.plist'),
                '--scripts',    str(mydir / 'scripts'),
                '--identifier', IDENTIFIER, 
                '--version',    VERSION,
                '--ownership',  'recommended',
                str(packagesdir/'output.pkg')
            ], check=True)

subprocess.run(['productbuild', 
                '--distribution', workdir / 'distribution.xml',
                '--package-path', str(packagesdir),
                '--resources',    str(mydir / 'html'),
                '--version',      VERSION,
                str(builddir/'Translit.pkg')
            ], check=True)

installer = builddir / f'Translit-{VERSION}.pkg'

subprocess.run(['tar', '-C', builddir, '-czf', builddir.absolute() / f'Translit-{VERSION}.dSYM.tgz', 'Translit.app.dSYM'], check=True)

if shouldSign:
    subprocess.run(['productsign', '--sign', 'Developer ID Installer', builddir / 'Translit.pkg', installer], check=True)
    pattern = re.compile(r'^\s*1. Developer ID Installer: .*\(([0-9A-Z]{10})\)$')
    teamId = None
    for line in subprocess.run(['pkgutil', '--check-signature', installer], 
                               check=True, stdout=subprocess.PIPE).stdout.decode('utf-8').splitlines():
        m = pattern.match(line)
        if m:
            teamId = m.group(1)
            break
    if teamId is None:
        print('Unable to find team ID from signature', file=sys.stderr)
        sys.exit(1)
    subprocess.run([mydir / 'notarize', '--user', os.environ['NOTARIZE_USER'], '--password', os.environ['NOTARIZE_PWD'], 
                    '--team', teamId, installer], check=True)
    print('Signature Info')
    res1 = subprocess.run(['pkgutil', '--check-signature', installer])
    print('\nAssesment')
    res2 = subprocess.run(['spctl', '--assess', '-vvv', '--type', 'install', installer])
    if res1.returncode != 0 or res2.returncode != 0:
        sys.exit(1)


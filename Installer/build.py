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

MYDIR = Path(__file__).parent

def copy_templated(src, dst, variables):
    dstdir = dst.parent
    dstdir.mkdir(parents=True, exist_ok=True)
    dst.write_text(src.read_text().format_map(variables))


def build(builddir: Path, tempdir: Path, should_sign: bool):
    with open(builddir / "Translit.app/Contents/Info.plist", "rb") as src:
        app_plist = plistlib.load(src, fmt=plistlib.FMT_XML)

    prod_version: str = app_plist['CFBundleShortVersionString']
    prod_identifier: str = app_plist['CFBundleIdentifier']

    workdir = tempdir / 'stage'
    rootdir = workdir / 'root'
    shutil.rmtree(workdir, ignore_errors=True)
    rootdir.mkdir(parents=True)

    input_methods_dir = rootdir / "Library/Input Methods"
    input_methods_dir.mkdir(parents=True)

    ignore_crap = shutil.ignore_patterns('.DS_Store')
    shutil.copytree(builddir / "Translit.app", input_methods_dir / "Translit.app", ignore=ignore_crap)
    subprocess.run(['/usr/bin/strip', '-no_code_signature_warning', '-u', '-r',
                    input_methods_dir / "Translit.app/Contents/MacOS/Translit"],
                   check=True)

    copy_templated(MYDIR / 'distribution.xml', workdir / 'distribution.xml', {
        'IDENTIFIER':prod_identifier, 
        'VERSION': prod_version
    })

    if should_sign:
        subprocess.run(['codesign', '--force', '--sign', 'Developer ID Application', '-o', 'runtime', '--timestamp',
                        '--preserve-metadata=entitlements',
                        input_methods_dir / "Translit.app"], check=True)
    else:
        subprocess.run(['codesign', '--force', '--sign', '-', '-o', 'runtime', '--timestamp=none',
                        '--preserve-metadata=entitlements',
                        input_methods_dir / "Translit.app"], check=True)


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
                    #'--scripts',    str(mydir / 'scripts'),
                    '--identifier', prod_identifier, 
                    '--version',    prod_version,
                    '--ownership',  'recommended',
                    str(packagesdir/'output.pkg')
                ], check=True)

    subprocess.run(['productbuild', 
                    '--distribution', workdir / 'distribution.xml',
                    '--package-path', str(packagesdir),
                    '--resources',    str(MYDIR / 'html'),
                    '--version',      prod_version,
                    str(builddir/'Translit.pkg')
                ], check=True)

    subprocess.run(['tar', '-C', builddir, '-czf', builddir.absolute() / f'Translit-{prod_version}.dSYM.tgz', 
                    'Translit.app.dSYM'], check=True)
    
    return prod_version

def sign_product(builddir: Path, prod_version: str):
    installer = builddir / f'Translit-{prod_version}.pkg'
    subprocess.run(['productsign', '--sign', 'Developer ID Installer', 
                    builddir / 'Translit.pkg', installer], check=True)
    
    sig_output = subprocess.run(['pkgutil', '--check-signature', installer], 
                                check=True, stdout=subprocess.PIPE).stdout.decode('utf-8')
    pattern = re.compile(r'^\s*1. Developer ID Installer: .*\(([0-9A-Z]{10})\)$')
    team_id = None
    for line in sig_output.splitlines():
        m = pattern.match(line)
        if m:
            team_id = m.group(1)
            break
    if team_id is None:
        print('Unable to find team ID from signature', file=sys.stderr)
        sys.exit(1)
    subprocess.run([MYDIR / 'notarize', 
                    '--user', os.environ['NOTARIZE_USER'], 
                    '--password', os.environ['NOTARIZE_PWD'], 
                    '--team', team_id, installer], check=True)
    print('Signature Info')
    res1 = subprocess.run(['pkgutil', '--check-signature', installer], check=False)
    print('\nAssesment')
    res2 = subprocess.run(['spctl', '--assess', '-vvv', '--type', 'install', installer], check=False)
    if res1.returncode != 0 or res2.returncode != 0:
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser()

    parser.add_argument('builddir', type=Path)
    parser.add_argument('tempdir', type=Path)
    parser.add_argument('--sign', dest='sign', action='store_true', required=False)
    parser.add_argument('--upload-results', dest='uploadResults', action='store_true', required=False)

    args = parser.parse_args()

    builddir: Path = args.builddir
    tempdir: Path = args.tempdir
    should_sign: bool = args.sign or os.environ.get('TRANSLIT_SIGN_PACKAGE', "false") == "true"

    prod_version = build(builddir, tempdir, should_sign)
    if should_sign:
        sign_product(builddir, prod_version)
    

if __name__ == '__main__':
    main()

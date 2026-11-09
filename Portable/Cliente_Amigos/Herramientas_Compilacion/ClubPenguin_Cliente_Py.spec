# -*- mode: python ; coding: utf-8 -*-


a = Analysis(
    ['E:/Users/Gener/Desktop/Gabriel_/proyecto/ClubPenguin/Portable/Cliente_Amigos/Herramientas_Compilacion/lanzador_cliente.py'],
    pathex=[],
    binaries=[],
    datas=[('E:/Users/Gener/Desktop/Gabriel_/proyecto/ClubPenguin/Portable/Cliente_Amigos/Chrome-Portable', 'Chrome-Portable'), ('E:/Users/Gener/Desktop/Gabriel_/proyecto/ClubPenguin/Portable/Cliente_Amigos/JUGAR-AQUI.bat', '.'), ('E:/Users/Gener/Desktop/Gabriel_/proyecto/ClubPenguin/Portable/Cliente_Amigos/README.md', '.')],
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name='ClubPenguin_Cliente_Py',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=['E:/Users/Gener/Desktop/Gabriel_/proyecto/ClubPenguin/Portable/Cliente_Amigos/Herramientas_Compilacion/icono_pinguino.ico'],
)

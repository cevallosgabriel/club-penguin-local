"""
Script de Automatización: Generador de Ejecutable SFX para el Cliente de Amigos.
Empaqueta 'Cliente_Amigos' en un archivo autoextraíble (.exe) que ejecuta automáticamente '1-JUGAR-CLIENTE.bat'.
"""

import os
import sys
import subprocess
import shutil

DIR_ACTUAL = os.path.dirname(os.path.abspath(__file__))
NOMBRE_SALIDA = "ClubPenguin_Cliente_Amigos.exe"
RUTA_SALIDA = os.path.join(DIR_ACTUAL, NOMBRE_SALIDA)

def buscar_winrar():
    rutas_comunes = [
        r"C:\Program Files\WinRAR\WinRAR.exe",
        r"C:\Program Files (x86)\WinRAR\WinRAR.exe",
        shutil.which("winrar"),
        shutil.which("rar")
    ]
    for r in rutas_comunes:
        if r and os.path.isfile(r):
            return r
    return None

def generar_sfx_winrar(winrar_exe):
    print(f"[*] Utilizando WinRAR encontrado en: {winrar_exe}")
    
    # Crear archivo de configuración SFX temporal
    sfx_config = os.path.join(DIR_ACTUAL, "_sfx_config.txt")
    with open(sfx_config, "w", encoding="utf-8") as f:
        f.write("; Script de configuración SFX para Club Penguin Cliente\n")
        f.write("Setup=1-JUGAR-CLIENTE.bat\n")
        f.write("TempMode\n")
        f.write("Silent=1\n")
        f.write("Overwrite=1\n")
        f.write("Title=Club Penguin Portable - Cliente de Juego\n")

    cmd = [
        winrar_exe,
        "a",
        "-sfx",
        f"-z{sfx_config}",
        "-r",
        "-ep1",
        RUTA_SALIDA,
        os.path.join(DIR_ACTUAL, "Chrome-Portable"),
        os.path.join(DIR_ACTUAL, "1-JUGAR-CLIENTE.bat"),
        os.path.join(DIR_ACTUAL, "README.md")
    ]

    print("[*] Empaquetando archivos del cliente en el ejecutable...")
    res = subprocess.run(cmd, capture_output=True, text=True)
    
    if os.path.exists(sfx_config):
        os.remove(sfx_config)

    if os.path.exists(RUTA_SALIDA):
        print(f"[OK] ¡Ejecutable generado con éxito!\nUbicación: {RUTA_SALIDA}")
        return True
    else:
        print("[!] Error al generar con WinRAR:")
        print(res.stderr)
        return False

def main():
    print("=" * 60)
    print("    GENERADOR DE EJECUTABLE PORTABLE (SFX) PARA CLIENTE")
    print("=" * 60)
    
    winrar = buscar_winrar()
    if winrar:
        generar_sfx_winrar(winrar)
    else:
        print("\n[AVISO] WinRAR no se encontró instalado en las rutas estándar.")
        print("Para generar el .exe manualmente, consulta la guía en el README.md")
        print("o utiliza el método interactivo descrito en las instrucciones.")

if __name__ == "__main__":
    main()


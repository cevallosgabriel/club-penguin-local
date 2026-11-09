import os
import subprocess
from PIL import Image

DIR_ACTUAL = os.path.dirname(os.path.abspath(__file__))
IMG_PATH = os.path.join(DIR_ACTUAL, "icono_pinguino.png")
ICO_PATH = os.path.join(DIR_ACTUAL, "icono_pinguino.ico")

def generar_icono():
    if os.path.exists(IMG_PATH):
        try:
            img = Image.open(IMG_PATH)
            img.save(ICO_PATH, format="ICO", sizes=[(256, 256)])
            print("[OK] Icono generado con exito.")
        except Exception as e:
            print(f"[!] Error generando icono: {e}")
    else:
        print("[!] No se encontro 'icono_pinguino.png'. Se usara el icono por defecto.")

def main():
    print("="*60)
    print("    GENERADOR DE EJECUTABLE PYTHON (SIN WINRAR)")
    print("="*60)
    
    # 1. Convertir la imagen PNG en ICO para el ejecutable
    generar_icono()
    
    launcher_script = os.path.join(DIR_ACTUAL, "lanzador_cliente.py")
    
    import sys
    # 2. Configurar el comando de PyInstaller
    PARENT_DIR = os.path.dirname(DIR_ACTUAL)
    cmd = [
        sys.executable, "-m", "PyInstaller",
        "--noconfirm",
        "--onefile",       # Empaquetar todo en un solo .exe
        "--console",       # Necesitamos consola para pedir la IP
        "--name", "ClubPenguin_Cliente_Py",
        "--add-data", f"{os.path.join(PARENT_DIR, 'Chrome-Portable')}{os.pathsep}Chrome-Portable",
        "--add-data", f"{os.path.join(PARENT_DIR, '1-JUGAR-CLIENTE.bat')}{os.pathsep}.",
        "--add-data", f"{os.path.join(PARENT_DIR, 'README.md')}{os.pathsep}."
    ]
    
    if os.path.exists(ICO_PATH):
        cmd.extend(["--icon", ICO_PATH])
        
    cmd.append(launcher_script)
    
    # 3. Lanzar construccion
    print("\n[*] Iniciando PyInstaller. Esto puede tardar varios minutos dependiendo de tu PC...")
    print("[*] Empaquetando un entorno Flash de mas de 300MB. Por favor, ten paciencia y NO CIERRES esta ventana.\n")
    
    try:
        subprocess.run(cmd, cwd=DIR_ACTUAL, check=True)
        print("\n" + "="*60)
        print("[OK] Proceso terminado con EXITO.")
        print(f"El ejecutable resultante se encuentra en la carpeta: {os.path.join(DIR_ACTUAL, 'dist')}")
        print("="*60)
    except subprocess.CalledProcessError as e:
        print(f"\n[!] Error durante la compilacion de PyInstaller: {e}")

if __name__ == "__main__":
    main()


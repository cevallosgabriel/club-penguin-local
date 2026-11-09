import os
import subprocess
import sys

def main():
    compilacion_dir = os.path.dirname(os.path.abspath(__file__))
    cliente_dir = os.path.dirname(compilacion_dir)
    winrar_exe = r"C:\Program Files\WinRAR\WinRAR.exe"
    
    sfx_salida = os.path.join(cliente_dir, "Instalar_ClubPenguin_Cliente.exe")
    sfx_comment = os.path.join(compilacion_dir, "comentarios_sfx_cliente.txt")

    comentarios = (
        "Path=%LocalAppData%\\\\ClubPenguin_Cliente\n"
        "SavePath\n"
        "Title=Instalador de Club Penguin (Cliente)\n"
        "Text\n"
        "{\n"
        "Bienvenido al instalador de Club Penguin para jugar con amigos.\n"
        "Esto instalara el juego de forma permanente en tu PC para que recuerde tu contrasena.\n"
        "}\n"
        "Shortcut=D, \"1-JUGAR-CLIENTE.bat\", \"\", \"Jugar Club Penguin\", \"Jugar\"\n"
        "Overwrite=1\n"
    )

    with open(sfx_comment, "w", encoding="utf-8") as f:
        f.write(comentarios)

    if os.path.exists(sfx_salida):
        try: os.remove(sfx_salida)
        except: pass

    print("[*] Empaquetando Cliente_Amigos...")
    
    items = ["1-JUGAR-CLIENTE.bat", "Chrome-Portable"]
    
    comando = [winrar_exe, "a", "-r", "-ep1", "-sfx", f"-z{sfx_comment}", sfx_salida] + items
    subprocess.run(comando, cwd=cliente_dir, check=True)
    
    print("\n[+] El instalador se creo correctamente.")
    
    if os.path.exists(sfx_comment): os.remove(sfx_comment)

if __name__ == "__main__":
    main()
import os
import sys
import subprocess
import shutil
import time

def main():
    # PyInstaller extrae los archivos en una carpeta temporal llamada sys._MEIPASS
    if getattr(sys, 'frozen', False):
        base_path = sys._MEIPASS
    else:
        base_path = os.path.dirname(os.path.abspath(__file__))
    
    bat_path = os.path.join(base_path, "1-JUGAR-CLIENTE.bat")
    
    if os.path.exists(bat_path):
        current_dir = os.getcwd()
        ip_file_current = os.path.join(current_dir, "ip_servidor.txt")
        ip_file_temp = os.path.join(base_path, "ip_servidor.txt")
        
        # Si ya existe un historial de IP guardado en la carpeta de ejecucion, copiarlo a la temp
        if os.path.exists(ip_file_current):
            shutil.copy2(ip_file_current, ip_file_temp)
            
        # Ejecutar el archivo .bat maestro
        subprocess.run([bat_path], cwd=base_path, shell=True)
        
        # Guardar la nueva IP ingresada (si cambio) de vuelta a la carpeta principal
        if os.path.exists(ip_file_temp):
            shutil.copy2(ip_file_temp, ip_file_current)
            
        print("\n[*] El juego se esta ejecutando en el navegador Flash.")
        print("[*] Por favor, NO CIERRES esta ventana negra hasta que termines de jugar.")
        print("[*] Monitoreando sesion...")
        
        time.sleep(5)
        
        # Monitorear si hay algun chrome.exe corriendo que tenga este MEIPASS en su ruta
        while True:
            try:
                # Verificamos mediante PowerShell si hay un proceso de Chrome ejecutandose desde esta carpeta temporal
                cmd = f'powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter \\"Name=\'chrome.exe\'\\" | Where-Object {{$_.ExecutablePath -match \'{os.path.basename(base_path)}\'}} | Measure-Object | Select-Object -ExpandProperty Count"'
                count = int(subprocess.check_output(cmd, shell=True, stderr=subprocess.DEVNULL).decode().strip())
                if count == 0:
                    break
            except Exception:
                pass
            time.sleep(3)
            
        print("\n[OK] Juego cerrado. Limpiando cache temporal...")
        
    else:
        print(f"[!] Error critico: No se encontro el archivo base {bat_path}")
        input("Presiona Enter para salir...")

if __name__ == "__main__":
    main()


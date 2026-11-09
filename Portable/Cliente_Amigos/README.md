# 🐧 Guía para Amigos / Clientes — Conexión a Club Penguin Multijugador

Bienvenido a la guía de conexión rápida para unirte al servidor de **Club Penguin** hosteado por tu amigo.

---

## 📋 Requisitos Previos

1. **Radmin VPN** instalado en tu computadora.
   - Enlace oficial de descarga gratuita: [https://www.radmin-vpn.com/es/](https://www.radmin-vpn.com/es/)
   - No requiere registro ni suscripciones.
2. Esta carpeta o el ejecutable `CCPP.exe` en cualquier lugar de tu equipo.

---

## 🚀 Paso a Paso: Cómo Conectarse a la Partida

### Paso 1: Configurar Radmin VPN
1. Abre **Radmin VPN** y asegúrate de que el botón de encendido grande esté en verde (Encendido).
2. Haz clic en el menú superior: **Red** ➔ **Unirse a una red existente**.
3. Pídele al anfitrión (Host) el **Nombre de la red** y la **Contraseña** de su sala de Radmin VPN.
4. Ingresa los datos y dale a **Unirse**.
5. Verás al host en la lista de miembros de la red con su dirección IP (empieza típicamente por `26.x.x.x`).

---

### Paso 2: Obtener la IP del Host
- Haz clic derecho sobre el nombre del anfitrión en la ventana de Radmin VPN y selecciona **Copiar dirección IP**.
- También puedes simplemente pedirle al host que te envíe su IP de Radmin por chat (WhatsApp, Discord, etc.).

---

### Paso 3: Iniciar el Juego (2 Formas Disponibles)

#### Método A: Mediante el Ejecutable Unificado (`CCPP.exe`)
- Si tienes el archivo **`CCPP.exe`**, haz doble clic sobre él.
- Se extraerá silenciosamente en segundo plano y abrirá directamente la ventana para poner la IP del Host y empezar a jugar.

#### Método B: Mediante la Carpeta y `JUGAR-AQUI.bat`
1. Haz doble clic sobre el archivo:
   👉 **`JUGAR-AQUI.bat`**
2. La consola te solicitará ingresar la IP del Servidor.
3. Pega la IP del host (ejemplo: `26.154.89.20`) y presiona **Enter**.
4. ¡Listo! Se abrirá automáticamente el navegador portátil compatible con Flash y cargará la pantalla del juego.
   *(La IP se guardará automáticamente en `ip_servidor.txt` para que las próximas veces solo debas presionar Enter).*

---

## 📦 Cómo Generar el Ejecutable Autoextraíble (.exe) para Amigos

Si eres el anfitrión y deseas enviar a tus amigos un único archivo ejecutable (`.exe`) en lugar de toda la carpeta:

### Opción 1: Usando el Script de Python + WinRAR (`crear_ejecutable_cliente.py`)
Si tienes Python y WinRAR instalados, el script automatizado configurará el ejecutable por ti:
1. Abre una terminal en esta carpeta.
2. Ejecuta:
   ```bash
   python crear_ejecutable_cliente.py
   ```
3. Se generará automáticamente `ClubPenguin_Cliente_Amigos.exe`.

### Opción 2: Usando WinRAR (Método Gráfico Interactivo)
1. Selecciona la carpeta `Chrome-Portable`, el archivo `JUGAR-AQUI.bat` y este `README.md`.
2. Haz clic derecho ➔ **Añadir al archivo...** (WinRAR).
3. En la pestaña **General**:
   - Marca la casilla: ☑ **Crear un archivo autoextraíble (SFX)**.
   - En *Método de compresión*, selecciona **La mejor**.
4. En la pestaña **Avanzado** ➔ haz clic en el botón **Opciones SFX...**:
   - En la pestaña **Instalación** ➔ en el campo *Ejecutar tras la extracción*, escribe exactamente:
     ```text
     JUGAR-AQUI.bat
     ```
   - En la pestaña **Modos** ➔ selecciona:
     - ☑ **Descomprimir en carpeta temporal**
     - Modo silencioso: ☑ **Ocultar todo**
   - En la pestaña **Actualizar** ➔ Modo de sobreescritura: ☑ **Sobrescribir todos los ficheros**.
5. Haz clic en **Aceptar** y luego en **Aceptar**.
6. ¡Listo! Se generará tu `.exe` listo para compartir.

### Opción 3: Usando Python (Nativo con PyInstaller, SIN WinRAR)
Hemos integrado un script nativo que crea un ejecutable robusto con un icono de pingüino. Solo necesitas Python instalado:
1. Haz doble clic en el archivo **`generar_exe_python.bat`**.
2. El script hará todo por ti automáticamente:
   - Leerá el `requirements.txt` e instalará las librerías `pyinstaller` y `pillow`.
   - Tomará la imagen `icono_pinguino.png` incluida y la convertirá en un icono.
   - Compilará la carpeta `Chrome-Portable` en un solo archivo `.exe`.
3. El proceso puede demorar varios minutos al empaquetar más de 300 MB. Al terminar, abre la carpeta **`dist`** para encontrar tu archivo `ClubPenguin_Cliente_Py.exe`.

---

## 💬 Prompt Reutilizable para Empaquetar Carpetas en `.exe` con Python o WinRAR

```markdown
### 📋 PROMPT MAESTRO: Empaquetador Autónomo a Archivo Ejecutable (.exe)

Actúa como un Desarrollador Senior en Automatización de Software y Empaquetado en Windows.
Necesito empaquetar una carpeta de archivos de usuario (scripts, ejecutables portables y recursos) en un único archivo ejecutable autónomo (`.exe`).

Detalles del proyecto a empaquetar:
- Carpeta origen: [RUTA_DE_CARPETA]
- Archivo principal que debe ejecutarse al abrir: [SCRIPT_O_EXE_PRINCIPAL] (por ejemplo: `iniciar.bat`)
- Nombre deseado del ejecutable resultante: [NOMBRE_SALIDA.exe]

Requisitos de la solución:
1. Genera dos métodos completamente detallados y a prueba de errores:
   - Método A (WinRAR SFX): Guía paso a paso en la interfaz de WinRAR con cada casilla a marcar (Modo temporal, Modo silencioso / Ocultar todo, Sobrescritura total, Ejecutar tras extracción). Incluye también el comando CLI exacto de `WinRAR.exe a -sfx ...`.
   - Método B (Script Python 100% portable): Script en Python que detecte herramientas de compresión instaladas (WinRAR o 7-Zip CLI) o que compile un ejecutable empaquetador usando `PyInstaller` o compresión zip autoextraíble, sin requerir interacción manual del usuario final.
2. Configuración para que el usuario final no vea descompresiones molestas ni carpetas temporales residuales.
3. Tratamiento de rutas relativas y variables de entorno para que funcione en cualquier PC con Windows.
```

---

## 🛠️ Solución de Problemas Comunes

- **¿Se queda la pantalla en blanco o azul sin cargar?**
  1. Verifica que tu Radmin VPN tenga un punto verde al lado del nombre del host (conexión directa establecida).
  2. Pídele al host que confirme que sus servidores (`1-INICIAR-CLUB-PENGUIN.bat`) estén corriendo.
  3. Asegúrate de haber escrito la IP correctamente (sin espacios ni prefijos `http://`).

- **¿No puedes crear pingüino o da error de conexión?**
  - Solicita al host que verifique que su Firewall de Windows permita el tráfico en los puertos de juego (6112, 9875 y 80).

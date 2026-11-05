import os
import sys
import re

if len(sys.argv) < 2:
    print("Se requiere la IP como argumento.")
    sys.exit(1)

ip = sys.argv[1]
base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
server_dir = os.path.join(base_dir, "Motor_Servidor", "Server")
server_dir_unix = server_dir.replace("\\", "/")

def replace_in_file(filepath, pattern, replacement):
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        new_content = re.sub(pattern, replacement, content)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)

# 1. Actualizar IPs en archivos XML/HTML
xml_files = [
    os.path.join(server_dir, "www", "play", "servers.xml"),
    os.path.join(server_dir, "www", "media", "play", "web_service", "environment_data.xml"),
    os.path.join(server_dir, "www", "web_service", "environment_data.xml"),
    os.path.join(server_dir, "www", "es", "index.html"),
    os.path.join(server_dir, "www", "pt", "index.html"),
    os.path.join(server_dir, "www", "en", "index.html"),
    os.path.join(server_dir, "www", "fr", "index.html"),
    os.path.join(server_dir, "www", "play", "index.html"),
    os.path.join(server_dir, "www", "index.html")
]

for f in xml_files:
    replace_in_file(f, r'address="[^"]+"', f'address="{ip}"')
    replace_in_file(f, r'http://[^/]+/media/', f'http://{ip}/media/')
    replace_in_file(f, r'http://[^/]+/es/penguin/create', f'http://{ip}/es/penguin/create')
    replace_in_file(f, r'http://[^/]+/play/', f'http://{ip}/play/')
    replace_in_file(f, r'createUrl":"[^"]+"', f'createUrl":"http://{ip}/es/penguin/create"')
    # Fix wns hardcoded in index.html
    replace_in_file(f, r'"wns":"http://[^"]+"', f'"wns":"http://{ip}"')

# 2. Actualizar startscreen.xml
local_dir = os.path.join(server_dir, "www", "media", "play", "v2", "content", "local")
if os.path.exists(local_dir):
    for root, dirs, files in os.walk(local_dir):
        for name in files:
            if "startscreen.xml" in name:
                fpath = os.path.join(root, name)
                replace_in_file(fpath, r'href="http://[^/]+/es/penguin/create"', f'href="http://{ip}/es/penguin/create"')
                replace_in_file(fpath, r'href="create/"', f'href="http://{ip}/es/penguin/create"')
                replace_in_file(fpath, r'cdn_url href="http://[^/]+/media/play/"', f'cdn_url href="http://{ip}/media/play/"')

# 3. Actualizar configuracion de Nginx (Rutas absolutas seguras)
nginx_conf = os.path.join(server_dir, "bin", "nginx", "nginx-1.28.2", "conf", "nginx.conf")
replace_in_file(nginx_conf, r'include\s+"[^"]+/Server/etc/nginx/php_upstream\.conf";', f'include "{server_dir_unix}/etc/nginx/php_upstream.conf";')
replace_in_file(nginx_conf, r'include\s+"[^"]+/Server/etc/nginx/sites-enabled/\*\.conf";', f'include "{server_dir_unix}/etc/nginx/sites-enabled/*.conf";')

site_conf = os.path.join(server_dir, "etc", "nginx", "sites-enabled", "00-default.conf")
replace_in_file(site_conf, r'root\s+"[^"]+/Server/www/";', f'root "{server_dir_unix}/www/";')
replace_in_file(site_conf, r'include\s+"[^"]+/Server/etc/nginx/alias/\*\.conf";', f'include "{server_dir_unix}/etc/nginx/alias/*.conf";')

print("[OK] Red y rutas actualizadas por Python.")

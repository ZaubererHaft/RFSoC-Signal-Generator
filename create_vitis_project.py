import os
import vitis

# Absolute Pfade definieren
BASE_DIR = os.path.abspath(os.path.dirname(__file__))
WORKSPACE_DIR = os.path.join(BASE_DIR, "vitis_workspace")
XSA_PATH = os.path.join(BASE_DIR, "main_wrapper.xsa") # Pfad anpassen falls nötig

# WICHTIG: Ordner manuell erstellen, da Vitis sonst abstürzt
if not os.path.exists(WORKSPACE_DIR):
    os.makedirs(WORKSPACE_DIR)

# Erst danach den Client im richtigen Verzeichnis starten
client = vitis.create_client()
client.set_workspace(WORKSPACE_DIR)
# 2. Plattform-Komponente aus der XSA erstellen
print("--> Erstelle Plattform-Komponente...")
platform = client.create_platform_component(
    name="hardware_platform",
    hw_design=XSA_PATH,
    os="standalone", # oder "freertos", "linux"
    cpu="psu_cortexa53_0" # CPU-Kern anpassen (z.B. psu_cortexa53_0)
)

# 3. Applikations-Komponente erstellen
print("--> Erstelle Applikations-Komponente...")
app = client.create_app_component(
    name="signal-generator-ps",
    platform="./vitis_workspace/hardware_platform/export/hardware_platform/hardware_platform.xpfm",
    domain="standalone_domain"
)

SRC_DIR = os.path.abspath("./src-ps")
if os.path.exists(SRC_DIR):
    # Alle Dateien und Unterordner im src-Verzeichnis auflisten
    files_to_import = os.listdir(SRC_DIR)
    
    if files_to_import:
        print(f"--> Importiere Dateien aus {SRC_DIR}: {files_to_import}")
        
        # Die korrekte Vitis-API-Methode nutzen
        app.import_files(
            from_loc=SRC_DIR,
            files=files_to_import,
            dest_dir_in_cmp="src",
            is_skip_copy_sources=True
        )
    else:
        print("⚠️ Warnung: Der 'src'-Ordner ist leer. Es wurden keine Dateien importiert.")
else:
    print(f"❌ Fehler: Quellcode-Ordner '{SRC_DIR}' existiert nicht!")


# 5. Projekt bauen
print("--> Starte Build-Prozess...")
app.build()
print("--> Fertig! Die .elf Datei liegt im Workspace unter my_application/build/")
